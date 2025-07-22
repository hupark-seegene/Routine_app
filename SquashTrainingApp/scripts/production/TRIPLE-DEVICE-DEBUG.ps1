# TRIPLE-DEVICE-DEBUG.ps1
# Debug on 3 devices simultaneously: BlueStacks, Emulator, and Pixel 8 Pro

param(
    [switch]$SkipBuild = $false
)

$ErrorActionPreference = "Continue"

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Triple Device Debug - Phase 4" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$apkPath = "$PSScriptRoot\..\..\android\app\build\outputs\apk\debug\app-debug.apk"

# Check APK
if (-not (Test-Path $apkPath)) {
    Write-Host "APK not found! Please build first." -ForegroundColor Red
    exit 1
}

$apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
Write-Host "APK: app-debug.apk ($apkSize MB)" -ForegroundColor Green

# Wait for all devices
Write-Host "`nWaiting for all 3 devices to be ready..." -ForegroundColor Yellow
$maxWait = 60
$waited = 0

while ($waited -lt $maxWait) {
    $devices = & $adbPath devices | Select-String -Pattern "\tdevice$" | ForEach-Object { $_.Line.Split("`t")[0] }
    
    if ($devices.Count -ge 3) {
        Write-Host "Found $($devices.Count) devices!" -ForegroundColor Green
        break
    }
    
    Write-Host "Currently $($devices.Count) devices connected. Waiting..." -ForegroundColor Gray
    Start-Sleep -Seconds 5
    $waited += 5
}

# List all devices
Write-Host "`nConnected devices:" -ForegroundColor Cyan
$devices | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }

# Define device IDs
$device1 = "127.0.0.1:5556"  # BlueStacks
$device2 = "emulator-5554"    # Standard Emulator
$device3 = "emulator-5556"    # Pixel 8 Pro

# Install on all devices
$deviceList = @(
    @{Name="BlueStacks"; ID=$device1; Color="Cyan"},
    @{Name="Emulator"; ID=$device2; Color="Green"},
    @{Name="Pixel 8 Pro"; ID=$device3; Color="Magenta"}
)

foreach ($device in $deviceList) {
    Write-Host "`n===========================================" -ForegroundColor $device.Color
    Write-Host "Installing on $($device.Name): $($device.ID)" -ForegroundColor $device.Color
    Write-Host "===========================================" -ForegroundColor $device.Color
    
    # Check if device exists
    if ($devices -contains $device.ID) {
        # Uninstall
        & $adbPath -s $device.ID uninstall com.squashtrainingapp 2>$null
        
        # Install
        Write-Host "Installing APK..." -ForegroundColor Gray
        $result = & $adbPath -s $device.ID install -r $apkPath 2>&1
        if ($result -match "Success") {
            Write-Host "✓ Installation successful" -ForegroundColor Green
            
            # Grant permissions
            Write-Host "Granting permissions..." -ForegroundColor Gray
            $permissions = @(
                "android.permission.INTERNET",
                "android.permission.ACCESS_NETWORK_STATE",
                "android.permission.RECORD_AUDIO",
                "android.permission.VIBRATE",
                "android.permission.POST_NOTIFICATIONS"
            )
            foreach ($perm in $permissions) {
                & $adbPath -s $device.ID shell pm grant com.squashtrainingapp $perm 2>$null
            }
            
            # Clear data and launch
            & $adbPath -s $device.ID shell pm clear com.squashtrainingapp
            Write-Host "Launching app..." -ForegroundColor $device.Color
            & $adbPath -s $device.ID shell am start -n com.squashtrainingapp/.ui.activities.SplashActivity
        } else {
            Write-Host "✗ Installation failed" -ForegroundColor Red
        }
    } else {
        Write-Host "✗ Device not connected" -ForegroundColor Red
    }
}

Write-Host "`n===========================================" -ForegroundColor Yellow
Write-Host "Starting Triple Device Monitoring" -ForegroundColor Yellow
Write-Host "===========================================" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

# Clear logs
foreach ($device in $deviceList) {
    if ($devices -contains $device.ID) {
        & $adbPath -s $device.ID logcat -c
    }
}

# Create monitoring jobs
$jobs = @()
foreach ($device in $deviceList) {
    if ($devices -contains $device.ID) {
        $job = Start-Job -ScriptBlock {
            param($adb, $deviceID, $deviceName)
            & $adb -s $deviceID logcat | ForEach-Object {
                if ($_ -match "SquashTraining|SplashActivity|OnboardingActivity|ERROR|Exception|AndroidRuntime") {
                    "[$deviceName] $_"
                }
            }
        } -ArgumentList $adbPath, $device.ID, $device.Name
        $jobs += $job
    }
}

# Monitor all jobs
Write-Host "Monitoring logs from $($jobs.Count) devices..." -ForegroundColor Cyan
Write-Host ""

try {
    while ($true) {
        foreach ($i in 0..($jobs.Count-1)) {
            $output = Receive-Job $jobs[$i]
            if ($output) {
                $output | ForEach-Object {
                    $color = "White"
                    if ($_ -match "\[BlueStacks\]") { $color = "Cyan" }
                    elseif ($_ -match "\[Emulator\]") { $color = "Green" }
                    elseif ($_ -match "\[Pixel") { $color = "Magenta" }
                    
                    if ($_ -match "ERROR|Exception|AndroidRuntime") {
                        Write-Host $_ -ForegroundColor Red
                    } else {
                        Write-Host $_ -ForegroundColor $color
                    }
                }
            }
        }
        Start-Sleep -Milliseconds 100
    }
} finally {
    # Clean up
    $jobs | ForEach-Object {
        Stop-Job $_
        Remove-Job $_
    }
    Write-Host "`nMonitoring stopped." -ForegroundColor Yellow
}

Write-Host "`n===========================================" -ForegroundColor Green
Write-Host "Triple Device Test Complete!" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green