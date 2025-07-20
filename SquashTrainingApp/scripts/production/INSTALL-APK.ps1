# INSTALL-APK.ps1
# Install and launch the premium UI APK
# Created: 2025-07-20

# Set ADB path
$adbPath = "C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools\adb.exe"
if (-not (Test-Path $adbPath)) {
    Write-Host "ADB not found at: $adbPath" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== APK INSTALLATION SCRIPT ===" -ForegroundColor Cyan
Write-Host "Waiting for emulator to be ready..." -ForegroundColor Yellow

# Wait for emulator
$maxWait = 60
$waited = 0
while ($waited -lt $maxWait) {
    $devices = & $adbPath devices | Select-String "emulator"
    if ($devices) {
        Write-Host "`nEmulator detected!" -ForegroundColor Green
        break
    }
    Write-Host "." -NoNewline
    Start-Sleep -Seconds 2
    $waited += 2
}

if ($waited -ge $maxWait) {
    Write-Host "`nTimeout: No emulator detected after 60 seconds" -ForegroundColor Red
    Write-Host "Please start the emulator manually and run this script again" -ForegroundColor Yellow
    exit 1
}

# Wait for boot completion
Write-Host "`nWaiting for emulator to boot completely..." -ForegroundColor Yellow
& $adbPath wait-for-device
& $adbPath shell getprop sys.boot_completed | Out-Null

# Install APK
$apkPath = "C:\Git\Routine_app\SquashTrainingApp\android\app\build\outputs\apk\debug\app-debug.apk"
if (Test-Path $apkPath) {
    Write-Host "`nUninstalling previous version..." -ForegroundColor Yellow
    & $adbPath uninstall com.squashtrainingapp 2>$null
    
    Write-Host "Installing premium UI APK..." -ForegroundColor Yellow
    & $adbPath install -r $apkPath
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✓ APK installed successfully!" -ForegroundColor Green
        
        Write-Host "Launching app..." -ForegroundColor Yellow
        & $adbPath shell am start -n com.squashtrainingapp/.MainActivity
        
        Write-Host "`n✓ App launched!" -ForegroundColor Green
        Write-Host "`nEnjoy the premium UI experience! 🎨" -ForegroundColor Cyan
    } else {
        Write-Host "`n✗ Installation failed" -ForegroundColor Red
    }
} else {
    Write-Host "`n✗ APK not found at: $apkPath" -ForegroundColor Red
}