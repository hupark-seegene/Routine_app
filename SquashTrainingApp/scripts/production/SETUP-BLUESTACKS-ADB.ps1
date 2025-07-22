# SETUP-BLUESTACKS-ADB.ps1
# Script to help setup BlueStacks for ADB connection

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "BlueStacks ADB Setup Guide" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

Write-Host "`nThis script will help you enable ADB in BlueStacks" -ForegroundColor Yellow

Write-Host "`n1. First, make sure BlueStacks is running" -ForegroundColor Yellow
$response = Read-Host "Is BlueStacks running? (y/n)"
if ($response -ne 'y') {
    Write-Host "`nPlease start BlueStacks first, then run this script again" -ForegroundColor Red
    exit
}

Write-Host "`n2. Enable Android Debug Bridge in BlueStacks:" -ForegroundColor Yellow
Write-Host "   a) Click the gear icon (Settings) in BlueStacks" -ForegroundColor White
Write-Host "   b) Go to 'Advanced' or 'Preferences'" -ForegroundColor White
Write-Host "   c) Find 'Android Debug Bridge' or 'ADB'" -ForegroundColor White
Write-Host "   d) Enable/Check the option" -ForegroundColor White
Write-Host "   e) Note the port number (usually 5555)" -ForegroundColor White

Write-Host "`nPress Enter when you've enabled ADB in BlueStacks..."
Read-Host

Write-Host "`n3. Testing connection..." -ForegroundColor Yellow

# Find ADB
$adbPath = $null
if ($env:ANDROID_HOME) {
    $adbPath = "$env:ANDROID_HOME\platform-tools\adb.exe"
}
if (-not $adbPath -or -not (Test-Path $adbPath)) {
    $adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
}

if (-not (Test-Path $adbPath)) {
    Write-Host "ADB not found! Please install Android SDK." -ForegroundColor Red
    exit 1
}

# Kill any existing ADB server
Write-Host "Restarting ADB server..." -ForegroundColor Gray
& $adbPath kill-server 2>$null
Start-Sleep -Seconds 2
& $adbPath start-server

# Try common BlueStacks ports
$ports = @(5555, 5556, 5557, 5037)
$connected = $false

foreach ($port in $ports) {
    Write-Host "`nTrying port $port..." -ForegroundColor Cyan
    $result = & $adbPath connect "localhost:$port" 2>&1
    Write-Host $result -ForegroundColor Gray
    
    Start-Sleep -Seconds 1
    $devices = & $adbPath devices
    
    if ($devices -match "localhost:$port\s+device") {
        Write-Host "✓ Successfully connected on port $port!" -ForegroundColor Green
        $connected = $true
        
        # Show device info
        Write-Host "`nDevice information:" -ForegroundColor Yellow
        $model = & $adbPath -s "localhost:$port" shell getprop ro.product.model 2>$null
        $android = & $adbPath -s "localhost:$port" shell getprop ro.build.version.release 2>$null
        Write-Host "Model: $model" -ForegroundColor White
        Write-Host "Android: $android" -ForegroundColor White
        
        break
    }
}

if (-not $connected) {
    Write-Host "`nCould not connect to BlueStacks!" -ForegroundColor Red
    Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Make sure ADB is enabled in BlueStacks settings" -ForegroundColor White
    Write-Host "2. Try restarting BlueStacks" -ForegroundColor White
    Write-Host "3. Check Windows Firewall isn't blocking the connection" -ForegroundColor White
    Write-Host "4. Try running BlueStacks as Administrator" -ForegroundColor White
} else {
    Write-Host "`n======================================" -ForegroundColor Green
    Write-Host "✓ BlueStacks ADB Setup Complete!" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    
    Write-Host "`nYou can now install APKs using:" -ForegroundColor Yellow
    Write-Host ".\INSTALL-TO-BLUESTACKS.ps1" -ForegroundColor Cyan
}

Write-Host "`nPress Enter to exit..."
Read-Host