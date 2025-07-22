# INSTALL-TO-BLUESTACKS.ps1
# Script to install APK to BlueStacks Android emulator

$ErrorActionPreference = "Continue"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "BlueStacks APK Installation Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Configuration
$APK_PATH = "..\..\android\app\build\outputs\apk\debug\app-debug.apk"
$PACKAGE_NAME = "com.squashtrainingapp"
$BLUESTACKS_PORT = 5555  # Default BlueStacks ADB port

# Check if APK exists
if (-not (Test-Path $APK_PATH)) {
    Write-Host "APK not found at: $APK_PATH" -ForegroundColor Red
    Write-Host "Please build the app first using BUILD-COMPLETE-APP.ps1" -ForegroundColor Yellow
    exit 1
}

$apkFullPath = (Resolve-Path $APK_PATH).Path
$apkSize = [math]::Round((Get-Item $apkFullPath).Length / 1MB, 2)
Write-Host "Found APK: $apkFullPath ($apkSize MB)" -ForegroundColor Green

# Function to check ADB
function Check-ADB {
    $adbPath = $null
    
    # Try environment variable first
    if ($env:ANDROID_HOME) {
        $adbPath = "$env:ANDROID_HOME\platform-tools\adb.exe"
    }
    
    # Try default location
    if (-not $adbPath -or -not (Test-Path $adbPath)) {
        $adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
    }
    
    # Try in PATH
    if (-not (Test-Path $adbPath)) {
        $adbInPath = Get-Command adb -ErrorAction SilentlyContinue
        if ($adbInPath) {
            $adbPath = $adbInPath.Source
        }
    }
    
    if (-not $adbPath -or -not (Test-Path $adbPath)) {
        Write-Host "ADB not found! Please install Android SDK." -ForegroundColor Red
        exit 1
    }
    
    return $adbPath
}

# Get ADB path
Write-Host "`n1. Checking ADB installation..." -ForegroundColor Yellow
$ADB = Check-ADB
Write-Host "ADB found at: $ADB" -ForegroundColor Green

# Check current devices
Write-Host "`n2. Checking connected devices..." -ForegroundColor Yellow
$devices = & $ADB devices
Write-Host $devices -ForegroundColor Gray

# Connect to BlueStacks
Write-Host "`n3. Connecting to BlueStacks..." -ForegroundColor Yellow
Write-Host "Attempting to connect to localhost:$BLUESTACKS_PORT" -ForegroundColor Cyan

$connectResult = & $ADB connect "localhost:$BLUESTACKS_PORT" 2>&1
Write-Host $connectResult -ForegroundColor Gray

# Wait a moment for connection
Start-Sleep -Seconds 2

# Check if connected
$devices = & $ADB devices
if ($devices -notmatch "localhost:$BLUESTACKS_PORT\s+device") {
    Write-Host "`nBlueStacks not connected!" -ForegroundColor Red
    Write-Host "`nTroubleshooting steps:" -ForegroundColor Yellow
    Write-Host "1. Make sure BlueStacks is running" -ForegroundColor White
    Write-Host "2. Enable Android Debug Bridge in BlueStacks settings:" -ForegroundColor White
    Write-Host "   - Open BlueStacks" -ForegroundColor Gray
    Write-Host "   - Go to Settings (gear icon)" -ForegroundColor Gray
    Write-Host "   - Advanced > Android Debug Bridge > Enable" -ForegroundColor Gray
    Write-Host "3. Try different ports: 5555, 5556, 5557" -ForegroundColor White
    Write-Host "4. Restart BlueStacks and try again" -ForegroundColor White
    
    Write-Host "`nTrying alternative ports..." -ForegroundColor Yellow
    $altPorts = @(5556, 5557, 5037)
    foreach ($port in $altPorts) {
        Write-Host "Trying port $port..." -ForegroundColor Gray
        $result = & $ADB connect "localhost:$port" 2>&1
        Start-Sleep -Seconds 1
        $devices = & $ADB devices
        if ($devices -match "localhost:$port\s+device") {
            Write-Host "Connected on port $port!" -ForegroundColor Green
            $BLUESTACKS_PORT = $port
            break
        }
    }
    
    # Final check
    $devices = & $ADB devices
    if ($devices -notmatch "device") {
        Write-Host "`nFailed to connect to BlueStacks" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n✓ Connected to BlueStacks!" -ForegroundColor Green

# Uninstall existing app
Write-Host "`n4. Checking for existing installation..." -ForegroundColor Yellow
$installedApps = & $ADB -s "localhost:$BLUESTACKS_PORT" shell pm list packages 2>$null
if ($installedApps -match $PACKAGE_NAME) {
    Write-Host "Found existing installation. Uninstalling..." -ForegroundColor Yellow
    & $ADB -s "localhost:$BLUESTACKS_PORT" uninstall $PACKAGE_NAME 2>$null
    Write-Host "Previous version uninstalled" -ForegroundColor Green
} else {
    Write-Host "No existing installation found" -ForegroundColor Gray
}

# Install APK
Write-Host "`n5. Installing APK..." -ForegroundColor Yellow
Write-Host "This may take a moment..." -ForegroundColor Gray

$installResult = & $ADB -s "localhost:$BLUESTACKS_PORT" install -r $apkFullPath 2>&1
if ($installResult -match "Success") {
    Write-Host "✓ APK installed successfully!" -ForegroundColor Green
} else {
    Write-Host "Installation failed!" -ForegroundColor Red
    Write-Host $installResult -ForegroundColor Red
    exit 1
}

# Grant permissions
Write-Host "`n6. Granting permissions..." -ForegroundColor Yellow
$permissions = @(
    "android.permission.RECORD_AUDIO",
    "android.permission.CAMERA",
    "android.permission.WRITE_EXTERNAL_STORAGE",
    "android.permission.READ_EXTERNAL_STORAGE"
)

foreach ($permission in $permissions) {
    Write-Host "Granting $permission..." -ForegroundColor Gray
    & $ADB -s "localhost:$BLUESTACKS_PORT" shell pm grant $PACKAGE_NAME $permission 2>$null
}

# Launch app
Write-Host "`n7. Launching app..." -ForegroundColor Yellow
& $ADB -s "localhost:$BLUESTACKS_PORT" shell monkey -p $PACKAGE_NAME 1

Write-Host "`n======================================" -ForegroundColor Green
Write-Host "✓ Installation Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

Write-Host "`nSquash Training App is now installed on BlueStacks!" -ForegroundColor Cyan
Write-Host "`nNote:" -ForegroundColor Yellow
Write-Host "- Voice features may not work perfectly in BlueStacks" -ForegroundColor White
Write-Host "- For best experience, use a physical device" -ForegroundColor White
Write-Host "- Check BlueStacks microphone settings if needed" -ForegroundColor White

Write-Host "`nTo monitor logs:" -ForegroundColor Yellow
Write-Host "adb -s localhost:$BLUESTACKS_PORT logcat | grep SquashTraining" -ForegroundColor Gray

Write-Host "`nPress Enter to exit..."
Read-Host