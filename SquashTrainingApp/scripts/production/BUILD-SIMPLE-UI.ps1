# BUILD-SIMPLE-UI.ps1
# Simple UI version app build and install script

Write-Host "Squash Training App - Simple UI Build Script" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Move to project root directory
$projectRoot = "C:\Git\Routine_app\SquashTrainingApp"
Set-Location $projectRoot

Write-Host "`nWorking directory: $pwd" -ForegroundColor Yellow

# 1. Clean previous build
Write-Host "`nCleaning previous build files..." -ForegroundColor Yellow
if (Test-Path "android\app\build\outputs\apk\debug\app-debug.apk") {
    Remove-Item "android\app\build\outputs\apk\debug\app-debug.apk" -Force
    Write-Host "Previous APK file deleted" -ForegroundColor Green
}

# Clean Gradle cache
Set-Location "android"
Write-Host "`nCleaning Gradle cache..." -ForegroundColor Yellow
.\gradlew.bat clean
if ($LASTEXITCODE -eq 0) {
    Write-Host "Gradle cache cleaned" -ForegroundColor Green
} else {
    Write-Host "Gradle cache clean failed" -ForegroundColor Red
}

# 2. Build new APK
Write-Host "`nStarting new APK build..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Gray

.\gradlew.bat assembleDebug

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nAPK build successful!" -ForegroundColor Green
    
    # Check APK file path
    $apkPath = "app\build\outputs\apk\debug\app-debug.apk"
    if (Test-Path $apkPath) {
        $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
        Write-Host "APK file size: ${apkSize}MB" -ForegroundColor Cyan
        Write-Host "APK path: $pwd\$apkPath" -ForegroundColor Cyan
        
        # 3. Check connected devices
        Write-Host "`nChecking connected devices..." -ForegroundColor Yellow
        $devices = adb devices | Select-String -Pattern "device$" | Where-Object { $_ -notmatch "List of devices" }
        
        if ($devices) {
            Write-Host "Connected devices found:" -ForegroundColor Green
            $devices | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
            
            # 4. Remove previous version
            Write-Host "`nRemoving previous version..." -ForegroundColor Yellow
            adb uninstall com.squashtrainingapp 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Previous version removed" -ForegroundColor Green
            } else {
                Write-Host "No previous version installed" -ForegroundColor Gray
            }
            
            # 5. Install new version
            Write-Host "`nInstalling new version..." -ForegroundColor Yellow
            adb install -r $apkPath
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "`nApp installation successful!" -ForegroundColor Green
                
                # 6. Launch app
                Write-Host "`nLaunching app..." -ForegroundColor Yellow
                adb shell am start -n com.squashtrainingapp/.SimpleMainActivity
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "App launched successfully!" -ForegroundColor Green
                    Write-Host "`nSimple UI version is running." -ForegroundColor Cyan
                    Write-Host "Check the 6 card buttons on the home screen!" -ForegroundColor Cyan
                } else {
                    Write-Host "App launch failed" -ForegroundColor Red
                }
            } else {
                Write-Host "App installation failed" -ForegroundColor Red
            }
        } else {
            Write-Host "No connected devices found!" -ForegroundColor Red
            Write-Host "`nPlease connect a device using:" -ForegroundColor Yellow
            Write-Host "1. Run Android emulator" -ForegroundColor Gray
            Write-Host "2. Connect real device with USB debugging enabled" -ForegroundColor Gray
            
            # APK file location info
            Write-Host "`nAPK file created at:" -ForegroundColor Cyan
            Write-Host "$pwd\$apkPath" -ForegroundColor White
            Write-Host "`nTransfer this file to your device for manual installation." -ForegroundColor Gray
        }
    } else {
        Write-Host "APK file not found!" -ForegroundColor Red
    }
} else {
    Write-Host "`nAPK build failed!" -ForegroundColor Red
    Write-Host "Please check the error messages above." -ForegroundColor Yellow
}

# Return to project root
Set-Location $projectRoot

Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "Build process completed" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan