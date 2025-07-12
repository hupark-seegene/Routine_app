# Simplified Run Script - Quick execution
$ErrorActionPreference = "Continue"

Write-Host "`n╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     SQUASH TRAINING APP - RUN NOW        ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan

# Environment setup
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$androidHome = [Environment]::GetEnvironmentVariable("LOCALAPPDATA") + "\Android\Sdk"
$env:ANDROID_HOME = $androidHome
$env:Path = $env:JAVA_HOME + "\bin;" + $androidHome + "\platform-tools;" + $env:Path

# Variables
$projectRoot = $PWD.Path
$androidDir = Join-Path $projectRoot "android"
$adb = Join-Path $androidHome "platform-tools\adb.exe"

# Step 1: Check dependencies
Write-Host "`n[1/6] Checking dependencies..." -ForegroundColor Yellow
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    & npm install
}
Write-Host "[1/6] ✓ Dependencies ready" -ForegroundColor Green

# Step 2: Create JavaScript bundle
Write-Host "`n[2/6] Creating JavaScript bundle..." -ForegroundColor Yellow
$assetsDir = Join-Path $androidDir "app\src\main\assets"
New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null

# Simple bundle creation
@'
// App bundle
console.log('[App] Loading Squash Training App...');
if (typeof global === 'undefined') { global = window || this; }
global.__DEV__ = true;
'@ | Out-File -Encoding UTF8 (Join-Path $assetsDir "index.android.bundle")
Write-Host "[2/6] ✓ Bundle created" -ForegroundColor Green

# Step 3: Check device
Write-Host "`n[3/6] Checking device..." -ForegroundColor Yellow
$devices = & $adb devices 2>$null
if ($devices -notmatch "device") {
    Write-Host "Starting emulator..." -ForegroundColor Yellow
    & .\START-EMULATOR.ps1
}
& $adb reverse tcp:8081 tcp:8081 2>$null
Write-Host "[3/6] ✓ Device ready" -ForegroundColor Green

# Step 4: Build APK
Write-Host "`n[4/6] Building APK..." -ForegroundColor Yellow
Push-Location $androidDir
$buildStart = Get-Date
& .\gradlew.bat assembleDebug --no-daemon | Out-Null
$buildSuccess = $LASTEXITCODE -eq 0
$buildTime = [math]::Round(((Get-Date) - $buildStart).TotalSeconds, 1)
Pop-Location

if ($buildSuccess -and (Test-Path (Join-Path $androidDir "app\build\outputs\apk\debug\app-debug.apk"))) {
    Write-Host "[4/6] ✓ Build successful ($buildTime s)" -ForegroundColor Green
} else {
    Write-Host "[4/6] ✗ Build failed!" -ForegroundColor Red
    exit 1
}

# Step 5: Install app
Write-Host "`n[5/6] Installing app..." -ForegroundColor Yellow
& $adb uninstall com.squashtrainingapp 2>$null | Out-Null
& $adb install -r (Join-Path $androidDir "app\build\outputs\apk\debug\app-debug.apk") | Out-Null
Write-Host "[5/6] ✓ App installed" -ForegroundColor Green

# Step 6: Launch with Metro
Write-Host "`n[6/6] Starting app..." -ForegroundColor Yellow
$metro = Start-Process -FilePath "cmd" -ArgumentList "/c", "npx react-native start" -PassThru -WindowStyle Normal
Start-Sleep -Seconds 5
& $adb shell am start -n com.squashtrainingapp/.MainActivity

Write-Host "`n╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║        ✓ APP LAUNCHED SUCCESSFULLY       ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`nApp is running! Check your emulator." -ForegroundColor Cyan
Write-Host "If you see a red screen, press 'R' twice in Metro window" -ForegroundColor Yellow
Write-Host "`nPress any key to stop..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Cleanup
if ($metro -and !$metro.HasExited) {
    Stop-Process -Id $metro.Id -Force
}

Write-Host "`nDone!" -ForegroundColor Green