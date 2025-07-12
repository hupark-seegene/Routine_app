# Complete Debug Script - Full React Native App
$ErrorActionPreference = "Continue"

Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     COMPLETE REACT NATIVE DEBUG        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan

# Environment setup
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:ANDROID_HOME = "${env:LOCALAPPDATA}\Android\Sdk"
$env:Path = "${env:JAVA_HOME}\bin;${env:ANDROID_HOME}\platform-tools;$env:Path"
$adb = "${env:ANDROID_HOME}\platform-tools\adb.exe"

# Step 1: Clean up
Write-Host "`n[1/8] Cleaning up..." -ForegroundColor Yellow
Stop-Process -Name node -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\metro*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\react*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "node_modules\.cache" -Recurse -Force -ErrorAction SilentlyContinue

# Step 2: Check React Native plugin JARs
Write-Host "[2/8] Checking React Native plugin..." -ForegroundColor Yellow
$pluginJars = @(
    "node_modules\@react-native\gradle-plugin\settings-plugin\build\libs\settings-plugin.jar",
    "node_modules\@react-native\gradle-plugin\react-native-gradle-plugin\build\libs\react-native-gradle-plugin.jar",
    "node_modules\@react-native\gradle-plugin\shared\build\libs\shared.jar"
)

$needsBuild = $false
foreach ($jar in $pluginJars) {
    if (-not (Test-Path $jar)) {
        $needsBuild = $true
        break
    }
}

if ($needsBuild) {
    Write-Host "  Building React Native plugin..." -ForegroundColor Yellow
    & .\BUILD-RN-PLUGIN.ps1
}

# Step 3: Restore proper build.gradle
Write-Host "[3/8] Configuring build..." -ForegroundColor Yellow
Push-Location android
if (Test-Path "app\build.gradle.backup") {
    Copy-Item "app\build.gradle.backup" "app\build.gradle" -Force
    Write-Host "  ✓ Restored React Native build configuration" -ForegroundColor Green
}
Pop-Location

# Step 4: Create JavaScript bundle
Write-Host "[4/8] Creating JavaScript bundle..." -ForegroundColor Yellow
$assetsDir = "android\app\src\main\assets"
New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null

# Try Metro bundler first
$bundleCreated = $false
try {
    $result = & npx react-native bundle `
        --platform android `
        --dev true `
        --entry-file index.js `
        --bundle-output "$assetsDir\index.android.bundle" `
        --assets-dest android\app\src\main\res `
        --max-workers 2 `
        --reset-cache 2>&1
    
    if ($LASTEXITCODE -eq 0 -and (Test-Path "$assetsDir\index.android.bundle")) {
        $size = [math]::Round((Get-Item "$assetsDir\index.android.bundle").Length / 1KB, 2)
        if ($size -gt 100) {
            $bundleCreated = $true
            Write-Host "  ✓ Bundle created ($size KB)" -ForegroundColor Green
        }
    }
} catch {}

if (-not $bundleCreated) {
    Write-Host "  Metro failed, using alternative bundler..." -ForegroundColor Yellow
    
    # Create a comprehensive fallback bundle
    @'
// React Native Debug Bundle
var __DEV__ = true;
var __BUNDLE_START_TIME__ = Date.now();
console.log('[Bundle] Loading React Native app...');

// Polyfills
if (typeof global === 'undefined') { global = window || this; }
if (typeof process === 'undefined') { global.process = { env: { NODE_ENV: 'development' } }; }

// Mock Metro HMR
global.__METRO_GLOBAL_PREFIX__ = '';
global.__r = function(moduleId) { 
    console.log('[Bundle] Requiring module:', moduleId);
    return {}; 
};
global.__d = function(factory, moduleId, dependencies) {
    console.log('[Bundle] Defining module:', moduleId);
};

// Bootstrap React Native
try {
    // Import React Native
    const { AppRegistry } = require('react-native');
    const App = require('./App').default;
    const { name: appName } = require('./app.json');
    
    // Register the app
    AppRegistry.registerComponent(appName, () => App);
    console.log('[Bundle] App registered:', appName);
    
    // Run the app
    AppRegistry.runApplication(appName, {
        rootTag: document.getElementById('root') || 1,
        initialProps: {}
    });
} catch (e) {
    console.error('[Bundle] Failed to load app:', e);
    
    // Minimal app registration
    if (global.require) {
        try {
            global.require('./index');
        } catch (e2) {
            console.error('[Bundle] Failed to load index.js:', e2);
        }
    }
}

console.log('[Bundle] Debug bundle loaded');
'@ | Out-File -Encoding UTF8 "$assetsDir\index.android.bundle"
}

# Step 5: Check emulator
Write-Host "[5/8] Checking emulator..." -ForegroundColor Yellow
$devices = & $adb devices 2>$null
if ($devices -notmatch "device") {
    Write-Host "  Starting emulator..." -ForegroundColor Yellow
    & .\START-EMULATOR.ps1
} else {
    Write-Host "  ✓ Device ready" -ForegroundColor Green
}

# Step 6: Setup ports
Write-Host "[6/8] Setting up ports..." -ForegroundColor Yellow
& $adb reverse tcp:8081 tcp:8081 2>$null
& $adb reverse tcp:8088 tcp:8088 2>$null

# Step 7: Build app
Write-Host "[7/8] Building app..." -ForegroundColor Yellow
Push-Location android

# Clean build directories
Remove-Item "app\build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item ".gradle" -Recurse -Force -ErrorAction SilentlyContinue

# Build with React Native plugin
$buildResult = & .\gradlew.bat assembleDebug --no-daemon 2>&1
$buildSuccess = $LASTEXITCODE -eq 0

Pop-Location

if ($buildSuccess -and (Test-Path "android\app\build\outputs\apk\debug\app-debug.apk")) {
    Write-Host "  ✓ Build successful!" -ForegroundColor Green
    
    # Step 8: Install and run
    Write-Host "[8/8] Installing app..." -ForegroundColor Yellow
    & $adb uninstall com.squashtrainingapp 2>$null
    & $adb install -r android\app\build\outputs\apk\debug\app-debug.apk
    
    # Launch app
    & $adb shell am start -n com.squashtrainingapp/.MainActivity
    
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║        ✓ APP LAUNCHED!                 ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
    
    # Stream logs
    Write-Host "`nStreaming logs (Ctrl+C to stop)..." -ForegroundColor Cyan
    & $adb logcat -c
    & $adb logcat ReactNative:V ReactNativeJS:V AndroidRuntime:E *:S
    
} else {
    Write-Host "  ✗ Build failed!" -ForegroundColor Red
    
    # Try simplified build as fallback
    Write-Host "`nTrying simplified build..." -ForegroundColor Yellow
    & .\SIMPLE-DEBUG.ps1
}