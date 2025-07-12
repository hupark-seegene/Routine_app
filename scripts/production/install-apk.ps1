#!/usr/bin/env pwsh
# Quick APK Installation Script
# For when you already have a built APK and just want to install it

param(
    [string]$Device,        # Specific device ID to target
    [switch]$Launch,        # Launch app after installation
    [switch]$Force          # Force reinstall even if app is running
)

$ErrorActionPreference = "Continue"

# Configuration
$env:ANDROID_HOME = "C:\Users\hwpar\AppData\Local\Android\Sdk"
$env:Path = "$env:ANDROID_HOME\platform-tools;$env:Path"

$ADB = "$env:ANDROID_HOME\platform-tools\adb.exe"
$APK_PATH = "app\build\outputs\apk\debug\app-debug.apk"
$PACKAGE_NAME = "com.squashtrainingapp"

# Colors
function Write-Success($msg) { Write-Host "✓ $msg" -ForegroundColor Green }
function Write-Error($msg) { Write-Host "✗ $msg" -ForegroundColor Red }
function Write-Warning($msg) { Write-Host "⚠ $msg" -ForegroundColor Yellow }
function Write-Info($msg) { Write-Host "→ $msg" -ForegroundColor Cyan }

Write-Host "`n🚀 Quick APK Install" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan

# Check for APK
if (-not (Test-Path $APK_PATH)) {
    Write-Error "APK not found at: $APK_PATH"
    Write-Warning "Build the app first using: .\build-and-run.ps1"
    exit 1
}

$apkInfo = Get-Item $APK_PATH
Write-Info "APK: $($apkInfo.Name)"
Write-Info "Size: $([math]::Round($apkInfo.Length / 1MB, 2))MB"
Write-Info "Built: $($apkInfo.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))"

# Get devices
$devices = & $ADB devices 2>&1 | Select-String -Pattern "^(\S+)\s+(device|emulator)$" | ForEach-Object {
    $matches = $_.Matches[0].Groups
    $deviceId = $matches[1].Value
    $model = (& $ADB -s $deviceId shell getprop ro.product.model 2>&1).Trim()
    $manufacturer = (& $ADB -s $deviceId shell getprop ro.product.manufacturer 2>&1).Trim()
    
    [PSCustomObject]@{
        Id = $deviceId
        Name = if ($model -and $manufacturer) { "$manufacturer $model" } else { $deviceId }
        Type = if ($deviceId -match "emulator") { "Emulator" } else { "Device" }
    }
}

if ($devices.Count -eq 0) {
    Write-Error "No devices connected!"
    Write-Info "Connect a device and enable USB debugging"
    exit 1
}

# Select device
$targetDevice = $null
if ($Device) {
    $targetDevice = $devices | Where-Object { $_.Id -eq $Device } | Select-Object -First 1
    if (-not $targetDevice) {
        Write-Error "Device '$Device' not found"
        Write-Info "Available devices:"
        $devices | ForEach-Object { Write-Host "  - $($_.Id) ($($_.Name))" }
        exit 1
    }
} else {
    $targetDevice = $devices[0]
    if ($devices.Count -gt 1) {
        Write-Warning "Multiple devices found, using: $($targetDevice.Name)"
    }
}

Write-Info "Target: $($targetDevice.Name) [$($targetDevice.Id)]"

# Check if app is running
if ($Force) {
    Write-Info "Force stopping app..."
    & $ADB -s $targetDevice.Id shell am force-stop $PACKAGE_NAME 2>&1 | Out-Null
}

# Uninstall old version
Write-Info "Removing old version..."
& $ADB -s $targetDevice.Id uninstall $PACKAGE_NAME 2>&1 | Out-Null

# Install APK
Write-Info "Installing APK..."
$installOutput = & $ADB -s $targetDevice.Id install -r $APK_PATH 2>&1 | Out-String

if ($installOutput -match "Success") {
    Write-Success "Installation successful!"
    
    # Setup port forwarding
    & $ADB -s $targetDevice.Id reverse tcp:8081 tcp:8081 2>&1 | Out-Null
    Write-Success "Port forwarding configured"
    
    # Launch app if requested
    if ($Launch) {
        Write-Info "Launching app..."
        $launchOutput = & $ADB -s $targetDevice.Id shell monkey -p $PACKAGE_NAME -c android.intent.category.LAUNCHER 1 2>&1
        if ($launchOutput -match "Events injected: 1") {
            Write-Success "App launched"
        } else {
            Write-Warning "Could not launch app automatically"
        }
    }
    
    Write-Host "`n✅ Done!" -ForegroundColor Green
    Write-Host "Package: $PACKAGE_NAME" -ForegroundColor Gray
    
} else {
    Write-Error "Installation failed!"
    Write-Host $installOutput
    
    # Common troubleshooting
    if ($installOutput -match "INSTALL_FAILED_VERSION_DOWNGRADE") {
        Write-Warning "Try: .\install-apk.ps1 -Force"
    } elseif ($installOutput -match "INSTALL_FAILED_INSUFFICIENT_STORAGE") {
        Write-Warning "Device is out of storage space"
    } elseif ($installOutput -match "INSTALL_FAILED_TEST_ONLY") {
        Write-Warning "APK is test-only, rebuild in release mode"
    }
    
    exit 1
}