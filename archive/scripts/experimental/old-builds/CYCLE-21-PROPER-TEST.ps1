<#
.SYNOPSIS
    Cycle 21: Proper comprehensive testing with screenshots
    
.DESCRIPTION
    - Tests ALL features properly
    - Takes screenshots of EVERYTHING
    - Verifies navigation is working
    - Tests History functionality
    - No rushing, proper debugging
#>

param(
    [switch]$SkipBuild = $false
)

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Configuration
$SCRIPT_NAME = "CYCLE-21-PROPER-TEST"
$ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$ADB = "$ANDROID_HOME\platform-tools\adb.exe"
$PROJECT_ROOT = "C:\git\routine_app\SquashTrainingApp"
$APK_PATH = "$PROJECT_ROOT\android\app\build\outputs\apk\debug\app-debug.apk"
$PACKAGE_NAME = "com.squashtrainingapp"
$SCREENSHOTS_DIR = "C:\git\routine_app\build-artifacts\screenshots\cycle-21-proper"
$LOGS_DIR = "C:\git\routine_app\build-artifacts\logs\cycle-21"

# Create directories
@($SCREENSHOTS_DIR, $LOGS_DIR) | ForEach-Object {
    if (!(Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

# Helper functions
function Write-TestLog {
    param([string]$Message, [string]$Type = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = switch ($Type) {
        "SUCCESS" { "Green" }
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        "TEST" { "Cyan" }
        "SCREEN" { "Magenta" }
        default { "White" }
    }
    Write-Host "[$timestamp] $Message" -ForegroundColor $color
}

function Capture-Screenshot {
    param([string]$Name, [string]$Description)
    Start-Sleep -Seconds 2
    $timestamp = Get-Date -Format "HHmmss"
    $filename = "${Name}_$timestamp.png"
    
    Write-TestLog "📸 Screenshot: $Description" "SCREEN"
    
    & $ADB shell screencap -p /sdcard/screenshot.png 2>&1 | Out-Null
    & $ADB pull /sdcard/screenshot.png "$SCREENSHOTS_DIR\$filename" 2>&1 | Out-Null
    & $ADB shell rm /sdcard/screenshot.png 2>&1 | Out-Null
    
    if (Test-Path "$SCREENSHOTS_DIR\$filename") {
        Write-TestLog "✓ Saved: $filename" "SUCCESS"
        return $true
    } else {
        Write-TestLog "✗ Failed to save screenshot" "ERROR"
        return $false
    }
}

function Check-AppRunning {
    $result = & $ADB shell pidof $PACKAGE_NAME 2>&1
    return $result -match '\d+'
}

function Get-CurrentActivity {
    $activity = & $ADB shell dumpsys activity activities | Select-String "mResumedActivity" | Select-Object -First 1
    if ($activity) {
        return $activity.ToString()
    }
    return "Unknown"
}

# Main execution
Write-TestLog "========================================" "TEST"
Write-TestLog "CYCLE 21: COMPREHENSIVE TESTING" "TEST"
Write-TestLog "========================================" "TEST"

# Build if needed
if (!$SkipBuild) {
    Write-TestLog "Building APK..." "INFO"
    Set-Location "$PROJECT_ROOT\android"
    $buildResult = .\gradlew.bat assembleDebug 2>&1
    
    if (Test-Path $APK_PATH) {
        $apkSize = [math]::Round((Get-Item $APK_PATH).Length / 1MB, 2)
        Write-TestLog "Build successful! APK size: $apkSize MB" "SUCCESS"
    } else {
        Write-TestLog "Build failed!" "ERROR"
        exit 1
    }
}

# Install APK
Write-TestLog "Installing APK..." "INFO"
& $ADB uninstall $PACKAGE_NAME 2>&1 | Out-Null
$install = & $ADB install $APK_PATH 2>&1
if ($install -match "Success") {
    Write-TestLog "APK installed successfully" "SUCCESS"
} else {
    Write-TestLog "Installation failed!" "ERROR"
    exit 1
}

# Test 1: App Launch
Write-TestLog "`n=== TEST 1: App Launch ===" "TEST"
& $ADB shell am start -n "$PACKAGE_NAME/.MainActivity" 2>&1 | Out-Null
Start-Sleep -Seconds 5

if (Check-AppRunning) {
    Write-TestLog "✓ App launched successfully" "SUCCESS"
    Capture-Screenshot "01_app_launch" "Initial app launch - Home screen"
} else {
    Write-TestLog "✗ App failed to launch!" "ERROR"
    exit 1
}

# Test 2: History Button
Write-TestLog "`n=== TEST 2: History Button ===" "TEST"
Write-TestLog "Testing History button functionality..." "INFO"

& $ADB shell input tap 540 806  # History button position
Start-Sleep -Seconds 3

$currentActivity = Get-CurrentActivity
Write-TestLog "Current activity: $currentActivity" "INFO"

if ($currentActivity -match "HistoryActivity") {
    Write-TestLog "✓ History button works! Opened HistoryActivity" "SUCCESS"
    Capture-Screenshot "02_history_empty" "Empty history screen"
} else {
    Write-TestLog "✗ History button failed to open HistoryActivity" "ERROR"
    Capture-Screenshot "02_history_failed" "History button not working"
}

# Go back to main
& $ADB shell input keyevent KEYCODE_BACK
Start-Sleep -Seconds 2

# Test 3: Navigation - Checklist
Write-TestLog "`n=== TEST 3: Navigation - Checklist ===" "TEST"
& $ADB shell input tap 216 2337  # Checklist tab
Start-Sleep -Seconds 3

$currentActivity = Get-CurrentActivity
if ($currentActivity -match "ChecklistActivity") {
    Write-TestLog "✓ Checklist navigation works!" "SUCCESS"
    Capture-Screenshot "03_checklist_screen" "Checklist with exercises"
    
    # Test checkbox functionality
    & $ADB shell input tap 950 400  # First checkbox
    & $ADB shell input tap 950 550  # Second checkbox
    Start-Sleep -Seconds 1
    Capture-Screenshot "03_checklist_checked" "Exercises checked"
} else {
    Write-TestLog "✗ Checklist navigation failed!" "ERROR"
    Capture-Screenshot "03_checklist_failed" "Navigation not working"
}

# Test 4: Navigation - Record
Write-TestLog "`n=== TEST 4: Navigation - Record ===" "TEST"
& $ADB shell am start -n "$PACKAGE_NAME/.MainActivity" 2>&1 | Out-Null
Start-Sleep -Seconds 2

& $ADB shell input tap 540 2337  # Record tab
Start-Sleep -Seconds 3

$currentActivity = Get-CurrentActivity
if ($currentActivity -match "RecordActivity") {
    Write-TestLog "✓ Record navigation works!" "SUCCESS"
    Capture-Screenshot "04_record_exercise_tab" "Record screen - Exercise tab"
    
    # Fill exercise data
    & $ADB shell input tap 540 410  # Exercise name
    Start-Sleep -Seconds 1
    & $ADB shell input text "Squash Training Session"
    & $ADB shell input keyevent KEYCODE_BACK
    
    # Test other tabs
    & $ADB shell input tap 353 257  # Ratings tab
    Start-Sleep -Seconds 2
    Capture-Screenshot "04_record_ratings_tab" "Record screen - Ratings tab"
    
    & $ADB shell input tap 588 257  # Memo tab
    Start-Sleep -Seconds 2
    Capture-Screenshot "04_record_memo_tab" "Record screen - Memo tab"
    
    # Save record
    & $ADB shell input tap 540 1450  # Save button
    Start-Sleep -Seconds 2
    Capture-Screenshot "04_record_saved" "Record saved confirmation"
} else {
    Write-TestLog "✗ Record navigation failed!" "ERROR"
    Capture-Screenshot "04_record_failed" "Navigation not working"
}

# Test 5: Navigation - Profile
Write-TestLog "`n=== TEST 5: Navigation - Profile ===" "TEST"
& $ADB shell am start -n "$PACKAGE_NAME/.MainActivity" 2>&1 | Out-Null
Start-Sleep -Seconds 2

& $ADB shell input tap 756 2337  # Profile tab
Start-Sleep -Seconds 3

$currentActivity = Get-CurrentActivity
if ($currentActivity -match "ProfileActivity") {
    Write-TestLog "✓ Profile navigation works!" "SUCCESS"
    Capture-Screenshot "05_profile_screen" "Profile with stats"
    
    # Test settings button
    & $ADB shell input tap 1000 150
    Start-Sleep -Seconds 1
    Capture-Screenshot "05_profile_settings" "Settings button pressed"
} else {
    Write-TestLog "✗ Profile navigation failed!" "ERROR"
    Capture-Screenshot "05_profile_failed" "Navigation not working"
}

# Test 6: Navigation - Coach
Write-TestLog "`n=== TEST 6: Navigation - Coach ===" "TEST"
& $ADB shell am start -n "$PACKAGE_NAME/.MainActivity" 2>&1 | Out-Null
Start-Sleep -Seconds 2

& $ADB shell input tap 972 2337  # Coach tab
Start-Sleep -Seconds 3

$currentActivity = Get-CurrentActivity
if ($currentActivity -match "CoachActivity") {
    Write-TestLog "✓ Coach navigation works!" "SUCCESS"
    Capture-Screenshot "06_coach_screen" "Coach tips screen"
    
    # Test refresh button
    & $ADB shell input tap 270 1450
    Start-Sleep -Seconds 2
    Capture-Screenshot "06_coach_refreshed" "Tips refreshed"
} else {
    Write-TestLog "✗ Coach navigation failed!" "ERROR"
    Capture-Screenshot "06_coach_failed" "Navigation not working"
}

# Test 7: Check History Again
Write-TestLog "`n=== TEST 7: Check History with Data ===" "TEST"
& $ADB shell am start -n "$PACKAGE_NAME/.MainActivity" 2>&1 | Out-Null
Start-Sleep -Seconds 2

& $ADB shell input tap 540 806  # History button
Start-Sleep -Seconds 3

if ($currentActivity -match "HistoryActivity") {
    Capture-Screenshot "07_history_with_data" "History with saved record"
    
    # Test delete
    & $ADB shell input swipe 540 400 540 400 1000  # Long press
    Start-Sleep -Seconds 2
    Capture-Screenshot "07_history_delete_dialog" "Delete confirmation dialog"
    
    # Cancel delete
    & $ADB shell input tap 350 1100
} else {
    Write-TestLog "History screen not accessible" "ERROR"
}

# Test 8: Navigation Persistence
Write-TestLog "`n=== TEST 8: Navigation Persistence ===" "TEST"
& $ADB shell am start -n "$PACKAGE_NAME/.MainActivity" 2>&1 | Out-Null
Start-Sleep -Seconds 2

# Navigate to Profile tab
& $ADB shell input tap 756 2337
Start-Sleep -Seconds 2
Capture-Screenshot "08_nav_to_profile" "Navigated to Profile tab"

# Open ProfileActivity directly
& $ADB shell am start -n "$PACKAGE_NAME/.ProfileActivity" 2>&1 | Out-Null
Start-Sleep -Seconds 3

# Go back
& $ADB shell input keyevent KEYCODE_BACK
Start-Sleep -Seconds 2
Capture-Screenshot "08_nav_persistence" "Should still show Profile tab selected"

# Generate summary
Write-TestLog "`n========================================" "TEST"
Write-TestLog "TEST SUMMARY" "TEST"
Write-TestLog "========================================" "TEST"

$screenshotCount = (Get-ChildItem $SCREENSHOTS_DIR -Filter "*.png").Count
Write-TestLog "Total screenshots captured: $screenshotCount" "INFO"

# Check navigation status
$navWorking = $false
$testLog = Get-Content "$LOGS_DIR\test-results.txt" -ErrorAction SilentlyContinue
if ($testLog -match "navigation works") {
    $navWorking = $true
}

if ($navWorking) {
    Write-TestLog "✓ Navigation is WORKING properly!" "SUCCESS"
} else {
    Write-TestLog "✗ Navigation is NOT working - needs fixing!" "ERROR"
}

Write-TestLog "`nTest complete. Check screenshots in:" "INFO"
Write-TestLog $SCREENSHOTS_DIR "INFO"

# Open screenshots folder
Start-Process explorer.exe $SCREENSHOTS_DIR