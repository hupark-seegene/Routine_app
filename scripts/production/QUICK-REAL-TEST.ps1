<#
.SYNOPSIS
    Quick real test execution with proper device handling
#>

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Configuration
$ADB = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$APK_PATH = "C:\git\routine_app\SquashTrainingApp\android\app\build\outputs\apk\debug\app-debug.apk"
$PACKAGE_NAME = "com.squashtrainingapp"
$SCREENSHOTS_DIR = "C:\git\routine_app\build-artifacts\screenshots\real-test"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Create screenshots directory
if (!(Test-Path $SCREENSHOTS_DIR)) {
    New-Item -ItemType Directory -Path $SCREENSHOTS_DIR -Force | Out-Null
}

Write-Host "=== REAL TEST EXECUTION ===" -ForegroundColor Cyan

# Get device
Write-Host "Checking devices..." -ForegroundColor Yellow
$devices = & $ADB devices 2>&1
Write-Host $devices

# Start emulator if needed
if ($devices -notmatch "device`$") {
    Write-Host "No device found. Starting Pixel_6..." -ForegroundColor Yellow
    $EMULATOR = "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe"
    Start-Process -FilePath $EMULATOR -ArgumentList "-avd", "Pixel_6" -WindowStyle Minimized
    
    Write-Host "Waiting for device..." -ForegroundColor Yellow
    & $ADB wait-for-device
    
    # Wait for boot
    $booted = $false
    for ($i = 0; $i -lt 60; $i++) {
        $boot = & $ADB shell getprop sys.boot_completed 2>&1
        if ($boot -match "1") {
            $booted = $true
            break
        }
        Write-Host "." -NoNewline
        Start-Sleep -Seconds 2
    }
    
    if ($booted) {
        Write-Host "`nDevice ready!" -ForegroundColor Green
        Start-Sleep -Seconds 5
    }
}

# Install APK
Write-Host "`nInstalling APK..." -ForegroundColor Yellow
& $ADB uninstall $PACKAGE_NAME 2>&1 | Out-Null
$install = & $ADB install $APK_PATH 2>&1
if ($install -match "Success") {
    Write-Host "APK installed!" -ForegroundColor Green
} else {
    Write-Host "Install failed: $install" -ForegroundColor Red
    exit 1
}

# Function to capture screenshot
function Capture-Screenshot {
    param([string]$Name)
    $filename = "${Name}_${timestamp}.png"
    & $ADB shell screencap -p /sdcard/screenshot.png 2>&1 | Out-Null
    & $ADB pull /sdcard/screenshot.png "$SCREENSHOTS_DIR\$filename" 2>&1 | Out-Null
    & $ADB shell rm /sdcard/screenshot.png 2>&1 | Out-Null
    Write-Host "📸 Screenshot: $filename" -ForegroundColor Magenta
}

# Test 1: Launch app
Write-Host "`n[TEST 1] Launching app..." -ForegroundColor Cyan
& $ADB shell am start -n "$PACKAGE_NAME/.MainActivity" 2>&1 | Out-Null
Start-Sleep -Seconds 5
Capture-Screenshot "01_app_launch"

# Test 2: Navigate to each tab
Write-Host "`n[TEST 2] Testing navigation tabs..." -ForegroundColor Cyan

# Checklist tab
Write-Host "- Checklist tab" -ForegroundColor Yellow
& $ADB shell input tap 216 2337
Start-Sleep -Seconds 3
Capture-Screenshot "02_checklist_tab"

# Record tab
Write-Host "- Record tab" -ForegroundColor Yellow
& $ADB shell input tap 540 2337
Start-Sleep -Seconds 3
Capture-Screenshot "03_record_tab"

# Profile tab
Write-Host "- Profile tab" -ForegroundColor Yellow
& $ADB shell input tap 756 2337
Start-Sleep -Seconds 3
Capture-Screenshot "04_profile_tab"

# Coach tab
Write-Host "- Coach tab" -ForegroundColor Yellow
& $ADB shell input tap 972 2337
Start-Sleep -Seconds 3
Capture-Screenshot "05_coach_tab"

# Test 3: History button
Write-Host "`n[TEST 3] Testing History button..." -ForegroundColor Cyan
& $ADB shell am start -n "$PACKAGE_NAME/.MainActivity" 2>&1 | Out-Null
Start-Sleep -Seconds 2
& $ADB shell input tap 540 900  # History button
Start-Sleep -Seconds 3
Capture-Screenshot "06_history_screen"

# Test 4: RecordActivity tabs
Write-Host "`n[TEST 4] Testing Record screen tabs..." -ForegroundColor Cyan
& $ADB shell am start -n "$PACKAGE_NAME/.RecordActivity" 2>&1 | Out-Null
Start-Sleep -Seconds 3
Capture-Screenshot "07_record_exercise_tab"

# Ratings tab
& $ADB shell input tap 353 257
Start-Sleep -Seconds 2
Capture-Screenshot "08_record_ratings_tab"

# Memo tab
& $ADB shell input tap 588 257
Start-Sleep -Seconds 2
Capture-Screenshot "09_record_memo_tab"

# Test 5: Navigation persistence
Write-Host "`n[TEST 5] Testing navigation persistence (Cycle 28 fix)..." -ForegroundColor Cyan
& $ADB shell am start -n "$PACKAGE_NAME/.MainActivity" 2>&1 | Out-Null
Start-Sleep -Seconds 2

# Navigate to Profile tab
& $ADB shell input tap 756 2337
Start-Sleep -Seconds 2
Capture-Screenshot "10_nav_to_profile"

# Open ProfileActivity
& $ADB shell am start -n "$PACKAGE_NAME/.ProfileActivity" 2>&1 | Out-Null
Start-Sleep -Seconds 3
Capture-Screenshot "11_profile_activity"

# Go back
& $ADB shell input keyevent KEYCODE_BACK
Start-Sleep -Seconds 2
Capture-Screenshot "12_nav_persistence_check"

Write-Host "`n=== TEST COMPLETE ===" -ForegroundColor Green
Write-Host "Screenshots saved to: $SCREENSHOTS_DIR" -ForegroundColor Cyan
Start-Process explorer.exe $SCREENSHOTS_DIR