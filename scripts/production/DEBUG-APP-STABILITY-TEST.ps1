<#
.SYNOPSIS
    Debug App Stability Test - Find and Fix Crashes
    
.DESCRIPTION
    Comprehensive debugging script to identify app crashes
    - Test each screen individually
    - Capture logcat for crash analysis
    - Test all navigation paths
    - Verify database operations
    - Check memory usage
#>

param(
    [switch]$StartEmulator = $false,
    [switch]$KeepInstalled = $true,
    [switch]$CaptureLogcat = $true
)

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Configuration
$ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$ADB = "$ANDROID_HOME\platform-tools\adb.exe"
$PackageName = "com.squashtrainingapp"
$APK_PATH = "C:\git\routine_app\SquashTrainingApp\android\app\build\outputs\apk\debug\app-debug.apk"
$SCREENSHOTS_DIR = "C:\git\routine_app\build-artifacts\screenshots\debug"
$LOGS_DIR = "C:\git\routine_app\build-artifacts\logs"

# Ensure directories exist
if (!(Test-Path $SCREENSHOTS_DIR)) {
    New-Item -ItemType Directory -Path $SCREENSHOTS_DIR -Force | Out-Null
}
if (!(Test-Path $LOGS_DIR)) {
    New-Item -ItemType Directory -Path $LOGS_DIR -Force | Out-Null
}

# Colors
function Write-DebugLog {
    param([string]$Message, [string]$Type = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = switch ($Type) {
        "SUCCESS" { "Green" }
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        "TEST" { "Cyan" }
        "CRASH" { "Magenta" }
        default { "White" }
    }
    Write-Host "[$timestamp] $Message" -ForegroundColor $color
}

function Start-LogcatCapture {
    $logFile = Join-Path $LOGS_DIR "logcat_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    Write-DebugLog "Starting logcat capture to: $logFile" "INFO"
    Start-Process -FilePath $ADB -ArgumentList "logcat", "-c" -NoNewWindow
    $global:LogcatProcess = Start-Process -FilePath $ADB -ArgumentList "logcat", "*:E" -NoNewWindow -PassThru -RedirectStandardOutput $logFile
    return $logFile
}

function Stop-LogcatCapture {
    if ($global:LogcatProcess) {
        Stop-Process -Id $global:LogcatProcess.Id -Force -ErrorAction SilentlyContinue
        Write-DebugLog "Logcat capture stopped" "INFO"
    }
}

function Check-AppRunning {
    $result = & $ADB shell pidof $PackageName 2>&1
    return $result -match '\d+'
}

function Capture-ScreenshotWithCheck {
    param([string]$Name)
    
    Start-Sleep -Seconds 2
    
    if (!(Check-AppRunning)) {
        Write-DebugLog "APP CRASHED! Taking crash screenshot" "CRASH"
        $crashShot = "CRASH_$Name"
    } else {
        Write-DebugLog "App still running, capturing $Name" "SUCCESS"
        $crashShot = $Name
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $filename = "${crashShot}_$timestamp.png"
    & $ADB shell screencap -p /sdcard/screenshot.png
    & $ADB pull /sdcard/screenshot.png "$SCREENSHOTS_DIR\$filename" 2>&1 | Out-Null
    & $ADB shell rm /sdcard/screenshot.png
    
    return !(Check-AppRunning)
}

function Get-CrashLog {
    $crashes = & $ADB logcat -d -b crash 2>&1 | Select-String $PackageName
    if ($crashes) {
        Write-DebugLog "=== CRASH LOG ===" "CRASH"
        $crashes | ForEach-Object { Write-Host $_ -ForegroundColor Red }
        
        # Save crash log
        $crashFile = Join-Path $LOGS_DIR "crash_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
        $crashes | Out-File $crashFile
        Write-DebugLog "Crash log saved to: $crashFile" "WARNING"
    }
}

# Main execution
Write-DebugLog "=== APP STABILITY DEBUG TEST ===" "TEST"
Write-DebugLog "Checking emulator status..." "INFO"

$devices = & $ADB devices 2>&1
$deviceOutput = $devices -join "`n"
if ($deviceOutput -notmatch "emulator-\d+\s+device") {
    Write-DebugLog "No emulator running. Please start it manually." "ERROR"
    exit 1
}

# Clear previous logs
& $ADB logcat -c

# Install APK
Write-DebugLog "Installing APK..." "INFO"
& $ADB uninstall $PackageName 2>&1 | Out-Null
$installResult = & $ADB install $APK_PATH 2>&1
if ($installResult -notmatch "Success") {
    Write-DebugLog "APK installation failed!" "ERROR"
    exit 1
}

# Start logcat capture
$logFile = Start-LogcatCapture

# Test 1: MainActivity Launch
Write-DebugLog "TEST 1: Testing MainActivity launch..." "TEST"
& $ADB shell am start -n "$PackageName/.MainActivity"
Start-Sleep -Seconds 5

if (Capture-ScreenshotWithCheck "01_main_activity") {
    Write-DebugLog "MainActivity crashed on launch!" "CRASH"
    Get-CrashLog
    Stop-LogcatCapture
    exit 1
}

# Test 2: ChecklistActivity
Write-DebugLog "TEST 2: Testing ChecklistActivity..." "TEST"
& $ADB shell input tap 216 2337  # Checklist tab
if (Capture-ScreenshotWithCheck "02_checklist_activity") {
    Write-DebugLog "ChecklistActivity crashed!" "CRASH"
    Get-CrashLog
}

# Test 3: RecordActivity
if (Check-AppRunning) {
    Write-DebugLog "TEST 3: Testing RecordActivity..." "TEST"
    & $ADB shell am start -n "$PackageName/.MainActivity"
    Start-Sleep -Seconds 2
    & $ADB shell input tap 540 2337  # Record tab
    if (Capture-ScreenshotWithCheck "03_record_activity") {
        Write-DebugLog "RecordActivity crashed!" "CRASH"
        Get-CrashLog
    }
}

# Test 4: ProfileActivity
if (Check-AppRunning) {
    Write-DebugLog "TEST 4: Testing ProfileActivity..." "TEST"
    & $ADB shell am start -n "$PackageName/.MainActivity"
    Start-Sleep -Seconds 2
    & $ADB shell input tap 756 2337  # Profile tab
    if (Capture-ScreenshotWithCheck "04_profile_activity") {
        Write-DebugLog "ProfileActivity crashed!" "CRASH"
        Get-CrashLog
    }
}

# Test 5: CoachActivity
if (Check-AppRunning) {
    Write-DebugLog "TEST 5: Testing CoachActivity..." "TEST"
    & $ADB shell am start -n "$PackageName/.MainActivity"
    Start-Sleep -Seconds 2
    & $ADB shell input tap 972 2337  # Coach tab
    if (Capture-ScreenshotWithCheck "05_coach_activity") {
        Write-DebugLog "CoachActivity crashed!" "CRASH"
        Get-CrashLog
    }
}

# Test 6: HistoryActivity
if (Check-AppRunning) {
    Write-DebugLog "TEST 6: Testing HistoryActivity..." "TEST"
    & $ADB shell am start -n "$PackageName/.MainActivity"
    Start-Sleep -Seconds 2
    & $ADB shell input tap 540 900  # History button
    if (Capture-ScreenshotWithCheck "06_history_activity") {
        Write-DebugLog "HistoryActivity crashed!" "CRASH"
        Get-CrashLog
    }
}

# Test 7: Database Operations - Save Record
if (Check-AppRunning) {
    Write-DebugLog "TEST 7: Testing database save..." "TEST"
    & $ADB shell am start -n "$PackageName/.RecordActivity"
    Start-Sleep -Seconds 3
    
    # Fill minimal data
    & $ADB shell input tap 540 410  # Exercise name
    & $ADB shell input text "Test"
    & $ADB shell input tap 540 1450  # Save button
    
    Start-Sleep -Seconds 2
    if (Capture-ScreenshotWithCheck "07_database_save") {
        Write-DebugLog "Database save operation crashed!" "CRASH"
        Get-CrashLog
    }
}

# Test 8: Check saved data in history
if (Check-AppRunning) {
    Write-DebugLog "TEST 8: Testing history with data..." "TEST"
    & $ADB shell am start -n "$PackageName/.HistoryActivity"
    if (Capture-ScreenshotWithCheck "08_history_with_data") {
        Write-DebugLog "HistoryActivity crashed with data!" "CRASH"
        Get-CrashLog
    }
}

# Test 9: Memory check
Write-DebugLog "TEST 9: Checking memory usage..." "TEST"
if (Check-AppRunning) {
    $meminfo = & $ADB shell dumpsys meminfo $PackageName | Select-String "TOTAL" -Context 0,1
    Write-DebugLog "Memory info: $meminfo" "INFO"
} else {
    Write-DebugLog "App not running for memory check" "WARNING"
}

# Stop logcat
Stop-LogcatCapture

# Final crash check
Get-CrashLog

# Analysis
Write-DebugLog "=== STABILITY TEST SUMMARY ===" "TEST"

$screenshots = Get-ChildItem $SCREENSHOTS_DIR -Filter "*.png" | Where-Object { $_.Name -match "^CRASH_" }
if ($screenshots) {
    Write-DebugLog "CRASHES DETECTED:" "CRASH"
    $screenshots | ForEach-Object {
        Write-DebugLog "  - $($_.Name)" "ERROR"
    }
} else {
    Write-DebugLog "No crashes detected during testing" "SUCCESS"
}

Write-DebugLog "Screenshots saved to: $SCREENSHOTS_DIR" "INFO"
Write-DebugLog "Logs saved to: $LOGS_DIR" "INFO"
Write-DebugLog "Logcat file: $logFile" "INFO"

# Get detailed error from logcat
Write-DebugLog "=== CHECKING FOR ERRORS IN LOGCAT ===" "WARNING"
$errors = Get-Content $logFile -ErrorAction SilentlyContinue | Select-String -Pattern "AndroidRuntime|FATAL|$PackageName" -Context 2,2
if ($errors) {
    Write-DebugLog "Errors found in logcat:" "ERROR"
    $errors | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
}

# Cleanup
if (!$KeepInstalled) {
    & $ADB uninstall $PackageName 2>&1 | Out-Null
}

Write-DebugLog "Debug test complete!" "INFO"

# Open folders
Start-Process explorer.exe $SCREENSHOTS_DIR
Start-Process explorer.exe $LOGS_DIR