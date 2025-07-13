<#
.SYNOPSIS
    Cycle 17 - Final Complete Test with Navigation Fix
    
.DESCRIPTION
    Complete testing of Cycle 17 with proper navigation handling
#>

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Configuration
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$ADB = "$env:ANDROID_HOME\platform-tools\adb.exe"
$PackageName = "com.squashtrainingapp"
$ScreenshotsDir = "C:\git\routine_app\build-artifacts\screenshots"

Write-Host "=== CYCLE 17 FINAL TESTING ===" -ForegroundColor Cyan
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Function to capture screenshot
function Capture-Screenshot {
    param($name)
    $filename = "cycle17_final_${name}_${timestamp}.png"
    & $ADB shell screencap -p /sdcard/temp.png
    & $ADB pull /sdcard/temp.png "$ScreenshotsDir\$filename" 2>&1 | Out-Null
    & $ADB shell rm /sdcard/temp.png
    Write-Host "Screenshot captured: $filename" -ForegroundColor Green
}

# Check app installation
$packages = & $ADB shell pm list packages 2>&1
if (!($packages -match $PackageName)) {
    Write-Host "Installing app..." -ForegroundColor Yellow
    $apkPath = "C:\git\routine_app\SquashTrainingApp\android\app\build\outputs\apk\debug\app-debug.apk"
    & $ADB install $apkPath
}

# Test 1: Launch MainActivity
Write-Host "`nTest 1: Launching MainActivity..." -ForegroundColor Cyan
& $ADB shell am start -n "$PackageName/.MainActivity"
Start-Sleep -Seconds 3
Capture-Screenshot "home_screen"

# Test 2: Try direct RecordActivity launch
Write-Host "`nTest 2: Launching RecordActivity directly..." -ForegroundColor Cyan
& $ADB shell am start -n "$PackageName/.RecordActivity"
Start-Sleep -Seconds 3
Capture-Screenshot "record_direct_attempt"

# Test 3: Navigate using coordinates for all tabs
Write-Host "`nTest 3: Testing navigation through tabs..." -ForegroundColor Cyan

# Return to MainActivity first
& $ADB shell am start -n "$PackageName/.MainActivity"
Start-Sleep -Seconds 2

# Try Checklist (2nd tab)
Write-Host "Testing Checklist tab..." -ForegroundColor Yellow
& $ADB shell input tap 216 2337
Start-Sleep -Seconds 3
Capture-Screenshot "checklist_navigation"

# Since ChecklistActivity launches, let's go back
& $ADB shell input keyevent KEYCODE_BACK
Start-Sleep -Seconds 2

# Try Record (3rd tab) - multiple coordinates
Write-Host "Testing Record tab with multiple coordinates..." -ForegroundColor Yellow
$recordCoordinates = @(
    @{X=540; Y=2337; Name="center"},
    @{X=324; Y=2337; Name="center_left"},
    @{X=432; Y=2337; Name="center_right"}
)

foreach ($coord in $recordCoordinates) {
    Write-Host "Trying coordinate: $($coord.Name) (X=$($coord.X), Y=$($coord.Y))" -ForegroundColor Cyan
    & $ADB shell input tap $coord.X $coord.Y
    Start-Sleep -Seconds 2
    
    # Check current activity
    $currentActivity = & $ADB shell dumpsys activity activities | Select-String "mResumedActivity" | Out-String
    if ($currentActivity -match "RecordActivity") {
        Write-Host "SUCCESS: RecordActivity is active!" -ForegroundColor Green
        Capture-Screenshot "record_screen_success"
        
        # Test Record features
        Write-Host "`nTesting Record Screen Features..." -ForegroundColor Cyan
        
        # Exercise tab (should be default)
        Write-Host "Testing Exercise inputs..." -ForegroundColor Yellow
        & $ADB shell input tap 540 600  # Exercise name
        Start-Sleep -Seconds 1
        & $ADB shell input text "Straight Drive Practice"
        & $ADB shell input keyevent 111  # Hide keyboard
        
        & $ADB shell input tap 270 850  # Sets
        Start-Sleep -Seconds 1
        & $ADB shell input text "3"
        
        & $ADB shell input tap 810 850  # Reps
        Start-Sleep -Seconds 1
        & $ADB shell input text "10"
        
        Capture-Screenshot "exercise_filled"
        
        # Ratings tab
        Write-Host "Testing Ratings tab..." -ForegroundColor Yellow
        & $ADB shell input tap 540 350  # Ratings tab
        Start-Sleep -Seconds 2
        
        # Adjust sliders
        & $ADB shell input swipe 200 700 700 700 300
        Start-Sleep -Seconds 1
        & $ADB shell input swipe 200 900 500 900 300
        Start-Sleep -Seconds 1
        
        Capture-Screenshot "ratings_adjusted"
        
        # Memo tab
        Write-Host "Testing Memo tab..." -ForegroundColor Yellow
        & $ADB shell input tap 810 350  # Memo tab
        Start-Sleep -Seconds 2
        
        & $ADB shell input tap 540 700
        Start-Sleep -Seconds 1
        & $ADB shell input text "Great workout session today"
        
        Capture-Screenshot "memo_filled"
        
        # Save button
        Write-Host "Testing Save button..." -ForegroundColor Yellow
        & $ADB shell input tap 540 2100
        Start-Sleep -Seconds 2
        Capture-Screenshot "save_result"
        
        break
    }
}

# Test 4: Profile and Coach screens
Write-Host "`nTest 4: Testing other screens..." -ForegroundColor Cyan

# Return to MainActivity
& $ADB shell am start -n "$PackageName/.MainActivity"
Start-Sleep -Seconds 2

# Profile (4th tab)
& $ADB shell input tap 756 2337
Start-Sleep -Seconds 2
Capture-Screenshot "profile_screen"

# Coach (5th tab)
& $ADB shell input tap 972 2337
Start-Sleep -Seconds 2
Capture-Screenshot "coach_screen"

# Generate summary
Write-Host "`n=== CYCLE 17 FINAL TEST SUMMARY ===" -ForegroundColor Green
Write-Host "Test completed at: $(Get-Date)" -ForegroundColor Cyan
Write-Host "Screenshots saved to: $ScreenshotsDir" -ForegroundColor Yellow

# List all captured screenshots
$screenshots = Get-ChildItem "$ScreenshotsDir\cycle17_final_*_$timestamp.png" | Select-Object -ExpandProperty Name
Write-Host "`nCaptured screenshots:" -ForegroundColor Cyan
$screenshots | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }

Write-Host "`n=== TEST COMPLETE ===" -ForegroundColor Green