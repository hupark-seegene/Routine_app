# SIMPLE DEBUG SCRIPT - Streamlined debugging
$ErrorActionPreference = "Continue"

Write-Host "`n=== SIMPLE DEBUG AUTOMATION ===" -ForegroundColor Cyan

# Setup
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$env:Path = "$env:JAVA_HOME\bin;$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\emulator;$env:Path"
$adb = "$env:ANDROID_HOME\platform-tools\adb.exe"

# 1. Clean processes
Write-Host "`n[1/6] Cleaning processes..." -ForegroundColor Yellow
Stop-Process -Name node -Force -ErrorAction SilentlyContinue

# 2. Clean temp files
Write-Host "[2/6] Cleaning temp files..." -ForegroundColor Yellow
Remove-Item "$env:TEMP\metro*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\react*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "node_modules\.cache" -Recurse -Force -ErrorAction SilentlyContinue

# 3. Create bundle
Write-Host "[3/6] Creating bundle..." -ForegroundColor Yellow
$assetsDir = "android\app\src\main\assets"
New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null

$bundle = @'
// Simple Debug Bundle
console.log('Debug bundle loaded');
global.__DEV__ = true;
'@
$bundle | Out-File -Encoding UTF8 "$assetsDir\index.android.bundle"

# 4. Start ADB
Write-Host "[4/6] Starting ADB..." -ForegroundColor Yellow
& $adb start-server 2>$null
Start-Sleep -Seconds 2

# 5. Check devices
Write-Host "[5/6] Checking devices..." -ForegroundColor Yellow
$devices = & $adb devices 2>$null
Write-Host $devices

# Set up port forwarding
& $adb reverse tcp:8081 tcp:8081 2>$null

# 6. Build and install
Write-Host "[6/6] Building app..." -ForegroundColor Yellow
Push-Location android
$result = & .\gradlew.bat assembleDebug --no-daemon 2>&1
$success = $LASTEXITCODE -eq 0
Pop-Location

if ($success) {
    Write-Host "`n✓ Build successful!" -ForegroundColor Green
    
    # Install APK
    Write-Host "Installing APK..." -ForegroundColor Yellow
    & $adb install -r android\app\build\outputs\apk\debug\app-debug.apk
    
    # Launch app
    & $adb shell am start -n com.squashtrainingapp/.MainActivity
    
    Write-Host "`nApp launched! Showing logs..." -ForegroundColor Green
    & $adb logcat -c
    & $adb logcat ReactNative:V ReactNativeJS:V *:S
} else {
    Write-Host "`n✗ Build failed!" -ForegroundColor Red
    Write-Host "Check the error messages above." -ForegroundColor Yellow
}