# Quick Build and Install Script
$ErrorActionPreference = "Stop"

Write-Host "`n=== Quick Build & Install ===" -ForegroundColor Cyan
Write-Host "Building and installing SquashTrainingApp..." -ForegroundColor Yellow

# Navigate to project
cd "$PSScriptRoot/../.."

# Clean previous build
Write-Host "`nCleaning previous build..." -ForegroundColor Yellow
if (Test-Path "android/app/build") {
    Remove-Item -Recurse -Force "android/app/build"
}

# Build
Write-Host "`nBuilding APK..." -ForegroundColor Green
cd android
cmd /c "gradlew.bat assembleDebug"

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nBuild failed!" -ForegroundColor Red
    exit 1
}

# Check for APK
$apkPath = "app/build/outputs/apk/debug/app-debug.apk"
if (!(Test-Path $apkPath)) {
    Write-Host "`nAPK not found!" -ForegroundColor Red
    exit 1
}

Write-Host "`nAPK built successfully!" -ForegroundColor Green

# Install
Write-Host "`nChecking for devices..." -ForegroundColor Yellow
$devices = adb devices | Select-String -Pattern "device$" | Where-Object { $_ -notmatch "List of devices" }

if ($devices.Count -eq 0) {
    Write-Host "`nNo devices connected. Please connect a device or start an emulator." -ForegroundColor Red
    
    # Try to start emulator
    Write-Host "`nAttempting to start emulator..." -ForegroundColor Yellow
    $emulators = emulator -list-avds
    if ($emulators) {
        $firstEmulator = ($emulators -split "`n")[0].Trim()
        Write-Host "Starting emulator: $firstEmulator" -ForegroundColor Cyan
        Start-Process -FilePath "emulator" -ArgumentList "-avd", $firstEmulator -WindowStyle Hidden
        
        Write-Host "Waiting for emulator to boot (30 seconds)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30
        
        # Wait for device
        Write-Host "Waiting for device to be ready..." -ForegroundColor Yellow
        adb wait-for-device
    } else {
        Write-Host "No emulators found. Please create one in Android Studio." -ForegroundColor Red
        exit 1
    }
}

# Uninstall old version
Write-Host "`nUninstalling old version..." -ForegroundColor Yellow
adb uninstall com.squashtrainingapp 2>$null

# Install new version
Write-Host "`nInstalling new version..." -ForegroundColor Green
adb install -r $apkPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nInstallation successful!" -ForegroundColor Green
    
    # Launch app
    Write-Host "`nLaunching app..." -ForegroundColor Cyan
    adb shell am start -n com.squashtrainingapp/.MainActivity
    
    Write-Host "`n=== App launched successfully! ===" -ForegroundColor Green
} else {
    Write-Host "`nInstallation failed!" -ForegroundColor Red
    exit 1
}