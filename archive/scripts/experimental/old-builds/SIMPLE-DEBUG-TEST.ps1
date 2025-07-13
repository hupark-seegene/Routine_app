<#
.SYNOPSIS
    Simple debug test to find exact issue
#>

$ErrorActionPreference = "Continue"
$ADB = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$PACKAGE_NAME = "com.squashtrainingapp"
$SCREENSHOTS_DIR = "C:\git\routine_app\build-artifacts\screenshots\simple-debug"

if (!(Test-Path $SCREENSHOTS_DIR)) {
    New-Item -ItemType Directory -Path $SCREENSHOTS_DIR -Force | Out-Null
}

Write-Host "=== SIMPLE DEBUG TEST ===" -ForegroundColor Cyan

# Launch app
Write-Host "`n1. Launching app..." -ForegroundColor Yellow
& $ADB shell am start -n "$PACKAGE_NAME/.MainActivity" 2>&1
Start-Sleep -Seconds 3

# Screenshot
& $ADB shell screencap -p /sdcard/screen.png
& $ADB pull /sdcard/screen.png "$SCREENSHOTS_DIR\01_initial.png" 2>&1 | Out-Null
Write-Host "   Screenshot: 01_initial.png" -ForegroundColor Green

# Test History button with different Y coordinates
Write-Host "`n2. Testing History button..." -ForegroundColor Yellow
$historyYCoords = @(806, 850, 900, 950)

foreach ($y in $historyYCoords) {
    Write-Host "   Trying Y=$y" -ForegroundColor White
    & $ADB shell input tap 540 $y
    Start-Sleep -Seconds 2
    
    # Check current activity
    $activity = & $ADB shell dumpsys activity activities | Select-String "mResumedActivity" | Select-Object -First 1
    Write-Host "   Activity: $activity" -ForegroundColor Gray
    
    if ($activity -match "HistoryActivity") {
        Write-Host "   SUCCESS! History button works at Y=$y" -ForegroundColor Green
        & $ADB shell screencap -p /sdcard/screen.png
        & $ADB pull /sdcard/screen.png "$SCREENSHOTS_DIR\02_history_success.png" 2>&1 | Out-Null
        & $ADB shell input keyevent KEYCODE_BACK
        break
    }
}

# Test navigation with actual coordinates from bottom nav
Write-Host "`n3. Testing bottom navigation..." -ForegroundColor Yellow

# Get device info
$size = & $ADB shell wm size
Write-Host "   Device size: $size" -ForegroundColor Gray

# Try different Y coordinates for bottom nav
$navYCoords = @(2337, 2350, 2400, 2300, 2250)

foreach ($y in $navYCoords) {
    Write-Host "`n   Testing navigation at Y=$y" -ForegroundColor White
    
    # Launch main activity fresh
    & $ADB shell am start -n "$PACKAGE_NAME/.MainActivity" 2>&1 | Out-Null
    Start-Sleep -Seconds 2
    
    # Try Checklist tab
    Write-Host "   Tapping Checklist (216, $y)" -ForegroundColor Gray
    & $ADB shell input tap 216 $y
    Start-Sleep -Seconds 2
    
    # Check if app is still running
    $running = & $ADB shell pidof $PACKAGE_NAME 2>&1
    if ($running -match '\d+') {
        Write-Host "   App still running" -ForegroundColor Green
        
        # Check activity
        $activity = & $ADB shell dumpsys activity activities | Select-String "mResumedActivity" | Select-Object -First 1
        if ($activity -match "ChecklistActivity") {
            Write-Host "   SUCCESS! Navigation works at Y=$y" -ForegroundColor Green
            & $ADB shell screencap -p /sdcard/screen.png
            & $ADB pull /sdcard/screen.png "$SCREENSHOTS_DIR\03_nav_success.png" 2>&1 | Out-Null
            break
        } else {
            Write-Host "   Navigation didn't work - still on: $activity" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   App CRASHED!" -ForegroundColor Red
        & $ADB shell screencap -p /sdcard/screen.png
        & $ADB pull /sdcard/screen.png "$SCREENSHOTS_DIR\03_crash_y$y.png" 2>&1 | Out-Null
    }
}

# Test direct activity launch
Write-Host "`n4. Testing direct activity launches..." -ForegroundColor Yellow

$activities = @("ChecklistActivity", "RecordActivity", "ProfileActivity", "CoachActivity", "HistoryActivity")

foreach ($activity in $activities) {
    Write-Host "`n   Testing $activity" -ForegroundColor White
    $result = & $ADB shell am start -n "$PACKAGE_NAME/.$activity" 2>&1
    
    if ($result -match "Error|Exception") {
        Write-Host "   FAILED: $result" -ForegroundColor Red
    } else {
        Write-Host "   SUCCESS: $activity launched" -ForegroundColor Green
        Start-Sleep -Seconds 2
        & $ADB shell screencap -p /sdcard/screen.png
        & $ADB pull /sdcard/screen.png "$SCREENSHOTS_DIR\04_direct_$activity.png" 2>&1 | Out-Null
    }
}

Write-Host "`n=== TEST COMPLETE ===" -ForegroundColor Green
Write-Host "Screenshots saved to: $SCREENSHOTS_DIR" -ForegroundColor Cyan
Start-Process explorer.exe $SCREENSHOTS_DIR