# Quick Run Script - Fast execution for Squash Training App
Write-Host "`n=== QUICK RUN - SQUASH TRAINING APP ===" -ForegroundColor Green

# Check if APK exists
$apkPath = "android\app\build\outputs\apk\debug\app-debug.apk"

if (Test-Path $apkPath) {
    Write-Host "Found existing APK, using it..." -ForegroundColor Yellow
    
    # Quick device check
    $adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
    $devices = & $adb devices 2>$null
    
    if ($devices -notmatch "device") {
        Write-Host "No device found, starting emulator..." -ForegroundColor Yellow
        & .\START-EMULATOR.ps1
    }
    
    # Install and run
    Write-Host "Installing app..." -ForegroundColor Yellow
    & $adb install -r $apkPath 2>$null
    
    # Start Metro
    Write-Host "Starting Metro bundler..." -ForegroundColor Yellow
    $metro = Start-Process -FilePath "cmd" -ArgumentList "/c", "npx react-native start" -PassThru -WindowStyle Normal
    Start-Sleep -Seconds 5
    
    # Launch app
    & $adb shell am start -n com.squashtrainingapp/.MainActivity
    
    Write-Host "`n✓ App launched!" -ForegroundColor Green
    Write-Host "If you see red screen, press 'R' twice in Metro window" -ForegroundColor Yellow
    
} else {
    Write-Host "No APK found. Running full build..." -ForegroundColor Yellow
    & .\MCP-FULL-AUTOMATION.ps1
}