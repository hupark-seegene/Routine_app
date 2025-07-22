# Quick Install and Run Script
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Quick Install and Run Squash App" -ForegroundColor White
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Find adb in common locations
$adbPaths = @(
    "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
    "$env:PROGRAMFILES\Android\android-sdk\platform-tools\adb.exe",
    "$env:PROGRAMFILES(x86)\Android\android-sdk\platform-tools\adb.exe",
    "C:\Android\sdk\platform-tools\adb.exe",
    "C:\adb\adb.exe"
)

$adb = $null
foreach ($path in $adbPaths) {
    if (Test-Path $path) {
        $adb = $path
        Write-Host "Found adb at: $adb" -ForegroundColor Green
        break
    }
}

if (-not $adb) {
    Write-Host "Error: adb not found!" -ForegroundColor Red
    Write-Host "Please install Android SDK Platform Tools"
    exit 1
}

# APK path
$apkPath = "..\..\android\app\build\outputs\apk\debug\app-debug.apk"

if (-not (Test-Path $apkPath)) {
    Write-Host "Error: APK not found at $apkPath" -ForegroundColor Red
    Write-Host "Please build the app first"
    exit 1
}

Write-Host "APK found: $apkPath" -ForegroundColor Green

# Kill any existing adb server
Write-Host "Restarting ADB server..." -ForegroundColor Yellow
& $adb kill-server
Start-Sleep -Seconds 2
& $adb start-server
Start-Sleep -Seconds 2

# List devices
Write-Host ""
Write-Host "Checking connected devices..." -ForegroundColor Yellow
$devices = & $adb devices
Write-Host $devices

# Install APK
Write-Host ""
Write-Host "Installing APK..." -ForegroundColor Yellow
$installResult = & $adb install -r $apkPath 2>&1
if ($installResult -match "Success") {
    Write-Host "✅ APK installed successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Installation failed!" -ForegroundColor Red
    Write-Host $installResult
    
    # Try to connect to common emulator ports
    Write-Host ""
    Write-Host "Trying to connect to emulator..." -ForegroundColor Yellow
    $ports = @(5554, 5555, 5556, 21503)
    foreach ($port in $ports) {
        Write-Host "Trying port $port..."
        $connectResult = & $adb connect "127.0.0.1:$port" 2>&1
        Write-Host $connectResult
        if ($connectResult -match "connected") {
            Write-Host "✅ Connected to emulator!" -ForegroundColor Green
            break
        }
    }
    
    # Retry installation
    Write-Host ""
    Write-Host "Retrying installation..." -ForegroundColor Yellow
    $installResult = & $adb install -r $apkPath 2>&1
    if ($installResult -match "Success") {
        Write-Host "✅ APK installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Installation still failed!" -ForegroundColor Red
        Write-Host $installResult
        exit 1
    }
}

# Launch app
Write-Host ""
Write-Host "Launching app..." -ForegroundColor Yellow
$launchResult = & $adb shell am start -n com.squashtrainingapp/.SimpleMainActivity 2>&1
if ($launchResult -match "Error") {
    Write-Host "❌ Failed to launch app!" -ForegroundColor Red
    Write-Host $launchResult
} else {
    Write-Host "✅ App launched successfully!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")