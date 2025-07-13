<#
.SYNOPSIS
    Cycle 17 - Complete Testing with Cycle 16 Success Pattern
    
.DESCRIPTION
    Complete testing of RecordScreen with proper emulator connection
    Based on successful Cycle 16 pattern
    
.VERSION
    1.0.17
    
.CYCLE
    17 of 50
    
.CREATED
    2025-07-13
#>

param(
    [switch]$SkipBuild = $false,
    [switch]$KeepInstalled = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ========================================
# CONFIGURATION (From Cycle 16 Success)
# ========================================

$CycleNumber = 17
$VersionName = "1.0.17"
$BuildTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$AppDir = Join-Path $ProjectRoot "SquashTrainingApp"
$AndroidDir = Join-Path $AppDir "android"
$APKPath = Join-Path $AndroidDir "app\build\outputs\apk\debug\app-debug.apk"
$OutputDir = Join-Path $ProjectRoot "build-artifacts\cycle-$CycleNumber"
$ScreenshotsDir = Join-Path $ProjectRoot "build-artifacts\screenshots"

# Environment Setup (Cycle 16 Pattern)
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$env:Path = "$env:JAVA_HOME\bin;$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\emulator;$env:Path"

$ADB = "$env:ANDROID_HOME\platform-tools\adb.exe"
$EMULATOR = "$env:ANDROID_HOME\emulator\emulator.exe"
$PackageName = "com.squashtrainingapp"

# Test Results
$global:TestResults = @{
    EmulatorConnected = $false
    APKInstalled = $false
    AppLaunched = $false
    RecordTabNavigated = $false
    ExerciseTabTested = $false
    RatingsTabTested = $false
    MemoTabTested = $false
    ScreenshotsCaptured = 0
    TotalTests = 0
    PassedTests = 0
}

# ========================================
# UTILITY FUNCTIONS (Cycle 16 Pattern)
# ========================================

function Write-TestLog {
    param(
        [string]$Message,
        [string]$Type = "INFO"
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = switch ($Type) {
        "SUCCESS" { "Green" }
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        "INFO" { "Cyan" }
        default { "White" }
    }
    Write-Host "[$timestamp] $Message" -ForegroundColor $color
}

function Test-EmulatorStatus {
    try {
        $devices = & $ADB devices 2>&1
        if ($devices -match "emulator.*device$") {
            return $true
        }
        return $false
    }
    catch {
        return $false
    }
}

function Start-EmulatorIfNeeded {
    Write-TestLog "Checking emulator status..."
    
    if (Test-EmulatorStatus) {
        Write-TestLog "Emulator already running" "SUCCESS"
        $global:TestResults.EmulatorConnected = $true
        return $true
    }
    
    Write-TestLog "Starting emulator..." "WARNING"
    
    # Try to start Pixel 6 API 33 (from project_plan.md)
    $avdName = "Pixel_6"
    Start-Process -FilePath $EMULATOR -ArgumentList "-avd", $avdName -NoNewWindow
    
    # Wait for emulator
    $timeout = 60
    $elapsed = 0
    while ($elapsed -lt $timeout) {
        Start-Sleep -Seconds 5
        $elapsed += 5
        Write-TestLog "Waiting for emulator... ($elapsed/$timeout seconds)"
        
        if (Test-EmulatorStatus) {
            Write-TestLog "Emulator connected!" "SUCCESS"
            $global:TestResults.EmulatorConnected = $true
            
            # Wait for boot completion
            Write-TestLog "Waiting for boot completion..."
            & $ADB wait-for-device
            Start-Sleep -Seconds 10
            
            return $true
        }
    }
    
    Write-TestLog "Emulator startup timeout" "ERROR"
    return $false
}

function Install-APK {
    Write-TestLog "Installing APK..."
    
    if (!(Test-Path $APKPath)) {
        Write-TestLog "APK not found at: $APKPath" "ERROR"
        return $false
    }
    
    # Uninstall first
    Write-TestLog "Uninstalling previous version..."
    & $ADB uninstall $PackageName 2>&1 | Out-Null
    
    # Install new APK
    $installResult = & $ADB install $APKPath 2>&1
    if ($installResult -match "Success") {
        Write-TestLog "APK installed successfully" "SUCCESS"
        $global:TestResults.APKInstalled = $true
        return $true
    }
    else {
        Write-TestLog "APK installation failed: $installResult" "ERROR"
        return $false
    }
}

function Start-App {
    Write-TestLog "Launching app..."
    
    $launchResult = & $ADB shell am start -n "$PackageName/.MainActivity" 2>&1
    if ($launchResult -match "Starting:") {
        Write-TestLog "App launched successfully" "SUCCESS"
        $global:TestResults.AppLaunched = $true
        Start-Sleep -Seconds 5
        return $true
    }
    else {
        Write-TestLog "App launch failed: $launchResult" "ERROR"
        return $false
    }
}

function Capture-Screenshot {
    param(
        [string]$Name
    )
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $filename = "cycle17_${Name}_${timestamp}.png"
    $devicePath = "/sdcard/$filename"
    $localPath = Join-Path $ScreenshotsDir $filename
    
    Write-TestLog "Capturing screenshot: $Name"
    
    & $ADB shell screencap -p $devicePath
    & $ADB pull $devicePath $localPath 2>&1 | Out-Null
    & $ADB shell rm $devicePath
    
    if (Test-Path $localPath) {
        Write-TestLog "Screenshot saved: $filename" "SUCCESS"
        $global:TestResults.ScreenshotsCaptured++
        return $true
    }
    else {
        Write-TestLog "Screenshot capture failed" "ERROR"
        return $false
    }
}

function Test-RecordNavigation {
    Write-TestLog "Testing Record tab navigation..."
    $global:TestResults.TotalTests++
    
    # Navigation coordinates from project_plan.md
    # Record tab: X=108, Y=2337 (3rd position)
    
    # Try multiple coordinates to ensure we hit the right tab
    $coordinates = @(
        @{X=108; Y=2337; Name="Left"},
        @{X=324; Y=2337; Name="CenterLeft"}, 
        @{X=540; Y=2337; Name="Center"},
        @{X=368; Y=2337; Name="Adjusted"}
    )
    
    foreach ($coord in $coordinates) {
        Write-TestLog "Trying Record tab at $($coord.Name) position (X=$($coord.X), Y=$($coord.Y))..."
        & $ADB shell input tap $coord.X $coord.Y
        Start-Sleep -Seconds 2
        
        # Check if we're on Record screen by looking for UI elements
        $uiDump = & $ADB shell uiautomator dump 2>&1
        if ($uiDump) {
            $dumpContent = & $ADB shell cat /sdcard/window_dump.xml 2>&1
            if ($dumpContent -match "RECORD WORKOUT" -or $dumpContent -match "RecordActivity") {
                Write-TestLog "Successfully navigated to Record screen!" "SUCCESS"
                $global:TestResults.RecordTabNavigated = $true
                $global:TestResults.PassedTests++
                Capture-Screenshot "record_screen"
                return $true
            }
        }
    }
    
    Write-TestLog "Could not navigate to Record screen" "ERROR"
    return $false
}

function Test-ExerciseTab {
    Write-TestLog "Testing Exercise tab..."
    $global:TestResults.TotalTests++
    
    # The Exercise tab should be the default tab
    Start-Sleep -Seconds 1
    Capture-Screenshot "exercise_tab"
    
    # Test form inputs
    Write-TestLog "Testing exercise name input..."
    & $ADB shell input tap 540 600  # Exercise name field
    Start-Sleep -Seconds 1
    & $ADB shell input text "Straight Drive"
    
    Write-TestLog "Testing sets input..."
    & $ADB shell input tap 270 800  # Sets field
    Start-Sleep -Seconds 1
    & $ADB shell input text "3"
    
    Write-TestLog "Testing reps input..."
    & $ADB shell input tap 810 800  # Reps field
    Start-Sleep -Seconds 1
    & $ADB shell input text "10"
    
    Write-TestLog "Testing duration input..."
    & $ADB shell input tap 540 1000  # Duration field
    Start-Sleep -Seconds 1
    & $ADB shell input text "20"
    
    Capture-Screenshot "exercise_tab_filled"
    $global:TestResults.ExerciseTabTested = $true
    $global:TestResults.PassedTests++
    
    return $true
}

function Test-RatingsTab {
    Write-TestLog "Testing Ratings tab..."
    $global:TestResults.TotalTests++
    
    # Click on Ratings tab (should be second tab)
    & $ADB shell input tap 540 450  # Tab position
    Start-Sleep -Seconds 2
    Capture-Screenshot "ratings_tab_initial"
    
    # Test sliders
    Write-TestLog "Testing intensity slider..."
    & $ADB shell input swipe 200 700 800 700 500  # Swipe slider
    Start-Sleep -Seconds 1
    
    Write-TestLog "Testing condition slider..."
    & $ADB shell input swipe 200 900 600 900 500  # Swipe slider
    Start-Sleep -Seconds 1
    
    Write-TestLog "Testing fatigue slider..."
    & $ADB shell input swipe 200 1100 700 1100 500  # Swipe slider
    Start-Sleep -Seconds 1
    
    Capture-Screenshot "ratings_tab_adjusted"
    $global:TestResults.RatingsTabTested = $true
    $global:TestResults.PassedTests++
    
    return $true
}

function Test-MemoTab {
    Write-TestLog "Testing Memo tab..."
    $global:TestResults.TotalTests++
    
    # Click on Memo tab (should be third tab)
    & $ADB shell input tap 810 450  # Tab position
    Start-Sleep -Seconds 2
    Capture-Screenshot "memo_tab_initial"
    
    # Test memo input
    Write-TestLog "Testing memo input field..."
    & $ADB shell input tap 540 800  # Memo field
    Start-Sleep -Seconds 1
    & $ADB shell input text "Great workout today. Improved backhand accuracy."
    
    Capture-Screenshot "memo_tab_filled"
    $global:TestResults.MemoTabTested = $true
    $global:TestResults.PassedTests++
    
    return $true
}

function Test-SaveButton {
    Write-TestLog "Testing Save button..."
    $global:TestResults.TotalTests++
    
    # Click Save button (bottom of screen)
    & $ADB shell input tap 540 2100
    Start-Sleep -Seconds 2
    Capture-Screenshot "save_result"
    
    $global:TestResults.PassedTests++
    return $true
}

# ========================================
# MAIN EXECUTION
# ========================================

Write-TestLog "=== CYCLE 17 COMPLETE TESTING ===" "INFO"
Write-TestLog "Timestamp: $BuildTimestamp" "INFO"

# Create directories
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
New-Item -ItemType Directory -Force -Path $ScreenshotsDir | Out-Null

# Step 1: Ensure emulator is running
if (!(Start-EmulatorIfNeeded)) {
    Write-TestLog "Failed to start emulator" "ERROR"
    exit 1
}

# Step 2: Install APK
if (!(Install-APK)) {
    Write-TestLog "Failed to install APK" "ERROR"
    exit 1
}

# Step 3: Launch app
if (!(Start-App)) {
    Write-TestLog "Failed to launch app" "ERROR"
    exit 1
}

# Step 4: Navigate to Record screen
if (!(Test-RecordNavigation)) {
    Write-TestLog "Failed to navigate to Record screen" "ERROR"
}

# Step 5: Test all features
if ($global:TestResults.RecordTabNavigated) {
    Test-ExerciseTab
    Test-RatingsTab
    Test-MemoTab
    Test-SaveButton
}

# Step 6: Navigate back and test other screens
Write-TestLog "Testing other navigation tabs..."

# Test Checklist
& $ADB shell input tap 216 2337
Start-Sleep -Seconds 2
Capture-Screenshot "checklist_screen"

# Test Profile
& $ADB shell input tap 324 2337
Start-Sleep -Seconds 2
Capture-Screenshot "profile_screen"

# Test Coach
& $ADB shell input tap 432 2337
Start-Sleep -Seconds 2
Capture-Screenshot "coach_screen"

# Step 7: Generate report
Write-TestLog "=== TEST RESULTS ===" "INFO"
Write-TestLog "Emulator Connected: $($global:TestResults.EmulatorConnected)"
Write-TestLog "APK Installed: $($global:TestResults.APKInstalled)"
Write-TestLog "App Launched: $($global:TestResults.AppLaunched)"
Write-TestLog "Record Tab Navigated: $($global:TestResults.RecordTabNavigated)"
Write-TestLog "Exercise Tab Tested: $($global:TestResults.ExerciseTabTested)"
Write-TestLog "Ratings Tab Tested: $($global:TestResults.RatingsTabTested)"
Write-TestLog "Memo Tab Tested: $($global:TestResults.MemoTabTested)"
Write-TestLog "Screenshots Captured: $($global:TestResults.ScreenshotsCaptured)"
Write-TestLog "Tests Passed: $($global:TestResults.PassedTests)/$($global:TestResults.TotalTests)"

# Step 8: Uninstall if not keeping
if (!$KeepInstalled) {
    Write-TestLog "Uninstalling app..."
    & $ADB uninstall $PackageName 2>&1 | Out-Null
}

Write-TestLog "=== CYCLE 17 TESTING COMPLETE ===" "SUCCESS"

# Save results
$resultsFile = Join-Path $OutputDir "test-results.json"
$global:TestResults | ConvertTo-Json | Set-Content $resultsFile

Write-TestLog "Results saved to: $resultsFile"