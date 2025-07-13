<#
.SYNOPSIS
    Test RecordActivity Directly
    
.DESCRIPTION
    Launch and test RecordActivity directly without navigation
#>

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Configuration
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$ADB = "$env:ANDROID_HOME\platform-tools\adb.exe"
$PackageName = "com.squashtrainingapp"
$ScreenshotsDir = "C:\git\routine_app\build-artifacts\screenshots"

Write-Host "=== TESTING RECORD ACTIVITY DIRECTLY ===" -ForegroundColor Cyan

# Check if app is installed
$packages = & $ADB shell pm list packages 2>&1
if ($packages -match $PackageName) {
    Write-Host "App is installed" -ForegroundColor Green
} else {
    Write-Host "Installing app..." -ForegroundColor Yellow
    $apkPath = "C:\git\routine_app\SquashTrainingApp\android\app\build\outputs\apk\debug\app-debug.apk"
    & $ADB install $apkPath
}

# Launch RecordActivity directly
Write-Host "`nLaunching RecordActivity..." -ForegroundColor Cyan
& $ADB shell am start -n "$PackageName/.RecordActivity"
Start-Sleep -Seconds 3

# Capture initial screenshot
Write-Host "Capturing RecordActivity screenshot..." -ForegroundColor Cyan
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
& $ADB shell screencap -p /sdcard/record_direct.png
& $ADB pull /sdcard/record_direct.png "$ScreenshotsDir\cycle17_record_direct_$timestamp.png"
& $ADB shell rm /sdcard/record_direct.png

# Test Exercise inputs
Write-Host "`nTesting Exercise form inputs..." -ForegroundColor Cyan

# Click on exercise name field and enter text
& $ADB shell input tap 540 600
Start-Sleep -Seconds 1
& $ADB shell input text "Cross Court Drive"

# Tab to sets field
& $ADB shell input keyevent 61
Start-Sleep -Seconds 1
& $ADB shell input text "4"

# Tab to reps field
& $ADB shell input keyevent 61
Start-Sleep -Seconds 1
& $ADB shell input text "12"

# Tab to duration field
& $ADB shell input keyevent 61
Start-Sleep -Seconds 1
& $ADB shell input text "25"

# Hide keyboard
& $ADB shell input keyevent 111

# Capture after input
Start-Sleep -Seconds 1
& $ADB shell screencap -p /sdcard/exercise_filled.png
& $ADB pull /sdcard/exercise_filled.png "$ScreenshotsDir\cycle17_exercise_filled_$timestamp.png"
& $ADB shell rm /sdcard/exercise_filled.png

# Test Ratings tab
Write-Host "`nTesting Ratings tab..." -ForegroundColor Cyan
& $ADB shell input tap 540 300  # Click on Ratings tab
Start-Sleep -Seconds 2

# Adjust sliders
& $ADB shell input swipe 200 700 800 700 300  # Intensity
Start-Sleep -Seconds 1
& $ADB shell input swipe 200 900 600 900 300  # Condition
Start-Sleep -Seconds 1
& $ADB shell input swipe 200 1100 700 1100 300  # Fatigue

# Capture ratings
& $ADB shell screencap -p /sdcard/ratings_adjusted.png
& $ADB pull /sdcard/ratings_adjusted.png "$ScreenshotsDir\cycle17_ratings_adjusted_$timestamp.png"
& $ADB shell rm /sdcard/ratings_adjusted.png

# Test Memo tab
Write-Host "`nTesting Memo tab..." -ForegroundColor Cyan
& $ADB shell input tap 810 300  # Click on Memo tab
Start-Sleep -Seconds 2

# Enter memo text
& $ADB shell input tap 540 700
Start-Sleep -Seconds 1
& $ADB shell input text "Excellent workout session. Improved cross court accuracy and power. Need to work on backhand volleys."

# Capture memo
& $ADB shell screencap -p /sdcard/memo_filled.png
& $ADB pull /sdcard/memo_filled.png "$ScreenshotsDir\cycle17_memo_filled_$timestamp.png"
& $ADB shell rm /sdcard/memo_filled.png

# Test Save button
Write-Host "`nTesting Save button..." -ForegroundColor Cyan
& $ADB shell input tap 540 2100
Start-Sleep -Seconds 2

# Final screenshot
& $ADB shell screencap -p /sdcard/save_result.png
& $ADB pull /sdcard/save_result.png "$ScreenshotsDir\cycle17_save_result_$timestamp.png"
& $ADB shell rm /sdcard/save_result.png

Write-Host "`n=== RECORD ACTIVITY TEST COMPLETE ===" -ForegroundColor Green
Write-Host "Screenshots saved to: $ScreenshotsDir" -ForegroundColor Yellow

# Check if we're back at home
& $ADB shell dumpsys activity activities | Select-String "mResumedActivity"