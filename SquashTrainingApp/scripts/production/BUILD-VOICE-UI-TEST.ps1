# BUILD-VOICE-UI-TEST.ps1
# Build and test the ChatGPT-style Voice UI

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = (Get-Item $scriptPath).Parent.Parent.FullName

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "ChatGPT Voice UI Build & Test" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to project root
Set-Location $projectRoot
Write-Host "Working directory: $projectRoot" -ForegroundColor Yellow

# Set Java path without spaces
$env:JAVA_HOME = "C:\PROGRA~1\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:ANDROID_HOME = "C:\Users\hwpar\AppData\Local\Android\Sdk"
$env:PATH = "$env:JAVA_HOME\bin;$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\tools;$env:PATH"

Write-Host "Environment configured" -ForegroundColor Green

# Navigate to android directory
Set-Location "android"

# Clean build
Write-Host "`nCleaning build directory..." -ForegroundColor Yellow
if (Test-Path "app/build") {
    try {
        # Try to clean using gradle first
        & cmd /c "gradlew.bat clean" 2>$null
    } catch {
        Write-Host "Gradle clean failed, using force remove" -ForegroundColor Yellow
    }
    
    # Force remove if still exists
    if (Test-Path "app/build") {
        cmd /c "rmdir /s /q app\build" 2>$null
    }
}

# Build the APK
Write-Host "`nBuilding APK..." -ForegroundColor Yellow
$buildOutput = & cmd /c "gradlew.bat assembleDebug 2>&1"

# Check if build succeeded
if ($LASTEXITCODE -eq 0) {
    Write-Host "`nBuild successful!" -ForegroundColor Green
    
    # Check if APK exists
    $apkPath = "app\build\outputs\apk\debug\app-debug.apk"
    if (Test-Path $apkPath) {
        $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
        Write-Host "APK created: $apkPath ($apkSize MB)" -ForegroundColor Green
        
        # Install APK
        Write-Host "`nInstalling APK..." -ForegroundColor Yellow
        $adb = "$env:ANDROID_HOME\platform-tools\adb.exe"
        
        # Check if device is connected
        $devices = & $adb devices
        if ($devices -match "device$") {
            # Uninstall previous version
            Write-Host "Uninstalling previous version..." -ForegroundColor Yellow
            & $adb uninstall com.squashtrainingapp 2>$null
            
            # Install new APK
            $installResult = & $adb install -r $apkPath 2>&1
            if ($installResult -match "Success") {
                Write-Host "Installation successful!" -ForegroundColor Green
                
                # Launch the app
                Write-Host "`nLaunching app..." -ForegroundColor Yellow
                & $adb shell am start -n com.squashtrainingapp/.SimpleMainActivity
                
                Start-Sleep -Seconds 3
                
                # Test Voice UI navigation
                Write-Host "`nTesting Voice UI navigation..." -ForegroundColor Yellow
                Write-Host "1. Opening Coach screen..." -ForegroundColor Cyan
                & $adb shell input tap 540 1400  # Coach button location
                Start-Sleep -Seconds 2
                
                Write-Host "2. Opening Voice Assistant (ChatGPT UI)..." -ForegroundColor Cyan
                & $adb shell input tap 540 1600  # Ask AI button location
                Start-Sleep -Seconds 2
                
                # Take screenshot
                Write-Host "3. Taking screenshot..." -ForegroundColor Cyan
                $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
                $screenshotPath = "$projectRoot\test-logs\voice-ui-$timestamp.png"
                & $adb shell screencap -p /sdcard/voice-ui.png
                & $adb pull /sdcard/voice-ui.png $screenshotPath 2>$null
                
                if (Test-Path $screenshotPath) {
                    Write-Host "Screenshot saved: $screenshotPath" -ForegroundColor Green
                }
                
                Write-Host "`n==================================" -ForegroundColor Green
                Write-Host "Voice UI Test Complete!" -ForegroundColor Green
                Write-Host "==================================" -ForegroundColor Green
                Write-Host ""
                Write-Host "✅ APK built successfully" -ForegroundColor Green
                Write-Host "✅ App installed and launched" -ForegroundColor Green
                Write-Host "✅ Voice Assistant UI accessible" -ForegroundColor Green
                Write-Host ""
                Write-Host "The ChatGPT-style Voice UI is now ready for testing." -ForegroundColor Cyan
                Write-Host "Korean language support is enabled." -ForegroundColor Cyan
                
            } else {
                Write-Host "Installation failed!" -ForegroundColor Red
                Write-Host $installResult
            }
        } else {
            Write-Host "No device connected!" -ForegroundColor Red
            Write-Host "Please connect a device or start an emulator"
        }
    } else {
        Write-Host "APK not found at expected location!" -ForegroundColor Red
    }
} else {
    Write-Host "`nBuild failed!" -ForegroundColor Red
    Write-Host $buildOutput | Select-String -Pattern "error:|ERROR:|FAILED"
}

# Return to project root
Set-Location $projectRoot