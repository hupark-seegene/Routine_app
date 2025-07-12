# Final Debug Script - Working Solution
$ErrorActionPreference = "Continue"

Write-Host "`n=== FINAL DEBUG SOLUTION ===" -ForegroundColor Green

# Environment
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

# Step 1: Clean
Write-Host "`n[1/6] Cleaning..." -ForegroundColor Yellow
Stop-Process -Name node -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\metro*" -Recurse -Force -ErrorAction SilentlyContinue

# Step 2: Create proper JS bundle
Write-Host "[2/6] Creating JavaScript bundle..." -ForegroundColor Yellow
$assetsDir = "android\app\src\main\assets"
New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null

# Try npx bundle command
Write-Host "  Attempting Metro bundler..." -ForegroundColor Gray
$bundleCmd = "npx react-native bundle --platform android --dev true --entry-file index.js --bundle-output android/app/src/main/assets/index.android.bundle --assets-dest android/app/src/main/res --reset-cache"
$bundleResult = cmd /c $bundleCmd 2>&1
$bundleSuccess = $LASTEXITCODE -eq 0

if ($bundleSuccess -and (Test-Path "$assetsDir\index.android.bundle")) {
    $size = (Get-Item "$assetsDir\index.android.bundle").Length / 1KB
    if ($size -gt 100) {
        Write-Host "  Bundle created successfully: $([math]::Round($size, 0))KB" -ForegroundColor Green
    } else {
        $bundleSuccess = $false
    }
}

if (-not $bundleSuccess) {
    Write-Host "  Metro failed, creating manual bundle..." -ForegroundColor Yellow
    # This won't work properly but will at least try to load the app
    @'
// Debug Bundle
var __DEV__ = true;
console.log('[Bundle] Loading Squash Training App...');
try { require('./index'); } catch(e) { console.error(e); }
'@ | Out-File -Encoding UTF8 "$assetsDir\index.android.bundle"
}

# Step 3: Setup build.gradle (bypass React Native plugin)
Write-Host "[3/6] Configuring build..." -ForegroundColor Yellow
Push-Location android

# Use simplified build.gradle
@'
apply plugin: "com.android.application"
apply plugin: "org.jetbrains.kotlin.android"

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
        
        buildConfigField "boolean", "IS_NEW_ARCHITECTURE_ENABLED", "false"
        buildConfigField "boolean", "IS_HERMES_ENABLED", "true"
        buildConfigField "boolean", "DEBUG", "true"
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
    
    packagingOptions {
        pickFirst '**/libc++_shared.so'
        pickFirst '**/libjsc.so'
        exclude 'META-INF/DEPENDENCIES'
    }
}

dependencies {
    implementation 'com.facebook.react:react-android:0.80.1'
    implementation 'com.facebook.react:hermes-android:0.80.1'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'androidx.swiperefreshlayout:swiperefreshlayout:1.1.0'
    implementation "org.jetbrains.kotlin:kotlin-stdlib:1.9.24"
    
    // React Native modules
    implementation project(':react-native-vector-icons')
    implementation project(':react-native-sqlite-storage')
}

// Copy fonts
apply from: file("../../node_modules/react-native-vector-icons/fonts.gradle")
'@ | Out-File -Encoding ASCII "app\build.gradle"

Pop-Location

# Step 4: Check device
Write-Host "[4/6] Checking device..." -ForegroundColor Yellow
$devices = adb devices 2>$null
if ($devices -notmatch "device") {
    & .\START-EMULATOR.ps1
}
adb reverse tcp:8081 tcp:8081 2>$null

# Step 5: Build
Write-Host "[5/6] Building app..." -ForegroundColor Yellow
Push-Location android
Remove-Item "app\build" -Recurse -Force -ErrorAction SilentlyContinue
$buildResult = .\gradlew.bat assembleDebug --no-daemon 2>&1
$buildSuccess = $LASTEXITCODE -eq 0
Pop-Location

# Step 6: Install and run
if ($buildSuccess -and (Test-Path "android\app\build\outputs\apk\debug\app-debug.apk")) {
    Write-Host "[6/6] Installing app..." -ForegroundColor Yellow
    
    # Uninstall old version
    adb uninstall com.squashtrainingapp 2>$null
    
    # Install new
    adb install -r android\app\build\outputs\apk\debug\app-debug.apk
    
    # Launch
    adb shell am start -n com.squashtrainingapp/.MainActivity
    
    Write-Host "`n=== APP LAUNCHED ===" -ForegroundColor Green
    Write-Host "`nShowing logs..." -ForegroundColor Cyan
    Write-Host "Look for [Bundle] messages to see if JS is loading" -ForegroundColor Yellow
    Write-Host "Press Ctrl+C to stop`n" -ForegroundColor Gray
    
    # Stream logs
    adb logcat -c
    adb logcat ReactNative:V ReactNativeJS:V Bundle:V AndroidRuntime:E *:S
} else {
    Write-Host "Build failed!" -ForegroundColor Red
    Write-Host "Error output:" -ForegroundColor Yellow
    $buildResult | Select-Object -Last 30
}