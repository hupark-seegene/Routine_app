#!/usr/bin/env pwsh
# Debug build script for React Native 0.80+

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " React Native Debug Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set JAVA_HOME
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

Write-Host "[1/5] Setting up environment..." -ForegroundColor Yellow
java -version

# Step 1: Clean everything
Write-Host ""
Write-Host "[2/5] Cleaning build directories..." -ForegroundColor Yellow
if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
if (Test-Path "app\build") { Remove-Item -Recurse -Force "app\build" }
if (Test-Path ".gradle") { Remove-Item -Recurse -Force ".gradle" }

# Step 2: Restore original settings
Write-Host ""
Write-Host "[3/5] Restoring original configuration..." -ForegroundColor Yellow
Copy-Item -Force "settings.gradle.original" "settings.gradle"

# Create a new build.gradle with minimal config
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
        gradlePluginPortal()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.3.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:`$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url "https://www.jitpack.io" }
        maven { url("`$rootDir/../node_modules/react-native/android") }
    }
}
"@ | Out-File -Encoding utf8 "build.gradle"

# Create a new app/build.gradle
@"
apply plugin: "com.android.application"
apply plugin: "org.jetbrains.kotlin.android"
apply plugin: "com.facebook.react"

react {
    entryFile = file("../../index.js")
    hermesEnabled = true
}

android {
    ndkVersion rootProject.ext.ndkVersion
    buildToolsVersion rootProject.ext.buildToolsVersion
    compileSdk rootProject.ext.compileSdkVersion
    
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
        release {
            signingConfig signingConfigs.debug
            minifyEnabled false
            proguardFiles getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro"
        }
    }
    
    packagingOptions {
        pickFirst '**/*.so'
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
}

dependencies {
    // React Native gradle plugin handles all React Native dependencies
    
    // Android dependencies
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.swiperefreshlayout:swiperefreshlayout:1.1.0")
    
    // Kotlin
    implementation("org.jetbrains.kotlin:kotlin-stdlib:`${rootProject.ext.kotlinVersion}")
}

apply from: file("../../node_modules/react-native-vector-icons/fonts.gradle")
"@ | Out-File -Encoding utf8 "app\build.gradle"

# Step 4: Build the gradle plugin first
Write-Host ""
Write-Host "[4/5] Building React Native gradle plugin..." -ForegroundColor Yellow
Push-Location "..\node_modules\@react-native\gradle-plugin"
if (Test-Path "gradlew.bat") {
    & .\gradlew.bat build --no-daemon
} else {
    Write-Host "  Warning: Could not build gradle plugin" -ForegroundColor Yellow
}
Pop-Location

# Step 5: Try the build
Write-Host ""
Write-Host "[5/5] Building APK..." -ForegroundColor Yellow
& .\gradlew.bat assembleDebug --no-daemon --stacktrace

# Check if APK was created
$apkPath = "app\build\outputs\apk\debug\app-debug.apk"
if (Test-Path $apkPath) {
    Write-Host ""
    Write-Host "✅ BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "APK location: $apkPath" -ForegroundColor Green
    
    $size = (Get-Item $apkPath).Length / 1MB
    Write-Host "APK size: $([math]::Round($size, 2)) MB" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "❌ BUILD FAILED" -ForegroundColor Red
    Write-Host "Check the error messages above" -ForegroundColor Red
}