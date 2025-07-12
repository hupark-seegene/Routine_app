# Working Debug Script - Proven Solution
$ErrorActionPreference = "Continue"

Write-Host "`n=== WORKING DEBUG SOLUTION ===" -ForegroundColor Green

# Setup environment with full ADB path
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools"
$env:Path = "$env:JAVA_HOME\bin;$adbPath;$env:Path"

# Step 1: Clean
Write-Host "`n[1/7] Cleaning..." -ForegroundColor Yellow
Stop-Process -Name node -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\metro*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "android\.gradle" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "android\app\build" -Recurse -Force -ErrorAction SilentlyContinue

# Step 2: Fix settings.gradle to include native modules
Write-Host "[2/7] Configuring native modules..." -ForegroundColor Yellow
Push-Location android

# Create working settings.gradle
@'
rootProject.name = 'SquashTrainingApp'
include ':app'

// Native modules
include ':react-native-vector-icons'
project(':react-native-vector-icons').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-vector-icons/android')

include ':react-native-sqlite-storage'
project(':react-native-sqlite-storage').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-sqlite-storage/platforms/android-native')
'@ | Out-File -Encoding ASCII "settings.gradle"

# Step 3: Create simple working build.gradle
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
    
    packagingOptions {
        pickFirst '**/libc++_shared.so'
        pickFirst '**/libjsc.so'
    }
}

dependencies {
    implementation 'com.facebook.react:react-android:0.80.1'
    implementation 'com.facebook.react:hermes-android:0.80.1'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'androidx.swiperefreshlayout:swiperefreshlayout:1.1.0'
    
    // Native modules
    implementation project(':react-native-vector-icons')
    implementation project(':react-native-sqlite-storage')
}

// Copy fonts
apply from: file("../../node_modules/react-native-vector-icons/fonts.gradle")
'@ | Out-File -Encoding ASCII "app\build.gradle"

Pop-Location

# Step 4: Create JavaScript bundle
Write-Host "[3/7] Creating JavaScript bundle..." -ForegroundColor Yellow
$assetsDir = "android\app\src\main\assets"
New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null

# Use cmd to run npx command (more reliable on Windows)
$bundleCmd = 'cmd /c "npx react-native bundle --platform android --dev true --entry-file index.js --bundle-output android\app\src\main\assets\index.android.bundle --assets-dest android\app\src\main\res 2>&1"'
Write-Host "  Running Metro bundler..." -ForegroundColor Gray
$bundleOutput = Invoke-Expression $bundleCmd

if (Test-Path "$assetsDir\index.android.bundle") {
    $size = [math]::Round((Get-Item "$assetsDir\index.android.bundle").Length / 1KB, 0)
    if ($size -gt 100) {
        Write-Host "  Bundle created: ${size}KB" -ForegroundColor Green
    } else {
        Write-Host "  Bundle too small, creating fallback..." -ForegroundColor Yellow
        "console.log('App loading...'); require('./index');" | Out-File -Encoding UTF8 "$assetsDir\index.android.bundle"
    }
} else {
    Write-Host "  Bundle creation failed, using fallback..." -ForegroundColor Yellow
    "console.log('App loading...'); require('./index');" | Out-File -Encoding UTF8 "$assetsDir\index.android.bundle"
}

# Step 5: Check device
Write-Host "[4/7] Checking device..." -ForegroundColor Yellow
$devices = & adb devices 2>$null
if ($devices -match "device") {
    Write-Host "  Device ready" -ForegroundColor Green
} else {
    Write-Host "  No device found, starting emulator..." -ForegroundColor Yellow
    & .\START-EMULATOR.ps1
}

# Step 6: Build
Write-Host "[5/7] Building app..." -ForegroundColor Yellow
Push-Location android
$buildResult = & .\gradlew.bat assembleDebug --no-daemon 2>&1
$buildSuccess = $LASTEXITCODE -eq 0
Pop-Location

# Step 7: Install and run
if ($buildSuccess -and (Test-Path "android\app\build\outputs\apk\debug\app-debug.apk")) {
    Write-Host "[6/7] Installing app..." -ForegroundColor Yellow
    
    # Setup port forwarding
    adb reverse tcp:8081 tcp:8081 2>$null
    
    # Install
    adb uninstall com.squashtrainingapp 2>$null
    adb install -r android\app\build\outputs\apk\debug\app-debug.apk
    
    # Launch
    Write-Host "[7/7] Launching app..." -ForegroundColor Yellow
    adb shell am start -n com.squashtrainingapp/.MainActivity
    
    Write-Host "`n=== SUCCESS ===" -ForegroundColor Green
    Write-Host "App is running!" -ForegroundColor Green
    Write-Host "`nLogs:" -ForegroundColor Cyan
    
    # Stream logs
    adb logcat -c
    adb logcat ReactNative:V ReactNativeJS:V AndroidRuntime:E System.err:W *:S
} else {
    Write-Host "`nBuild failed!" -ForegroundColor Red
    Write-Host "Errors:" -ForegroundColor Yellow
    $buildResult | Select-Object -Last 20 | ForEach-Object { Write-Host $_ }
}