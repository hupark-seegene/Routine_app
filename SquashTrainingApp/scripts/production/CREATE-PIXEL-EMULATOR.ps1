# CREATE-PIXEL-EMULATOR.ps1
# Create Pixel 8 Pro emulator (latest model)

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Creating Pixel 8 Pro Emulator" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Setup paths
$androidHome = $env:ANDROID_HOME
if (-not $androidHome) {
    $androidHome = "$env:LOCALAPPDATA\Android\Sdk"
}

$avdManagerPath = "$androidHome\cmdline-tools\latest\bin\avdmanager.bat"
$sdkManagerPath = "$androidHome\cmdline-tools\latest\bin\sdkmanager.bat"
$emulatorPath = "$androidHome\emulator\emulator.exe"

# Check if cmdline-tools exist
if (-not (Test-Path $avdManagerPath)) {
    Write-Host "AVD Manager not found. Please install Android cmdline-tools." -ForegroundColor Red
    exit 1
}

# List available devices
Write-Host "`nChecking available device definitions..." -ForegroundColor Yellow
$devices = & $avdManagerPath list device -c

# Check for Pixel 8 Pro
$pixel8Pro = $devices | Where-Object { $_ -match "pixel_8_pro" }
if (-not $pixel8Pro) {
    Write-Host "Pixel 8 Pro device definition not found. Using Pixel 7 Pro instead." -ForegroundColor Yellow
    $deviceName = "pixel_7_pro"
} else {
    $deviceName = "pixel_8_pro"
}

# AVD Name
$avdName = "Pixel_8_Pro_API_34"

# Check if AVD already exists
Write-Host "`nChecking existing AVDs..." -ForegroundColor Yellow
$existingAvds = & $avdManagerPath list avd -c
if ($existingAvds -contains $avdName) {
    Write-Host "AVD '$avdName' already exists!" -ForegroundColor Green
    
    # Start the emulator
    Write-Host "`nStarting existing Pixel 8 Pro emulator..." -ForegroundColor Cyan
    Start-Process -FilePath $emulatorPath -ArgumentList "-avd", $avdName, "-no-snapshot-load" -WindowStyle Normal
    
    Write-Host "Pixel 8 Pro emulator started!" -ForegroundColor Green
    exit 0
}

# Download system image if needed
Write-Host "`nChecking system images..." -ForegroundColor Yellow
Write-Host "Installing Android 14 (API 34) system image..." -ForegroundColor Cyan
& $sdkManagerPath "system-images;android-34;google_apis_playstore;x86_64"

# Create AVD
Write-Host "`nCreating Pixel 8 Pro AVD..." -ForegroundColor Cyan
$createCommand = @"
echo no | $avdManagerPath create avd `
    --name $avdName `
    --device "$deviceName" `
    --package "system-images;android-34;google_apis_playstore;x86_64" `
    --tag "google_apis_playstore" `
    --abi "x86_64"
"@

Invoke-Expression $createCommand

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to create AVD!" -ForegroundColor Red
    exit 1
}

# Configure AVD for better performance
$avdConfigPath = "$env:USERPROFILE\.android\avd\$avdName.avd\config.ini"
if (Test-Path $avdConfigPath) {
    Write-Host "`nConfiguring AVD for optimal performance..." -ForegroundColor Yellow
    
    # Read current config
    $config = Get-Content $avdConfigPath
    
    # Update settings
    $newConfig = @()
    $settings = @{
        "hw.ramSize" = "4096"
        "hw.cpu.ncore" = "4"
        "hw.gpu.enabled" = "yes"
        "hw.gpu.mode" = "auto"
        "hw.keyboard" = "yes"
        "hw.audioInput" = "yes"
        "hw.camera.back" = "webcam0"
        "hw.camera.front" = "webcam0"
        "disk.dataPartition.size" = "4096M"
        "vm.heapSize" = "256"
    }
    
    foreach ($line in $config) {
        $updated = $false
        foreach ($key in $settings.Keys) {
            if ($line -match "^$key=") {
                $newConfig += "$key=$($settings[$key])"
                $updated = $true
                break
            }
        }
        if (-not $updated) {
            $newConfig += $line
        }
    }
    
    # Add missing settings
    foreach ($key in $settings.Keys) {
        if (-not ($config -match "^$key=")) {
            $newConfig += "$key=$($settings[$key])"
        }
    }
    
    # Write updated config
    $newConfig | Set-Content $avdConfigPath
    Write-Host "AVD configuration updated!" -ForegroundColor Green
}

# Start the emulator
Write-Host "`nStarting Pixel 8 Pro emulator..." -ForegroundColor Cyan
Start-Process -FilePath $emulatorPath -ArgumentList "-avd", $avdName, "-no-snapshot-load" -WindowStyle Normal

Write-Host "`n======================================" -ForegroundColor Green
Write-Host "Pixel 8 Pro Emulator Created!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "AVD Name: $avdName" -ForegroundColor White
Write-Host "Android Version: 14 (API 34)" -ForegroundColor White
Write-Host "Device: Pixel 8 Pro" -ForegroundColor White
Write-Host "RAM: 4GB" -ForegroundColor White
Write-Host "Storage: 4GB" -ForegroundColor White
Write-Host ""
Write-Host "Emulator is starting in the background..." -ForegroundColor Yellow
Write-Host "Wait for boot completion before installing apps." -ForegroundColor Yellow