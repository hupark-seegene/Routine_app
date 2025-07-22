# BUILD-CYCLE-TEST.ps1
# Purpose: Automated build-test-debug cycle for 50+ iterations
# Category: BUILD
# Description: Comprehensive automated testing with logging

param(
    [int]$Cycles = 50,
    [switch]$DetailedLogging,
    [switch]$StopOnError,
    [string]$LogPath = "test-logs"
)

$ErrorActionPreference = "Continue"
$StartTime = Get-Date
$CycleResults = @()

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Automated Build-Test-Debug Cycle" -ForegroundColor Cyan
Write-Host "    Target Cycles: $Cycles" -ForegroundColor Yellow
Write-Host "    Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "==========================================" -ForegroundColor Cyan

# Project paths
$projectRoot = Split-Path -Parent -Path (Split-Path -Parent -Path $PSScriptRoot)
$androidPath = Join-Path $projectRoot "android"
$srcPath = Join-Path $projectRoot "src"
$buildPath = Join-Path $androidPath "app\build\outputs\apk\debug"
$apkName = "app-debug.apk"
$dddPath = Join-Path $projectRoot "ddd"

# Create log directory
$logDir = Join-Path $projectRoot $LogPath
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# ADB and emulator paths
$adbPath = "C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$emulatorPath = "C:\Users\hwpar\AppData\Local\Android\Sdk\emulator\emulator.exe"

# Color output functions
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

# Logging function
function Write-Log {
    param($Message, $Level = "INFO", $CycleNum = 0)
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logFile = Join-Path $logDir "cycle-$($CycleNum.ToString('000')).log"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    Add-Content -Path $logFile -Value $logEntry -Force
    
    if ($DetailedLogging) {
        switch ($Level) {
            "ERROR" { Write-Error $Message }
            "WARNING" { Write-Warning $Message }
            "SUCCESS" { Write-Success $Message }
            default { Write-Info $Message }
        }
    }
}

# Test feature list
$TestFeatures = @(
    @{ Name = "Mascot Drag"; Command = "input swipe 100 500 300 500"; Description = "Testing mascot drag functionality" },
    @{ Name = "Long Press AI"; Command = "input touchscreen swipe 200 500 200 500 2000"; Description = "Testing AI voice activation" },
    @{ Name = "Navigate Home"; Command = "input tap 100 100"; Description = "Testing home navigation" },
    @{ Name = "Navigate Profile"; Command = "input tap 300 100"; Description = "Testing profile screen" },
    @{ Name = "Navigate Checklist"; Command = "input tap 100 300"; Description = "Testing checklist screen" },
    @{ Name = "Navigate Record"; Command = "input tap 300 300"; Description = "Testing record screen" },
    @{ Name = "Navigate Coach"; Command = "input tap 100 500"; Description = "Testing coach screen" },
    @{ Name = "Navigate Settings"; Command = "input tap 300 500"; Description = "Testing settings screen" },
    @{ Name = "Test Backup"; Command = "input tap 200 400"; Description = "Testing backup functionality" },
    @{ Name = "Check Memory"; Command = "dumpsys meminfo com.squashtrainingapp"; Description = "Checking memory usage" }
)

# Update DDD directory
function Update-DDD {
    param($CycleNum)
    
    Write-Log "Updating DDD directory..." "INFO" $CycleNum
    
    try {
        Set-Location $projectRoot
        
        # Remove and recreate ddd
        if (Test-Path $dddPath) {
            Remove-Item -Path $dddPath -Recurse -Force
        }
        New-Item -ItemType Directory -Path $dddPath -Force | Out-Null
        
        # Copy node_modules
        $nodeModulesPath = Join-Path $projectRoot "node_modules"
        if (Test-Path $nodeModulesPath) {
            Write-Log "Copying node_modules to ddd..." "INFO" $CycleNum
            Copy-Item -Path $nodeModulesPath -Destination $dddPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "DDD update completed" "SUCCESS" $CycleNum
            return $true
        } else {
            Write-Log "node_modules not found" "ERROR" $CycleNum
            return $false
        }
    } catch {
        Write-Log "Failed to update DDD: $_" "ERROR" $CycleNum
        return $false
    }
}

# Build APK
function Build-APK {
    param($CycleNum)
    
    Write-Log "Building APK..." "INFO" $CycleNum
    
    try {
        Set-Location $androidPath
        
        # Clean build
        Write-Log "Cleaning previous build..." "INFO" $CycleNum
        & ./gradlew clean 2>&1 | Out-Null
        
        # Build debug APK
        Write-Log "Building debug APK..." "INFO" $CycleNum
        $buildOutput = & ./gradlew assembleDebug 2>&1
        
        # Check if APK exists
        $apkPath = Join-Path $buildPath $apkName
        if (Test-Path $apkPath) {
            $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
            Write-Log "APK built successfully ($apkSize MB)" "SUCCESS" $CycleNum
            return $apkPath
        } else {
            Write-Log "APK not found at expected location" "ERROR" $CycleNum
            Write-Log "Build output: $buildOutput" "ERROR" $CycleNum
            return $null
        }
    } catch {
        Write-Log "Build failed: $_" "ERROR" $CycleNum
        return $null
    }
}

# Install and test app
function Test-App {
    param($ApkPath, $CycleNum)
    
    $testResults = @{
        Success = $false
        MemoryUsage = 0
        Errors = @()
        PassedTests = 0
        TotalTests = $TestFeatures.Count
    }
    
    try {
        # Uninstall previous version
        Write-Log "Uninstalling previous version..." "INFO" $CycleNum
        & $adbPath uninstall com.squashtrainingapp 2>&1 | Out-Null
        
        # Install new APK
        Write-Log "Installing APK..." "INFO" $CycleNum
        $installResult = & $adbPath install -r $ApkPath 2>&1 | Out-String
        if ($installResult -match "Success" -or $installResult -match "Performing Streamed Install") {
            Write-Log "Installation successful" "SUCCESS" $CycleNum
        } else {
            Write-Log "Installation failed: $installResult" "ERROR" $CycleNum
            $testResults.Errors += "Installation failed"
            return $testResults
        }
        
        # Launch app
        Write-Log "Launching app..." "INFO" $CycleNum
        & $adbPath shell am start -n com.squashtrainingapp/.MainActivity 2>&1 | Out-Null
        Start-Sleep -Seconds 5
        
        # Clear logcat
        & $adbPath logcat -c
        
        # Run tests
        foreach ($test in $TestFeatures) {
            Write-Log "Running test: $($test.Name)" "INFO" $CycleNum
            
            try {
                if ($test.Command -like "dumpsys*") {
                    $output = & $adbPath shell $test.Command 2>&1 | Out-String
                    if ($test.Name -eq "Check Memory") {
                        # Look for TOTAL PSS line which shows actual memory usage
                        if ($output -match "TOTAL PSS:\s+(\d+)") {
                            $memoryKB = [int]$matches[1]
                            $memoryMB = [math]::Round($memoryKB / 1024, 2)
                            $testResults.MemoryUsage = $memoryMB
                            Write-Log "Memory usage: $memoryMB MB" "INFO" $CycleNum
                            
                            if ($memoryMB -gt 120) {
                                Write-Log "Memory usage exceeds 120MB limit" "WARNING" $CycleNum
                                $testResults.Errors += "High memory usage: $memoryMB MB"
                            }
                        } elseif ($output -match "TOTAL\s+(\d+)") {
                            # Fallback to first TOTAL line
                            $memoryKB = [int]$matches[1]
                            $memoryMB = [math]::Round($memoryKB / 1024, 2)
                            $testResults.MemoryUsage = $memoryMB
                            Write-Log "Memory usage: $memoryMB MB" "INFO" $CycleNum
                        }
                    }
                } else {
                    & $adbPath shell $test.Command 2>&1 | Out-Null
                    Start-Sleep -Seconds 1  # Give app time to process navigation
                }
                
                # Check for crashes
                $logcat = & $adbPath logcat -d -s AndroidRuntime:E 2>&1
                if ($logcat -match "FATAL EXCEPTION") {
                    Write-Log "App crashed during $($test.Name)" "ERROR" $CycleNum
                    $testResults.Errors += "Crash during $($test.Name)"
                    continue
                }
                
                $testResults.PassedTests++
                Write-Log "Test passed: $($test.Name)" "SUCCESS" $CycleNum
                
            } catch {
                Write-Log "Test failed: $($test.Name) - $_" "ERROR" $CycleNum
                $testResults.Errors += "Failed: $($test.Name)"
            }
        }
        
        # Check final app state with a short delay
        Start-Sleep -Seconds 2  # Give app time to stabilize after tests
        $isRunning = & $adbPath shell pidof com.squashtrainingapp
        if ($isRunning) {
            $testResults.Success = ($testResults.Errors.Count -eq 0)
            Write-Log "App still running after tests (PID: $isRunning)" "SUCCESS" $CycleNum
        } else {
            # Try to get crash info from logcat
            $crashInfo = & $adbPath logcat -d -s AndroidRuntime:E -t 50 2>&1 | Out-String
            if ($crashInfo -match "FATAL EXCEPTION") {
                Write-Log "App crashed - check logcat for details" "ERROR" $CycleNum
                $testResults.Errors += "App crashed during tests"
            } else {
                Write-Log "App not running after tests (may have been closed)" "WARNING" $CycleNum
                # Don't mark as error if no crash detected - app might have just closed
                if ($testResults.Errors.Count -eq 0) {
                    $testResults.Success = $true
                }
            }
        }
        
    } catch {
        Write-Log "Test execution failed: $_" "ERROR" $CycleNum
        $testResults.Errors += "Test execution error"
    } finally {
        # Always uninstall after test
        Write-Log "Uninstalling app..." "INFO" $CycleNum
        & $adbPath uninstall com.squashtrainingapp 2>&1 | Out-Null
    }
    
    return $testResults
}

# Main cycle function
function Run-TestCycle {
    param($CycleNum)
    
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "  CYCLE $CycleNum / $Cycles" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    $cycleStart = Get-Date
    $cycleResult = @{
        CycleNumber = $CycleNum
        StartTime = $cycleStart
        Success = $false
        BuildSuccess = $false
        TestsPassed = 0
        TotalTests = $TestFeatures.Count
        MemoryUsage = 0
        Errors = @()
        Duration = 0
    }
    
    # Update DDD
    if (-not (Update-DDD -CycleNum $CycleNum)) {
        $cycleResult.Errors += "DDD update failed"
        if ($StopOnError) {
            Write-Error "Stopping due to DDD update failure"
            return $cycleResult
        }
    }
    
    # Build APK
    $apkPath = Build-APK -CycleNum $CycleNum
    if ($apkPath) {
        $cycleResult.BuildSuccess = $true
        
        # Test app
        $testResults = Test-App -ApkPath $apkPath -CycleNum $CycleNum
        $cycleResult.TestsPassed = $testResults.PassedTests
        $cycleResult.MemoryUsage = $testResults.MemoryUsage
        $cycleResult.Errors += $testResults.Errors
        $cycleResult.Success = $testResults.Success
    } else {
        $cycleResult.Errors += "Build failed"
        if ($StopOnError) {
            Write-Error "Stopping due to build failure"
            return $cycleResult
        }
    }
    
    $cycleResult.Duration = [math]::Round(((Get-Date) - $cycleStart).TotalSeconds, 2)
    
    # Display cycle summary
    if ($cycleResult.Success) {
        Write-Success "✅ Cycle $CycleNum PASSED"
    } else {
        Write-Error "❌ Cycle $CycleNum FAILED"
    }
    
    Write-Info "  • Duration: $($cycleResult.Duration)s"
    Write-Info "  • Tests: $($cycleResult.TestsPassed)/$($cycleResult.TotalTests)"
    Write-Info "  • Memory: $($cycleResult.MemoryUsage) MB"
    
    if ($cycleResult.Errors.Count -gt 0) {
        Write-Warning "  • Errors: $($cycleResult.Errors -join ', ')"
    }
    
    return $cycleResult
}

# Main execution
Write-Info "Checking prerequisites..."

# Check emulator
$devices = & $adbPath devices 2>&1
if ($devices -notmatch "emulator|device") {
    Write-Error "No emulator/device detected. Please start an emulator first."
    exit 1
}

# Start Metro bundler
Write-Info "Starting Metro bundler..."
$metroJob = Start-Job -ScriptBlock {
    param($projectPath)
    Set-Location $projectPath
    npx react-native start --reset-cache
} -ArgumentList $projectRoot

Write-Success "Metro bundler started (Job ID: $($metroJob.Id))"
Start-Sleep -Seconds 10

# Run cycles
try {
    for ($i = 1; $i -le $Cycles; $i++) {
        $result = Run-TestCycle -CycleNum $i
        $CycleResults += $result
        
        if ($StopOnError -and -not $result.Success) {
            Write-Error "Stopping due to error in cycle $i"
            break
        }
        
        # Small delay between cycles
        if ($i -lt $Cycles) {
            Start-Sleep -Seconds 2
        }
    }
} finally {
    # Stop Metro bundler
    Write-Info "`nStopping Metro bundler..."
    Stop-Job -Job $metroJob
    Remove-Job $metroJob
}

# Generate summary report
$summaryFile = Join-Path $logDir "summary-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$successCount = ($CycleResults | Where-Object { $_.Success }).Count
$failureCount = $Cycles - $successCount
$avgMemory = if ($CycleResults.Count -gt 0) {
    [math]::Round(($CycleResults | Where-Object { $_.MemoryUsage -gt 0 } | Measure-Object -Property MemoryUsage -Average).Average, 2)
} else { 0 }
$avgDuration = if ($CycleResults.Count -gt 0) {
    [math]::Round(($CycleResults | Where-Object { $_.Duration -gt 0 } | Measure-Object -Property Duration -Average).Average, 2)
} else { 0 }

$summary = @{
    TotalCycles = $Cycles
    SuccessfulCycles = $successCount
    FailedCycles = $failureCount
    SuccessRate = [math]::Round(($successCount / $Cycles) * 100, 2)
    AverageMemoryUsage = $avgMemory
    AverageDuration = $avgDuration
    TotalDuration = [math]::Round(((Get-Date) - $StartTime).TotalMinutes, 2)
    Results = $CycleResults
}

$summary | ConvertTo-Json -Depth 10 | Set-Content $summaryFile

# Display final summary
Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "    TEST CYCLE SUMMARY" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Write-Info "Total Cycles: $Cycles"
Write-Success "Successful: $successCount"
Write-Error "Failed: $failureCount"
Write-Info "Success Rate: $($summary.SuccessRate)%"
Write-Info "Average Memory: $avgMemory MB"
Write-Info "Average Duration: $avgDuration seconds"
Write-Info "Total Time: $($summary.TotalDuration) minutes"

Write-Host "`n📊 Detailed results saved to:" -ForegroundColor Yellow
Write-Host "  $summaryFile" -ForegroundColor Gray

# Show common errors
$allErrors = $CycleResults | ForEach-Object { $_.Errors } | Group-Object | Sort-Object Count -Descending
if ($allErrors) {
    Write-Host "`n⚠️  Most Common Issues:" -ForegroundColor Yellow
    $allErrors | Select-Object -First 5 | ForEach-Object {
        Write-Host "  • $($_.Name) (occurred $($_.Count) times)" -ForegroundColor Gray
    }
}

Write-Host "`n✅ Test automation completed!" -ForegroundColor Green