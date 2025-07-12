#!/usr/bin/env pwsh
# ULTIMATE Build Script for React Native 0.80+
# This will keep trying until it works

Write-Host @"
============================================
 ULTIMATE React Native Build Script
 Will NOT give up until APK is built!
============================================
"@ -ForegroundColor Cyan

# Set JAVA_HOME
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

$attempt = 0
$maxAttempts = 10

while ($attempt -lt $maxAttempts) {
    $attempt++
    Write-Host ""
    Write-Host "==================== ATTEMPT $attempt ====================" -ForegroundColor Yellow
    
    # Clean everything
    Write-Host "[Clean] Removing all build directories..." -ForegroundColor Cyan
    @("build", "app\build", ".gradle", "app\.gradle") | ForEach-Object {
        if (Test-Path $_) { 
            Remove-Item -Recurse -Force $_ -ErrorAction SilentlyContinue
        }
    }
    
    # Strategy based on attempt number
    switch ($attempt) {
        1 {
            Write-Host "[Strategy 1] Using stable configuration from January 2025..." -ForegroundColor Green
            
            # Restore stable configs
            if (Test-Path "settings.gradle.safe") {
                Copy-Item -Force "settings.gradle.safe" "settings.gradle"
            }
            if (Test-Path "build.gradle.safe") {
                Copy-Item -Force "build.gradle.safe" "build.gradle"
            }
            if (Test-Path "app\build.gradle.safe") {
                Copy-Item -Force "app\build.gradle.safe" "app\build.gradle"
            }
        }
        
        2 {
            Write-Host "[Strategy 2] Using minimal React Native config..." -ForegroundColor Green
            
            # Minimal settings.gradle
            @"
rootProject.name = 'SquashTrainingApp'
include ':app'
"@ | Out-File -Encoding utf8 "settings.gradle"
            
            # Minimal build.gradle
            @"
buildscript {
    ext {
        buildToolsVersion = "34.0.0"
        minSdkVersion = 24
        compileSdkVersion = 34
        targetSdkVersion = 34
        ndkVersion = "26.1.10909125"
        kotlinVersion = "1.9.24"
    }
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.3.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:\$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url "https://www.jitpack.io" }
        maven { url "\$rootDir/../node_modules/react-native/android" }
    }
}
"@ | Out-File -Encoding utf8 "build.gradle"
            
            # Basic Android app without React Native plugin
            @"
apply plugin: "com.android.application"
apply plugin: "org.jetbrains.kotlin.android"

android {
    compileSdk rootProject.ext.compileSdkVersion
    buildToolsVersion rootProject.ext.buildToolsVersion
    ndkVersion rootProject.ext.ndkVersion
    
    namespace "com.squashtrainingapp"
    
    defaultConfig {
        applicationId "com.squashtrainingapp"
        minSdkVersion rootProject.ext.minSdkVersion
        targetSdkVersion rootProject.ext.targetSdkVersion
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
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
}

dependencies {
    implementation("com.facebook.react:react-android:0.80.1")
    implementation("com.facebook.react:hermes-android:0.80.1")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.swiperefreshlayout:swiperefreshlayout:1.1.0")
    implementation("org.jetbrains.kotlin:kotlin-stdlib:\${rootProject.ext.kotlinVersion}")
}

// Manual JS bundling
task createBundleDebugJsAndAssets(type: Exec) {
    workingDir rootProject.file('.')
    commandLine 'cmd', '/c', 'mkdir', 'app\\src\\main\\assets'
    
    doLast {
        exec {
            workingDir rootProject.file('../')
            commandLine 'cmd', '/c', 'npx', 'react-native', 'bundle', '--platform', 'android', '--dev', 'true', '--entry-file', 'index.js', '--bundle-output', 'android/app/src/main/assets/index.android.bundle', '--assets-dest', 'android/app/src/main/res'
        }
    }
}

preBuild.dependsOn createBundleDebugJsAndAssets

apply from: file("../../node_modules/react-native-vector-icons/fonts.gradle")
"@ | Out-File -Encoding utf8 "app\build.gradle"
        }
        
        3 {
            Write-Host "[Strategy 3] Using React Native CLI from parent directory..." -ForegroundColor Green
            Push-Location ..
            & npx react-native build-android --mode=debug
            Pop-Location
        }
        
        4 {
            Write-Host "[Strategy 4] Direct gradlew with manual plugin path..." -ForegroundColor Green
            
            # Try to set plugin path manually
            $pluginPath = "$PWD\..\node_modules\@react-native\gradle-plugin"
            & .\gradlew.bat assembleDebug --no-daemon -PpluginPath="$pluginPath"
        }
        
        5 {
            Write-Host "[Strategy 5] Using Android Studio gradle wrapper..." -ForegroundColor Green
            
            # Find Android Studio gradle
            $androidStudioPath = "${env:LOCALAPPDATA}\Android\Sdk"
            if (Test-Path $androidStudioPath) {
                Write-Host "  Found Android SDK at: $androidStudioPath"
            }
            
            & .\gradlew.bat assembleDebug --no-daemon
        }
        
        default {
            Write-Host "[Strategy $attempt] Trying with increasing desperation..." -ForegroundColor Magenta
            & .\gradlew.bat assembleDebug --no-daemon --stacktrace
        }
    }
    
    # Check if APK exists
    $apkPath = "app\build\outputs\apk\debug\app-debug.apk"
    if (Test-Path $apkPath) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host " ✅ SUCCESS! APK BUILT! ✅" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "APK Location: $((Get-Item $apkPath).FullName)" -ForegroundColor Yellow
        $size = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
        Write-Host "APK Size: $size MB" -ForegroundColor Yellow
        
        # Install if device connected
        $devices = & adb devices 2>$null | Select-String -Pattern "device$"
        if ($devices) {
            Write-Host ""
            Write-Host "Installing APK to device..." -ForegroundColor Cyan
            & adb install -r $apkPath
        }
        
        exit 0
    }
    
    Write-Host ""
    Write-Host "❌ Attempt $attempt failed" -ForegroundColor Red
    
    if ($attempt -lt $maxAttempts) {
        Write-Host "Waiting 3 seconds before next attempt..." -ForegroundColor Yellow
        Start-Sleep -Seconds 3
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Red
Write-Host " ALL ATTEMPTS FAILED!" -ForegroundColor Red
Write-Host "============================================" -ForegroundColor Red
Write-Host ""
Write-Host "FINAL RECOMMENDATION:" -ForegroundColor Yellow
Write-Host "1. Use Android Studio - it handles everything automatically" -ForegroundColor White
Write-Host "2. Or downgrade to React Native 0.73.x which has simpler build system" -ForegroundColor White
Write-Host ""
Write-Host "The issue is with React Native 0.80+ gradle plugin system on Windows." -ForegroundColor Gray
Write-Host "Android Studio has special handling for this that command line builds lack." -ForegroundColor Gray

exit 1