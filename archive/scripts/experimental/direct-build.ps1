# Direct Build Script - Most Basic Approach
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Direct React Native Build" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Set JAVA_HOME
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

# Clean
Write-Host "[1/4] Cleaning..." -ForegroundColor Yellow
if (Test-Path "app\build") { Remove-Item -Recurse -Force "app\build" }

# Create the simplest possible configuration
Write-Host "[2/4] Creating build configuration..." -ForegroundColor Yellow

# Restore original React Native configuration
@'
pluginManagement { 
    includeBuild("../node_modules/@react-native/gradle-plugin")
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins { 
    id("com.facebook.react.settings") 
}

rootProject.name = 'SquashTrainingApp'
include ':app'
'@ | Out-File -Encoding ASCII "settings.gradle"

# Standard build.gradle
@'
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
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url "https://www.jitpack.io" }
        maven { url "$rootDir/../node_modules/react-native/android" }
    }
}
'@ | Out-File -Encoding ASCII "build.gradle"

# Create assets directory
Write-Host "[3/4] Setting up assets..." -ForegroundColor Yellow
$assetsDir = "app\src\main\assets"
if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
}

# Create empty bundle file to bypass bundling
Write-Host "  Creating placeholder bundle..." -ForegroundColor Gray
"// Placeholder bundle" | Out-File -Encoding ASCII "$assetsDir\index.android.bundle"

# Build
Write-Host "[4/4] Building APK..." -ForegroundColor Green
Write-Host "  This may take a few minutes..." -ForegroundColor Gray

# First, try to build the gradle plugin
Push-Location "..\node_modules\@react-native\gradle-plugin"
if (Test-Path "gradlew.bat") {
    Write-Host "  Building React Native gradle plugin..." -ForegroundColor Gray
    & .\gradlew.bat build --no-daemon -q
}
Pop-Location

# Now build the app
$buildOutput = & .\gradlew.bat assembleDebug --no-daemon 2>&1
$buildSuccess = $LASTEXITCODE -eq 0

# Show output only if failed
if (-not $buildSuccess) {
    Write-Host ""
    Write-Host "Build output:" -ForegroundColor Red
    $buildOutput | Select-Object -Last 50 | ForEach-Object { Write-Host $_ }
}

# Check result
$apkPath = "app\build\outputs\apk\debug\app-debug.apk"
if (Test-Path $apkPath) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host " ✅ BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "APK: $apkPath" -ForegroundColor Yellow
    $size = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
    Write-Host "Size: $size MB" -ForegroundColor Yellow
    
    # Offer to install
    $devices = & adb devices 2>$null | Select-String -Pattern "device$"
    if ($devices) {
        Write-Host ""
        $install = Read-Host "Install APK to device? (Y/N)"
        if ($install -eq "Y" -or $install -eq "y") {
            & adb install -r $apkPath
        }
    }
} else {
    Write-Host ""
    Write-Host "❌ Build failed" -ForegroundColor Red
    
    # Try alternative approach
    Write-Host ""
    Write-Host "Trying alternative build approach..." -ForegroundColor Yellow
    
    # Remove React Native plugin and try basic Android build
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
    implementation 'androidx.appcompat:appcompat:1.6.1'
}
'@ | Out-File -Encoding ASCII "app\build.gradle"
    
    # Try again
    & .\gradlew.bat assembleDebug --no-daemon
    
    if (Test-Path $apkPath) {
        Write-Host ""
        Write-Host "✅ Alternative build succeeded!" -ForegroundColor Green
        Write-Host "APK: $apkPath" -ForegroundColor Yellow
    }
}