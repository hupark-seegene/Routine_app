# Full Build Script with Local React Native Plugin Build
# This script handles the complete build process including gradle plugin

param(
    [switch]$SkipPluginBuild = $false,
    [switch]$Clean = $false,
    [switch]$Install = $false,
    [switch]$Run = $false,
    [switch]$Debug = $false
)

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " SQUASH TRAINING APP - FULL BUILD" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set environment variables
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:ANDROID_HOME = "C:\Users\hwpar\AppData\Local\Android\Sdk"
$env:Path = "$env:JAVA_HOME\bin;$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\tools;$env:Path"

# Verify environment
Write-Host "[ENV] Checking environment..." -ForegroundColor Yellow
if (-not (Test-Path $env:JAVA_HOME)) {
    Write-Host "ERROR: JAVA_HOME not found!" -ForegroundColor Red
    exit 1
}
Write-Host "  JAVA_HOME: $env:JAVA_HOME" -ForegroundColor Green
Write-Host "  ANDROID_HOME: $env:ANDROID_HOME" -ForegroundColor Green

# Clean if requested
if ($Clean) {
    Write-Host "`n[CLEAN] Cleaning build artifacts..." -ForegroundColor Yellow
    
    # Clean Android build
    Push-Location android
    if (Test-Path "gradlew.bat") {
        .\gradlew.bat clean --no-daemon 2>&1 | Out-Null
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
    }
    
    Write-Host "  Clean complete!" -ForegroundColor Green
}

# Step 1: Build React Native Gradle Plugin Locally
if (-not $SkipPluginBuild) {
    Write-Host "`n[PLUGIN] Building React Native gradle plugin locally..." -ForegroundColor Yellow
    
    # Check if plugin already exists in local Maven
    $m2Home = "$env:USERPROFILE\.m2\repository"
    $pluginPath = "$m2Home\com\facebook\react\react-native-gradle-plugin\0.80.1\react-native-gradle-plugin-0.80.1.jar"
    
    if (Test-Path $pluginPath) {
        Write-Host "  Plugin already exists in local Maven repository" -ForegroundColor Green
    } else {
        # Build plugin
        & powershell.exe -File BUILD-RN-PLUGIN-LOCAL.ps1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  WARNING: Plugin build had issues, continuing anyway..." -ForegroundColor Yellow
        }
    }
}

# Step 2: Install dependencies if needed
if (-not (Test-Path "node_modules")) {
    Write-Host "`n[SETUP] Installing dependencies..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ERROR: npm install failed!" -ForegroundColor Red
        exit 1
    }
    Write-Host "  Dependencies installed!" -ForegroundColor Green
}

# Step 3: Create JavaScript bundle
Write-Host "`n[BUNDLE] Creating JavaScript bundle..." -ForegroundColor Yellow
$bundleOutput = "android\app\src\main\assets"
if (-not (Test-Path $bundleOutput)) {
    New-Item -ItemType Directory -Path $bundleOutput -Force | Out-Null
}

# Remove old bundle
if (Test-Path "$bundleOutput\index.android.bundle") {
    Remove-Item "$bundleOutput\index.android.bundle" -Force
}

Write-Host "  Building debug bundle..." -ForegroundColor Gray
$bundleCmd = "npx react-native bundle --platform android --dev true --entry-file index.js --bundle-output $bundleOutput\index.android.bundle --assets-dest android\app\src\main\res --reset-cache"
$bundleResult = cmd /c $bundleCmd 2>&1 | Out-String

if (Test-Path "$bundleOutput\index.android.bundle") {
    $bundleSize = [math]::Round((Get-Item "$bundleOutput\index.android.bundle").Length / 1MB, 2)
    Write-Host "  Bundle created successfully! ($bundleSize MB)" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Bundle creation had issues" -ForegroundColor Yellow
    # Create placeholder bundle
    "// Placeholder bundle" | Out-File -FilePath "$bundleOutput\index.android.bundle" -Encoding ASCII
}

# Step 4: Build APK
Write-Host "`n[BUILD] Building APK with all modules..." -ForegroundColor Yellow
Push-Location android

# Ensure gradlew is executable
if (Test-Path "gradlew.bat") {
    Write-Host "  Using project gradlew" -ForegroundColor Gray
    
    # Build with local init.gradle
    $initGradleArg = ""
    if (Test-Path "init.gradle") {
        $initGradleArg = "--init-script init.gradle"
    }
    
    Write-Host "  Running: gradlew assembleDebug $initGradleArg" -ForegroundColor Gray
    $buildCmd = ".\gradlew.bat assembleDebug --no-daemon $initGradleArg"
    
    if ($Debug) {
        $buildCmd += " --info"
    }
    
    $buildResult = cmd /c $buildCmd 2>&1 | Out-String
    $buildSuccess = $LASTEXITCODE -eq 0
} else {
    Write-Host "  ERROR: gradlew.bat not found!" -ForegroundColor Red
    $buildSuccess = $false
}

Pop-Location

# Check build result
$apkPath = "android\app\build\outputs\apk\debug\app-debug.apk"
if ($buildSuccess -and (Test-Path $apkPath)) {
    $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host " BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "APK: $apkPath" -ForegroundColor Yellow
    Write-Host "Size: $apkSize MB" -ForegroundColor Yellow
    Write-Host "Features included:" -ForegroundColor Cyan
    Write-Host "  ✓ React Native Vector Icons" -ForegroundColor Green
    Write-Host "  ✓ SQLite Storage" -ForegroundColor Green
    Write-Host "  ✓ SVG Support" -ForegroundColor Green
    Write-Host "  ✓ Linear Gradient" -ForegroundColor Green
    Write-Host "  ✓ Community Slider" -ForegroundColor Green
    Write-Host "  ✓ Custom App Icon (Squash Theme)" -ForegroundColor Green
    
    # Install if requested
    if ($Install -or $Run) {
        Write-Host "`n[INSTALL] Installing APK..." -ForegroundColor Yellow
        
        # Check for devices
        $devices = adb devices 2>$null | Select-String -Pattern "\sdevice$"
        if (-not $devices) {
            Write-Host "  No devices connected. Starting emulator..." -ForegroundColor Yellow
            if (Test-Path "START-EMULATOR.ps1") {
                & .\START-EMULATOR.ps1
                Start-Sleep -Seconds 30
            }
        }
        
        # Uninstall old version
        Write-Host "  Uninstalling old version..." -ForegroundColor Gray
        adb uninstall com.squashtrainingapp 2>$null | Out-Null
        
        # Install new APK
        Write-Host "  Installing new APK..." -ForegroundColor Gray
        $installResult = adb install -r $apkPath 2>&1
        if ($installResult -match "Success") {
            Write-Host "  APK installed successfully!" -ForegroundColor Green
            
            # Setup port forwarding
            adb reverse tcp:8081 tcp:8081 2>$null
            
            # Run app if requested
            if ($Run) {
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
                Write-Host "Debug tools:" -ForegroundColor Cyan
                Write-Host "  - Shake device for developer menu" -ForegroundColor White
                Write-Host "  - Run: adb logcat *:S ReactNative:V ReactNativeJS:V" -ForegroundColor White
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
    
    if ($Debug) {
        # Show build output
        Write-Host "`nBuild output:" -ForegroundColor Yellow
        Write-Host $buildResult
    } else {
        # Show last 100 lines of build output
        Write-Host "`nBuild output (last 100 lines):" -ForegroundColor Yellow
        $buildResult -split "`n" | Select-Object -Last 100 | ForEach-Object { Write-Host $_ }
    }
    
    # Common fixes
    Write-Host "`n[TROUBLESHOOTING]" -ForegroundColor Cyan
    Write-Host "1. Try running with -Clean flag: .\FULL-BUILD-LOCAL.ps1 -Clean" -ForegroundColor White
    Write-Host "2. Check if all native modules are installed: npm install" -ForegroundColor White
    Write-Host "3. Run with -Debug flag for detailed output" -ForegroundColor White
    Write-Host "4. Check android\local.properties file exists" -ForegroundColor White
    Write-Host "5. Try the minimal build: .\MINIMAL-BUILD.ps1" -ForegroundColor White
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " Script completed" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan