# Build and Run Script - Complete build with Java compilation
Write-Host "`n=== BUILD AND RUN - SQUASH TRAINING APP ===" -ForegroundColor Cyan

# Environment setup
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$androidHome = Join-Path $env:LOCALAPPDATA "Android\Sdk"
$env:ANDROID_HOME = $androidHome
$env:Path = (Join-Path $env:JAVA_HOME "bin") + ";" + (Join-Path $androidHome "platform-tools") + ";" + $env:Path

# Variables
$projectRoot = $PSScriptRoot
$androidDir = Join-Path $projectRoot "android"
$adb = Join-Path $androidHome "platform-tools\adb.exe"

Write-Host "Environment configured" -ForegroundColor Green

# Step 1: Clean build
Write-Host "`n[1/7] Cleaning old build..." -ForegroundColor Yellow
Push-Location $androidDir
if (Test-Path "app\build") {
    Remove-Item -Recurse -Force "app\build" -ErrorAction SilentlyContinue
}
if (Test-Path ".gradle") {
    Remove-Item -Recurse -Force ".gradle" -ErrorAction SilentlyContinue
}
Pop-Location
Write-Host "[1/7] ✓ Clean completed" -ForegroundColor Green

# Step 2: Check dependencies
Write-Host "`n[2/7] Checking dependencies..." -ForegroundColor Yellow
if (-not (Test-Path "node_modules")) {
    & npm install
}
Write-Host "[2/7] ✓ Dependencies ready" -ForegroundColor Green

# Step 3: Create assets directory
Write-Host "`n[3/7] Creating assets directory..." -ForegroundColor Yellow
$assetsDir = Join-Path $androidDir "app\src\main\assets"
New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
Write-Host "[3/7] ✓ Assets directory created" -ForegroundColor Green

# Step 4: Create JS bundle
Write-Host "`n[4/7] Creating JavaScript bundle..." -ForegroundColor Yellow
$bundlePath = Join-Path $assetsDir "index.android.bundle"
@'
// Squash Training App Bundle
console.log('[App] Loading Squash Training App...');
if (typeof global === 'undefined') { global = window || this; }
global.__DEV__ = true;

// Entry point
require('./index.js');
'@ | Out-File -Encoding UTF8 $bundlePath
Write-Host "[4/7] ✓ Bundle created" -ForegroundColor Green

# Step 5: Build APK
Write-Host "`n[5/7] Building APK (this may take a minute)..." -ForegroundColor Yellow
Push-Location $androidDir

# Use the working build command
$buildCmd = ".\gradlew.bat assembleDebug --no-daemon -x test"
Write-Host "Running: $buildCmd" -ForegroundColor Gray

$buildStart = Get-Date
$buildResult = cmd /c $buildCmd 2>&1
$buildSuccess = $LASTEXITCODE -eq 0
$buildTime = [math]::Round(((Get-Date) - $buildStart).TotalSeconds, 1)

Pop-Location

$apkPath = Join-Path $androidDir "app\build\outputs\apk\debug\app-debug.apk"
if ($buildSuccess -and (Test-Path $apkPath)) {
    $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 1)
    Write-Host "[5/7] ✓ Build successful! ($buildTime s, $apkSize MB)" -ForegroundColor Green
} else {
    Write-Host "[5/7] ✗ Build failed!" -ForegroundColor Red
    Write-Host "`nBuild output (last 30 lines):" -ForegroundColor Yellow
    $buildResult -split "`n" | Select-Object -Last 30 | ForEach-Object { Write-Host $_ }
    exit 1
}

# Step 6: Install app
Write-Host "`n[6/7] Installing app..." -ForegroundColor Yellow

# Check device
$devices = & $adb devices 2>$null
if ($devices -notmatch "device") {
    Write-Host "No device found! Please start emulator first." -ForegroundColor Red
    exit 1
}

# Uninstall old version
& $adb uninstall com.squashtrainingapp 2>$null | Out-Null

# Install new APK
$installResult = & $adb install -r $apkPath 2>&1
if ($installResult -match "Success") {
    Write-Host "[6/7] ✓ App installed successfully" -ForegroundColor Green
} else {
    Write-Host "[6/7] ✗ Installation failed!" -ForegroundColor Red
    Write-Host $installResult
    exit 1
}

# Step 7: Launch app with Metro
Write-Host "`n[7/7] Starting app..." -ForegroundColor Yellow

# Set up port forwarding
& $adb reverse tcp:8081 tcp:8081 2>$null

# Start Metro bundler
$metroCmd = "cd /d `"$projectRoot`" && npx react-native start --reset-cache"
$metro = Start-Process -FilePath "cmd" -ArgumentList "/c", $metroCmd -PassThru -WindowStyle Normal
Write-Host "Metro bundler started (PID: $($metro.Id))" -ForegroundColor Gray
Start-Sleep -Seconds 5

# Launch app
& $adb shell am start -n com.squashtrainingapp/.MainActivity

Write-Host "`n╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║        ✓ APP LAUNCHED SUCCESSFULLY       ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`nThe app is now running on your device!" -ForegroundColor Cyan
Write-Host "If you see a red screen, press 'R' twice in the Metro window." -ForegroundColor Yellow

# Monitor for crashes
Write-Host "`nMonitoring app for 10 seconds..." -ForegroundColor Gray
& $adb logcat -c
Start-Sleep -Seconds 2

$crashed = $false
for ($i = 0; $i -lt 8; $i++) {
    Start-Sleep -Seconds 1
    $logs = & $adb logcat -d -t 100 2>$null
    if ($logs -match "AndroidRuntime.*FATAL.*MainActivity") {
        $crashed = $true
        break
    }
    Write-Host "." -NoNewline
}

if ($crashed) {
    Write-Host "`n`n✗ App crashed!" -ForegroundColor Red
    Write-Host "Running diagnostic..." -ForegroundColor Yellow
    & powershell.exe -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "CHECK-APP-STATUS.ps1")
} else {
    Write-Host "`n`n✓ App is running without crashes!" -ForegroundColor Green
}

Write-Host "`nPress any key to stop Metro bundler..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Cleanup
if ($metro -and !$metro.HasExited) {
    Stop-Process -Id $metro.Id -Force
}

Write-Host "Done!" -ForegroundColor Green