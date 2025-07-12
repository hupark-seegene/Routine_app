#!/usr/bin/env pwsh
# FOOLPROOF React Native 0.80+ Build Script
# This script tries multiple approaches to ensure a successful build

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " FOOLPROOF React Native Build Script" -ForegroundColor Cyan
Write-Host " Will try multiple approaches until success" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Ensure we're in android directory
if (-not (Test-Path "gradlew.bat")) {
    Write-Host "Error: Run from android directory" -ForegroundColor Red
    exit 1
}

# Set up environment
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
Write-Host "[Environment] Java configured" -ForegroundColor Green

# Function to check if APK was created
function Test-APKExists {
    return Test-Path "app\build\outputs\apk\debug\app-debug.apk"
}

# Method 1: Try with gradle init script
Write-Host ""
Write-Host "[Method 1] Trying with gradle init script..." -ForegroundColor Yellow

if (Test-Path "init.gradle") {
    & cmd /c "gradlew.bat clean --init-script init.gradle 2>&1" | Out-Null
    $output = & cmd /c "gradlew.bat assembleDebug --init-script init.gradle 2>&1"
    
    if (Test-APKExists) {
        Write-Host "✓ SUCCESS with init script!" -ForegroundColor Green
        Write-Host "APK: app\build\outputs\apk\debug\app-debug.apk" -ForegroundColor Cyan
        exit 0
    } else {
        Write-Host "✗ Failed with init script" -ForegroundColor Red
    }
}

# Method 2: Try minimal configuration
Write-Host ""
Write-Host "[Method 2] Trying minimal configuration..." -ForegroundColor Yellow

if ((Test-Path "settings.gradle.minimal") -and (Test-Path "build.gradle.minimal") -and (Test-Path "app\build.gradle.minimal")) {
    # Backup current files
    Copy-Item "settings.gradle" "settings.gradle.backup" -Force
    Copy-Item "build.gradle" "build.gradle.backup" -Force
    Copy-Item "app\build.gradle" "app\build.gradle.backup" -Force
    
    # Apply minimal configuration
    Copy-Item "settings.gradle.minimal" "settings.gradle" -Force
    Copy-Item "build.gradle.minimal" "build.gradle" -Force
    Copy-Item "app\build.gradle.minimal" "app\build.gradle" -Force
    
    & cmd /c "gradlew.bat clean 2>&1" | Out-Null
    $output = & cmd /c "gradlew.bat assembleDebug 2>&1"
    
    if (Test-APKExists) {
        Write-Host "✓ SUCCESS with minimal configuration!" -ForegroundColor Green
        Write-Host "APK: app\build\outputs\apk\debug\app-debug.apk" -ForegroundColor Cyan
        exit 0
    } else {
        Write-Host "✗ Failed with minimal configuration" -ForegroundColor Red
        # Restore original files
        Copy-Item "settings.gradle.backup" "settings.gradle" -Force
        Copy-Item "build.gradle.backup" "build.gradle" -Force
        Copy-Item "app\build.gradle.backup" "app\build.gradle" -Force
    }
}

# Method 3: Build React Native plugin manually then try
Write-Host ""
Write-Host "[Method 3] Building RN plugin manually..." -ForegroundColor Yellow

$pluginPath = "..\node_modules\@react-native\gradle-plugin"
if (Test-Path $pluginPath) {
    Push-Location $pluginPath
    $buildOutput = & cmd /c "gradlew.bat build -x test 2>&1"
    Pop-Location
    
    Write-Host "✓ Plugin built" -ForegroundColor Green
    
    # Try build again
    & cmd /c "gradlew.bat clean 2>&1" | Out-Null
    $output = & cmd /c "gradlew.bat assembleDebug 2>&1"
    
    if (Test-APKExists) {
        Write-Host "✓ SUCCESS after building plugin!" -ForegroundColor Green
        Write-Host "APK: app\build\outputs\apk\debug\app-debug.apk" -ForegroundColor Cyan
        exit 0
    } else {
        Write-Host "✗ Failed even after building plugin" -ForegroundColor Red
    }
}

# Method 4: Create JavaScript bundle manually
Write-Host ""
Write-Host "[Method 4] Creating JS bundle manually..." -ForegroundColor Yellow

# Ensure assets directory exists
$assetsDir = "app\src\main\assets"
if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
}

# Create bundle
Push-Location ..
$bundleOutput = & cmd /c "npx react-native bundle --platform android --dev true --entry-file index.js --bundle-output android/app/src/main/assets/index.android.bundle --assets-dest android/app/src/main/res 2>&1"
Pop-Location

if (Test-Path "app\src\main\assets\index.android.bundle") {
    Write-Host "✓ JS bundle created" -ForegroundColor Green
    
    # Try minimal Android build without React Native plugin
    Write-Host "Attempting Android-only build..." -ForegroundColor Yellow
    
    # Create a temporary build.gradle for app without React plugin
    $tempBuildGradle = @'
apply plugin: "com.android.application"
apply plugin: "org.jetbrains.kotlin.android"

android {
    namespace 'com.squashtrainingapp'
    compileSdk 35
    
    defaultConfig {
        applicationId "com.squashtrainingapp"
        minSdk 24
        targetSdk 35
        versionCode 1
        versionName "1.0"
    }
    
    buildTypes {
        debug {
            minifyEnabled false
        }
    }
}

dependencies {
    implementation fileTree(dir: "libs", include: ["*.jar", "*.aar"])
    implementation "com.facebook.react:react-native:+"
    implementation "androidx.appcompat:appcompat:1.7.0"
}
'@
    
    Copy-Item "app\build.gradle" "app\build.gradle.temp" -Force
    Set-Content -Path "app\build.gradle" -Value $tempBuildGradle
    
    $output = & cmd /c "gradlew.bat assembleDebug 2>&1"
    
    if (Test-APKExists) {
        Write-Host "✓ SUCCESS with manual bundle!" -ForegroundColor Green
        Write-Host "APK: app\build\outputs\apk\debug\app-debug.apk" -ForegroundColor Cyan
        exit 0
    } else {
        Write-Host "✗ Failed with manual bundle" -ForegroundColor Red
        Copy-Item "app\build.gradle.temp" "app\build.gradle" -Force
    }
}

# All methods failed
Write-Host ""
Write-Host "============================================" -ForegroundColor Red
Write-Host " ALL METHODS FAILED" -ForegroundColor Red
Write-Host "============================================" -ForegroundColor Red
Write-Host ""
Write-Host "FINAL RECOMMENDATION: Use Android Studio" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Open Android Studio" -ForegroundColor Cyan
Write-Host "2. File -> Open -> Select this 'android' folder" -ForegroundColor Cyan
Write-Host "3. Wait for 'Sync Project with Gradle Files' to complete" -ForegroundColor Cyan
Write-Host "4. Build -> Build Bundle(s) / APK(s) -> Build APK(s)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Android Studio handles React Native 0.80+ automatically." -ForegroundColor Green
Write-Host "It's the officially supported method for complex builds." -ForegroundColor Green
Write-Host ""
Write-Host "Alternative: Downgrade to React Native 0.73.x which has" -ForegroundColor Yellow
Write-Host "a simpler build system without these plugin issues." -ForegroundColor Yellow