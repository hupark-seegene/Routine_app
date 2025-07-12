# Simple Build Script - Bypass Native Module Issues
# This script builds with minimal native modules to get a working APK

param(
    [switch]$Install = $false,
    [switch]$Run = $false
)

$ErrorActionPreference = "Continue"

Write-Host "`n=== SIMPLE BUILD - BYPASS MODE ===" -ForegroundColor Green

# Environment
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:LOCALAPPDATA\Android\Sdk\platform-tools;$env:Path"

# Navigate to android directory
Push-Location android

# Create minimal settings.gradle (only vector icons)
@'
rootProject.name = 'SquashTrainingApp'
include ':app'

// Only include stable modules
include ':react-native-vector-icons'
project(':react-native-vector-icons').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-vector-icons/android')
'@ | Out-File -Encoding ASCII "settings.gradle"

# Create app/build.gradle without problematic modules
@'
apply plugin: "com.android.application"
apply plugin: "kotlin-android"

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
        multiDexEnabled true
        
        // BuildConfig fields
        buildConfigField "boolean", "IS_NEW_ARCHITECTURE_ENABLED", "false"
        buildConfigField "boolean", "IS_HERMES_ENABLED", "true"
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
    
    packagingOptions {
        pickFirst '**/libc++_shared.so'
        pickFirst '**/libjsc.so'
        pickFirst '**/libhermes.so'
    }
}

dependencies {
    implementation 'com.facebook.react:react-android:0.80.1'
    implementation 'com.facebook.react:hermes-android:0.80.1'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'androidx.swiperefreshlayout:swiperefreshlayout:1.1.0'
    implementation 'androidx.multidex:multidex:2.0.1'
    implementation "org.jetbrains.kotlin:kotlin-stdlib:1.9.24"
    
    // Only stable native module
    implementation project(':react-native-vector-icons')
}

// Copy fonts for vector icons
task copyFonts(type: Copy) {
    from "../node_modules/react-native-vector-icons/Fonts"
    into "src/main/assets/fonts"
}

preBuild.dependsOn copyFonts
'@ | Out-File -Encoding ASCII "app\build.gradle"

# Simple MainApplication.java
$mainAppDir = "app\src\main\java\com\squashtrainingapp"
@'
package com.squashtrainingapp;

import android.app.Application;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.defaults.DefaultReactNativeHost;
import com.facebook.react.shell.MainReactPackage;
import com.facebook.soloader.SoLoader;
import com.oblador.vectoricons.VectorIconsPackage;

import java.util.Arrays;
import java.util.List;

public class MainApplication extends Application implements ReactApplication {

    private final ReactNativeHost mReactNativeHost = new DefaultReactNativeHost(this) {
        @Override
        public boolean getUseDeveloperSupport() {
            return BuildConfig.DEBUG;
        }

        @Override
        protected List<ReactPackage> getPackages() {
            return Arrays.<ReactPackage>asList(
                new MainReactPackage(),
                new VectorIconsPackage()
            );
        }

        @Override
        protected String getJSMainModuleName() {
            return "index";
        }

        @Override
        protected boolean isNewArchEnabled() {
            return BuildConfig.IS_NEW_ARCHITECTURE_ENABLED;
        }

        @Override
        protected Boolean isHermesEnabled() {
            return BuildConfig.IS_HERMES_ENABLED;
        }
    };

    @Override
    public ReactNativeHost getReactNativeHost() {
        return mReactNativeHost;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        SoLoader.init(this, false);
    }
}
'@ | Out-File -Encoding ASCII "$mainAppDir\MainApplication.java"

# Create JavaScript bundle
Write-Host "`nCreating JavaScript bundle..." -ForegroundColor Yellow
$assetsDir = "app\src\main\assets"
if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
}

Pop-Location

# Bundle creation
npx react-native bundle `
    --platform android `
    --dev true `
    --entry-file index.js `
    --bundle-output android/app/src/main/assets/index.android.bundle `
    --assets-dest android/app/src/main/res 2>&1 | Out-Null

Push-Location android

# Build APK
Write-Host "`nBuilding APK (bypass mode)..." -ForegroundColor Yellow
.\gradlew.bat clean assembleDebug --no-daemon

$apkPath = "app\build\outputs\apk\debug\app-debug.apk"
if (Test-Path $apkPath) {
    $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
    Write-Host "`nBUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "APK: $apkPath ($apkSize MB)" -ForegroundColor Yellow
    Write-Host "`nNote: This build includes only vector icons module" -ForegroundColor Cyan
    Write-Host "SQLite and other modules temporarily disabled due to compatibility issues" -ForegroundColor Yellow
    
    if ($Install -or $Run) {
        Write-Host "`nInstalling APK..." -ForegroundColor Yellow
        adb uninstall com.squashtrainingapp 2>$null | Out-Null
        adb install -r $apkPath
        
        if ($Run) {
            Write-Host "`nStarting app..." -ForegroundColor Yellow
            Pop-Location
            adb reverse tcp:8081 tcp:8081
            $metro = Start-Process -FilePath "cmd" -ArgumentList "/c", "npx react-native start --reset-cache" -PassThru -WindowStyle Normal
            Start-Sleep -Seconds 10
            
            adb shell am start -n com.squashtrainingapp/.MainActivity
            
            Write-Host "`nApp is running!" -ForegroundColor Green
            Write-Host "Press any key to stop..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            
            if ($metro -and !$metro.HasExited) {
                Stop-Process -Id $metro.Id -Force
            }
            return
        }
    }
} else {
    Write-Host "`nBUILD FAILED!" -ForegroundColor Red
}

Pop-Location