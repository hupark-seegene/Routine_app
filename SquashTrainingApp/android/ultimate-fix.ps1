#!/usr/bin/env pwsh
# Ultimate fix for React Native 0.80+ build issues
# This applies a proven working configuration

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " React Native 0.80+ Ultimate Fix" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check we're in android directory
if (-not (Test-Path "gradlew.bat")) {
    Write-Host "Error: Run from android directory" -ForegroundColor Red
    exit 1
}

# Set Java environment
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

# Step 1: Add React Native plugin to root build.gradle
Write-Host "[1/3] Fixing root build.gradle..." -ForegroundColor Yellow

$buildGradleContent = @'
buildscript {
    ext {
        buildToolsVersion = "35.0.0"
        minSdkVersion = 24
        compileSdkVersion = 35
        targetSdkVersion = 35
        ndkVersion = "27.1.12297006"
        kotlinVersion = "2.1.20"
    }
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.9.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

// Apply React Native plugin BEFORE allprojects
apply plugin: "com.facebook.react"

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url "https://www.jitpack.io" }
    }
}

// Force a specific react-native version
ext {
    versionOverrides = [
        "react-native": "0.80.1"
    ]
}
'@

Set-Content -Path "build.gradle" -Value $buildGradleContent
Write-Host "✓ Fixed root build.gradle" -ForegroundColor Green

# Step 2: Ensure React Native plugin is built
Write-Host ""
Write-Host "[2/3] Building React Native plugin..." -ForegroundColor Yellow

$pluginPath = "..\node_modules\@react-native\gradle-plugin"
Push-Location $pluginPath
try {
    & cmd /c "gradlew.bat build -x test 2>&1" | Out-Null
    Write-Host "✓ Plugin built successfully" -ForegroundColor Green
} catch {
    Write-Host "Warning: Plugin build had issues" -ForegroundColor Yellow
} finally {
    Pop-Location
}

# Step 3: Build the app
Write-Host ""
Write-Host "[3/3] Building Android app..." -ForegroundColor Yellow
Write-Host "This may take several minutes..." -ForegroundColor Cyan

& cmd /c "gradlew.bat clean 2>&1" | Out-Null
$buildOutput = & cmd /c "gradlew.bat assembleDebug 2>&1"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host " BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    
    $apkPath = "app\build\outputs\apk\debug\app-debug.apk"
    if (Test-Path $apkPath) {
        Write-Host ""
        Write-Host "APK Location: $((Get-Item $apkPath).FullName)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "To install: adb install $apkPath" -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "BUILD FAILED" -ForegroundColor Red
    Write-Host "Error output:" -ForegroundColor Yellow
    Write-Host $buildOutput
    
    Write-Host ""
    Write-Host "Last resort: Use Android Studio" -ForegroundColor Yellow
    Write-Host "1. Open Android Studio" -ForegroundColor Cyan
    Write-Host "2. Open this android folder as a project" -ForegroundColor Cyan
    Write-Host "3. File -> Sync Project with Gradle Files" -ForegroundColor Cyan
    Write-Host "4. Build -> Build Bundle(s) / APK(s) -> Build APK(s)" -ForegroundColor Cyan
}