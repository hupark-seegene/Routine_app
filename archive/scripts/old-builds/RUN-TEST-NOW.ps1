<#
.SYNOPSIS
    Simple test runner that handles emulator issues
#>

$ErrorActionPreference = "Continue"
$ADB = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$EMULATOR = "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe"

Write-Host "=== STARTING FRESH TEST RUN ===" -ForegroundColor Cyan

# Kill all emulators and ADB
Write-Host "Cleaning up existing emulators..." -ForegroundColor Yellow
& taskkill /F /IM "emulator.exe" /T 2>&1 | Out-Null
& taskkill /F /IM "qemu-system-x86_64.exe" /T 2>&1 | Out-Null
& $ADB kill-server 2>&1 | Out-Null
Start-Sleep -Seconds 2

# Start ADB
Write-Host "Starting ADB server..." -ForegroundColor Yellow
& $ADB start-server

# Start fresh emulator
Write-Host "Starting Pixel_6 emulator..." -ForegroundColor Yellow
Start-Process -FilePath $EMULATOR -ArgumentList "-avd", "Pixel_6" -WindowStyle Minimized

# Wait for device
Write-Host "Waiting for emulator to boot..." -ForegroundColor Yellow
& $ADB wait-for-device

# Wait for boot completion
$attempts = 0
while ($attempts -lt 60) {
    $bootProp = & $ADB shell getprop sys.boot_completed 2>&1
    if ($bootProp -match "1") {
        Write-Host "Emulator is ready!" -ForegroundColor Green
        break
    }
    Write-Host "." -NoNewline
    Start-Sleep -Seconds 2
    $attempts++
}

Start-Sleep -Seconds 5  # Extra time for UI

# Now run the test
Write-Host "`n=== RUNNING COMPREHENSIVE TEST ===" -ForegroundColor Cyan
& "$PSScriptRoot\COMPLETE-APP-TEST-V028.ps1" -SkipEmulatorCheck