# TMUX-AUTOMATION-CONTROLLER.ps1
# Main orchestrator for continuous build-test-debug automation
# Manages 50+ iteration cycles with automatic error resolution

param(
    [int]$TargetIterations = 50,
    [switch]$ContinueFromLastState = $false,
    [switch]$DebugMode = $false
)

$ErrorActionPreference = "Stop"

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item "$ScriptDir/../../../..").FullName
$StateFile = "$ScriptDir/state/automation-state.json"
$SessionName = "squash-automation"

# Import helper functions
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White",
        [switch]$NoNewline
    )
    
    $params = @{
        Object = $Message
        ForegroundColor = $Color
        NoNewline = $NoNewline.IsPresent
    }
    Write-Host @params
}

function Send-TmuxCommand {
    param(
        [string]$Window,
        [string]$Command,
        [switch]$Enter = $true
    )
    
    $tmuxCmd = "tmux send-keys -t '${SessionName}:${Window}' `"$Command`""
    if ($Enter) {
        $tmuxCmd += " C-m"
    }
    
    if ($DebugMode) {
        Write-ColorOutput "TMUX: $tmuxCmd" "DarkGray"
    }
    
    & bash -c $tmuxCmd
}

function Update-State {
    param(
        [hashtable]$Updates
    )
    
    $state = Get-State
    foreach ($key in $Updates.Keys) {
        $state.$key = $Updates[$key]
    }
    $state.lastUpdate = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile
}

function Get-State {
    if (Test-Path $StateFile) {
        return Get-Content $StateFile | ConvertFrom-Json
    }
    
    # Initialize default state
    $defaultState = @{
        currentIteration = 0
        targetIterations = $TargetIterations
        buildSuccesses = 0
        buildFailures = 0
        testSuccesses = 0
        testFailures = 0
        debugAttempts = 0
        status = "initialized"
        startTime = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        lastUpdate = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        currentDDD = "DDD001"
        errors = @()
        fixes = @()
    }
    
    $defaultState | ConvertTo-Json -Depth 10 | Set-Content $StateFile
    return $defaultState
}

function Start-BuildWorker {
    param([int]$Iteration)
    
    Write-ColorOutput "`n[BUILD] Starting build for iteration $Iteration" "Blue"
    
    # Update DDD version
    $dddVersion = "DDD$('{0:D3}' -f $Iteration)"
    Update-State @{ currentDDD = $dddVersion }
    
    # Send build command to build window
    $buildScript = "$ScriptDir/TMUX-BUILD-WORKER.ps1"
    Send-TmuxCommand -Window "build" -Command "pwsh -File '$buildScript' -Iteration $Iteration -DDDVersion $dddVersion"
    
    # Wait for build completion (monitor state file)
    $timeout = 600 # 10 minutes
    $elapsed = 0
    while ($elapsed -lt $timeout) {
        Start-Sleep -Seconds 5
        $elapsed += 5
        
        $buildLog = "$ScriptDir/logs/build-logs/build-$Iteration.log"
        if (Test-Path $buildLog) {
            $content = Get-Content $buildLog -Tail 5 -ErrorAction SilentlyContinue
            if ($content -match "BUILD_COMPLETE|BUILD_FAILED") {
                $success = $content -match "BUILD_COMPLETE"
                if ($success) {
                    Update-State @{ buildSuccesses = (Get-State).buildSuccesses + 1 }
                    Write-ColorOutput "[BUILD] Completed successfully" "Green"
                } else {
                    Update-State @{ buildFailures = (Get-State).buildFailures + 1 }
                    Write-ColorOutput "[BUILD] Failed" "Red"
                }
                return $success
            }
        }
        
        # Show progress
        if ($elapsed % 30 -eq 0) {
            Write-ColorOutput "." "Yellow" -NoNewline
        }
    }
    
    Write-ColorOutput "[BUILD] Timeout reached" "Red"
    return $false
}

function Start-TestWorker {
    param([int]$Iteration)
    
    Write-ColorOutput "`n[TEST] Starting tests for iteration $Iteration" "Yellow"
    
    # Send test command to test window
    $testScript = "$ScriptDir/TMUX-TEST-WORKER.ps1"
    Send-TmuxCommand -Window "test" -Command "pwsh -File '$testScript' -Iteration $Iteration"
    
    # Wait for test completion
    $timeout = 300 # 5 minutes
    $elapsed = 0
    while ($elapsed -lt $timeout) {
        Start-Sleep -Seconds 5
        $elapsed += 5
        
        $testLog = "$ScriptDir/logs/test-logs/test-$Iteration.log"
        if (Test-Path $testLog) {
            $content = Get-Content $testLog -Tail 5 -ErrorAction SilentlyContinue
            if ($content -match "TEST_COMPLETE|TEST_FAILED") {
                $success = $content -match "TEST_COMPLETE"
                if ($success) {
                    Update-State @{ testSuccesses = (Get-State).testSuccesses + 1 }
                    Write-ColorOutput "[TEST] All tests passed" "Green"
                } else {
                    Update-State @{ testFailures = (Get-State).testFailures + 1 }
                    Write-ColorOutput "[TEST] Tests failed" "Red"
                }
                return $success
            }
        }
        
        # Show progress
        if ($elapsed % 15 -eq 0) {
            Write-ColorOutput "." "Yellow" -NoNewline
        }
    }
    
    Write-ColorOutput "[TEST] Timeout reached" "Red"
    return $false
}

function Start-DebugWorker {
    param(
        [int]$Iteration,
        [string]$Phase # "build" or "test"
    )
    
    Write-ColorOutput "`n[DEBUG] Analyzing $Phase failures for iteration $Iteration" "Magenta"
    
    # Send debug command to debug window
    $debugScript = "$ScriptDir/TMUX-DEBUG-WORKER.ps1"
    Send-TmuxCommand -Window "debug" -Command "pwsh -File '$debugScript' -Iteration $Iteration -Phase $Phase"
    
    # Wait for debug completion
    $timeout = 180 # 3 minutes
    $elapsed = 0
    while ($elapsed -lt $timeout) {
        Start-Sleep -Seconds 5
        $elapsed += 5
        
        $debugLog = "$ScriptDir/logs/debug-logs/debug-$Iteration-$Phase.log"
        if (Test-Path $debugLog) {
            $content = Get-Content $debugLog -Tail 5 -ErrorAction SilentlyContinue
            if ($content -match "DEBUG_COMPLETE|DEBUG_FAILED") {
                $success = $content -match "DEBUG_COMPLETE"
                if ($success) {
                    Write-ColorOutput "[DEBUG] Fix applied successfully" "Green"
                } else {
                    Write-ColorOutput "[DEBUG] Could not fix automatically" "Red"
                }
                
                Update-State @{ debugAttempts = (Get-State).debugAttempts + 1 }
                return $success
            }
        }
    }
    
    Write-ColorOutput "[DEBUG] Timeout reached" "Red"
    return $false
}

function Start-Monitor {
    Write-ColorOutput "`nStarting monitoring dashboard..." "Cyan"
    
    $monitorScript = "$ScriptDir/TMUX-MONITOR.ps1"
    Send-TmuxCommand -Window "monitor" -Command "pwsh -File '$monitorScript'"
}

function Show-Summary {
    $state = Get-State
    $totalTime = [DateTime]::Now - [DateTime]::Parse($state.startTime)
    
    Write-ColorOutput "`n$('='*60)" "Cyan"
    Write-ColorOutput "AUTOMATION SUMMARY" "Cyan"
    Write-ColorOutput "$('='*60)" "Cyan"
    
    Write-ColorOutput "Total Iterations: $($state.currentIteration)" "White"
    Write-ColorOutput "Total Time: $($totalTime.ToString('hh\:mm\:ss'))" "White"
    Write-ColorOutput ""
    
    Write-ColorOutput "Build Results:" "Blue"
    Write-ColorOutput "  Successes: $($state.buildSuccesses)" "Green"
    Write-ColorOutput "  Failures: $($state.buildFailures)" "Red"
    Write-ColorOutput "  Success Rate: $('{0:P0}' -f ($state.buildSuccesses / [Math]::Max($state.currentIteration, 1)))" "White"
    Write-ColorOutput ""
    
    Write-ColorOutput "Test Results:" "Yellow"
    Write-ColorOutput "  Successes: $($state.testSuccesses)" "Green"
    Write-ColorOutput "  Failures: $($state.testFailures)" "Red"
    Write-ColorOutput "  Success Rate: $('{0:P0}' -f ($state.testSuccesses / [Math]::Max($state.buildSuccesses, 1)))" "White"
    Write-ColorOutput ""
    
    Write-ColorOutput "Debug Attempts: $($state.debugAttempts)" "Magenta"
    Write-ColorOutput "$('='*60)" "Cyan"
}

# Main execution
try {
    Write-ColorOutput "SQUASH TRAINING APP - CONTINUOUS AUTOMATION CONTROLLER" "Cyan"
    Write-ColorOutput "$('='*60)" "Cyan"
    
    # Initialize or load state
    $state = Get-State
    if ($ContinueFromLastState -and $state.currentIteration -gt 0) {
        Write-ColorOutput "Continuing from iteration $($state.currentIteration + 1)" "Yellow"
        $startIteration = $state.currentIteration + 1
    } else {
        Write-ColorOutput "Starting fresh automation run" "Green"
        $startIteration = 1
        # Reset state
        Update-State @{
            currentIteration = 0
            buildSuccesses = 0
            buildFailures = 0
            testSuccesses = 0
            testFailures = 0
            debugAttempts = 0
            status = "running"
            startTime = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        }
    }
    
    # Start monitor
    Start-Monitor
    
    # Main automation loop
    for ($i = $startIteration; $i -le $TargetIterations; $i++) {
        Write-ColorOutput "`n$('='*60)" "DarkGray"
        Write-ColorOutput "ITERATION $i OF $TargetIterations" "White"
        Write-ColorOutput "$('='*60)" "DarkGray"
        
        Update-State @{ 
            currentIteration = $i
            status = "building"
        }
        
        # Build phase
        $buildSuccess = Start-BuildWorker -Iteration $i
        
        if (-not $buildSuccess) {
            # Try to debug build failure
            Update-State @{ status = "debugging-build" }
            $debugSuccess = Start-DebugWorker -Iteration $i -Phase "build"
            
            if ($debugSuccess) {
                # Retry build after fix
                Write-ColorOutput "`n[BUILD] Retrying after fix..." "Blue"
                $buildSuccess = Start-BuildWorker -Iteration $i
            }
        }
        
        if ($buildSuccess) {
            # Test phase
            Update-State @{ status = "testing" }
            $testSuccess = Start-TestWorker -Iteration $i
            
            if (-not $testSuccess) {
                # Try to debug test failure
                Update-State @{ status = "debugging-test" }
                $debugSuccess = Start-DebugWorker -Iteration $i -Phase "test"
                
                if ($debugSuccess) {
                    # Retry test after fix
                    Write-ColorOutput "`n[TEST] Retrying after fix..." "Yellow"
                    $testSuccess = Start-TestWorker -Iteration $i
                }
            }
        }
        
        # Check if we've achieved perfect run
        $recentState = Get-State
        if ($recentState.buildFailures -eq 0 -and $recentState.testFailures -eq 0 -and $i -ge 10) {
            Write-ColorOutput "`n*** PERFECT RUN ACHIEVED! ***" "Green"
            Write-ColorOutput "No failures in $i iterations!" "Green"
            break
        }
        
        # Progress checkpoint
        if ($i % 10 -eq 0) {
            Write-ColorOutput "`n--- Progress Checkpoint: $i/$TargetIterations ---" "Cyan"
            Show-Summary
        }
    }
    
    # Final summary
    Update-State @{ status = "completed" }
    Show-Summary
    
    # Generate final report
    $reportPath = "$ScriptDir/logs/automation-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
    Write-ColorOutput "`nGenerating report: $reportPath" "Cyan"
    
    @"
SQUASH TRAINING APP - AUTOMATION REPORT
Generated: $(Get-Date)

CONFIGURATION:
- Target Iterations: $TargetIterations
- Actual Iterations: $($state.currentIteration)
- Total Time: $($totalTime.ToString('hh\:mm\:ss'))

RESULTS:
- Build Success Rate: $('{0:P0}' -f ($state.buildSuccesses / [Math]::Max($state.currentIteration, 1)))
- Test Success Rate: $('{0:P0}' -f ($state.testSuccesses / [Math]::Max($state.buildSuccesses, 1)))
- Debug Attempts: $($state.debugAttempts)

RECOMMENDATION:
$(if ($state.buildFailures -eq 0 -and $state.testFailures -eq 0) {
    "Application is stable and ready for production deployment."
} else {
    "Further manual intervention required for remaining issues."
})
"@ | Set-Content $reportPath
    
    Write-ColorOutput "`nAutomation complete!" "Green"
    
} catch {
    Write-ColorOutput "ERROR: $_" "Red"
    Update-State @{ status = "error" }
    exit 1
}