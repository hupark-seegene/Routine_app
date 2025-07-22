# FINAL-TEST-PHASE4.ps1
# Final test of Phase 4 on both devices

$ErrorActionPreference = "Continue"

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Final Phase 4 Test - Dual Device" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$apkPath = "$PSScriptRoot\..\..\android\app\build\outputs\apk\debug\app-debug.apk"

# Install on both devices
Write-Host "`nInstalling on both devices..." -ForegroundColor Yellow

# BlueStacks
Write-Host "[BlueStacks] Installing..." -ForegroundColor Cyan
& $adbPath -s 127.0.0.1:5556 uninstall com.squashtrainingapp 2>$null | Out-Null
$result1 = & $adbPath -s 127.0.0.1:5556 install -r $apkPath 2>&1
if ($result1 -match "Success") {
    Write-Host "[BlueStacks] ✓ Installed" -ForegroundColor Green
} else {
    Write-Host "[BlueStacks] ✗ Failed" -ForegroundColor Red
}

# Emulator
Write-Host "[Emulator] Installing..." -ForegroundColor Cyan
& $adbPath -s emulator-5554 uninstall com.squashtrainingapp 2>$null | Out-Null
$result2 = & $adbPath -s emulator-5554 install -r $apkPath 2>&1
if ($result2 -match "Success") {
    Write-Host "[Emulator] ✓ Installed" -ForegroundColor Green
} else {
    Write-Host "[Emulator] ✗ Failed" -ForegroundColor Red
}

# Launch apps
Write-Host "`nLaunching apps..." -ForegroundColor Yellow
& $adbPath -s 127.0.0.1:5556 shell am start -n com.squashtrainingapp/.ui.activities.SplashActivity
& $adbPath -s emulator-5554 shell am start -n com.squashtrainingapp/.ui.activities.SplashActivity

Write-Host "`n===========================================" -ForegroundColor Green
Write-Host "Apps Launched - Monitoring..." -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

# Clear logs
& $adbPath -s 127.0.0.1:5556 logcat -c
& $adbPath -s emulator-5554 logcat -c

# Simple monitoring
Write-Host "`nWatching for errors..." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

# Monitor for 30 seconds
$startTime = Get-Date
$duration = 30

while (((Get-Date) - $startTime).TotalSeconds -lt $duration) {
    # Get logs from both devices
    $logs1 = & $adbPath -s 127.0.0.1:5556 logcat -d -t 50 2>$null | Select-String -Pattern "AndroidRuntime|FATAL|ERROR|SquashTraining|Onboarding"
    $logs2 = & $adbPath -s emulator-5554 logcat -d -t 50 2>$null | Select-String -Pattern "AndroidRuntime|FATAL|ERROR|SquashTraining|Onboarding"
    
    if ($logs1) {
        $logs1 | ForEach-Object {
            if ($_ -match "AndroidRuntime|FATAL|ERROR") {
                Write-Host "[BlueStacks] $_" -ForegroundColor Red
            } else {
                Write-Host "[BlueStacks] $_" -ForegroundColor Cyan
            }
        }
    }
    
    if ($logs2) {
        $logs2 | ForEach-Object {
            if ($_ -match "AndroidRuntime|FATAL|ERROR") {
                Write-Host "[Emulator] $_" -ForegroundColor Red
            } else {
                Write-Host "[Emulator] $_" -ForegroundColor Green
            }
        }
    }
    
    # Clear logs for next iteration
    & $adbPath -s 127.0.0.1:5556 logcat -c
    & $adbPath -s emulator-5554 logcat -c
    
    Start-Sleep -Seconds 2
}

Write-Host "`n===========================================" -ForegroundColor Yellow
Write-Host "Test Complete!" -ForegroundColor Yellow
Write-Host "===========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Phase 4 Features to Check:" -ForegroundColor Cyan
Write-Host "1. Splash Screen Animation" -ForegroundColor White
Write-Host "2. Onboarding Flow (5 screens)" -ForegroundColor White
Write-Host "3. Personalization Options" -ForegroundColor White
Write-Host "4. Premium Features" -ForegroundColor White
Write-Host "5. Login/Registration" -ForegroundColor White