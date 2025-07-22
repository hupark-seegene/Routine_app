# BUILD-AND-TEST-3DEVICES.ps1
# Build and test on 3 devices simultaneously

$ErrorActionPreference = "Stop"

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "Building and Testing on 3 Devices" -ForegroundColor Cyan
Write-Host "==================================================`n" -ForegroundColor Cyan

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$androidDir = Join-Path $scriptDir "..\..\android"

# Navigate to Android directory
Set-Location $androidDir

# Check connected devices
Write-Host "Checking connected devices..." -ForegroundColor Yellow
adb devices

# Clean and build
Write-Host "`nCleaning project..." -ForegroundColor Yellow
.\gradlew.bat clean

Write-Host "`nBuilding APK..." -ForegroundColor Yellow
.\gradlew.bat assembleDebug

# Check if build was successful
$apkPath = "app\build\outputs\apk\debug\app-debug.apk"
if (Test-Path $apkPath) {
    Write-Host "`nBuild successful! APK found at: $apkPath" -ForegroundColor Green
    
    # Get list of devices
    $devices = @()
    $output = adb devices | Select-Object -Skip 1
    foreach ($line in $output) {
        if ($line -match '(\S+)\s+device') {
            $devices += $matches[1]
        }
    }
    
    Write-Host "`nFound $($devices.Count) devices:" -ForegroundColor Yellow
    foreach ($device in $devices) {
        Write-Host "  - $device" -ForegroundColor Gray
    }
    
    # Install on all devices
    foreach ($device in $devices) {
        Write-Host "`nInstalling on $device..." -ForegroundColor Yellow
        adb -s $device install -r $apkPath
        
        # Launch the app
        Write-Host "Launching app on $device..." -ForegroundColor Yellow
        adb -s $device shell am start -n com.squashtrainingapp/.MainActivity
    }
    
    Write-Host "`n==================================================" -ForegroundColor Green
    Write-Host "Deployment complete on all devices!" -ForegroundColor Green
    Write-Host "==================================================`n" -ForegroundColor Green
    
    # Show logcat for all devices in separate PowerShell windows
    Write-Host "Opening logcat for each device..." -ForegroundColor Yellow
    foreach ($device in $devices) {
        $title = "Logcat - $device"
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "adb -s $device logcat *:E | Select-String 'squashtraining'"
    }
    
} else {
    Write-Host "`nBuild failed! APK not found." -ForegroundColor Red
    exit 1
}

Write-Host "`nMonitoring main device logs..." -ForegroundColor Yellow
adb -s $devices[0] logcat *:E | Select-String "squashtraining"