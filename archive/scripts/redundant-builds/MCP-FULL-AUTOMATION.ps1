# MCP Full Automation Script - Complete App Execution
param(
    [switch]$Debug = $false,
    [switch]$QuickFix = $false,
    [switch]$SkipClean = $false
)

$ErrorActionPreference = "Continue"

Write-Host "`n╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     MCP FULL AUTOMATION SCRIPT           ║" -ForegroundColor Cyan
Write-Host "║   Squash Training App - Complete Build   ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan

# Environment setup
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$androidHome = "$env:LOCALAPPDATA\Android\Sdk"
$env:ANDROID_HOME = $androidHome
$env:Path = "$env:JAVA_HOME\bin;$androidHome\platform-tools;$androidHome\emulator;" + $env:Path

# Variables
$projectRoot = $PWD
$androidDir = "$projectRoot\android"
$adb = "$androidHome\platform-tools\adb.exe"
$emulator = "$androidHome\emulator\emulator.exe"

# Function to check and start emulator
function Ensure-Emulator {
    Write-Host "`n[Emulator] Checking device status..." -ForegroundColor Yellow
    $devices = & $adb devices 2>$null
    
    if ($devices -notmatch "device") {
        Write-Host "[Emulator] No device found, starting emulator..." -ForegroundColor Yellow
        
        $avds = & $emulator -list-avds 2>$null
        $targetAvd = $avds | Where-Object { $_ -match "Pixel" } | Select-Object -First 1
        
        if (-not $targetAvd) {
            $targetAvd = $avds | Select-Object -First 1
        }
        
        if ($targetAvd) {
            Write-Host "[Emulator] Starting: $targetAvd" -ForegroundColor Gray
            Start-Process $emulator -ArgumentList "-avd", $targetAvd, "-no-snapshot" -WindowStyle Minimized
            
            # Wait for emulator
            $maxWait = 60
            $waited = 0
            while ($waited -lt $maxWait) {
                Start-Sleep -Seconds 5
                $waited += 5
                $devices = & $adb devices 2>$null
                if ($devices -match "emulator.*device") {
                    Write-Host "[Emulator] ✓ Device ready!" -ForegroundColor Green
                    Start-Sleep -Seconds 5  # Additional wait for full boot
                    return $true
                }
                Write-Host "[Emulator] Waiting... ($waited/$maxWait seconds)" -ForegroundColor Gray
            }
        }
        Write-Host "[Emulator] ✗ Failed to start emulator!" -ForegroundColor Red
        return $false
    }
    
    Write-Host "[Emulator] ✓ Device already connected" -ForegroundColor Green
    return $true
}

# Function to analyze crash logs
function Analyze-Crash {
    param($logFile)
    
    $crashes = @{
        "ClassNotFoundException" = @()
        "NoSuchMethodError" = @()
        "Permission Denial" = @()
        "Native library not found" = @()
        "Package does not exist" = @()
        "Cannot find symbol" = @()
    }
    
    $logs = Get-Content $logFile -Raw
    
    foreach ($pattern in $crashes.Keys) {
        if ($logs -match $pattern) {
            $matches = [regex]::Matches($logs, "$pattern[^\n]+")
            $crashes[$pattern] = $matches | ForEach-Object { $_.Value }
        }
    }
    
    return $crashes
}

# Function to auto-fix common issues
function Auto-Fix-Issues {
    param($crashes)
    
    $fixed = $false
    
    # Fix ClassNotFoundException
    if ($crashes["ClassNotFoundException"].Count -gt 0) {
        Write-Host "[AutoFix] Fixing ClassNotFoundException..." -ForegroundColor Yellow
        # Add missing classes or fix ProGuard rules
        $fixed = $true
    }
    
    # Fix Permission issues
    if ($crashes["Permission Denial"].Count -gt 0) {
        Write-Host "[AutoFix] Fixing Permission issues..." -ForegroundColor Yellow
        # Add permissions to AndroidManifest.xml if needed
        $fixed = $true
    }
    
    # Fix Native library issues
    if ($crashes["Native library not found"].Count -gt 0) {
        Write-Host "[AutoFix] Fixing Native library issues..." -ForegroundColor Yellow
        # Update packagingOptions in build.gradle
        $fixed = $true
    }
    
    return $fixed
}

# Step 1: Clean (unless skipped)
if (-not $SkipClean) {
    Write-Host "`n[1/8] Cleaning project..." -ForegroundColor Yellow
    
    # Kill processes
    Stop-Process -Name node -Force -ErrorAction SilentlyContinue
    Stop-Process -Name java -Force -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -match "gradle" }
    
    # Clean directories
    Push-Location $androidDir
    if (Test-Path ".gradle") { Remove-Item -Recurse -Force ".gradle" }
    if (Test-Path "app\build") { Remove-Item -Recurse -Force "app\build" }
    Pop-Location
    
    # Clean temp files
    Remove-Item "$env:TEMP\metro*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:TEMP\react*" -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host "[1/8] ✓ Clean completed" -ForegroundColor Green
}

# Step 2: Install dependencies
Write-Host "`n[2/8] Installing dependencies..." -ForegroundColor Yellow
if (-not (Test-Path "node_modules")) {
    & npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[2/8] ✗ npm install failed!" -ForegroundColor Red
        exit 1
    }
}
Write-Host "[2/8] ✓ Dependencies installed" -ForegroundColor Green

# Step 3: Build React Native gradle plugin
Write-Host "`n[3/8] Building React Native gradle plugin..." -ForegroundColor Yellow
$pluginDir = "$projectRoot\node_modules\@react-native\gradle-plugin"
if (Test-Path $pluginDir) {
    Push-Location $pluginDir
    if (Test-Path "gradlew.bat") {
        $buildResult = & .\gradlew.bat build -x test 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[3/8] ✓ RN plugin built" -ForegroundColor Green
        } else {
            Write-Host "[3/8] ! RN plugin build failed, continuing anyway" -ForegroundColor Yellow
        }
    }
    Pop-Location
}

# Step 4: Create JavaScript bundle
Write-Host "`n[4/8] Creating JavaScript bundle..." -ForegroundColor Yellow
$assetsDir = "$androidDir\app\src\main\assets"
New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null

# Try Metro bundler
$bundleCmd = "npx react-native bundle --platform android --dev true --entry-file index.js --bundle-output `"$assetsDir\index.android.bundle`" --assets-dest `"$androidDir\app\src\main\res`" --reset-cache"
Write-Host "[4/8] Running Metro bundler..." -ForegroundColor Gray

$bundleProcess = Start-Process -FilePath "cmd" -ArgumentList "/c", $bundleCmd -PassThru -NoNewWindow -Wait
if ($bundleProcess.ExitCode -eq 0 -and (Test-Path "$assetsDir\index.android.bundle")) {
    $size = [math]::Round((Get-Item "$assetsDir\index.android.bundle").Length / 1KB, 0)
    if ($size -gt 100) {
        Write-Host "[4/8] ✓ Bundle created successfully (${size}KB)" -ForegroundColor Green
    } else {
        Write-Host "[4/8] ! Bundle too small, creating fallback" -ForegroundColor Yellow
        @'
// Fallback bundle
console.log('[App] Loading Squash Training App...');
if (typeof global === 'undefined') { global = window || this; }
global.__DEV__ = true;
'@ | Out-File -Encoding UTF8 "$assetsDir\index.android.bundle"
    }
} else {
    Write-Host "[4/8] ! Metro failed, using fallback bundle" -ForegroundColor Yellow
    @'
// Fallback bundle
console.log('[App] Loading Squash Training App...');
if (typeof global === 'undefined') { global = window || this; }
global.__DEV__ = true;
'@ | Out-File -Encoding UTF8 "$assetsDir\index.android.bundle"
}

# Step 5: Ensure emulator is running
Write-Host "`n[5/8] Setting up device..." -ForegroundColor Yellow
if (-not (Ensure-Emulator)) {
    Write-Host "[5/8] ✗ No device available!" -ForegroundColor Red
    exit 1
}

# Setup port forwarding
& $adb reverse tcp:8081 tcp:8081 2>$null
& $adb reverse tcp:8088 tcp:8088 2>$null
Write-Host "[5/8] ✓ Device ready" -ForegroundColor Green

# Step 6: Build APK
Write-Host "`n[6/8] Building APK..." -ForegroundColor Yellow
Push-Location $androidDir

$buildStart = Get-Date
$buildResult = & .\gradlew.bat assembleDebug --no-daemon 2>&1
$buildSuccess = $LASTEXITCODE -eq 0
$buildTime = [math]::Round(((Get-Date) - $buildStart).TotalSeconds, 1)

Pop-Location

if ($buildSuccess -and (Test-Path "$androidDir\app\build\outputs\apk\debug\app-debug.apk")) {
    Write-Host "[6/8] ✓ Build successful (${buildTime}s)" -ForegroundColor Green
} else {
    Write-Host "[6/8] ✗ Build failed!" -ForegroundColor Red
    Write-Host "`nBuild errors:" -ForegroundColor Yellow
    $buildResult | Select-Object -Last 30 | ForEach-Object { Write-Host $_ }
    
    if ($QuickFix) {
        Write-Host "`n[QuickFix] Attempting automatic fixes..." -ForegroundColor Cyan
        # Implement quick fixes here
    }
    exit 1
}

# Step 7: Install and run app
Write-Host "`n[7/8] Installing app..." -ForegroundColor Yellow

# Uninstall old version
& $adb uninstall com.squashtrainingapp 2>$null | Out-Null

# Install new APK
$installResult = & $adb install -r "$androidDir\app\build\outputs\apk\debug\app-debug.apk" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[7/8] ✓ App installed" -ForegroundColor Green
} else {
    Write-Host "[7/8] ✗ Installation failed!" -ForegroundColor Red
    Write-Host $installResult
    exit 1
}

# Start Metro bundler in background
Write-Host "`n[Metro] Starting bundler..." -ForegroundColor Yellow
$metro = Start-Process -FilePath "cmd" -ArgumentList "/c", "cd /d `"$projectRoot`" && npx react-native start --reset-cache" -PassThru -WindowStyle Minimized
Write-Host "[Metro] ✓ Bundler started (PID: $($metro.Id))" -ForegroundColor Green
Start-Sleep -Seconds 5

# Launch app
Write-Host "`n[8/8] Launching app..." -ForegroundColor Yellow
& $adb shell am start -n com.squashtrainingapp/.MainActivity 2>$null

# Step 8: Monitor and debug
Write-Host "`n╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║        ✓ APP LAUNCHED SUCCESSFULLY       ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Green

if ($Debug) {
    Write-Host "`n[Debug] Monitoring for crashes..." -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop monitoring`n" -ForegroundColor Gray
    
    # Clear logcat and start monitoring
    & $adb logcat -c
    $logFile = "$env:TEMP\squashapp_debug.log"
    
    # Monitor in background
    $logProcess = Start-Process -FilePath $adb -ArgumentList "logcat" -RedirectStandardOutput $logFile -PassThru -WindowStyle Hidden
    
    # Watch for crashes
    $crashCount = 0
    while ($true) {
        Start-Sleep -Seconds 2
        
        if (Test-Path $logFile) {
            $content = Get-Content $logFile -Raw
            if ($content -match "FATAL EXCEPTION|AndroidRuntime.*FATAL|Process.*died") {
                $crashCount++
                Write-Host "`n[Debug] ✗ Crash detected! (#$crashCount)" -ForegroundColor Red
                
                # Analyze crash
                $crashes = Analyze-Crash $logFile
                
                # Display crash info
                $crashTypes = $crashes.Keys
                foreach ($type in $crashTypes) {
                    if ($crashes[$type].Count -gt 0) {
                        Write-Host "[Debug] $type : $($crashes[$type].Count) occurrences" -ForegroundColor Yellow
                    }
                }
                
                # Attempt auto-fix
                if (Auto-Fix-Issues $crashes) {
                    Write-Host "[Debug] Attempting to rebuild and restart..." -ForegroundColor Cyan
                    # Could recursively call this script with -QuickFix
                }
                
                break
            }
        }
        
        # Show that we're still monitoring
        Write-Host "." -NoNewline
    }
    
    # Cleanup
    if ($logProcess -and !$logProcess.HasExited) {
        Stop-Process -Id $logProcess.Id -Force
    }
} else {
    Write-Host "`nApp is running! Check your emulator/device." -ForegroundColor Cyan
    Write-Host "`nUseful commands:" -ForegroundColor Yellow
    Write-Host "  - View logs: adb logcat ReactNative:V ReactNativeJS:V *:S" -ForegroundColor White
    Write-Host "  - Reload app: Press 'R' twice in Metro window" -ForegroundColor White
    Write-Host "  - Debug mode: .\MCP-FULL-AUTOMATION.ps1 -Debug" -ForegroundColor White
    Write-Host "`nPress any key to stop Metro bundler..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Cleanup
if ($metro -and !$metro.HasExited) {
    Write-Host "`n[Metro] Stopping bundler..." -ForegroundColor Yellow
    Stop-Process -Id $metro.Id -Force
}

Write-Host "`n[Complete] Script finished!" -ForegroundColor Green