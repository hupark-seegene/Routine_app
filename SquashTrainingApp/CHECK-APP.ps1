# Check App Status
Write-Host "`n=== CHECKING APP STATUS ===" -ForegroundColor Cyan

# Check if device is connected
$devices = adb devices 2>$null
Write-Host "`nConnected devices:" -ForegroundColor Yellow
Write-Host $devices

# Check if app is installed
Write-Host "`nChecking if app is installed..." -ForegroundColor Yellow
$packages = adb shell pm list packages | Select-String "squashtrainingapp"
if ($packages) {
    Write-Host "✓ App is installed" -ForegroundColor Green
} else {
    Write-Host "✗ App is not installed" -ForegroundColor Red
}

# Check if app is running
Write-Host "`nChecking if app is running..." -ForegroundColor Yellow
$processes = adb shell ps | Select-String "squashtrainingapp"
if ($processes) {
    Write-Host "✓ App is running" -ForegroundColor Green
    Write-Host $processes
} else {
    Write-Host "✗ App is not running" -ForegroundColor Red
}

# Check Metro bundler
Write-Host "`nChecking Metro bundler..." -ForegroundColor Yellow
$metro = Get-Process -Name node -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -match "react-native" }
if ($metro) {
    Write-Host "✓ Metro bundler is running" -ForegroundColor Green
} else {
    Write-Host "✗ Metro bundler is not running" -ForegroundColor Red
}

# Show recent logs
Write-Host "`nRecent app logs:" -ForegroundColor Yellow
adb logcat -d -t 20 ReactNative:V ReactNativeJS:V *:S

Write-Host "`n=== QUICK ACTIONS ===" -ForegroundColor Cyan
Write-Host "1. To reload app: Press 'R' twice in Metro window" -ForegroundColor White
Write-Host "2. To restart app: adb shell am start -n com.squashtrainingapp/.MainActivity" -ForegroundColor White
Write-Host "3. To view live logs: adb logcat ReactNative:V ReactNativeJS:V *:S" -ForegroundColor White
Write-Host "4. To run complete app: .\FINAL-RUN.ps1" -ForegroundColor White