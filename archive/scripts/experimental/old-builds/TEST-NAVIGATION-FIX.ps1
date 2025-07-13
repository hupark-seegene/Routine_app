<#
.SYNOPSIS
    Test navigation fix with debug toasts
#>

$ErrorActionPreference = "Continue"
$ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$ADB = "$ANDROID_HOME\platform-tools\adb.exe"
$PROJECT_ROOT = "C:\git\routine_app\SquashTrainingApp"
$APK_PATH = "$PROJECT_ROOT\android\app\build\outputs\apk\debug\app-debug.apk"
$PACKAGE_NAME = "com.squashtrainingapp"
$SCREENSHOTS_DIR = "C:\git\routine_app\build-artifacts\screenshots\nav-fix-test"

Write-Host "=== NAVIGATION FIX TEST ===" -ForegroundColor Cyan

# Create screenshot directory
if (!(Test-Path $SCREENSHOTS_DIR)) {
    New-Item -ItemType Directory -Path $SCREENSHOTS_DIR -Force | Out-Null
}

# Build APK
Write-Host "`nBuilding APK with navigation fix..." -ForegroundColor Yellow
Set-Location "$PROJECT_ROOT\android"
.\gradlew.bat assembleDebug 2>&1 | Out-Null

if (!(Test-Path $APK_PATH)) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Build successful!" -ForegroundColor Green

# Install
Write-Host "Installing APK..." -ForegroundColor Yellow
& $ADB uninstall $PACKAGE_NAME 2>&1 | Out-Null
$install = & $ADB install $APK_PATH 2>&1
if ($install -match "Success") {
    Write-Host "Installed!" -ForegroundColor Green
} else {
    Write-Host "Install failed!" -ForegroundColor Red
    exit 1
}

# Launch app
Write-Host "Launching app..." -ForegroundColor Yellow
& $ADB shell am start -n "$PACKAGE_NAME/.MainActivity" 2>&1 | Out-Null
Start-Sleep -Seconds 3

# Screenshot function
function Screenshot {
    param([string]$Name)
    $timestamp = Get-Date -Format "HHmmss"
    & $ADB shell screencap -p /sdcard/screen.png 2>&1 | Out-Null
    & $ADB pull /sdcard/screen.png "$SCREENSHOTS_DIR\${Name}_$timestamp.png" 2>&1 | Out-Null
    & $ADB shell rm /sdcard/screen.png 2>&1 | Out-Null
    Write-Host "📸 $Name" -ForegroundColor Magenta
}

# Test 1: Initial state
Write-Host "`n[TEST 1] Initial state" -ForegroundColor Cyan
Screenshot "01_initial"

# Test 2: History button
Write-Host "`n[TEST 2] Testing History button" -ForegroundColor Cyan
Write-Host "Tapping History button at (540, 900)..." -ForegroundColor Yellow
& $ADB shell input tap 540 900
Start-Sleep -Seconds 3
Screenshot "02_history_button"

# Back to main
& $ADB shell input keyevent KEYCODE_BACK
Start-Sleep -Seconds 2

# Test 3: Navigation tabs with different Y coordinates
Write-Host "`n[TEST 3] Testing navigation tabs" -ForegroundColor Cyan

# Try different Y coordinates for bottom nav
$yCoords = @(2337, 2300, 2250, 2350)

foreach ($y in $yCoords) {
    Write-Host "`nTrying Y=$y" -ForegroundColor Yellow
    
    # Checklist tab
    Write-Host "- Checklist (216, $y)" -ForegroundColor White
    & $ADB shell input tap 216 $y
    Start-Sleep -Seconds 2
    Screenshot "03_checklist_y$y"
    
    # Check if we moved from home
    $activity = & $ADB shell dumpsys activity activities | Select-String "mResumedActivity" | Select-Object -First 1
    if ($activity -match "ChecklistActivity") {
        Write-Host "SUCCESS! ChecklistActivity opened!" -ForegroundColor Green
        break
    } else {
        Write-Host "Still on: $activity" -ForegroundColor Red
    }
}

# Test 4: Direct navigation icon locations
Write-Host "`n[TEST 4] Testing exact icon positions" -ForegroundColor Cyan

# Get screen info
$screenInfo = & $ADB shell wm size
Write-Host "Screen info: $screenInfo" -ForegroundColor Gray

# Try tapping the actual navigation bar area
Write-Host "Tapping navigation bar directly..." -ForegroundColor Yellow
& $ADB shell input tap 540 2337  # Record tab
Start-Sleep -Seconds 2
Screenshot "04_record_attempt"

Write-Host "`n=== TEST COMPLETE ===" -ForegroundColor Green
Write-Host "Check screenshots in: $SCREENSHOTS_DIR" -ForegroundColor Cyan
Start-Process explorer.exe $SCREENSHOTS_DIR