# Full Debug Script - Complete React Native App
$ErrorActionPreference = "Continue"

Write-Host "`n=== FULL REACT NATIVE DEBUG ===" -ForegroundColor Cyan

# Environment
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$androidHome = "$env:LOCALAPPDATA\Android\Sdk"
$env:ANDROID_HOME = $androidHome
$oldPath = $env:Path
$env:Path = "$env:JAVA_HOME\bin;$androidHome\platform-tools;$oldPath"

# Step 1: Clean
Write-Host "`n[1/7] Cleaning..." -ForegroundColor Yellow
Stop-Process -Name node -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\metro*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "node_modules\.cache" -Recurse -Force -ErrorAction SilentlyContinue

# Step 2: Restore proper build.gradle
Write-Host "[2/7] Restoring build config..." -ForegroundColor Yellow
Push-Location android
if (Test-Path "app\build.gradle.backup") {
    Copy-Item "app\build.gradle.backup" "app\build.gradle" -Force
    Write-Host "  Restored React Native config" -ForegroundColor Green
} else {
    Write-Host "  No backup found, using current config" -ForegroundColor Yellow
}
Pop-Location

# Step 3: Create bundle
Write-Host "[3/7] Creating JS bundle..." -ForegroundColor Yellow
$assetsDir = "android\app\src\main\assets"
New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null

# Create comprehensive bundle
$bundle = @'
// React Native Full App Bundle
var __DEV__ = true;
console.log('[App] Starting React Native...');

// Mock Metro bundler environment
global.__r = global.__r || function() {};
global.__d = global.__d || function() {};
global.__BUNDLE_START_TIME__ = Date.now();

// Initialize React Native
try {
    // Load the actual app
    require('./index.js');
    console.log('[App] App loaded successfully');
} catch (e) {
    console.error('[App] Failed to load:', e);
    
    // Fallback: Try to register directly
    try {
        const { AppRegistry } = require('react-native');
        const App = require('./App').default;
        AppRegistry.registerComponent('SquashTrainingApp', () => App);
        console.log('[App] Registered via fallback');
    } catch (e2) {
        console.error('[App] Fallback failed:', e2);
    }
}
'@
$bundle | Out-File -Encoding UTF8 "$assetsDir\index.android.bundle"
Write-Host "  Bundle created" -ForegroundColor Green

# Step 4: Check emulator
Write-Host "[4/7] Checking device..." -ForegroundColor Yellow
$devices = adb devices 2>$null
if ($devices -notmatch "device") {
    Write-Host "  Starting emulator..." -ForegroundColor Yellow
    & .\START-EMULATOR.ps1
} else {
    Write-Host "  Device ready" -ForegroundColor Green
}

# Step 5: Setup ports
Write-Host "[5/7] Setting up ports..." -ForegroundColor Yellow
adb reverse tcp:8081 tcp:8081 2>$null
adb reverse tcp:8088 tcp:8088 2>$null

# Step 6: Build
Write-Host "[6/7] Building app..." -ForegroundColor Yellow
Push-Location android
Remove-Item "app\build" -Recurse -Force -ErrorAction SilentlyContinue

# Try with React Native plugin first
$buildCmd = ".\gradlew.bat assembleDebug --no-daemon"
Write-Host "  Running: $buildCmd" -ForegroundColor Gray
$buildResult = Invoke-Expression $buildCmd 2>&1
$buildSuccess = $LASTEXITCODE -eq 0

Pop-Location

$apkPath = "android\app\build\outputs\apk\debug\app-debug.apk"
if ($buildSuccess -and (Test-Path $apkPath)) {
    Write-Host "  Build successful!" -ForegroundColor Green
    
    # Step 7: Install and run
    Write-Host "[7/7] Installing app..." -ForegroundColor Yellow
    adb uninstall com.squashtrainingapp 2>$null
    adb install -r $apkPath
    
    # Launch
    adb shell am start -n com.squashtrainingapp/.MainActivity
    
    Write-Host "`n=== APP LAUNCHED ===" -ForegroundColor Green
    Write-Host "Streaming logs..." -ForegroundColor Cyan
    
    # Clear and stream logs
    adb logcat -c
    adb logcat ReactNative:V ReactNativeJS:V AndroidRuntime:E *:S
} else {
    Write-Host "  Build failed!" -ForegroundColor Red
    
    # Fallback to simple build
    Write-Host "`nTrying simple build..." -ForegroundColor Yellow
    & .\SIMPLE-DEBUG.ps1
}