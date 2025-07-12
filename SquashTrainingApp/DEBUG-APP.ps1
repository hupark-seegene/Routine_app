# Debug Script for Squash Training App
# This script helps debug and fix runtime issues

param(
    [switch]$LogcatOnly = $false,
    [switch]$ClearData = $false,
    [switch]$CheckModules = $false
)

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " SQUASH TRAINING APP - DEBUG MODE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set environment
$env:ANDROID_HOME = "C:\Users\hwpar\AppData\Local\Android\Sdk"
$env:Path = "$env:ANDROID_HOME\platform-tools;$env:Path"

# Check device connection
Write-Host "[CHECK] Device connection..." -ForegroundColor Yellow
$devices = adb devices 2>&1
if ($devices -match "device$") {
    Write-Host "  Device connected!" -ForegroundColor Green
    adb devices
} else {
    Write-Host "  No device connected!" -ForegroundColor Red
    Write-Host "  Please connect a device or start an emulator." -ForegroundColor Yellow
    exit 1
}

# Clear app data if requested
if ($ClearData) {
    Write-Host "`n[CLEAR] Clearing app data..." -ForegroundColor Yellow
    adb shell pm clear com.squashtrainingapp 2>&1
    Write-Host "  App data cleared!" -ForegroundColor Green
}

# Check installed modules
if ($CheckModules) {
    Write-Host "`n[MODULES] Checking native modules..." -ForegroundColor Yellow
    
    # List installed npm packages
    Write-Host "  Installed packages:" -ForegroundColor Gray
    $packages = @(
        "react-native-vector-icons",
        "react-native-sqlite-storage",
        "react-native-svg",
        "react-native-linear-gradient",
        "@react-native-community/slider",
        "react-native-screens",
        "react-native-safe-area-context"
    )
    
    foreach ($pkg in $packages) {
        if (Test-Path "node_modules\$pkg") {
            $version = (Get-Content "node_modules\$pkg\package.json" | ConvertFrom-Json).version
            Write-Host "    ✓ $pkg@$version" -ForegroundColor Green
        } else {
            Write-Host "    ✗ $pkg - NOT INSTALLED" -ForegroundColor Red
        }
    }
}

# Start debugging
if (-not $LogcatOnly) {
    Write-Host "`n[DEBUG] Starting debug session..." -ForegroundColor Yellow
    
    # Clear logcat
    adb logcat -c
    
    # Setup port forwarding
    adb reverse tcp:8081 tcp:8081 2>$null
    Write-Host "  Port forwarding set up" -ForegroundColor Green
    
    # Start Metro in debug mode
    Write-Host "`n[METRO] Starting Metro bundler..." -ForegroundColor Yellow
    $metro = Start-Process -FilePath "cmd" -ArgumentList "/c", "npx react-native start --reset-cache" -PassThru -WindowStyle Normal
    Start-Sleep -Seconds 10
    
    # Launch app
    Write-Host "[LAUNCH] Starting app..." -ForegroundColor Yellow
    adb shell am start -n com.squashtrainingapp/.MainActivity
    
    Write-Host "`n[INFO] Debug session started!" -ForegroundColor Green
    Write-Host "  - Metro bundler is running in separate window" -ForegroundColor Gray
    Write-Host "  - Logcat will show below" -ForegroundColor Gray
    Write-Host "  - Press Ctrl+C to stop" -ForegroundColor Gray
    Write-Host ""
}

# Show logcat with filters
Write-Host "[LOGCAT] Showing app logs..." -ForegroundColor Yellow
Write-Host "  Filters: ReactNative, ReactNativeJS, AndroidRuntime, DEBUG" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create logcat command with filters
$logcatCmd = 'adb logcat ReactNative:V ReactNativeJS:V AndroidRuntime:E DEBUG:V *:S'

# Also save to file
$logFile = "debug-log-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
Write-Host "Logs are also being saved to: $logFile" -ForegroundColor Gray
Write-Host ""

# Start logcat
$logcatProcess = Start-Process -FilePath "cmd" -ArgumentList "/c", "$logcatCmd | tee $logFile" -PassThru -NoNewWindow

# Wait for user to stop
Write-Host "Press any key to stop debugging..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Cleanup
Write-Host "`n[CLEANUP] Stopping debug session..." -ForegroundColor Yellow
if ($logcatProcess -and !$logcatProcess.HasExited) {
    Stop-Process -Id $logcatProcess.Id -Force
}
if ($metro -and !$metro.HasExited) {
    Stop-Process -Id $metro.Id -Force
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " Debug session ended" -ForegroundColor Cyan
Write-Host " Log saved to: $logFile" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

# Show common issues found in log
Write-Host "`n[ANALYSIS] Checking for common issues..." -ForegroundColor Yellow
if (Test-Path $logFile) {
    $logContent = Get-Content $logFile -Raw
    
    $issues = @()
    if ($logContent -match "Unable to load script") {
        $issues += "Metro bundler connection issue - Check port 8081"
    }
    if ($logContent -match "Module .+ does not exist") {
        $issues += "Missing native module - Run 'npm install' and rebuild"
    }
    if ($logContent -match "java\.lang\.ClassNotFoundException") {
        $issues += "Missing Java class - Check MainApplication.java"
    }
    if ($logContent -match "SQLite.*error") {
        $issues += "Database error - Check SQLite initialization"
    }
    
    if ($issues.Count -gt 0) {
        Write-Host "  Found issues:" -ForegroundColor Red
        foreach ($issue in $issues) {
            Write-Host "    - $issue" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  No common issues detected" -ForegroundColor Green
    }
}