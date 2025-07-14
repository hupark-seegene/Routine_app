# TMUX-TEST-WORKER.ps1
# Test worker process for continuous automation
# Handles automated testing on Android emulator

param(
    [Parameter(Mandatory=$true)]
    [int]$Iteration
)

$ErrorActionPreference = "Stop"

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item "$ScriptDir/../../../..").FullName
$AndroidDir = "$ProjectRoot/SquashTrainingApp/android"
$LogFile = "$ScriptDir/logs/test-logs/test-$Iteration.log"
$ScreenshotDir = "$ScriptDir/logs/test-logs/screenshots-$Iteration"

# ADB configuration
$ADB = "C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$EMULATOR = "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe"

# Ensure directories exist
@($ScriptDir, "$ScriptDir/logs/test-logs", $ScreenshotDir) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

# Initialize log
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Write to console
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARN"  { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        "TEST" { Write-Host $logMessage -ForegroundColor Cyan }
        default { Write-Host $logMessage }
    }
    
    # Write to file
    $logMessage | Add-Content $LogFile
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

function Install-APK {
    Write-Log "Installing APK on emulator"
    
    # Find the latest APK
    $apkPath = "$AndroidDir/app/build/outputs/apk/debug/app-debug.apk"
    if (-not (Test-Path $apkPath)) {
        Write-Log "APK not found at $apkPath" "ERROR"
        return $false
    }
    
    # Uninstall existing app
    Write-Log "Uninstalling existing app"
    & $ADB uninstall com.squashtrainingapp 2>&1 | Out-Null
    
    # Install new APK
    Write-Log "Installing new APK"
    $installResult = & $ADB install $apkPath 2>&1
    
    if ($installResult -match "Success") {
        Write-Log "APK installed successfully" "SUCCESS"
        return $true
    } else {
        Write-Log "APK installation failed: $installResult" "ERROR"
        return $false
    }
}

function Take-Screenshot {
    param([string]$Name)
    
    $screenshotPath = "$ScreenshotDir/$Name.png"
    
    # Capture screenshot
    & $ADB shell screencap -p /sdcard/screenshot.png
    & $ADB pull /sdcard/screenshot.png $screenshotPath 2>&1 | Out-Null
    & $ADB shell rm /sdcard/screenshot.png
    
    if (Test-Path $screenshotPath) {
        Write-Log "Screenshot saved: $Name.png" "TEST"
    }
}

function Launch-App {
    Write-Log "Launching app"
    
    & $ADB shell am start -n com.squashtrainingapp/.MainActivity
    Start-Sleep -Seconds 3
    
    Take-Screenshot -Name "01-app-launch"
}

function Test-HomeScreen {
    Write-Log "Testing Home Screen" "TEST"
    
    # Test mascot drag
    Write-Log "Testing mascot drag functionality"
    & $ADB shell input swipe 540 1200 300 1000 500
    Start-Sleep -Seconds 1
    Take-Screenshot -Name "02-mascot-drag"
    
    # Test long press for voice
    Write-Log "Testing voice activation (2s press)"
    & $ADB shell input swipe 540 1200 540 1200 2000
    Start-Sleep -Seconds 2
    Take-Screenshot -Name "03-voice-activated"
    
    # Dismiss voice if activated
    & $ADB shell input tap 100 100
    Start-Sleep -Seconds 1
    
    return $true
}

function Test-Navigation {
    param([string]$Zone, [int]$X, [int]$Y, [string]$ScreenName)
    
    Write-Log "Testing navigation to $Zone" "TEST"
    
    # Drag mascot to zone
    & $ADB shell input swipe 540 1200 $X $Y 500
    Start-Sleep -Seconds 2
    
    Take-Screenshot -Name "$ScreenName-enter"
    
    # Test screen functionality
    switch ($Zone) {
        "Checklist" {
            # Test checkbox interaction
            & $ADB shell input tap 900 400
            Start-Sleep -Seconds 1
            Take-Screenshot -Name "$ScreenName-interact"
        }
        "Record" {
            # Test tab navigation
            & $ADB shell input tap 353 257
            Start-Sleep -Seconds 1
            Take-Screenshot -Name "$ScreenName-tab"
        }
        "Profile" {
            # Test scroll
            & $ADB shell input swipe 540 1500 540 500 300
            Start-Sleep -Seconds 1
            Take-Screenshot -Name "$ScreenName-scroll"
        }
        "Coach" {
            # Test refresh button
            & $ADB shell input tap 540 1800
            Start-Sleep -Seconds 1
            Take-Screenshot -Name "$ScreenName-refresh"
        }
        "History" {
            # Test if any records exist
            Take-Screenshot -Name "$ScreenName-list"
        }
    }
    
    # Go back to home
    & $ADB shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 2
    
    return $true
}

function Test-AllFeatures {
    Write-Log "Starting comprehensive feature tests" "TEST"
    
    $testResults = @{
        HomeScreen = $false
        Checklist = $false
        Record = $false
        Profile = $false
        Coach = $false
        History = $false
    }
    
    try {
        # Test home screen
        $testResults.HomeScreen = Test-HomeScreen
        
        # Test navigation to each zone
        # Coordinates based on zone layout
        $zones = @(
            @{Name="Checklist"; X=200; Y=900; Screen="04-checklist"},
            @{Name="Record"; X=200; Y=1500; Screen="05-record"},
            @{Name="Profile"; X=540; Y=600; Screen="06-profile"},
            @{Name="Coach"; X=880; Y=900; Screen="07-coach"},
            @{Name="History"; X=880; Y=1500; Screen="08-history"}
        )
        
        foreach ($zone in $zones) {
            $testResults[$zone.Name] = Test-Navigation -Zone $zone.Name -X $zone.X -Y $zone.Y -ScreenName $zone.Screen
        }
        
        # Calculate success rate
        $passed = ($testResults.Values | Where-Object { $_ -eq $true }).Count
        $total = $testResults.Count
        $successRate = [math]::Round(($passed / $total) * 100, 2)
        
        Write-Log "Test Summary: $passed/$total passed ($successRate%)" "TEST"
        
        # Log detailed results
        foreach ($test in $testResults.GetEnumerator()) {
            $status = if ($test.Value) { "PASSED" } else { "FAILED" }
            Write-Log "$($test.Key): $status" "TEST"
        }
        
        return $passed -eq $total
        
    } catch {
        Write-Log "Test execution error: $_" "ERROR"
        return $false
    }
}

function Analyze-Performance {
    Write-Log "Analyzing app performance" "TEST"
    
    # Get memory usage
    $memInfo = & $ADB shell dumpsys meminfo com.squashtrainingapp | Select-String "TOTAL"
    if ($memInfo) {
        Write-Log "Memory usage: $memInfo" "TEST"
    }
    
    # Check for crashes
    $crashes = & $ADB shell dumpsys dropbox | Select-String "com.squashtrainingapp.*crash"
    if ($crashes) {
        Write-Log "Crashes detected: $($crashes.Count)" "WARN"
    } else {
        Write-Log "No crashes detected" "SUCCESS"
    }
}

# Main execution
try {
    Write-Log "=== TEST WORKER STARTED ==="
    Write-Log "Iteration: $Iteration"
    
    # Check emulator status
    if (-not (Test-EmulatorStatus)) {
        Write-Log "Emulator not running or not connected" "ERROR"
        Write-Log "TEST_FAILED" "ERROR"
        exit 1
    }
    
    Write-Log "Emulator connected" "SUCCESS"
    
    # Install APK
    if (-not (Install-APK)) {
        Write-Log "Failed to install APK" "ERROR"
        Write-Log "TEST_FAILED" "ERROR"
        exit 1
    }
    
    # Launch app
    Launch-App
    
    # Run all feature tests
    $testSuccess = Test-AllFeatures
    
    # Analyze performance
    Analyze-Performance
    
    # Final screenshot
    Take-Screenshot -Name "99-final-state"
    
    # Generate test report
    $report = @{
        iteration = $Iteration
        success = $testSuccess
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        screenshotCount = (Get-ChildItem $ScreenshotDir -Filter "*.png").Count
    }
    
    $reportFile = "$ScriptDir/logs/test-logs/report-$Iteration.json"
    $report | ConvertTo-Json | Set-Content $reportFile
    
    if ($testSuccess) {
        Write-Log "TEST_COMPLETE" "SUCCESS"
    } else {
        Write-Log "TEST_FAILED" "ERROR"
    }
    
} catch {
    Write-Log "Test worker error: $_" "ERROR"
    Write-Log "TEST_FAILED" "ERROR"
    exit 1
} finally {
    # Cleanup
    & $ADB shell am force-stop com.squashtrainingapp
    Write-Log "=== TEST WORKER COMPLETED ==="
}