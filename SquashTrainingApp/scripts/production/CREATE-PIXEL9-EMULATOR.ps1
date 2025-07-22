# CREATE-PIXEL9-EMULATOR.ps1
# Create Pixel 9 Pro emulator (latest model)

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Creating Pixel 9 Pro Emulator" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Setup paths
$androidHome = $env:ANDROID_HOME
if (-not $androidHome) {
    $androidHome = "$env:LOCALAPPDATA\Android\Sdk"
}

$sdkManagerPath = "$androidHome\tools\bin\sdkmanager.bat"
$avdManagerPath = "$androidHome\tools\bin\avdmanager.bat"
$emulatorPath = "$androidHome\emulator\emulator.exe"

# Check if tools exist
if (-not (Test-Path $sdkManagerPath)) {
    Write-Host "SDK Manager not found at: $sdkManagerPath" -ForegroundColor Yellow
    Write-Host "Checking alternative paths..." -ForegroundColor Yellow
    
    # Try cmdline-tools path
    $sdkManagerPath = "$androidHome\cmdline-tools\latest\bin\sdkmanager.bat"
    $avdManagerPath = "$androidHome\cmdline-tools\latest\bin\avdmanager.bat"
}

if (-not (Test-Path $emulatorPath)) {
    Write-Host "Emulator not found. Please install Android SDK." -ForegroundColor Red
    exit 1
}

# AVD Name for Pixel 9 Pro
$avdName = "Pixel_9_Pro_API_34"

# Check if AVD already exists
Write-Host "`nChecking existing AVDs..." -ForegroundColor Yellow
$existingAvds = & $emulatorPath -list-avds
if ($existingAvds -contains $avdName) {
    Write-Host "AVD '$avdName' already exists!" -ForegroundColor Green
    
    # Start the emulator
    Write-Host "`nStarting existing Pixel 9 Pro emulator..." -ForegroundColor Cyan
    Start-Process -FilePath $emulatorPath -ArgumentList "-avd", $avdName, "-no-snapshot-load" -WindowStyle Normal
    
    Write-Host "Pixel 9 Pro emulator started!" -ForegroundColor Green
    exit 0
}

# Create using Android Studio AVD Manager if available
Write-Host "`nPixel 9 Pro AVD not found." -ForegroundColor Yellow
Write-Host "Please create it using Android Studio AVD Manager:" -ForegroundColor Cyan
Write-Host "1. Open Android Studio" -ForegroundColor White
Write-Host "2. Tools -> AVD Manager" -ForegroundColor White
Write-Host "3. Create Virtual Device" -ForegroundColor White
Write-Host "4. Select 'Pixel 9 Pro' or 'Pixel 8 Pro' (latest available)" -ForegroundColor White
Write-Host "5. Select Android 14 (API 34) with Google Play" -ForegroundColor White
Write-Host "6. Name it: $avdName" -ForegroundColor White
Write-Host "7. Finish and start the emulator" -ForegroundColor White

Write-Host "`nAlternatively, you can use existing emulators:" -ForegroundColor Yellow
$existingAvds | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }