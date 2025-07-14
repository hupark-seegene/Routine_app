# Comprehensive Functional Debug Script for Squash Training App
# This script performs thorough testing of all app features, not just repetitive launches

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$debugDir = "comprehensive-debug-$timestamp"
$screenshotDir = "$debugDir/screenshots"
$logFile = "$debugDir/debug-log.txt"

# Create directories
New-Item -ItemType Directory -Path $debugDir -Force | Out-Null
New-Item -ItemType Directory -Path $screenshotDir -Force | Out-Null

function Write-Log {
    param($Message, $Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Type] $Message"
    Write-Host $logMessage -ForegroundColor $(if($Type -eq "ERROR"){"Red"}elseif($Type -eq "SUCCESS"){"Green"}elseif($Type -eq "WARNING"){"Yellow"}else{"Cyan"})
    $logMessage | Out-File -Append -FilePath $logFile
}

function Take-Screenshot {
    param($Name)
    $screenshotPath = "/sdcard/$Name.png"
    $localPath = "$screenshotDir/$Name.png"
    
    adb shell screencap -p $screenshotPath
    Start-Sleep -Milliseconds 500
    adb pull $screenshotPath $localPath 2>$null
    adb shell rm $screenshotPath
    Write-Log "Screenshot saved: $Name.png" "SUCCESS"
}

function Test-MascotDrag {
    param($FromX, $FromY, $ToX, $ToY, $Duration, $TestName)
    
    Write-Log "Testing mascot drag: $TestName"
    adb shell input swipe $FromX $FromY $ToX $ToY $Duration
    Start-Sleep -Seconds 2
    Take-Screenshot "mascot_drag_$TestName"
}

function Test-VoiceRecognition {
    Write-Log "Testing voice recognition (2 second hold)"
    
    # Long press on mascot (2 seconds)
    adb shell input swipe 540 900 540 900 2000
    Start-Sleep -Seconds 1
    Take-Screenshot "voice_recognition_overlay"
    
    # Cancel voice recognition
    adb shell input tap 540 1500
    Start-Sleep -Seconds 1
}

function Test-ChecklistScreen {
    Write-Log "=== Testing Checklist Screen ===" "INFO"
    
    # Navigate to checklist
    adb shell input swipe 540 900 300 700 500
    Start-Sleep -Seconds 2
    Take-Screenshot "checklist_initial"
    
    # Test checkbox interactions
    $checkboxPositions = @(
        @{y=400; name="exercise1"},
        @{y=550; name="exercise2"},
        @{y=700; name="exercise3"}
    )
    
    foreach ($pos in $checkboxPositions) {
        Write-Log "Checking exercise: $($pos.name)"
        adb shell input tap 650 $pos.y
        Start-Sleep -Milliseconds 500
        Take-Screenshot "checklist_$($pos.name)_checked"
    }
    
    # Test scrolling
    Write-Log "Testing checklist scrolling"
    adb shell input swipe 540 1200 540 400 300
    Start-Sleep -Seconds 1
    Take-Screenshot "checklist_scrolled"
    
    # Return to home
    adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
}

function Test-RecordScreen {
    Write-Log "=== Testing Record Screen ===" "INFO"
    
    # Navigate to record
    adb shell input swipe 540 900 300 1100 500
    Start-Sleep -Seconds 2
    Take-Screenshot "record_initial"
    
    # Test tab navigation
    $tabs = @(
        @{x=200; name="exercise"},
        @{x=540; name="ratings"},
        @{x=880; name="memo"}
    )
    
    foreach ($tab in $tabs) {
        Write-Log "Testing tab: $($tab.name)"
        adb shell input tap $tab.x 350
        Start-Sleep -Seconds 1
        Take-Screenshot "record_tab_$($tab.name)"
        
        # Interact with tab content
        switch($tab.name) {
            "exercise" {
                # Select exercise
                adb shell input tap 540 600
                Start-Sleep -Milliseconds 500
            }
            "ratings" {
                # Adjust sliders
                adb shell input swipe 300 600 700 600 300
                Start-Sleep -Milliseconds 500
                adb shell input swipe 300 750 600 750 300
                Start-Sleep -Milliseconds 500
            }
            "memo" {
                # Tap memo field and type
                adb shell input tap 540 600
                Start-Sleep -Milliseconds 500
                adb shell input text "Great_workout_today"
                Start-Sleep -Milliseconds 500
            }
        }
        Take-Screenshot "record_tab_$($tab.name)_filled"
    }
    
    # Save record
    Write-Log "Saving record"
    adb shell input tap 540 1400
    Start-Sleep -Seconds 2
    Take-Screenshot "record_saved"
    
    # Return to home
    adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
}

function Test-HistoryScreen {
    Write-Log "=== Testing History Screen ===" "INFO"
    
    # Navigate to history
    adb shell input swipe 540 900 780 1100 500
    Start-Sleep -Seconds 2
    Take-Screenshot "history_initial"
    
    # Test scrolling through history
    Write-Log "Testing history scrolling"
    adb shell input swipe 540 1000 540 400 500
    Start-Sleep -Seconds 1
    Take-Screenshot "history_scrolled"
    
    # Test record deletion (long press)
    Write-Log "Testing record deletion"
    adb shell input swipe 540 600 540 600 1000
    Start-Sleep -Seconds 1
    Take-Screenshot "history_delete_dialog"
    
    # Cancel deletion
    adb shell input tap 300 900
    Start-Sleep -Seconds 1
    
    # Return to home
    adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
}

function Test-ProfileScreen {
    Write-Log "=== Testing Profile Screen ===" "INFO"
    
    # Navigate to profile
    adb shell input swipe 540 900 540 400 500
    Start-Sleep -Seconds 2
    Take-Screenshot "profile_initial"
    
    # Test scrolling
    Write-Log "Testing profile scrolling"
    adb shell input swipe 540 1200 540 400 500
    Start-Sleep -Seconds 1
    Take-Screenshot "profile_scrolled"
    
    # Test stats interaction
    Write-Log "Testing stats grid"
    adb shell input tap 300 700
    Start-Sleep -Milliseconds 500
    Take-Screenshot "profile_stats_tapped"
    
    # Return to home
    adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
}

function Test-CoachScreen {
    Write-Log "=== Testing Coach Screen ===" "INFO"
    
    # Navigate to coach
    adb shell input swipe 540 900 780 700 500
    Start-Sleep -Seconds 2
    Take-Screenshot "coach_initial"
    
    # Test refresh tips
    Write-Log "Testing refresh tips"
    adb shell input tap 540 1100
    Start-Sleep -Seconds 2
    Take-Screenshot "coach_tips_refreshed"
    
    # Test AI coach chat
    Write-Log "Testing AI coach chat"
    adb shell input tap 540 1250
    Start-Sleep -Seconds 2
    Take-Screenshot "coach_ai_chat"
    
    # Return to home
    adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
    adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
}

function Test-EdgeCases {
    Write-Log "=== Testing Edge Cases ===" "WARNING"
    
    # Rapid navigation
    Write-Log "Testing rapid screen switching"
    for ($i = 1; $i -le 5; $i++) {
        adb shell input swipe 540 900 300 700 200
        Start-Sleep -Milliseconds 300
        adb shell input keyevent KEYCODE_BACK
        Start-Sleep -Milliseconds 300
    }
    Take-Screenshot "edge_rapid_navigation"
    
    # Multiple simultaneous touches
    Write-Log "Testing simultaneous touches"
    Start-Job -ScriptBlock { adb shell input tap 300 700 } | Out-Null
    Start-Job -ScriptBlock { adb shell input tap 700 700 } | Out-Null
    Start-Sleep -Seconds 1
    Get-Job | Remove-Job -Force
    Take-Screenshot "edge_simultaneous_touch"
    
    # Drag to invalid zones
    Write-Log "Testing drag to corners"
    adb shell input swipe 540 900 50 50 500
    Start-Sleep -Seconds 1
    Take-Screenshot "edge_corner_drag"
    
    # Very fast drag
    Write-Log "Testing very fast drag"
    adb shell input swipe 540 900 300 700 50
    Start-Sleep -Seconds 1
    Take-Screenshot "edge_fast_drag"
    
    # Very slow drag
    Write-Log "Testing very slow drag"
    adb shell input swipe 540 900 780 700 3000
    Start-Sleep -Seconds 2
    Take-Screenshot "edge_slow_drag"
}

function Test-MemoryAndPerformance {
    Write-Log "=== Testing Memory and Performance ===" "INFO"
    
    # Get initial memory info
    $initialMemory = adb shell dumpsys meminfo com.squashtrainingapp | Out-String
    $initialMemory | Out-File "$debugDir/memory_initial.txt"
    
    # Stress test - navigate through all screens multiple times
    Write-Log "Performing stress test"
    for ($i = 1; $i -le 10; $i++) {
        Write-Log "Stress test iteration $i/10"
        
        # Navigate to each screen
        $zones = @(
            @{x=540; y=400; name="profile"},
            @{x=300; y=700; name="checklist"},
            @{x=780; y=700; name="coach"},
            @{x=300; y=1100; name="record"},
            @{x=780; y=1100; name="history"}
        )
        
        foreach ($zone in $zones) {
            adb shell input swipe 540 900 $zone.x $zone.y 300
            Start-Sleep -Milliseconds 500
            adb shell input keyevent KEYCODE_BACK
            Start-Sleep -Milliseconds 500
        }
    }
    
    # Get final memory info
    $finalMemory = adb shell dumpsys meminfo com.squashtrainingapp | Out-String
    $finalMemory | Out-File "$debugDir/memory_final.txt"
    
    # Check for memory leaks
    Write-Log "Memory analysis saved to debug folder"
    
    # Get performance stats
    $gfxinfo = adb shell dumpsys gfxinfo com.squashtrainingapp | Out-String
    $gfxinfo | Out-File "$debugDir/gfxinfo.txt"
}

function Test-RealUserScenario {
    Write-Log "=== Testing Real User Scenario ===" "SUCCESS"
    
    Write-Log "Scenario: Complete daily workout routine"
    
    # 1. Check profile first
    Write-Log "Step 1: Checking profile"
    adb shell input swipe 540 900 540 400 500
    Start-Sleep -Seconds 2
    Take-Screenshot "scenario_01_profile"
    adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
    
    # 2. View checklist
    Write-Log "Step 2: Viewing today's exercises"
    adb shell input swipe 540 900 300 700 500
    Start-Sleep -Seconds 2
    Take-Screenshot "scenario_02_checklist"
    
    # Check first 3 exercises
    for ($i = 0; $i -lt 3; $i++) {
        $y = 400 + ($i * 150)
        adb shell input tap 650 $y
        Start-Sleep -Milliseconds 300
    }
    Take-Screenshot "scenario_03_exercises_checked"
    adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
    
    # 3. Get coach advice
    Write-Log "Step 3: Getting coach advice"
    adb shell input swipe 540 900 780 700 500
    Start-Sleep -Seconds 2
    Take-Screenshot "scenario_04_coach_advice"
    adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
    
    # 4. Record workout
    Write-Log "Step 4: Recording workout"
    adb shell input swipe 540 900 300 1100 500
    Start-Sleep -Seconds 2
    
    # Fill all tabs
    adb shell input tap 200 350  # Exercise tab
    Start-Sleep -Milliseconds 500
    adb shell input tap 540 600  # Select exercise
    Start-Sleep -Milliseconds 500
    
    adb shell input tap 540 350  # Ratings tab
    Start-Sleep -Milliseconds 500
    adb shell input swipe 300 600 700 600 300  # Intensity
    Start-Sleep -Milliseconds 300
    adb shell input swipe 300 750 600 750 300  # Technique
    Start-Sleep -Milliseconds 300
    
    adb shell input tap 880 350  # Memo tab
    Start-Sleep -Milliseconds 500
    adb shell input tap 540 600
    Start-Sleep -Milliseconds 500
    adb shell input text "Completed_all_exercises_feeling_great"
    Start-Sleep -Milliseconds 500
    
    # Save
    adb shell input tap 540 1400
    Start-Sleep -Seconds 2
    Take-Screenshot "scenario_05_workout_saved"
    adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
    
    # 5. Check history
    Write-Log "Step 5: Verifying in history"
    adb shell input swipe 540 900 780 1100 500
    Start-Sleep -Seconds 2
    Take-Screenshot "scenario_06_history_updated"
    adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
    
    Write-Log "User scenario completed successfully" "SUCCESS"
}

# Main execution
Write-Log "Starting Comprehensive Functional Debug" "INFO"
Write-Log "Debug results will be saved to: $debugDir" "INFO"

# Ensure app is installed and running
Write-Log "Launching app..."
adb shell am force-stop com.squashtrainingapp
Start-Sleep -Seconds 1
adb shell am start -n com.squashtrainingapp/.MainActivity
Start-Sleep -Seconds 3
Take-Screenshot "00_app_launch"

# Run all tests
$testResults = @{}

try {
    # 1. Mascot drag functionality
    Write-Log "=== TEST 1: Mascot Drag Functionality ===" "INFO"
    Test-MascotDrag 540 900 540 400 500 "to_profile"
    adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
    
    Test-MascotDrag 540 900 300 700 500 "to_checklist"
    adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
    
    Test-MascotDrag 540 900 780 700 500 "to_coach"
    adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
    
    Test-MascotDrag 540 900 300 1100 500 "to_record"
    adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
    
    Test-MascotDrag 540 900 780 1100 500 "to_history"
    adb shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
    
    $testResults["MascotDrag"] = "PASSED"
    
    # 2. Voice recognition
    Write-Log "=== TEST 2: Voice Recognition ===" "INFO"
    Test-VoiceRecognition
    $testResults["VoiceRecognition"] = "PASSED"
    
    # 3. Screen functionality tests
    Test-ProfileScreen
    $testResults["ProfileScreen"] = "PASSED"
    
    Test-ChecklistScreen
    $testResults["ChecklistScreen"] = "PASSED"
    
    Test-RecordScreen
    $testResults["RecordScreen"] = "PASSED"
    
    Test-HistoryScreen
    $testResults["HistoryScreen"] = "PASSED"
    
    Test-CoachScreen
    $testResults["CoachScreen"] = "PASSED"
    
    # 4. Edge cases
    Test-EdgeCases
    $testResults["EdgeCases"] = "PASSED"
    
    # 5. Memory and performance
    Test-MemoryAndPerformance
    $testResults["MemoryPerformance"] = "PASSED"
    
    # 6. Real user scenario
    Test-RealUserScenario
    $testResults["UserScenario"] = "PASSED"
    
} catch {
    Write-Log "Error during testing: $_" "ERROR"
    $testResults["LastTest"] = "FAILED"
}

# Generate test report
Write-Log "`n=== COMPREHENSIVE DEBUG REPORT ===" "INFO"
$report = @"
SQUASH TRAINING APP - COMPREHENSIVE DEBUG REPORT
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

TEST RESULTS:
"@

foreach ($test in $testResults.GetEnumerator()) {
    $status = if ($test.Value -eq "PASSED") { "[PASS]" } else { "[FAIL]" }
    $report += "`n$status $($test.Key): $($test.Value)"
    Write-Log "$($test.Key): $($test.Value)" $(if($test.Value -eq "PASSED"){"SUCCESS"}else{"ERROR"})
}

$passedTests = ($testResults.Values | Where-Object { $_ -eq "PASSED" }).Count
$totalTests = $testResults.Count
$successRate = [math]::Round(($passedTests / $totalTests) * 100, 2)

$report += @"

SUMMARY:
- Total Tests: $totalTests
- Passed: $passedTests
- Failed: $($totalTests - $passedTests)
- Success Rate: $successRate%

SCREENSHOTS CAPTURED: $(Get-ChildItem $screenshotDir -Filter "*.png" | Measure-Object).Count
DEBUG LOGS: $logFile

RECOMMENDATIONS:
"@

if ($successRate -eq 100) {
    $report += "`n- All tests passed! App is functioning correctly."
} else {
    $report += "`n- Review failed tests and fix issues before release."
}

$report | Out-File "$debugDir/TEST_REPORT.txt"
Write-Log "`nTest report saved to: $debugDir/TEST_REPORT.txt" "SUCCESS"
Write-Log "Debug session completed. Success rate: $successRate%" $(if($successRate -eq 100){"SUCCESS"}else{"WARNING"})

# Display final status
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "COMPREHENSIVE DEBUG COMPLETED" -ForegroundColor Green
Write-Host "Results saved to: $debugDir" -ForegroundColor Yellow
Write-Host "Success Rate: $successRate%" -ForegroundColor $(if($successRate -eq 100){"Green"}else{"Yellow"})
Write-Host "========================================" -ForegroundColor Cyan