# Complete Build Script for Squash Training App
# This script builds the app with all React Native modules enabled

param(
    [switch]$Clean = $false,
    [switch]$Release = $false,
    [switch]$Install = $false,
    [switch]$RunApp = $false
)

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " SQUASH TRAINING APP - COMPLETE BUILD" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set environment variables
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:ANDROID_HOME = "C:\Users\hwpar\AppData\Local\Android\Sdk"
$env:Path = "$env:JAVA_HOME\bin;$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\tools;$env:Path"

# Change to project directory
$projectRoot = (Get-Item -Path ".\" -Verbose).FullName
Write-Host "Project root: $projectRoot" -ForegroundColor Gray

# Clean if requested
if ($Clean) {
    Write-Host "`n[CLEAN] Cleaning build artifacts..." -ForegroundColor Yellow
    
    # Clean Android build
    Push-Location android
    if (Test-Path "gradlew.bat") {
        .\gradlew.bat clean
    }
    @("build", "app\build", ".gradle", "app\.gradle") | ForEach-Object {
        if (Test-Path $_) {
            Remove-Item -Recurse -Force $_ -ErrorAction SilentlyContinue
            Write-Host "  Removed: $_" -ForegroundColor Gray
        }
    }
    Pop-Location
    
    # Clean node_modules cache
    if (Test-Path "node_modules\.cache") {
        Remove-Item -Recurse -Force "node_modules\.cache" -ErrorAction SilentlyContinue
        Write-Host "  Cleared node_modules cache" -ForegroundColor Gray
    }
    
    Write-Host "  Clean complete!" -ForegroundColor Green
}

# Install dependencies if needed
if (-not (Test-Path "node_modules")) {
    Write-Host "`n[SETUP] Installing dependencies..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ERROR: npm install failed!" -ForegroundColor Red
        exit 1
    }
    Write-Host "  Dependencies installed!" -ForegroundColor Green
}

# Create JavaScript bundle
Write-Host "`n[BUNDLE] Creating JavaScript bundle..." -ForegroundColor Yellow
$bundleOutput = "android\app\src\main\assets"
if (-not (Test-Path $bundleOutput)) {
    New-Item -ItemType Directory -Path $bundleOutput -Force | Out-Null
}

$buildType = if ($Release) { "release" } else { "debug" }
$devFlag = if ($Release) { "false" } else { "true" }

Write-Host "  Building $buildType bundle..." -ForegroundColor Gray
$bundleCmd = "npx react-native bundle --platform android --dev $devFlag --entry-file index.js --bundle-output $bundleOutput\index.android.bundle --assets-dest android\app\src\main\res"
$bundleResult = cmd /c $bundleCmd 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Bundle created successfully!" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Bundle creation had issues" -ForegroundColor Yellow
    Write-Host $bundleResult -ForegroundColor Red
}

# Pre-build React Native gradle plugin
Write-Host "`n[PREBUILD] Building React Native gradle plugin..." -ForegroundColor Yellow
Push-Location android
$preBuildCmd = '.\gradlew.bat :react-native-gradle-plugin:build --no-daemon'
$preBuildResult = cmd /c $preBuildCmd 2>&1 | Out-String
if ($preBuildResult -match "BUILD SUCCESSFUL") {
    Write-Host "  Gradle plugin built successfully!" -ForegroundColor Green
} else {
    Write-Host "  Gradle plugin build skipped or failed (might be normal)" -ForegroundColor Yellow
}

# Build APK
Write-Host "`n[BUILD] Building APK..." -ForegroundColor Yellow
$buildCommand = if ($Release) { "assembleRelease" } else { "assembleDebug" }
Write-Host "  Running: gradlew $buildCommand" -ForegroundColor Gray

$buildResult = .\gradlew.bat $buildCommand --no-daemon 2>&1 | Out-String
$buildSuccess = $LASTEXITCODE -eq 0

Pop-Location

# Check build result
$apkPath = if ($Release) { 
    "android\app\build\outputs\apk\release\app-release.apk" 
} else { 
    "android\app\build\outputs\apk\debug\app-debug.apk" 
}

if ($buildSuccess -and (Test-Path $apkPath)) {
    $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host " BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "APK: $apkPath" -ForegroundColor Yellow
    Write-Host "Size: $apkSize MB" -ForegroundColor Yellow
    
    # Install if requested
    if ($Install -or $RunApp) {
        Write-Host "`n[INSTALL] Installing APK..." -ForegroundColor Yellow
        
        # Check for devices
        $devices = adb devices 2>$null | Select-String -Pattern "\sdevice$"
        if (-not $devices) {
            Write-Host "  No devices connected. Starting emulator..." -ForegroundColor Yellow
            # Try to start emulator
            $emulatorPath = "$env:ANDROID_HOME\emulator\emulator.exe"
            if (Test-Path $emulatorPath) {
                $avds = & $emulatorPath -list-avds 2>$null
                if ($avds) {
                    $firstAvd = ($avds -split "`n")[0].Trim()
                    Write-Host "  Starting emulator: $firstAvd" -ForegroundColor Gray
                    Start-Process -FilePath $emulatorPath -ArgumentList "-avd", $firstAvd -WindowStyle Hidden
                    Start-Sleep -Seconds 30
                }
            }
        }
        
        # Uninstall old version
        adb uninstall com.squashtrainingapp 2>$null | Out-Null
        
        # Install new APK
        $installResult = adb install -r $apkPath 2>&1
        if ($installResult -match "Success") {
            Write-Host "  APK installed successfully!" -ForegroundColor Green
            
            # Setup port forwarding
            adb reverse tcp:8081 tcp:8081 2>$null
            
            # Run app if requested
            if ($RunApp) {
                Write-Host "`n[RUN] Starting Metro bundler..." -ForegroundColor Yellow
                $metro = Start-Process -FilePath "cmd" -ArgumentList "/c", "npx react-native start --reset-cache" -PassThru -WindowStyle Normal
                Start-Sleep -Seconds 10
                
                Write-Host "[RUN] Launching app..." -ForegroundColor Yellow
                adb shell am start -n com.squashtrainingapp/.MainActivity
                
                Write-Host "`n========================================" -ForegroundColor Green
                Write-Host " APP IS RUNNING!" -ForegroundColor Green
                Write-Host "========================================" -ForegroundColor Green
                Write-Host ""
                Write-Host "Metro bundler is running in a separate window." -ForegroundColor Cyan
                Write-Host "If you see a red screen, press 'R' twice in Metro window." -ForegroundColor Yellow
                Write-Host ""
                Write-Host "Press any key to stop Metro and exit..." -ForegroundColor Gray
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                
                # Stop Metro
                if ($metro -and !$metro.HasExited) {
                    Stop-Process -Id $metro.Id -Force
                }
            }
        } else {
            Write-Host "  ERROR: Failed to install APK" -ForegroundColor Red
            Write-Host $installResult -ForegroundColor Red
        }
    }
} else {
    Write-Host "`n========================================" -ForegroundColor Red
    Write-Host " BUILD FAILED!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    
    # Show last 100 lines of build output
    Write-Host "`nBuild output (last 100 lines):" -ForegroundColor Yellow
    $buildResult -split "`n" | Select-Object -Last 100 | ForEach-Object { Write-Host $_ }
    
    # Common fixes
    Write-Host "`n[TROUBLESHOOTING]" -ForegroundColor Cyan
    Write-Host "1. Try running with -Clean flag: .\COMPLETE-BUILD.ps1 -Clean" -ForegroundColor White
    Write-Host "2. Check JAVA_HOME: $env:JAVA_HOME" -ForegroundColor White
    Write-Host "3. Verify Android SDK: $env:ANDROID_HOME" -ForegroundColor White
    Write-Host "4. Run 'npm install' to ensure all dependencies are installed" -ForegroundColor White
    Write-Host "5. Check android\local.properties file exists" -ForegroundColor White
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " Script completed" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan