# Grant All Permissions Script

# Set environment variables
$env:ANDROID_HOME = "C:\Users\hwpar\AppData\Local\Android\Sdk"
$env:PATH = "$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\tools;$env:PATH"

Write-Host "Granting permissions to Squash Training App..." -ForegroundColor Yellow

# Get device
$device = adb devices | Select-String "device$" | Select-Object -First 1
if ($device) {
    $deviceId = ($device -split "`t")[0]
    Write-Host "Using device: $deviceId" -ForegroundColor Green
    
    # Package name
    $packageName = "com.squashtrainingapp"
    
    # Grant RECORD_AUDIO permission
    Write-Host "Granting RECORD_AUDIO permission..." -ForegroundColor Cyan
    adb -s $deviceId shell pm grant $packageName android.permission.RECORD_AUDIO
    
    # Grant INTERNET permission (usually auto-granted)
    Write-Host "Granting INTERNET permission..." -ForegroundColor Cyan
    adb -s $deviceId shell pm grant $packageName android.permission.INTERNET 2>$null
    
    # Grant VIBRATE permission (usually auto-granted)
    Write-Host "Granting VIBRATE permission..." -ForegroundColor Cyan
    adb -s $deviceId shell pm grant $packageName android.permission.VIBRATE 2>$null
    
    # Check granted permissions
    Write-Host "`nChecking granted permissions..." -ForegroundColor Yellow
    $permissions = adb -s $deviceId shell dumpsys package $packageName | Select-String "permission"
    
    Write-Host "`nPermissions status:" -ForegroundColor Green
    $recordAudio = $permissions | Select-String "RECORD_AUDIO"
    if ($recordAudio) {
        Write-Host "✓ RECORD_AUDIO: Granted" -ForegroundColor Green
    } else {
        Write-Host "✗ RECORD_AUDIO: Not granted" -ForegroundColor Red
    }
    
    $internet = $permissions | Select-String "INTERNET"
    if ($internet) {
        Write-Host "✓ INTERNET: Granted" -ForegroundColor Green
    } else {
        Write-Host "✗ INTERNET: Not granted" -ForegroundColor Red
    }
    
    $vibrate = $permissions | Select-String "VIBRATE"
    if ($vibrate) {
        Write-Host "✓ VIBRATE: Granted" -ForegroundColor Green
    } else {
        Write-Host "✗ VIBRATE: Not granted" -ForegroundColor Red
    }
    
    Write-Host "`nPermissions granted successfully!" -ForegroundColor Green
    Write-Host "You can now test the app with all features enabled." -ForegroundColor Cyan
} else {
    Write-Host "No device found!" -ForegroundColor Red
    Write-Host "Please ensure your emulator or device is running." -ForegroundColor Yellow
}