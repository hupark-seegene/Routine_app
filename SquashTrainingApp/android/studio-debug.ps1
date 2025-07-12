# Android Studio Debug Helper Script
param(
    [switch]$NoMetro = $false
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Android Studio Debug Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Kill existing Metro
Write-Host "[1/5] Stopping existing Metro processes..." -ForegroundColor Yellow
taskkill /F /IM node.exe 2>$null

# Check emulator
Write-Host "[2/5] Checking for running emulators..." -ForegroundColor Yellow
$devices = & adb devices
Write-Host $devices

if ($devices -notmatch "emulator") {
    Write-Host "No emulator found. Please start Pixel 6 from Android Studio!" -ForegroundColor Red
    Write-Host "Device Manager → Pixel 6 → Launch" -ForegroundColor Yellow
    exit
}

# Create JS bundle (backup)
Write-Host "[3/5] Creating JS bundle..." -ForegroundColor Yellow
Push-Location ..
npx react-native bundle `
    --platform android `
    --dev true `
    --entry-file index.js `
    --bundle-output android/app/src/main/assets/index.android.bundle `
    --assets-dest android/app/src/main/res 2>$null
Pop-Location

# Setup port forwarding
Write-Host "[4/5] Setting up port forwarding..." -ForegroundColor Yellow
adb reverse tcp:8081 tcp:8081
adb reverse tcp:8088 tcp:8088

if (-not $NoMetro) {
    # Start Metro in new window
    Write-Host "[5/5] Starting Metro bundler..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\..' ; npx react-native start --reset-cache"
    
    Write-Host ""
    Write-Host "✅ Setup complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Now in Android Studio:" -ForegroundColor Cyan
    Write-Host "1. Click the Debug button (🐛)" -ForegroundColor White
    Write-Host "2. Select 'Pixel 6 API 34'" -ForegroundColor White
    Write-Host "3. Wait for app to launch" -ForegroundColor White
    Write-Host ""
    Write-Host "Developer Menu: Ctrl+M in emulator" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "✅ Setup complete (No Metro mode)" -ForegroundColor Green
    Write-Host "Using pre-bundled JavaScript" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Gray
Write-Host "  adb logcat *:S ReactNative:V ReactNativeJS:V" -ForegroundColor Gray
Write-Host "  adb shell am force-stop com.squashtrainingapp" -ForegroundColor Gray
Write-Host "  adb shell am start -n com.squashtrainingapp/.MainActivity" -ForegroundColor Gray