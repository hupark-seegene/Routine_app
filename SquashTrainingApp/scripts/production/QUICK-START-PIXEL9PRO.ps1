# QUICK-START-PIXEL9PRO.ps1
# Quick launcher for the Pixel 9 Pro emulator (assumes it's already created)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Quick Start Pixel 9 Pro Emulator" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Set paths
$androidHome = "C:\Users\hwpar\AppData\Local\Android\Sdk"
$emulatorPath = "$androidHome\emulator\emulator.exe"
$avdName = "Pixel_9_Pro"

# Check if emulator exists
if (-not (Test-Path $emulatorPath)) {
    Write-Host "❌ Emulator not found. Run SETUP-PIXEL9PRO-EMULATOR.ps1 first." -ForegroundColor Red
    exit 1
}

# List available AVDs
Write-Host "`nAvailable AVDs:" -ForegroundColor Yellow
$avds = & $emulatorPath -list-avds
$avds | ForEach-Object { 
    if ($_ -eq $avdName) {
        Write-Host "  ✓ $_" -ForegroundColor Green
    } else {
        Write-Host "  - $_" -ForegroundColor Gray
    }
}

# Check if Pixel 9 Pro AVD exists
if ($avds -notcontains $avdName) {
    Write-Host "`n❌ Pixel 9 Pro AVD not found. Run SETUP-PIXEL9PRO-EMULATOR.ps1 first." -ForegroundColor Red
    exit 1
}

# Start the emulator
Write-Host "`n🎯 Starting Pixel 9 Pro emulator..." -ForegroundColor Cyan

try {
    $emulatorArgs = @(
        "-avd", $avdName,
        "-gpu", "auto",
        "-memory", "4096"
    )
    
    Start-Process -FilePath $emulatorPath -ArgumentList $emulatorArgs -WindowStyle Normal
    
    Write-Host "✅ Pixel 9 Pro emulator started successfully!" -ForegroundColor Green
    Write-Host "`nThe emulator window should open shortly..." -ForegroundColor Yellow
    Write-Host "Use 'adb devices' to check when it's ready." -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Failed to start emulator: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}