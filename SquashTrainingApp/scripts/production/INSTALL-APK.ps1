# Install APK Script
$ErrorActionPreference = "Stop"

# Set ADB path
$env:PATH += ";C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools"

Write-Host "`n=== APK Installation ===" -ForegroundColor Cyan

# Check for APK
$apkPath = "$PSScriptRoot/../../android/app/build/outputs/apk/debug/app-debug.apk"
if (!(Test-Path $apkPath)) {
    Write-Host "APK not found at: $apkPath" -ForegroundColor Red
    exit 1
}

Write-Host "APK found: $apkPath" -ForegroundColor Green

# Check devices
Write-Host "`nChecking for devices..." -ForegroundColor Yellow
$devices = adb devices 2>$null | Select-String -Pattern "device$" | Where-Object { $_ -notmatch "List of devices" }

if (!$devices -or $devices.Count -eq 0) {
    Write-Host "`nNo devices connected!" -ForegroundColor Red
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Connect an Android device with USB debugging enabled, OR" -ForegroundColor White
    Write-Host "2. Start an Android emulator from Android Studio" -ForegroundColor White
    exit 1
}

Write-Host "`nDevices found:" -ForegroundColor Green
adb devices

# Uninstall old version
Write-Host "`nUninstalling old version..." -ForegroundColor Yellow
adb uninstall com.squashtrainingapp 2>$null

# Install new version
Write-Host "`nInstalling new version..." -ForegroundColor Green
adb install -r $apkPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nInstallation successful!" -ForegroundColor Green
    
    # Launch app
    Write-Host "`nLaunching app..." -ForegroundColor Cyan
    adb shell am start -n com.squashtrainingapp/.MainActivity
    
    Write-Host "`n=== App launched successfully! ===" -ForegroundColor Green
    Write-Host "`nTo test Korean localization:" -ForegroundColor Yellow
    Write-Host "1. Go to Settings" -ForegroundColor White
    Write-Host "2. Select Language -> Korean (한국어)" -ForegroundColor White
    Write-Host "3. Restart the app" -ForegroundColor White
} else {
    Write-Host "`nInstallation failed!" -ForegroundColor Red
    exit 1
}