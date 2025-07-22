# QUICK-START-EMULATOR.ps1
# Simplified script to quickly start emulator with microphone

$ErrorActionPreference = "Continue"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Quick Start Emulator with Microphone" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Try to find Android SDK
$androidHome = $env:ANDROID_HOME
if (-not $androidHome) {
    $androidHome = "$env:LOCALAPPDATA\Android\Sdk"
}

$emulatorPath = "$androidHome\emulator\emulator.exe"
$adbPath = "$androidHome\platform-tools\adb.exe"

if (-not (Test-Path $emulatorPath)) {
    Write-Host "Emulator not found at: $emulatorPath" -ForegroundColor Red
    Write-Host "Please ensure Android SDK is installed" -ForegroundColor Yellow
    exit 1
}

# Check if emulator is already running
Write-Host "`nChecking for running emulator..." -ForegroundColor Yellow
$devices = & $adbPath devices 2>$null
if ($devices -match "emulator") {
    Write-Host "Emulator is already running!" -ForegroundColor Green
    Write-Host "Configuring microphone permissions..." -ForegroundColor Yellow
    
    # Configure permissions
    & $adbPath shell settings put system microphone_mute 0
    & $adbPath shell pm grant com.squashtrainingapp android.permission.RECORD_AUDIO
    & $adbPath shell pm grant com.google.android.googlequicksearchbox android.permission.RECORD_AUDIO 2>$null
    & $adbPath shell appops set com.squashtrainingapp SYSTEM_ALERT_WINDOW allow 2>$null
    
    Write-Host "`n✓ Microphone configured!" -ForegroundColor Green
    exit 0
}

# Get available AVDs
Write-Host "`nFinding available AVDs..." -ForegroundColor Yellow
$avds = & $emulatorPath -list-avds
if (-not $avds) {
    Write-Host "No AVDs found!" -ForegroundColor Red
    Write-Host "Please create an AVD in Android Studio first" -ForegroundColor Yellow
    exit 1
}

# Use first AVD
$selectedAvd = $avds[0]
Write-Host "Selected AVD: $selectedAvd" -ForegroundColor Green

# Start emulator
Write-Host "`nStarting emulator with microphone support..." -ForegroundColor Cyan
Write-Host "This may take 1-3 minutes..." -ForegroundColor Gray

$emulatorArgs = @(
    "-avd", $selectedAvd,
    "-feature", "VirtualMicrophone,AudioInput,WindowsHypervisorPlatform",
    "-no-snapshot-load"
)

Start-Process -FilePath $emulatorPath -ArgumentList $emulatorArgs -WindowStyle Normal

Write-Host "`nEmulator starting in background..." -ForegroundColor Green
Write-Host "Waiting for boot completion..." -ForegroundColor Yellow

# Wait for emulator
$maxWait = 180
$waited = 0
$dotCount = 0

while ($waited -lt $maxWait) {
    Start-Sleep -Seconds 2
    $waited += 2
    
    # Animated dots
    $dots = "." * (($dotCount % 3) + 1)
    Write-Host -NoNewline "`rWaiting$dots   " -ForegroundColor Gray
    $dotCount++
    
    # Check if booted
    $bootComplete = & $adbPath shell getprop sys.boot_completed 2>$null
    if ($bootComplete -eq "1") {
        Write-Host "`n✓ Emulator booted!" -ForegroundColor Green
        break
    }
}

if ($waited -ge $maxWait) {
    Write-Host "`nTimeout!" -ForegroundColor Red
    exit 1
}

# Configure after boot
Write-Host "`nConfiguring microphone..." -ForegroundColor Yellow

& $adbPath shell settings put system microphone_mute 0
& $adbPath shell pm grant com.squashtrainingapp android.permission.RECORD_AUDIO
& $adbPath shell pm grant com.google.android.googlequicksearchbox android.permission.RECORD_AUDIO 2>$null
& $adbPath shell appops set com.squashtrainingapp SYSTEM_ALERT_WINDOW allow 2>$null

Write-Host "`n======================================" -ForegroundColor Green
Write-Host "✓ Emulator Ready with Microphone!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

Write-Host "`nTest microphone:" -ForegroundColor Yellow
Write-Host "1. Open Google app > Say 'Ok Google'" -ForegroundColor White
Write-Host "2. Open Squash Training > Record > Mic button" -ForegroundColor White
Write-Host "3. Say: '헤이 코치' for wake word" -ForegroundColor White

Write-Host "`nPress Enter to exit..."
Read-Host