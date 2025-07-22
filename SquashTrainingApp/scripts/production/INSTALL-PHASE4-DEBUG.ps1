# INSTALL-PHASE4-DEBUG.ps1
# Install and debug Phase 4 APK

$ErrorActionPreference = "Continue"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Phase 4 APK Install & Debug" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Setup paths
$androidHome = $env:ANDROID_HOME
if (-not $androidHome) {
    $androidHome = "$env:LOCALAPPDATA\Android\Sdk"
}
$adbPath = "$androidHome\platform-tools\adb.exe"

# APK path
$apkPath = "$PSScriptRoot\..\..\android\app\build\outputs\apk\debug\app-debug.apk"

if (-not (Test-Path $apkPath)) {
    Write-Host "APK not found at: $apkPath" -ForegroundColor Red
    exit 1
}

$apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
Write-Host "`nAPK found: app-debug.apk" -ForegroundColor Green
Write-Host "Size: $apkSize MB" -ForegroundColor Gray

# Check for devices
Write-Host "`nChecking for connected devices..." -ForegroundColor Yellow
$devices = & $adbPath devices 2>$null | Select-String -Pattern "\tdevice$"

if ($devices.Count -eq 0) {
    Write-Host "`nNo devices connected!" -ForegroundColor Red
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "1. Start Android Emulator from Android Studio" -ForegroundColor White
    Write-Host "2. Connect to BlueStacks: adb connect 127.0.0.1:5555" -ForegroundColor White
    Write-Host "3. Connect a physical device with USB debugging" -ForegroundColor White
    
    # Try BlueStacks
    Write-Host "`nAttempting to connect to BlueStacks..." -ForegroundColor Yellow
    & $adbPath connect 127.0.0.1:5555 2>$null
    Start-Sleep -Seconds 2
    
    $devices = & $adbPath devices 2>$null | Select-String -Pattern "\tdevice$"
    if ($devices.Count -eq 0) {
        Write-Host "Still no devices found. Please start an emulator." -ForegroundColor Red
        exit 1
    }
}

Write-Host "Device(s) connected!" -ForegroundColor Green

# Uninstall existing app
Write-Host "`nUninstalling existing app..." -ForegroundColor Yellow
& $adbPath uninstall com.squashtrainingapp 2>$null

# Install APK
Write-Host "Installing Phase 4 APK..." -ForegroundColor Yellow
$installResult = & $adbPath install -r $apkPath 2>&1

if ($installResult -match "Success") {
    Write-Host "Installation successful!" -ForegroundColor Green
} else {
    Write-Host "Installation failed!" -ForegroundColor Red
    Write-Host $installResult
    exit 1
}

# Grant permissions
Write-Host "`nGranting permissions..." -ForegroundColor Yellow
$permissions = @(
    "android.permission.INTERNET",
    "android.permission.ACCESS_NETWORK_STATE",
    "android.permission.RECORD_AUDIO",
    "android.permission.VIBRATE",
    "android.permission.POST_NOTIFICATIONS",
    "android.permission.CAMERA"
)

foreach ($permission in $permissions) {
    & $adbPath shell pm grant com.squashtrainingapp $permission 2>$null
}

# Clear app data for fresh onboarding
Write-Host "Clearing app data..." -ForegroundColor Yellow
& $adbPath shell pm clear com.squashtrainingapp

# Launch app
Write-Host "`nLaunching app..." -ForegroundColor Cyan
& $adbPath shell am start -n com.squashtrainingapp/.ui.activities.SplashActivity

Write-Host "`n======================================" -ForegroundColor Green
Write-Host "Phase 4 Testing Checklist:" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "[ ] 1. Splash Screen Animation" -ForegroundColor White
Write-Host "[ ] 2. Onboarding Flow (5 screens)" -ForegroundColor White
Write-Host "[ ] 3. A/B Test Variant" -ForegroundColor White
Write-Host "[ ] 4. Personalization Options" -ForegroundColor White
Write-Host "[ ] 5. Premium Features Display" -ForegroundColor White
Write-Host "[ ] 6. Registration/Login Flow" -ForegroundColor White
Write-Host "[ ] 7. Referral Program" -ForegroundColor White
Write-Host "[ ] 8. Social Sharing" -ForegroundColor White
Write-Host ""
Write-Host "Starting LogCat monitoring..." -ForegroundColor Yellow
Write-Host "Filter: Phase4, Onboarding, Referral" -ForegroundColor Gray
Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

# Monitor filtered logcat
& $adbPath logcat -c
& $adbPath logcat "SquashTraining:V" "SplashActivity:V" "OnboardingActivity:V" "ReferralService:V" "ShareManager:V" "AndroidRuntime:E" "*:S"