# Install and Run Script
Write-Host "Installing and running Squash Training App..." -ForegroundColor Cyan

$adb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
$apkPath = Join-Path $PSScriptRoot "android\app\build\outputs\apk\debug\app-debug.apk"

# Check device
$devices = & $adb devices 2>$null
if ($devices -notmatch "device") {
    Write-Host "No device found! Please start emulator." -ForegroundColor Red
    exit 1
}

# Uninstall old version
Write-Host "Uninstalling old version..." -ForegroundColor Yellow
& $adb uninstall com.squashtrainingapp 2>$null | Out-Null

# Install new APK
Write-Host "Installing new APK..." -ForegroundColor Yellow
$installResult = & $adb install -r $apkPath 2>&1

if ($installResult -match "Success") {
    Write-Host "✓ App installed successfully!" -ForegroundColor Green
} else {
    Write-Host "✗ Installation failed!" -ForegroundColor Red
    Write-Host $installResult
    exit 1
}

# Set up port forwarding
& $adb reverse tcp:8081 tcp:8081 2>$null

# Create a basic JS bundle in assets
$assetsDir = Join-Path $PSScriptRoot "android\app\src\main\assets"
$bundlePath = Join-Path $assetsDir "index.android.bundle"

if (-not (Test-Path $bundlePath) -or (Get-Item $bundlePath).Length -lt 1000) {
    Write-Host "Creating JavaScript bundle..." -ForegroundColor Yellow
    
    # Use npx to create bundle
    $bundleCmd = "npx react-native bundle --platform android --dev true --entry-file index.js --bundle-output `"$bundlePath`" --assets-dest `"$($PSScriptRoot)\android\app\src\main\res`""
    
    Write-Host "Running: $bundleCmd" -ForegroundColor Gray
    cmd /c $bundleCmd 2>&1 | Out-Null
    
    if (Test-Path $bundlePath) {
        $size = [math]::Round((Get-Item $bundlePath).Length / 1KB, 0)
        Write-Host "✓ Bundle created (${size}KB)" -ForegroundColor Green
    }
}

# Start Metro bundler
Write-Host "Starting Metro bundler..." -ForegroundColor Yellow
$metro = Start-Process -FilePath "cmd" -ArgumentList "/c", "cd /d `"$PSScriptRoot`" && npx react-native start --reset-cache" -PassThru -WindowStyle Normal
Start-Sleep -Seconds 5

# Launch app
Write-Host "Launching app..." -ForegroundColor Yellow
& $adb shell am start -n com.squashtrainingapp/.MainActivity

Write-Host "`n✓ App launched!" -ForegroundColor Green
Write-Host "`nThe app should now be running on your device." -ForegroundColor Cyan
Write-Host "If you see a red screen, press 'R' twice in the Metro window." -ForegroundColor Yellow

# Monitor for initial crash
Write-Host "`nMonitoring for crashes..." -ForegroundColor Gray
& $adb logcat -c
Start-Sleep -Seconds 3

$logs = & $adb logcat -d -t 200 2>$null
if ($logs -match "AndroidRuntime.*FATAL.*MainActivity") {
    Write-Host "`n✗ App crashed on launch!" -ForegroundColor Red
    Write-Host "The app needs the JavaScript bundle to be properly loaded." -ForegroundColor Yellow
} else {
    Write-Host "`n✓ App is running!" -ForegroundColor Green
}

Write-Host "`nPress any key to stop Metro bundler..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Stop Metro
if ($metro -and !$metro.HasExited) {
    Stop-Process -Id $metro.Id -Force
}

Write-Host "`nDone!" -ForegroundColor Green