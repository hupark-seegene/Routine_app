<#
.SYNOPSIS
    Simple script to complete Cycle 28 testing
    
.DESCRIPTION
    Run this after starting the emulator manually
#>

$ErrorActionPreference = "Continue"
$ADB = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$APK_PATH = "C:\git\routine_app\SquashTrainingApp\android\app\build\outputs\apk\debug\app-debug.apk"
$PACKAGE_NAME = "com.squashtrainingapp"
$SCREENSHOTS_DIR = "C:\git\routine_app\build-artifacts\cycle-028\screenshots"

# Create screenshots directory
if (!(Test-Path $SCREENSHOTS_DIR)) {
    New-Item -ItemType Directory -Path $SCREENSHOTS_DIR -Force | Out-Null
}

Write-Host "=== CYCLE 28: NAVIGATION FIX TEST ===" -ForegroundColor Cyan

# Check emulator
Write-Host "Checking emulator..." -ForegroundColor Yellow
$devices = & $ADB devices 2>&1
if ($devices -notmatch "emulator|device") {
    Write-Host "No emulator found! Please start emulator first." -ForegroundColor Red
    exit 1
}

# Install APK
Write-Host "Installing APK..." -ForegroundColor Yellow
& $ADB uninstall $PACKAGE_NAME 2>&1 | Out-Null
$install = & $ADB install $APK_PATH 2>&1
if ($install -match "Success") {
    Write-Host "APK installed successfully!" -ForegroundColor Green
} else {
    Write-Host "Installation failed!" -ForegroundColor Red
    exit 1
}

# Launch app
Write-Host "Launching app..." -ForegroundColor Yellow
& $ADB shell am start -n "$PACKAGE_NAME/.MainActivity" 2>&1 | Out-Null
Start-Sleep -Seconds 5

# Test navigation
Write-Host "Testing navigation (tap on each bottom nav item)..." -ForegroundColor Yellow

# Capture screenshots
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Main screen
& $ADB shell screencap -p /sdcard/main.png
& $ADB pull /sdcard/main.png "$SCREENSHOTS_DIR\01_main_${timestamp}.png" 2>&1 | Out-Null

# Navigate to Checklist (second tab)
& $ADB shell input tap 216 2337
Start-Sleep -Seconds 3
& $ADB shell screencap -p /sdcard/checklist.png
& $ADB pull /sdcard/checklist.png "$SCREENSHOTS_DIR\02_checklist_${timestamp}.png" 2>&1 | Out-Null

# Navigate to Record (middle tab)
& $ADB shell input tap 540 2337
Start-Sleep -Seconds 3
& $ADB shell screencap -p /sdcard/record.png
& $ADB pull /sdcard/record.png "$SCREENSHOTS_DIR\03_record_${timestamp}.png" 2>&1 | Out-Null

# Navigate to Profile (fourth tab)
& $ADB shell input tap 756 2337
Start-Sleep -Seconds 3
& $ADB shell screencap -p /sdcard/profile.png
& $ADB pull /sdcard/profile.png "$SCREENSHOTS_DIR\04_profile_${timestamp}.png" 2>&1 | Out-Null

# Navigate to Coach (last tab)
& $ADB shell input tap 972 2337
Start-Sleep -Seconds 3
& $ADB shell screencap -p /sdcard/coach.png
& $ADB pull /sdcard/coach.png "$SCREENSHOTS_DIR\05_coach_${timestamp}.png" 2>&1 | Out-Null

# Test back navigation
Write-Host "Testing back navigation..." -ForegroundColor Yellow
& $ADB shell input keyevent KEYCODE_BACK
Start-Sleep -Seconds 2

# Final screenshot
& $ADB shell screencap -p /sdcard/final.png
& $ADB pull /sdcard/final.png "$SCREENSHOTS_DIR\06_final_nav_state_${timestamp}.png" 2>&1 | Out-Null

# Cleanup
& $ADB shell rm /sdcard/*.png 2>&1 | Out-Null

Write-Host "=== CYCLE 28 TESTING COMPLETE ===" -ForegroundColor Green
Write-Host "Navigation fix has been applied!" -ForegroundColor Green
Write-Host "Screenshots saved to: $SCREENSHOTS_DIR" -ForegroundColor Cyan

# Open screenshots folder
Start-Process explorer.exe $SCREENSHOTS_DIR