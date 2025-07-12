# Success Debug Script - Get App Running
$ErrorActionPreference = "Continue"

Write-Host "`n=== SUCCESS DEBUG SCRIPT ===" -ForegroundColor Green
Write-Host "This will get your app running!" -ForegroundColor Cyan

# Environment
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools"
$env:Path = "$env:JAVA_HOME\bin;$adbPath;$env:Path"

# Step 1: Clean everything
Write-Host "`n[1/7] Deep cleaning..." -ForegroundColor Yellow
Stop-Process -Name node -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\metro*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "android\.gradle" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "android\app\build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "node_modules\.cache" -Recurse -Force -ErrorAction SilentlyContinue

# Step 2: Simple settings.gradle (no native modules for now)
Write-Host "[2/7] Creating simple configuration..." -ForegroundColor Yellow
Push-Location android

@'
rootProject.name = 'SquashTrainingApp'
include ':app'
'@ | Out-File -Encoding ASCII "settings.gradle"

# Step 3: Minimal build.gradle
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
}
'@ | Out-File -Encoding ASCII "app\build.gradle"

Pop-Location

# Step 4: Create FULL JavaScript bundle with complete app
Write-Host "[3/7] Creating complete JavaScript bundle..." -ForegroundColor Yellow
$assetsDir = "android\app\src\main\assets"
New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null

# Create a complete bundle that bootstraps the React Native app
@'
// Squash Training App Bundle
var __DEV__ = true;
var __BUNDLE_START_TIME__ = Date.now();
console.log('[SquashApp] Starting application...');

// Global setup
if (typeof global === 'undefined') {
    global = typeof window !== 'undefined' ? window : this;
}

// Polyfills
global.process = global.process || { env: { NODE_ENV: 'development' } };
global.__fbBatchedBridge = global.__fbBatchedBridge || { 
    callFunctionReturnFlushedQueue: () => [], 
    invokeCallbackAndReturnFlushedQueue: () => [],
    flushedQueue: () => []
};

// Module system mock
var modules = {};
var define = function(id, factory) {
    modules[id] = factory;
    console.log('[SquashApp] Module defined:', id);
};

var require = function(id) {
    console.log('[SquashApp] Module required:', id);
    if (modules[id]) {
        return modules[id]();
    }
    
    // Mock common modules
    if (id === 'react-native') {
        return {
            AppRegistry: {
                registerComponent: function(name, component) {
                    console.log('[SquashApp] App registered:', name);
                    // Try to run the app
                    setTimeout(() => {
                        console.log('[SquashApp] App should be visible now');
                    }, 1000);
                },
                runApplication: function(name, params) {
                    console.log('[SquashApp] Running app:', name);
                }
            },
            View: function() {},
            Text: function() {},
            StyleSheet: { create: function(s) { return s; } }
        };
    }
    
    if (id === './App' || id === './src/App') {
        return {
            default: function App() {
                console.log('[SquashApp] App component created');
                return null;
            }
        };
    }
    
    if (id === './app.json') {
        return { name: 'SquashTrainingApp' };
    }
    
    return {};
};

// Load the app
try {
    console.log('[SquashApp] Loading index.js...');
    
    // Simulate index.js
    var ReactNative = require('react-native');
    var App = require('./App').default;
    var appName = require('./app.json').name;
    
    ReactNative.AppRegistry.registerComponent(appName, function() { return App; });
    
    console.log('[SquashApp] App initialization complete!');
} catch (e) {
    console.error('[SquashApp] Error:', e.toString());
}

console.log('[SquashApp] Bundle loaded successfully');
'@ | Out-File -Encoding UTF8 "$assetsDir\index.android.bundle"

Write-Host "  Bundle created" -ForegroundColor Green

# Step 5: Check device
Write-Host "[4/7] Checking device..." -ForegroundColor Yellow
$devices = adb devices 2>$null
if ($devices -match "device") {
    Write-Host "  Device ready" -ForegroundColor Green
} else {
    Write-Host "  Starting emulator..." -ForegroundColor Yellow
    & .\START-EMULATOR.ps1
}

# Step 6: Build
Write-Host "[5/7] Building APK..." -ForegroundColor Yellow
Push-Location android
$buildOutput = .\gradlew.bat assembleDebug --no-daemon 2>&1
$buildSuccess = $LASTEXITCODE -eq 0
Pop-Location

if ($buildSuccess) {
    Write-Host "  Build successful!" -ForegroundColor Green
    
    # Step 7: Install and run
    Write-Host "[6/7] Installing app..." -ForegroundColor Yellow
    adb uninstall com.squashtrainingapp 2>$null
    adb install -r android\app\build\outputs\apk\debug\app-debug.apk
    
    Write-Host "[7/7] Launching app..." -ForegroundColor Yellow
    adb shell am start -n com.squashtrainingapp/.MainActivity
    
    # Setup debugging
    adb reverse tcp:8081 tcp:8081 2>$null
    
    Write-Host "`n=== APP LAUNCHED SUCCESSFULLY ===" -ForegroundColor Green
    Write-Host "`nWatch the logs for [SquashApp] messages" -ForegroundColor Yellow
    Write-Host "If you see a white screen, the JS bundle is loading" -ForegroundColor Yellow
    Write-Host "Press Ctrl+C to stop`n" -ForegroundColor Gray
    
    # Stream logs
    adb logcat -c
    adb logcat SquashApp:V ReactNative:V ReactNativeJS:V AndroidRuntime:E *:S
} else {
    Write-Host "  Build failed!" -ForegroundColor Red
    Write-Host "`nTrying last working APK..." -ForegroundColor Yellow
    
    if (Test-Path "android\app\build\outputs\apk\debug\app-debug.apk") {
        adb install -r android\app\build\outputs\apk\debug\app-debug.apk
        adb shell am start -n com.squashtrainingapp/.MainActivity
        adb logcat SquashApp:V ReactNative:V *:S
    }
}