# Quick Install Script - Install existing APK
Write-Host "`n=== QUICK INSTALL - SQUASH TRAINING APP ===" -ForegroundColor Green

# Set up ADB path
$adb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"

# Check device
Write-Host "Checking device..." -ForegroundColor Yellow
$devices = & $adb devices 2>$null
if ($devices -notmatch "device") {
    Write-Host "No device found! Please start emulator first." -ForegroundColor Red
    exit 1
}

# Install APK
$apkPath = Join-Path $PSScriptRoot "android\app\build\outputs\apk\debug\app-debug.apk"
if (Test-Path $apkPath) {
    Write-Host "Installing APK..." -ForegroundColor Yellow
    & $adb uninstall com.squashtrainingapp 2>$null | Out-Null
    & $adb install -r $apkPath
    
    # Set up port forwarding
    & $adb reverse tcp:8081 tcp:8081 2>$null
    
    # Start Metro in background
    Write-Host "`nStarting Metro bundler..." -ForegroundColor Yellow
    $metro = Start-Process -FilePath "cmd" -ArgumentList "/c", "cd /d `"$PSScriptRoot`" && npx react-native start" -PassThru -WindowStyle Normal
    Start-Sleep -Seconds 5
    
    # Launch app
    Write-Host "Launching app..." -ForegroundColor Yellow
    & $adb shell am start -n com.squashtrainingapp/.MainActivity
    
    Write-Host "`n✓ App launched!" -ForegroundColor Green
    Write-Host "If you see red screen, press 'R' twice in Metro window" -ForegroundColor Yellow
    Write-Host "`nPress any key to stop Metro..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    # Stop Metro
    if ($metro -and !$metro.HasExited) {
        Stop-Process -Id $metro.Id -Force
    }
} else {
    Write-Host "APK not found at: $apkPath" -ForegroundColor Red
    Write-Host "Please build first with: .\build-simple.ps1" -ForegroundColor Yellow
}