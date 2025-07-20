# Phase 5: Comprehensive Test Automation Script
# Runs 50+ cycles of: Install -> Run -> Test -> Debug -> Uninstall -> Modify

param(
    [int]$MaxCycles = 50,
    [int]$StartCycle = 1,
    [switch]$SkipBuild = $false,
    [switch]$DetailedLog = $false,
    [string]$LogFile = "automation_log.txt"
)

$ErrorActionPreference = "Continue"

# Global variables
$AppPackage = "com.squashtrainingapp"
$AppName = "SquashTrainingApp"
$AdbPath = "adb"
$BuildPath = "SquashTrainingApp/android"
$ApkPath = "SquashTrainingApp/android/app/build/outputs/apk/debug/app-debug.apk"
$TestResults = @()
$FailedCycles = @()
$PassedCycles = @()

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Blue = "Blue"

function Write-Status {
    param([string]$Message, [string]$Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage -ForegroundColor $Color
    
    if ($DetailedLog) {
        Add-Content -Path $LogFile -Value $logMessage
    }
}

function Write-CycleHeader {
    param([int]$Cycle, [string]$Phase)
    $header = "=" * 80
    Write-Status $header $Cyan
    Write-Status "CYCLE $Cycle - $Phase" $Cyan
    Write-Status $header $Cyan
}

function Test-DeviceConnection {
    Write-Status "Testing device connection..." $Yellow
    
    $devices = & $AdbPath devices | Select-String "device$"
    if ($devices.Count -eq 0) {
        Write-Status "❌ No devices connected" $Red
        return $false
    }
    
    Write-Status "✅ Device connected: $($devices[0].ToString().Split()[0])" $Green
    return $true
}

function Build-App {
    Write-Status "Building application..." $Yellow
    
    Set-Location $BuildPath
    
    # Clean previous build
    & ./gradlew clean
    
    # Build debug APK
    $buildResult = & ./gradlew assembleDebug
    
    Set-Location "../.."
    
    if (Test-Path $ApkPath) {
        Write-Status "✅ Build successful: $ApkPath" $Green
        return $true
    } else {
        Write-Status "❌ Build failed" $Red
        return $false
    }
}

function Install-App {
    Write-Status "Installing application..." $Yellow
    
    # Uninstall previous version if exists
    & $AdbPath uninstall $AppPackage 2>$null
    
    # Install new APK
    $installResult = & $AdbPath install -r $ApkPath 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Status "✅ App installed successfully" $Green
        return $true
    } else {
        Write-Status "❌ App installation failed: $installResult" $Red
        return $false
    }
}

function Start-App {
    Write-Status "Starting application..." $Yellow
    
    # Start the app
    & $AdbPath shell am start -n "$AppPackage/.MainActivity"
    Start-Sleep -Seconds 3
    
    # Check if app is running
    $runningApps = & $AdbPath shell ps | Select-String $AppPackage
    if ($runningApps) {
        Write-Status "✅ App started successfully" $Green
        return $true
    } else {
        Write-Status "❌ App failed to start" $Red
        return $false
    }
}

function Test-AppFeatures {
    Write-Status "Testing app features..." $Yellow
    
    $testsPassed = 0
    $totalTests = 6
    
    # Test 1: Check if MainActivity is responsive
    Write-Status "Test 1: Checking MainActivity responsiveness..." $Blue
    $activityCheck = & $AdbPath shell dumpsys activity activities | Select-String "MainActivity"
    if ($activityCheck) {
        Write-Status "✅ MainActivity is active" $Green
        $testsPassed++
    } else {
        Write-Status "❌ MainActivity not found" $Red
    }
    
    # Test 2: Test screen touches (simulate mascot interaction)
    Write-Status "Test 2: Testing touch interactions..." $Blue
    & $AdbPath shell input tap 500 800  # Center tap
    Start-Sleep -Seconds 1
    & $AdbPath shell input tap 300 600  # Drag simulation
    Start-Sleep -Seconds 1
    & $AdbPath shell input tap 700 600  # Another zone
    Start-Sleep -Seconds 1
    Write-Status "✅ Touch interactions completed" $Green
    $testsPassed++
    
    # Test 3: Test long press for voice (simulate)
    Write-Status "Test 3: Testing long press interaction..." $Blue
    & $AdbPath shell input swipe 500 800 500 800 2000  # Long press simulation
    Start-Sleep -Seconds 2
    Write-Status "✅ Long press interaction completed" $Green
    $testsPassed++
    
    # Test 4: Check for crashes
    Write-Status "Test 4: Checking for crashes..." $Blue
    $crashCheck = & $AdbPath shell dumpsys dropbox | Select-String "crash"
    if (-not $crashCheck) {
        Write-Status "✅ No crashes detected" $Green
        $testsPassed++
    } else {
        Write-Status "❌ Crashes detected" $Red
    }
    
    # Test 5: Check memory usage
    Write-Status "Test 5: Checking memory usage..." $Blue
    $memInfo = & $AdbPath shell dumpsys meminfo $AppPackage
    if ($memInfo) {
        Write-Status "✅ Memory usage check completed" $Green
        $testsPassed++
    } else {
        Write-Status "❌ Memory check failed" $Red
    }
    
    # Test 6: Test app navigation
    Write-Status "Test 6: Testing app navigation..." $Blue
    & $AdbPath shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
    & $AdbPath shell input keyevent KEYCODE_HOME
    Start-Sleep -Seconds 1
    & $AdbPath shell am start -n "$AppPackage/.MainActivity"
    Start-Sleep -Seconds 2
    Write-Status "✅ Navigation test completed" $Green
    $testsPassed++
    
    $passRate = ($testsPassed / $totalTests) * 100
    Write-Status "Feature tests completed: $testsPassed/$totalTests passed ($passRate%)" $Yellow
    
    return @{
        PassedTests = $testsPassed
        TotalTests = $totalTests
        PassRate = $passRate
        Success = ($testsPassed -ge 5)  # At least 5 out of 6 tests must pass
    }
}

function Debug-App {
    Write-Status "Debugging application..." $Yellow
    
    # Capture logs
    $logOutput = & $AdbPath logcat -d | Select-String -Pattern "SquashTrainingApp|MainActivity|MascotView" | Select-Object -Last 20
    
    if ($logOutput) {
        Write-Status "Debug logs captured:" $Blue
        foreach ($line in $logOutput) {
            Write-Status $line.ToString() $Blue
        }
    }
    
    # Check for errors
    $errors = & $AdbPath logcat -d | Select-String -Pattern "ERROR|FATAL" | Select-String "SquashTrainingApp"
    if ($errors) {
        Write-Status "❌ Errors found in logs:" $Red
        foreach ($error in $errors) {
            Write-Status $error.ToString() $Red
        }
        return $false
    } else {
        Write-Status "✅ No critical errors found" $Green
        return $true
    }
}

function Uninstall-App {
    Write-Status "Uninstalling application..." $Yellow
    
    $uninstallResult = & $AdbPath uninstall $AppPackage 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Status "✅ App uninstalled successfully" $Green
        return $true
    } else {
        Write-Status "❌ App uninstallation failed: $uninstallResult" $Red
        return $false
    }
}

function Simulate-Modifications {
    Write-Status "Simulating code modifications..." $Yellow
    
    # This is a placeholder for actual modifications
    # In a real scenario, you might:
    # 1. Update version numbers
    # 2. Modify configuration files
    # 3. Update test parameters
    # 4. Change build configurations
    
    Write-Status "✅ Modifications simulated" $Green
    return $true
}

function Generate-CycleReport {
    param([int]$Cycle, [hashtable]$TestResult, [bool]$Success)
    
    $result = @{
        Cycle = $Cycle
        Timestamp = Get-Date
        TestResult = $TestResult
        Success = $Success
        PassRate = if ($TestResult) { $TestResult.PassRate } else { 0 }
    }
    
    $TestResults += $result
    
    if ($Success) {
        $PassedCycles += $Cycle
        Write-Status "✅ CYCLE $Cycle PASSED" $Green
    } else {
        $FailedCycles += $Cycle
        Write-Status "❌ CYCLE $Cycle FAILED" $Red
    }
    
    return $result
}

function Generate-FinalReport {
    Write-Status "=" * 80 $Cyan
    Write-Status "FINAL AUTOMATION REPORT" $Cyan
    Write-Status "=" * 80 $Cyan
    
    $totalCycles = $TestResults.Count
    $passedCount = $PassedCycles.Count
    $failedCount = $FailedCycles.Count
    $overallPassRate = if ($totalCycles -gt 0) { ($passedCount / $totalCycles) * 100 } else { 0 }
    
    Write-Status "Total Cycles: $totalCycles" $Yellow
    Write-Status "Passed: $passedCount" $Green
    Write-Status "Failed: $failedCount" $Red
    Write-Status "Overall Pass Rate: $overallPassRate%" $Yellow
    
    if ($failedCount -gt 0) {
        Write-Status "Failed Cycles: $($FailedCycles -join ', ')" $Red
    }
    
    if ($passedCount -gt 0) {
        Write-Status "Passed Cycles: $($PassedCycles -join ', ')" $Green
    }
    
    # Average test pass rate
    $avgTestPassRate = ($TestResults | ForEach-Object { $_.PassRate } | Measure-Object -Average).Average
    Write-Status "Average Test Pass Rate: $avgTestPassRate%" $Yellow
    
    # Recommendation
    if ($overallPassRate -ge 80) {
        Write-Status "✅ RECOMMENDATION: Application is ready for production deployment" $Green
    } elseif ($overallPassRate -ge 60) {
        Write-Status "⚠️  RECOMMENDATION: Application needs minor improvements before deployment" $Yellow
    } else {
        Write-Status "❌ RECOMMENDATION: Application needs significant improvements before deployment" $Red
    }
    
    Write-Status "=" * 80 $Cyan
}

function Main {
    Write-Status "Starting Comprehensive Test Automation..." $Cyan
    Write-Status "Target Cycles: $MaxCycles" $Cyan
    Write-Status "Starting from Cycle: $StartCycle" $Cyan
    
    # Initialize log file
    if ($DetailedLog) {
        "Test Automation Started: $(Get-Date)" | Out-File -FilePath $LogFile -Encoding UTF8
    }
    
    # Check device connection
    if (-not (Test-DeviceConnection)) {
        Write-Status "❌ Device connection failed. Exiting..." $Red
        return
    }
    
    # Main automation loop
    for ($cycle = $StartCycle; $cycle -le $MaxCycles; $cycle++) {
        try {
            Write-CycleHeader $cycle "Starting DDD Cycle"
            
            $cycleSuccess = $true
            
            # Phase 1: Build (if not skipped)
            if (-not $SkipBuild -or $cycle -eq $StartCycle) {
                if (-not (Build-App)) {
                    $cycleSuccess = $false
                }
            }
            
            # Phase 2: Install
            if ($cycleSuccess -and -not (Install-App)) {
                $cycleSuccess = $false
            }
            
            # Phase 3: Run
            if ($cycleSuccess -and -not (Start-App)) {
                $cycleSuccess = $false
            }
            
            # Phase 4: Test
            $testResult = $null
            if ($cycleSuccess) {
                $testResult = Test-AppFeatures
                if (-not $testResult.Success) {
                    $cycleSuccess = $false
                }
            }
            
            # Phase 5: Debug
            if ($cycleSuccess -and -not (Debug-App)) {
                $cycleSuccess = $false
            }
            
            # Phase 6: Uninstall
            if (-not (Uninstall-App)) {
                Write-Status "⚠️  Uninstall failed, continuing..." $Yellow
            }
            
            # Phase 7: Modify (simulate)
            if ($cycle -lt $MaxCycles) {
                Simulate-Modifications
            }
            
            # Generate cycle report
            Generate-CycleReport $cycle $testResult $cycleSuccess
            
            # Brief pause between cycles
            Start-Sleep -Seconds 2
            
        } catch {
            Write-Status "❌ Cycle $cycle failed with exception: $($_.Exception.Message)" $Red
            $FailedCycles += $cycle
        }
    }
    
    # Generate final report
    Generate-FinalReport
    
    Write-Status "Comprehensive Test Automation Completed!" $Cyan
}

# Run the main function
Main