# DUAL-DEVICE-DEBUG.ps1
# Install and debug on both BlueStacks and Emulator simultaneously

param(
    [switch]$SkipBuild = $false
)

$ErrorActionPreference = "Continue"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Dual Device Debug - Phase 4" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Setup paths
$androidHome = $env:ANDROID_HOME
if (-not $androidHome) {
    $androidHome = "$env:LOCALAPPDATA\Android\Sdk"
}
$adbPath = "$androidHome\platform-tools\adb.exe"
$apkPath = "$PSScriptRoot\..\..\android\app\build\outputs\apk\debug\app-debug.apk"

# Check APK exists
if (-not (Test-Path $apkPath)) {
    Write-Host "APK not found! Please build first." -ForegroundColor Red
    exit 1
}

$apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
Write-Host "`nAPK: app-debug.apk ($apkSize MB)" -ForegroundColor Green

# Get connected devices
Write-Host "`nChecking connected devices..." -ForegroundColor Yellow
$devices = & $adbPath devices | Select-String -Pattern "\tdevice$" | ForEach-Object { $_.Line.Split("`t")[0] }

if ($devices.Count -lt 2) {
    Write-Host "Less than 2 devices connected. Found: $($devices.Count)" -ForegroundColor Red
    exit 1
}

Write-Host "Found $($devices.Count) devices:" -ForegroundColor Green
$devices | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }

# Device 1: BlueStacks
$device1 = "127.0.0.1:5556"
# Device 2: Emulator
$device2 = "emulator-5554"

Write-Host "`n==========================================" -ForegroundColor Yellow
Write-Host "Installing on Device 1: $device1 (BlueStacks)" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Yellow

# Uninstall and install on Device 1
& $adbPath -s $device1 uninstall com.squashtrainingapp 2>$null
Write-Host "Installing APK..." -ForegroundColor Gray
$result1 = & $adbPath -s $device1 install -r $apkPath 2>&1
if ($result1 -match "Success") {
    Write-Host "✓ Installation successful on $device1" -ForegroundColor Green
} else {
    Write-Host "✗ Installation failed on $device1" -ForegroundColor Red
}

# Grant permissions on Device 1
Write-Host "Granting permissions..." -ForegroundColor Gray
$permissions = @(
    "android.permission.INTERNET",
    "android.permission.ACCESS_NETWORK_STATE",
    "android.permission.RECORD_AUDIO",
    "android.permission.VIBRATE",
    "android.permission.POST_NOTIFICATIONS"
)
foreach ($perm in $permissions) {
    & $adbPath -s $device1 shell pm grant com.squashtrainingapp $perm 2>$null
}

# Clear data and launch on Device 1
& $adbPath -s $device1 shell pm clear com.squashtrainingapp
Write-Host "Launching app on $device1..." -ForegroundColor Cyan
& $adbPath -s $device1 shell am start -n com.squashtrainingapp/.ui.activities.SplashActivity

Write-Host "`n==========================================" -ForegroundColor Yellow
Write-Host "Installing on Device 2: $device2 (Emulator)" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Yellow

# Uninstall and install on Device 2
& $adbPath -s $device2 uninstall com.squashtrainingapp 2>$null
Write-Host "Installing APK..." -ForegroundColor Gray
$result2 = & $adbPath -s $device2 install -r $apkPath 2>&1
if ($result2 -match "Success") {
    Write-Host "✓ Installation successful on $device2" -ForegroundColor Green
} else {
    Write-Host "✗ Installation failed on $device2" -ForegroundColor Red
}

# Grant permissions on Device 2
Write-Host "Granting permissions..." -ForegroundColor Gray
foreach ($perm in $permissions) {
    & $adbPath -s $device2 shell pm grant com.squashtrainingapp $perm 2>$null
}

# Clear data and launch on Device 2
& $adbPath -s $device2 shell pm clear com.squashtrainingapp
Write-Host "Launching app on $device2..." -ForegroundColor Cyan
& $adbPath -s $device2 shell am start -n com.squashtrainingapp/.ui.activities.SplashActivity

Write-Host "`n==========================================" -ForegroundColor Green
Write-Host "Apps Launched on Both Devices!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Start parallel logcat monitoring
Write-Host "`nStarting dual device monitoring..." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

# Clear previous logs
& $adbPath -s $device1 logcat -c
& $adbPath -s $device2 logcat -c

# Create jobs for parallel monitoring
$job1 = Start-Job -ScriptBlock {
    param($adb, $device)
    & $adb -s $device logcat "SquashTraining:V" "SplashActivity:V" "OnboardingActivity:V" "AndroidRuntime:E" "*:S" | ForEach-Object {
        "[BlueStacks] $_"
    }
} -ArgumentList $adbPath, $device1

$job2 = Start-Job -ScriptBlock {
    param($adb, $device)
    & $adb -s $device logcat "SquashTraining:V" "SplashActivity:V" "OnboardingActivity:V" "AndroidRuntime:E" "*:S" | ForEach-Object {
        "[Emulator] $_"
    }
} -ArgumentList $adbPath, $device2

Write-Host "Monitoring logs from both devices..." -ForegroundColor Cyan
Write-Host "BlueStacks logs prefixed with [BlueStacks]" -ForegroundColor Gray
Write-Host "Emulator logs prefixed with [Emulator]" -ForegroundColor Gray
Write-Host ""

# Monitor both jobs
try {
    while ($true) {
        # Get output from both jobs
        $output1 = Receive-Job $job1 -Keep
        $output2 = Receive-Job $job2 -Keep
        
        # Display output
        if ($output1) {
            $output1 | ForEach-Object {
                if ($_ -match "ERROR|Exception|FATAL") {
                    Write-Host $_ -ForegroundColor Red
                } elseif ($_ -match "WARN") {
                    Write-Host $_ -ForegroundColor Yellow
                } elseif ($_ -match "Onboarding|Referral|ABTest") {
                    Write-Host $_ -ForegroundColor Cyan
                } else {
                    Write-Host $_
                }
            }
        }
        
        if ($output2) {
            $output2 | ForEach-Object {
                if ($_ -match "ERROR|Exception|FATAL") {
                    Write-Host $_ -ForegroundColor Red
                } elseif ($_ -match "WARN") {
                    Write-Host $_ -ForegroundColor Yellow
                } elseif ($_ -match "Onboarding|Referral|ABTest") {
                    Write-Host $_ -ForegroundColor Cyan
                } else {
                    Write-Host $_
                }
            }
        }
        
        Start-Sleep -Milliseconds 100
    }
} finally {
    # Clean up jobs
    Stop-Job $job1, $job2
    Remove-Job $job1, $job2
    Write-Host "`nStopped monitoring." -ForegroundColor Yellow
}