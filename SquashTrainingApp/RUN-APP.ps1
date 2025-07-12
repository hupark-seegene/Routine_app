# Run App - Simplest Working Solution
$ErrorActionPreference = "Continue"

Write-Host "`n=== RUNNING SQUASH TRAINING APP ===" -ForegroundColor Green

# Environment
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:LOCALAPPDATA\Android\Sdk\platform-tools;$env:Path"

# Use the last successfully built APK
$apkPath = "android\app\build\outputs\apk\debug\app-debug.apk"

if (Test-Path $apkPath) {
    Write-Host "Found existing APK, installing..." -ForegroundColor Yellow
    
    # Check device
    $devices = adb devices 2>$null
    if ($devices -notmatch "device") {
        Write-Host "Starting emulator..." -ForegroundColor Yellow
        & .\START-EMULATOR.ps1
        Start-Sleep -Seconds 5
    }
    
    # Setup ports
    adb reverse tcp:8081 tcp:8081 2>$null
    adb reverse tcp:8088 tcp:8088 2>$null
    
    # Install and run
    Write-Host "Installing app..." -ForegroundColor Yellow
    adb uninstall com.squashtrainingapp 2>$null | Out-Null
    adb install -r $apkPath
    
    # Create proper JS bundle
    Write-Host "Creating JavaScript bundle..." -ForegroundColor Yellow
    $assetsDir = "android\app\src\main\assets"
    if (-not (Test-Path $assetsDir)) {
        New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
    }
    
    # Start Metro in background
    Write-Host "Starting Metro bundler..." -ForegroundColor Yellow
    $metro = Start-Process -FilePath "cmd" -ArgumentList "/c", "cd /d $PWD && npx react-native start --reset-cache" -PassThru -WindowStyle Minimized
    Write-Host "Metro started (PID: $($metro.Id))" -ForegroundColor Gray
    Start-Sleep -Seconds 8
    
    # Launch app
    Write-Host "Launching app..." -ForegroundColor Yellow
    adb shell am start -n com.squashtrainingapp/.MainActivity
    
    Write-Host "`n=== APP RUNNING ===" -ForegroundColor Green
    Write-Host "`nIf you see a red error screen:" -ForegroundColor Yellow
    Write-Host "1. Press 'R' twice to reload" -ForegroundColor White
    Write-Host "2. Or shake device and select 'Reload'" -ForegroundColor White
    Write-Host "`nMetro bundler is running in background" -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop`n" -ForegroundColor Gray
    
    # Stream logs
    adb logcat -c
    adb logcat ReactNative:V ReactNativeJS:V Bundle:V *:S
    
    # Cleanup
    if ($metro -and !$metro.HasExited) {
        Stop-Process -Id $metro.Id -Force
    }
} else {
    Write-Host "No APK found!" -ForegroundColor Red
    Write-Host "`nTrying to build with existing backup..." -ForegroundColor Yellow
    
    # Restore backup build.gradle if exists
    Push-Location android
    if (Test-Path "app\build.gradle.backup") {
        Copy-Item "app\build.gradle.backup" "app\build.gradle.original" -Force
        
        # Create working build.gradle without Kotlin
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
}

dependencies {
    implementation 'com.facebook.react:react-android:0.80.1'
    implementation 'com.facebook.react:hermes-android:0.80.1'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    
    // Temporarily remove Kotlin dependency
    // implementation "org.jetbrains.kotlin:kotlin-stdlib:1.9.24"
}
'@ | Out-File -Encoding ASCII "app\build.gradle"
        
        # Simple settings.gradle
        @'
rootProject.name = 'SquashTrainingApp'
include ':app'
'@ | Out-File -Encoding ASCII "settings.gradle"
        
        # Convert MainApplication.kt to Java
        Write-Host "Converting Kotlin to Java..." -ForegroundColor Yellow
        $javaContent = @'
package com.squashtrainingapp;

import android.app.Application;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.PackageList;
import com.facebook.react.defaults.DefaultReactNativeHost;

import java.util.List;

public class MainApplication extends Application implements ReactApplication {

    private final ReactNativeHost mReactNativeHost = new DefaultReactNativeHost(this) {
        @Override
        public boolean getUseDeveloperSupport() {
            return BuildConfig.DEBUG;
        }

        @Override
        protected List<ReactPackage> getPackages() {
            return new PackageList(this).getPackages();
        }

        @Override
        protected String getJSMainModuleName() {
            return "index";
        }
    };

    @Override
    public ReactNativeHost getReactNativeHost() {
        return mReactNativeHost;
    }

    @Override
    public void onCreate() {
        super.onCreate();
    }
}
'@
        $javaContent | Out-File -Encoding ASCII "app\src\main\java\com\squashtrainingapp\MainApplication.java"
        
        # Move Kotlin file temporarily
        if (Test-Path "app\src\main\java\com\squashtrainingapp\MainApplication.kt") {
            Move-Item "app\src\main\java\com\squashtrainingapp\MainApplication.kt" "app\src\main\java\com\squashtrainingapp\MainApplication.kt.bak" -Force
        }
        
        # Build
        Write-Host "Building APK..." -ForegroundColor Yellow
        .\gradlew.bat clean assembleDebug --no-daemon
        
        Pop-Location
        
        # Run this script again
        & $PSCommandPath
    }
}