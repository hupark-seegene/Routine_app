# INSTALL-AND-RUN.ps1
# Simple script to build, install and run the mascot app on emulator

[CmdletBinding()]
param()

# Configuration
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent (Split-Path -Parent $SCRIPT_DIR)
$ANDROID_DIR = Join-Path $ROOT_DIR "SquashTrainingApp\android"
$ADB = "C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$EMULATOR = "C:\Users\hwpar\AppData\Local\Android\Sdk\emulator\emulator.exe"
$AVD_NAME = "Pixel_6"

Write-Host "=== SQUASH TRAINING MASCOT APP INSTALLER ===" -ForegroundColor Cyan
Write-Host "Building and installing the app..." -ForegroundColor Yellow

# Check emulator status
function Test-EmulatorStatus {
    try {
        $devices = & $ADB devices 2>&1
        if ($devices -match "emulator.*device$") {
            return $true
        }
        return $false
    }
    catch {
        return $false
    }
}

# Start emulator if needed
if (-not (Test-EmulatorStatus)) {
    Write-Host "Starting emulator..." -ForegroundColor Yellow
    Start-Process -FilePath $EMULATOR -ArgumentList "-avd", $AVD_NAME -NoNewWindow
    
    # Wait for emulator
    $maxWait = 60
    $waited = 0
    while (-not (Test-EmulatorStatus) -and $waited -lt $maxWait) {
        Start-Sleep -Seconds 5
        $waited += 5
        Write-Host "Waiting for emulator... ($waited seconds)" -ForegroundColor Gray
    }
    
    if (Test-EmulatorStatus) {
        Write-Host "Emulator started successfully!" -ForegroundColor Green
        Start-Sleep -Seconds 10
    } else {
        Write-Host "Failed to start emulator!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Emulator already running!" -ForegroundColor Green
}

# Clean and build
Set-Location $ANDROID_DIR
Write-Host "`nCleaning previous build..." -ForegroundColor Yellow
& .\gradlew.bat clean 2>&1 | Out-Null

Write-Host "Building APK..." -ForegroundColor Yellow
$buildOutput = & .\gradlew.bat assembleDebug 2>&1

if ($LASTEXITCODE -eq 0) {
    $apkPath = Join-Path $ANDROID_DIR "app\build\outputs\apk\debug\app-debug.apk"
    if (Test-Path $apkPath) {
        $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
        Write-Host "Build successful! APK size: ${apkSize}MB" -ForegroundColor Green
        
        # Uninstall previous version
        Write-Host "`nUninstalling previous version..." -ForegroundColor Yellow
        & $ADB uninstall com.squashtrainingapp 2>&1 | Out-Null
        
        # Install new APK
        Write-Host "Installing APK..." -ForegroundColor Yellow
        $installResult = & $ADB install $apkPath 2>&1
        
        if ($installResult -match "Success") {
            Write-Host "APK installed successfully!" -ForegroundColor Green
            
            # Launch app
            Write-Host "`nLaunching app..." -ForegroundColor Yellow
            & $ADB shell am start -n com.squashtrainingapp/.MainActivity
            
            Write-Host "`nApp launched! Features:" -ForegroundColor Green
            Write-Host "- Drag the mascot to navigate between zones" -ForegroundColor Cyan
            Write-Host "- Long press (2 seconds) on mascot for voice commands" -ForegroundColor Cyan
            Write-Host "- Tap the mascot for a fun animation" -ForegroundColor Cyan
            Write-Host "`nEnjoy your interactive squash training!" -ForegroundColor Green
        } else {
            Write-Host "Installation failed!" -ForegroundColor Red
            Write-Host $installResult
        }
    } else {
        Write-Host "APK not found at expected location!" -ForegroundColor Red
    }
} else {
    Write-Host "Build failed!" -ForegroundColor Red
    Write-Host $buildOutput | Select-Object -Last 20
}

Set-Location $SCRIPT_DIR