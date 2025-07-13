<#
.SYNOPSIS
    Start emulator and run comprehensive app test
    
.DESCRIPTION
    Helps start the Android emulator and then runs the comprehensive test
#>

$ErrorActionPreference = "Continue"
$ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$EMULATOR = "$ANDROID_HOME\emulator\emulator.exe"
$ADB = "$ANDROID_HOME\platform-tools\adb.exe"

Write-Host "=== EMULATOR STARTER ===" -ForegroundColor Cyan

# List available AVDs
Write-Host "`nAvailable emulators:" -ForegroundColor Yellow
$avds = & $EMULATOR -list-avds 2>&1
if ($avds) {
    $avds | ForEach-Object { Write-Host "  - $_" -ForegroundColor Green }
} else {
    Write-Host "No emulators found! Please create one in Android Studio." -ForegroundColor Red
    exit 1
}

# Check if emulator is already running
Write-Host "`nChecking if emulator is already running..." -ForegroundColor Yellow
$devices = & $ADB devices 2>&1
if ($devices -match "emulator.*device") {
    Write-Host "Emulator is already running!" -ForegroundColor Green
} else {
    # Start emulator
    Write-Host "`nStarting emulator..." -ForegroundColor Yellow
    Write-Host "Choose which emulator to start:" -ForegroundColor Cyan
    Write-Host "1. Pixel_6" -ForegroundColor White
    Write-Host "2. Medium_Phone_API_36.0" -ForegroundColor White
    
    $choice = Read-Host "Enter choice (1 or 2)"
    $avdName = if ($choice -eq "2") { "Medium_Phone_API_36.0" } else { "Pixel_6" }
    
    Write-Host "Starting $avdName..." -ForegroundColor Yellow
    Start-Process -FilePath $EMULATOR -ArgumentList "-avd", $avdName -WindowStyle Minimized
    
    Write-Host "Waiting for emulator to boot (this may take 1-2 minutes)..." -ForegroundColor Yellow
    
    # Wait for device
    & $ADB wait-for-device
    
    # Wait for boot completion
    $bootComplete = $false
    $attempts = 0
    while (!$bootComplete -and $attempts -lt 60) {
        $bootProp = & $ADB shell getprop sys.boot_completed 2>&1
        if ($bootProp -match "1") {
            $bootComplete = $true
        } else {
            Write-Host "." -NoNewline
            Start-Sleep -Seconds 2
            $attempts++
        }
    }
    
    if ($bootComplete) {
        Write-Host "`nEmulator is ready!" -ForegroundColor Green
        Start-Sleep -Seconds 5  # Extra time for UI to be ready
    } else {
        Write-Host "`nEmulator boot timeout. It may still be starting..." -ForegroundColor Yellow
    }
}

# Run comprehensive test
Write-Host "`n=== RUNNING COMPREHENSIVE APP TEST ===" -ForegroundColor Cyan
Write-Host "This will test ALL features and take many screenshots..." -ForegroundColor Yellow

$testScript = "$PSScriptRoot\COMPLETE-APP-TEST-V028.ps1"
if (Test-Path $testScript) {
    & $testScript -SkipEmulatorCheck
} else {
    Write-Host "Test script not found: $testScript" -ForegroundColor Red
}

Write-Host "`nDone!" -ForegroundColor Green