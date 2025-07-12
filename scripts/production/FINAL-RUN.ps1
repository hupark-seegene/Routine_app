# Final Run Script - Get App Running Now
$ErrorActionPreference = "Continue"

Write-Host "`n=== FINAL RUN - SQUASH TRAINING APP ===" -ForegroundColor Green

# Environment
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:LOCALAPPDATA\Android\Sdk\platform-tools;$env:Path"

# Clean up old Kotlin file if exists
if (Test-Path "android\app\src\main\java\com\squashtrainingapp\MainApplication.kt") {
    Move-Item "android\app\src\main\java\com\squashtrainingapp\MainApplication.kt" "android\app\src\main\java\com\squashtrainingapp\MainApplication.kt.old" -Force
}

# Ensure we have the right build files
Push-Location android

# Minimal settings.gradle
@'
rootProject.name = 'SquashTrainingApp'
include ':app'
'@ | Out-File -Encoding ASCII "settings.gradle"

# Minimal build.gradle with buildConfig
@'
apply plugin: "com.android.application"

android {
    compileSdkVersion 34
    buildToolsVersion "34.0.0"
    namespace "com.squashtrainingapp"
    
    defaultConfig {
        applicationId "com.squashtrainingapp"
        minSdkVersion 24
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
    }
    
    signingConfigs {
        debug {
            storeFile file('debug.keystore')
            storePassword 'android'
            keyAlias 'androiddebugkey'
            keyPassword 'android'
        }
    }
    
    buildTypes {
        debug {
            signingConfig signingConfigs.debug
        }
    }
    
    buildFeatures {
        buildConfig true
    }
}

dependencies {
    implementation 'com.facebook.react:react-android:0.80.1'
    implementation 'com.facebook.react:hermes-android:0.80.1'
    implementation 'androidx.appcompat:appcompat:1.6.1'
}
'@ | Out-File -Encoding ASCII "app\build.gradle"

# Build
Write-Host "`nBuilding APK..." -ForegroundColor Yellow
$buildOutput = .\gradlew.bat clean assembleDebug --no-daemon 2>&1
$buildSuccess = $LASTEXITCODE -eq 0

Pop-Location

if ($buildSuccess -and (Test-Path "android\app\build\outputs\apk\debug\app-debug.apk")) {
    Write-Host "Build successful!" -ForegroundColor Green
    
    # Check device
    $devices = adb devices 2>$null
    if ($devices -notmatch "device") {
        Write-Host "Starting emulator..." -ForegroundColor Yellow
        & .\START-EMULATOR.ps1
        Start-Sleep -Seconds 5
    }
    
    # Install
    Write-Host "Installing app..." -ForegroundColor Yellow
    adb uninstall com.squashtrainingapp 2>$null | Out-Null
    adb install -r android\app\build\outputs\apk\debug\app-debug.apk
    
    # Setup Metro
    Write-Host "Starting Metro bundler..." -ForegroundColor Yellow
    adb reverse tcp:8081 tcp:8081 2>$null
    $metro = Start-Process -FilePath "cmd" -ArgumentList "/c", "npx react-native start --reset-cache" -PassThru -WindowStyle Normal
    Start-Sleep -Seconds 10
    
    # Launch
    Write-Host "Launching app..." -ForegroundColor Yellow
    adb shell am start -n com.squashtrainingapp/.MainActivity
    
    Write-Host "`n=== SUCCESS ===" -ForegroundColor Green
    Write-Host "App should be running now!" -ForegroundColor Green
    Write-Host "`nIf you see a red screen:" -ForegroundColor Yellow
    Write-Host "- Press 'R' twice in Metro window to reload" -ForegroundColor White
    Write-Host "- Or shake device and tap 'Reload'" -ForegroundColor White
    Write-Host "`nMetro bundler is running in the window" -ForegroundColor Cyan
    
    # Keep script running
    Write-Host "`nPress any key to stop..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    # Cleanup
    if ($metro -and !$metro.HasExited) {
        Stop-Process -Id $metro.Id -Force
    }
} else {
    Write-Host "Build failed!" -ForegroundColor Red
    Write-Host "`nTrying Android Studio approach instead..." -ForegroundColor Yellow
    Write-Host "`n1. Open Android Studio" -ForegroundColor Cyan
    Write-Host "2. Open the 'android' folder" -ForegroundColor Cyan
    Write-Host "3. Wait for sync to complete" -ForegroundColor Cyan
    Write-Host "4. Click the green Run button" -ForegroundColor Cyan
}