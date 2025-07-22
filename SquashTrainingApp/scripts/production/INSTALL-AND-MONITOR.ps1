# INSTALL-AND-MONITOR.ps1
# Install on both devices and monitor logs

$ErrorActionPreference = "Continue"

Write-Host "Installing on both devices..." -ForegroundColor Cyan

$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$apkPath = "$PSScriptRoot\..\..\android\app\build\outputs\apk\debug\app-debug.apk"

# Device 1: BlueStacks
Write-Host "`n[BlueStacks] Installing..." -ForegroundColor Yellow
& $adbPath -s 127.0.0.1:5556 uninstall com.squashtrainingapp 2>$null
& $adbPath -s 127.0.0.1:5556 install -r $apkPath
& $adbPath -s 127.0.0.1:5556 shell pm clear com.squashtrainingapp
& $adbPath -s 127.0.0.1:5556 shell am start -n com.squashtrainingapp/.ui.activities.SplashActivity

# Device 2: Emulator  
Write-Host "`n[Emulator] Installing..." -ForegroundColor Yellow
& $adbPath -s emulator-5554 uninstall com.squashtrainingapp 2>$null
& $adbPath -s emulator-5554 install -r $apkPath
& $adbPath -s emulator-5554 shell pm clear com.squashtrainingapp
& $adbPath -s emulator-5554 shell am start -n com.squashtrainingapp/.ui.activities.SplashActivity

Write-Host "`nMonitoring logs..." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray

# Clear logs
& $adbPath -s 127.0.0.1:5556 logcat -c
& $adbPath -s emulator-5554 logcat -c

# Monitor in parallel
$job1 = Start-Job -ScriptBlock {
    param($adb)
    & $adb -s 127.0.0.1:5556 logcat | Select-String -Pattern "SquashTraining|SplashActivity|OnboardingActivity|ERROR|Exception"
} -ArgumentList $adbPath

$job2 = Start-Job -ScriptBlock {
    param($adb)
    & $adb -s emulator-5554 logcat | Select-String -Pattern "SquashTraining|SplashActivity|OnboardingActivity|ERROR|Exception"
} -ArgumentList $adbPath

while ($true) {
    $out1 = Receive-Job $job1
    $out2 = Receive-Job $job2
    
    if ($out1) {
        $out1 | ForEach-Object {
            if ($_ -match "ERROR|Exception") {
                Write-Host "[BlueStacks] $_" -ForegroundColor Red
            } else {
                Write-Host "[BlueStacks] $_" -ForegroundColor Cyan
            }
        }
    }
    
    if ($out2) {
        $out2 | ForEach-Object {
            if ($_ -match "ERROR|Exception") {
                Write-Host "[Emulator] $_" -ForegroundColor Red  
            } else {
                Write-Host "[Emulator] $_" -ForegroundColor Green
            }
        }
    }
    
    Start-Sleep -Milliseconds 100
}