# LAUNCH-AND-RUN-APP.ps1
# Launch emulator and run the app

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = (Get-Item $scriptPath).Parent.Parent.FullName
$apkPath = "$projectRoot\android\app\build\outputs\apk\debug\app-debug.apk"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Launching Routine App" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check if APK exists
if (-not (Test-Path $apkPath)) {
    Write-Host "APK not found! Building first..." -ForegroundColor Yellow
    & powershell.exe -ExecutionPolicy Bypass -File "$scriptPath\BUILD-SIMPLE-UI.ps1"
}

# Start emulator if not running
Write-Host "Starting emulator..." -ForegroundColor Yellow
$emulatorPath = "$env:ANDROID_HOME\emulator\emulator.exe"
$avdName = "Pixel_7_API_34"

# Check if emulator is already running
$emulatorRunning = Get-Process | Where-Object { $_.ProcessName -like "*qemu*" -or $_.ProcessName -like "*emulator*" }

if (-not $emulatorRunning) {
    Write-Host "Starting Android emulator..." -ForegroundColor Yellow
    Start-Process -FilePath $emulatorPath -ArgumentList "-avd", $avdName, "-gpu", "host"
    
    # Wait for emulator to boot
    Write-Host "Waiting for emulator to boot (this may take 1-2 minutes)..." -ForegroundColor Yellow
    $maxWaitTime = 120 # 2 minutes
    $waitedTime = 0
    
    while ($waitedTime -lt $maxWaitTime) {
        Start-Sleep -Seconds 5
        $waitedTime += 5
        
        $devices = & "$env:ANDROID_HOME\platform-tools\adb.exe" devices
        if ($devices -match "emulator-\d+\s+device") {
            Write-Host "Emulator is ready!" -ForegroundColor Green
            break
        }
        Write-Host "Still waiting... ($waitedTime seconds)" -ForegroundColor Gray
    }
} else {
    Write-Host "Emulator is already running!" -ForegroundColor Green
}

# Give it a moment to settle
Start-Sleep -Seconds 2

# Check connected devices
Write-Host "`nChecking connected devices..." -ForegroundColor Yellow
$adb = "$env:ANDROID_HOME\platform-tools\adb.exe"
& $adb devices

# Install APK
if (Test-Path $apkPath) {
    Write-Host "`nInstalling app..." -ForegroundColor Yellow
    $installResult = & $adb install -r $apkPath 2>&1
    
    if ($installResult -match "Success") {
        Write-Host "Installation successful!" -ForegroundColor Green
        
        # Launch the app
        Write-Host "`nLaunching app..." -ForegroundColor Yellow
        & $adb shell am start -n com.squashtrainingapp/.SimpleMainActivity
        
        Write-Host "`n==================================" -ForegroundColor Green
        Write-Host "App launched successfully!" -ForegroundColor Green
        Write-Host "==================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "The app should now be running on the emulator." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "To test the ChatGPT Voice UI:" -ForegroundColor Yellow
        Write-Host "1. Click on 'Coach' (AI 코치)" -ForegroundColor White
        Write-Host "2. Click on 'AI 코치에게 물어보기' button" -ForegroundColor White
        Write-Host "3. The ChatGPT-style voice interface will open" -ForegroundColor White
        Write-Host ""
        
    } else {
        Write-Host "Installation failed!" -ForegroundColor Red
        Write-Host $installResult
    }
} else {
    Write-Host "APK not found at: $apkPath" -ForegroundColor Red
    Write-Host "Please build the app first using BUILD-SIMPLE-UI.ps1"
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")