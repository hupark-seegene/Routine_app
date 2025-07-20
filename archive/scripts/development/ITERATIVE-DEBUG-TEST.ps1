# ITERATIVE-DEBUG-TEST.ps1
# Performs 50+ iterations of install-test-uninstall cycle with existing APK

param(
    [int]$Iterations = 50,
    [string]$ApkPath = "debug-results-20250714-191158/app-debug.apk",
    [switch]$StopOnError = $false
)

# Environment setup
$ADB = "C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$PACKAGE_NAME = "com.squashtrainingapp"
$TIMESTAMP = Get-Date -Format "yyyyMMdd-HHmmss"
$RESULTS_DIR = "iterative-debug-$TIMESTAMP"

# Create results directory
New-Item -ItemType Directory -Force -Path $RESULTS_DIR | Out-Null

# Logging function
function Write-Log {
    param($Message, $Type = "INFO")
    $LogMessage = "[$(Get-Date -Format 'HH:mm:ss')] [$Type] $Message"
    $Color = switch ($Type) {
        "ERROR" { "Red" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        default { "White" }
    }
    Write-Host $LogMessage -ForegroundColor $Color
    Add-Content -Path "$RESULTS_DIR\iteration-log.txt" -Value $LogMessage
}

# Test results tracking
$TestResults = @{
    TotalIterations = 0
    SuccessfulIterations = 0
    FailedIterations = 0
    CrashCount = 0
    Issues = @()
}

# Check if APK exists
if (-not (Test-Path $ApkPath)) {
    Write-Log "APK not found at: $ApkPath" "ERROR"
    exit 1
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "   ITERATIVE DEBUG TEST - $Iterations CYCLES" -ForegroundColor Cyan
Write-Host "================================================`n" -ForegroundColor Cyan

# Main iteration loop
for ($i = 1; $i -le $Iterations; $i++) {
    Write-Log "=== ITERATION $i/$Iterations ===" "INFO"
    $TestResults.TotalIterations++
    $IterationSuccess = $true
    $IterationDir = "$RESULTS_DIR\iteration-$i"
    New-Item -ItemType Directory -Force -Path $IterationDir | Out-Null
    
    try {
        # 1. Uninstall previous version
        Write-Log "Uninstalling previous version..." "INFO"
        & $ADB uninstall $PACKAGE_NAME 2>&1 | Out-Null
        
        # 2. Install APK
        Write-Log "Installing APK..." "INFO"
        $installResult = & $ADB install $ApkPath 2>&1
        if ($installResult -match "Success") {
            Write-Log "APK installed successfully" "SUCCESS"
        } else {
            Write-Log "Installation failed: $installResult" "ERROR"
            $TestResults.Issues += "Iteration ${i}: Installation failed"
            $IterationSuccess = $false
            continue
        }
        
        # 3. Clear logcat
        & $ADB logcat -c
        
        # 4. Launch app
        Write-Log "Launching app..." "INFO"
        & $ADB shell am start -n "$PACKAGE_NAME/.MainActivity" 2>&1 | Out-Null
        Start-Sleep -Seconds 3
        
        # 5. Take initial screenshot
        & $ADB shell screencap -p /sdcard/home_$i.png
        & $ADB pull /sdcard/home_$i.png "$IterationDir\01_home.png" 2>&1 | Out-Null
        & $ADB shell rm /sdcard/home_$i.png
        
        # 6. Test mascot navigation
        Write-Log "Testing mascot navigation..." "INFO"
        $zones = @(
            @{Name="Profile"; X=540; Y=400},
            @{Name="Checklist"; X=270; Y=800},
            @{Name="Coach"; X=810; Y=800},
            @{Name="Record"; X=270; Y=1600},
            @{Name="History"; X=810; Y=1600},
            @{Name="Settings"; X=540; Y=2000}
        )
        
        foreach ($zone in $zones) {
            Write-Log "Testing $($zone.Name) zone..." "INFO"
            # Drag mascot to zone
            & $ADB shell input swipe 540 1200 $($zone.X) $($zone.Y) 800
            Start-Sleep -Seconds 2
            
            # Take screenshot
            & $ADB shell screencap -p /sdcard/zone_$i.png
            & $ADB pull /sdcard/zone_$i.png "$IterationDir\$($zone.Name).png" 2>&1 | Out-Null
            & $ADB shell rm /sdcard/zone_$i.png
            
            # Return to home
            & $ADB shell input keyevent KEYCODE_BACK
            Start-Sleep -Seconds 1
        }
        
        # 7. Test voice recognition
        Write-Log "Testing voice recognition..." "INFO"
        & $ADB shell input swipe 540 1200 540 1200 2000  # 2-second long press
        Start-Sleep -Seconds 2
        & $ADB shell screencap -p /sdcard/voice_$i.png
        & $ADB pull /sdcard/voice_$i.png "$IterationDir\voice_recognition.png" 2>&1 | Out-Null
        & $ADB shell rm /sdcard/voice_$i.png
        & $ADB shell input keyevent KEYCODE_BACK
        
        # 8. Check for crashes
        $logcat = & $ADB logcat -d -v brief | Select-String "FATAL|AndroidRuntime.*FATAL|Process.*died"
        if ($logcat) {
            Write-Log "Crash detected!" "ERROR"
            $TestResults.CrashCount++
            $TestResults.Issues += "Iteration ${i}: Crash detected"
            $logcat | Out-File "$IterationDir\crash_log.txt"
            $IterationSuccess = $false
        }
        
        # 9. Performance check
        $memInfo = & $ADB shell dumpsys meminfo $PACKAGE_NAME | Select-String "TOTAL PSS"
        $memInfo | Out-File "$IterationDir\memory.txt"
        
        if ($IterationSuccess) {
            $TestResults.SuccessfulIterations++
            Write-Log "Iteration $i completed successfully" "SUCCESS"
        } else {
            $TestResults.FailedIterations++
            Write-Log "Iteration $i failed" "ERROR"
            
            if ($StopOnError) {
                Write-Log "Stopping due to error (StopOnError flag set)" "WARNING"
                break
            }
        }
        
    } catch {
        Write-Log "Exception in iteration ${i}: $_" "ERROR"
        $TestResults.FailedIterations++
        $TestResults.Issues += "Iteration ${i}: Exception - $_"
        
        if ($StopOnError) {
            break
        }
    } finally {
        # Uninstall app for clean next iteration
        & $ADB uninstall $PACKAGE_NAME 2>&1 | Out-Null
    }
    
    # Progress report every 10 iterations
    if ($i % 10 -eq 0) {
        Write-Host "`n--- PROGRESS REPORT ---" -ForegroundColor Yellow
        Write-Host "Completed: $i/$Iterations" -ForegroundColor White
        Write-Host "Success Rate: $([math]::Round(($TestResults.SuccessfulIterations/$i)*100, 2))%" -ForegroundColor White
        Write-Host "Crashes: $($TestResults.CrashCount)" -ForegroundColor White
        Write-Host "----------------------`n" -ForegroundColor Yellow
    }
    
    # Small pause between iterations
    Start-Sleep -Seconds 2
}

# Generate final report
$Report = @"
ITERATIVE DEBUG TEST REPORT
==========================
Date: $(Get-Date)
APK: $ApkPath

SUMMARY
-------
Total Iterations: $($TestResults.TotalIterations)
Successful: $($TestResults.SuccessfulIterations)
Failed: $($TestResults.FailedIterations)
Success Rate: $([math]::Round(($TestResults.SuccessfulIterations/$TestResults.TotalIterations)*100, 2))%
Crashes: $($TestResults.CrashCount)

ISSUES FOUND
------------
$($TestResults.Issues -join "`n")

CONCLUSION
----------
$(if ($TestResults.SuccessfulIterations -eq $TestResults.TotalIterations) {
    "✅ ALL TESTS PASSED! The app is stable and ready for production."
} elseif ($TestResults.SuccessfulIterations -gt ($TestResults.TotalIterations * 0.9)) {
    "⚠️ MOSTLY STABLE: The app passed $([math]::Round(($TestResults.SuccessfulIterations/$TestResults.TotalIterations)*100, 2))% of tests. Minor issues need attention."
} else {
    "❌ UNSTABLE: The app only passed $([math]::Round(($TestResults.SuccessfulIterations/$TestResults.TotalIterations)*100, 2))% of tests. Major issues need to be fixed."
})
"@

$Report | Out-File "$RESULTS_DIR\FINAL-REPORT.txt"
Write-Host "`n$Report" -ForegroundColor Cyan

Write-Log "Test results saved to: $RESULTS_DIR" "INFO"

# Open results folder
explorer $RESULTS_DIR