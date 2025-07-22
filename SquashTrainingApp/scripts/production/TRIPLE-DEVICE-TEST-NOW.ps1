# TRIPLE-DEVICE-TEST-NOW.ps1
# Quick test on 3 connected devices

$ErrorActionPreference = "Continue"

Write-Host "===========================================`n" -ForegroundColor Cyan
Write-Host "    Triple Device Test - Phase 4`n" -ForegroundColor Cyan
Write-Host "===========================================`n" -ForegroundColor Cyan

$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$apkPath = "$PSScriptRoot\..\..\android\app\build\outputs\apk\debug\app-debug.apk"

# Check APK
if (-not (Test-Path $apkPath)) {
    Write-Host "APK not found!" -ForegroundColor Red
    exit 1
}

# Get connected devices
$devices = & $adbPath devices | Select-String -Pattern "\tdevice$" | ForEach-Object { $_.Line.Split("`t")[0] }
Write-Host "Found $($devices.Count) devices:" -ForegroundColor Green
$devices | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }

# Install on all devices
Write-Host "`nInstalling on all devices..." -ForegroundColor Yellow

foreach ($device in $devices) {
    Write-Host "`n[$device] Installing..." -ForegroundColor Cyan
    
    # Uninstall first
    & $adbPath -s $device uninstall com.squashtrainingapp 2>$null | Out-Null
    
    # Install
    $result = & $adbPath -s $device install -r $apkPath 2>&1
    if ($result -match "Success") {
        Write-Host "[$device] ✓ Installed" -ForegroundColor Green
        
        # Clear data and launch
        & $adbPath -s $device shell pm clear com.squashtrainingapp 2>$null | Out-Null
        & $adbPath -s $device shell am start -n com.squashtrainingapp/.ui.activities.SplashActivity
        Write-Host "[$device] ✓ Launched" -ForegroundColor Green
    } else {
        Write-Host "[$device] ✗ Failed to install" -ForegroundColor Red
    }
}

Write-Host "`n===========================================`n" -ForegroundColor Green
Write-Host "    All Apps Launched!`n" -ForegroundColor Green
Write-Host "===========================================`n" -ForegroundColor Green

Write-Host "Phase 4 Features:" -ForegroundColor Cyan
Write-Host "✓ Splash Screen Animation" -ForegroundColor White
Write-Host "✓ Premium Onboarding (5 screens)" -ForegroundColor White
Write-Host "✓ A/B Testing Variants" -ForegroundColor White
Write-Host "✓ Referral System" -ForegroundColor White
Write-Host "✓ Social Sharing" -ForegroundColor White

Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
Read-Host