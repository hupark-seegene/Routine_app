# TMUX-MONITOR.ps1
# Real-time monitoring dashboard for continuous automation
# Displays live status, metrics, and progress

param(
    [switch]$Continuous = $true,
    [int]$RefreshInterval = 2
)

$ErrorActionPreference = "SilentlyContinue"

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$StateFile = "$ScriptDir/state/automation-state.json"
$LogsDir = "$ScriptDir/logs"

# Console setup
$Host.UI.RawUI.WindowTitle = "Squash Automation Monitor"
Clear-Host

# Color definitions
$Colors = @{
    Header = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "White"
    Metric = "Blue"
    Progress = "Magenta"
}

function Get-State {
    if (Test-Path $StateFile) {
        return Get-Content $StateFile | ConvertFrom-Json
    }
    return $null
}

function Draw-Box {
    param(
        [string]$Title,
        [int]$Width = 60,
        [string]$Color = "White"
    )
    
    $line = "+" + ("-" * ($Width - 2)) + "+"
    Write-Host $line -ForegroundColor $Color
    
    if ($Title) {
        $padding = [Math]::Floor(($Width - $Title.Length - 4) / 2)
        $titleLine = "| " + (" " * $padding) + $Title + (" " * ($Width - $padding - $Title.Length - 4)) + " |"
        Write-Host $titleLine -ForegroundColor $Color
        Write-Host $line -ForegroundColor $Color
    }
}

function Format-Time {
    param($StartTime)
    
    try {
        $start = [DateTime]::Parse($StartTime)
        $elapsed = [DateTime]::Now - $start
        return "{0:d2}:{1:d2}:{2:d2}" -f $elapsed.Hours, $elapsed.Minutes, $elapsed.Seconds
    } catch {
        return "00:00:00"
    }
}

function Draw-ProgressBar {
    param(
        [int]$Current,
        [int]$Total,
        [int]$Width = 40
    )
    
    if ($Total -eq 0) { $Total = 1 }
    $percentage = [Math]::Round(($Current / $Total) * 100, 0)
    $filled = [Math]::Floor(($Current / $Total) * $Width)
    $empty = $Width - $filled
    
    $bar = "[" + ("█" * $filled) + ("░" * $empty) + "]"
    return "$bar $percentage%"
}

function Get-LatestLogEntry {
    param(
        [string]$LogType,
        [int]$Iteration
    )
    
    $logFile = "$LogsDir/$LogType-logs/$LogType-$Iteration.log"
    if (Test-Path $logFile) {
        $lastLine = Get-Content $logFile -Tail 1
        if ($lastLine -match "\[(.*?)\].*\[(.*?)\] (.*)") {
            return @{
                Time = $matches[1]
                Level = $matches[2]
                Message = $matches[3]
            }
        }
    }
    return $null
}

function Get-MetricsSummary {
    $metrics = @{
        TotalBuilds = 0
        SuccessfulBuilds = 0
        TotalTests = 0
        PassedTests = 0
        AverageTestDuration = 0
        LastBuildSize = 0
    }
    
    # Count build metrics
    $buildLogs = Get-ChildItem "$LogsDir/build-logs" -Filter "metrics-*.json" -ErrorAction SilentlyContinue
    foreach ($log in $buildLogs) {
        $data = Get-Content $log.FullName | ConvertFrom-Json
        $metrics.TotalBuilds++
        if ($data.status -eq "success") {
            $metrics.SuccessfulBuilds++
        }
    }
    
    # Count test metrics
    $testReports = Get-ChildItem "$LogsDir/test-logs" -Filter "report-*.json" -ErrorAction SilentlyContinue
    foreach ($report in $testReports) {
        $data = Get-Content $report.FullName | ConvertFrom-Json
        $metrics.TotalTests++
        if ($data.success) {
            $metrics.PassedTests++
        }
    }
    
    # Get latest APK size
    $latestAPK = Get-ChildItem "$LogsDir/build-logs" -Filter "app-*.apk" -ErrorAction SilentlyContinue | 
                 Sort-Object LastWriteTime -Descending | 
                 Select-Object -First 1
    
    if ($latestAPK) {
        $metrics.LastBuildSize = [Math]::Round($latestAPK.Length / 1MB, 2)
    }
    
    return $metrics
}

function Display-Dashboard {
    $state = Get-State
    if (-not $state) {
        Write-Host "No automation state found. Waiting for controller to start..." -ForegroundColor $Colors.Warning
        return
    }
    
    Clear-Host
    
    # Header
    Draw-Box -Title "SQUASH AUTOMATION MONITOR" -Color $Colors.Header -Width 80
    Write-Host ""
    
    # Status Overview
    Write-Host "STATUS OVERVIEW" -ForegroundColor $Colors.Header
    Write-Host ("-" * 80) -ForegroundColor DarkGray
    
    $statusColor = switch ($state.status) {
        "running" { $Colors.Success }
        "completed" { $Colors.Info }
        "error" { $Colors.Error }
        default { $Colors.Warning }
    }
    
    Write-Host ("Current Status: {0,-20} Started: {1}" -f $state.status.ToUpper(), $state.startTime) -ForegroundColor $statusColor
    Write-Host ("Elapsed Time:  {0,-20} Current DDD: {1}" -f (Format-Time $state.startTime), $state.currentDDD) -ForegroundColor $Colors.Info
    Write-Host ""
    
    # Progress
    Write-Host "PROGRESS" -ForegroundColor $Colors.Header
    Write-Host ("-" * 80) -ForegroundColor DarkGray
    
    $progressBar = Draw-ProgressBar -Current $state.currentIteration -Total $state.targetIterations
    Write-Host ("Iterations: {0}/{1} {2}" -f $state.currentIteration, $state.targetIterations, $progressBar) -ForegroundColor $Colors.Progress
    Write-Host ""
    
    # Build & Test Results
    Write-Host "BUILD & TEST RESULTS" -ForegroundColor $Colors.Header
    Write-Host ("-" * 80) -ForegroundColor DarkGray
    
    # Build stats
    $buildRate = if ($state.currentIteration -gt 0) { 
        [Math]::Round(($state.buildSuccesses / $state.currentIteration) * 100, 1) 
    } else { 0 }
    
    Write-Host -NoNewline "Builds:  "
    Write-Host -NoNewline ("Success: {0,-6}" -f $state.buildSuccesses) -ForegroundColor $Colors.Success
    Write-Host -NoNewline ("Failed: {0,-6}" -f $state.buildFailures) -ForegroundColor $Colors.Error
    Write-Host ("Success Rate: {0}%" -f $buildRate) -ForegroundColor $Colors.Metric
    
    # Test stats
    $testRate = if ($state.buildSuccesses -gt 0) { 
        [Math]::Round(($state.testSuccesses / $state.buildSuccesses) * 100, 1) 
    } else { 0 }
    
    Write-Host -NoNewline "Tests:   "
    Write-Host -NoNewline ("Passed: {0,-7}" -f $state.testSuccesses) -ForegroundColor $Colors.Success
    Write-Host -NoNewline ("Failed: {0,-6}" -f $state.testFailures) -ForegroundColor $Colors.Error
    Write-Host ("Pass Rate: {0}%" -f $testRate) -ForegroundColor $Colors.Metric
    
    Write-Host ("Debug Attempts: {0}" -f $state.debugAttempts) -ForegroundColor $Colors.Warning
    Write-Host ""
    
    # Latest Activity
    Write-Host "LATEST ACTIVITY" -ForegroundColor $Colors.Header
    Write-Host ("-" * 80) -ForegroundColor DarkGray
    
    if ($state.currentIteration -gt 0) {
        # Get latest log entries
        $buildLog = Get-LatestLogEntry -LogType "build" -Iteration $state.currentIteration
        $testLog = Get-LatestLogEntry -LogType "test" -Iteration $state.currentIteration
        
        if ($buildLog) {
            $color = switch ($buildLog.Level) {
                "SUCCESS" { $Colors.Success }
                "ERROR" { $Colors.Error }
                "WARN" { $Colors.Warning }
                default { $Colors.Info }
            }
            Write-Host ("Build: [{0}] {1}" -f $buildLog.Time, $buildLog.Message) -ForegroundColor $color
        }
        
        if ($testLog) {
            $color = switch ($testLog.Level) {
                "SUCCESS" { $Colors.Success }
                "ERROR" { $Colors.Error }
                "TEST" { $Colors.Metric }
                default { $Colors.Info }
            }
            Write-Host ("Test:  [{0}] {1}" -f $testLog.Time, $testLog.Message) -ForegroundColor $color
        }
    }
    
    Write-Host ""
    
    # Metrics Summary
    $metrics = Get-MetricsSummary
    Write-Host "METRICS SUMMARY" -ForegroundColor $Colors.Header
    Write-Host ("-" * 80) -ForegroundColor DarkGray
    
    Write-Host ("Total Builds: {0,-15} Successful: {1}" -f $metrics.TotalBuilds, $metrics.SuccessfulBuilds) -ForegroundColor $Colors.Metric
    Write-Host ("Total Tests:  {0,-15} Passed: {1}" -f $metrics.TotalTests, $metrics.PassedTests) -ForegroundColor $Colors.Metric
    Write-Host ("Latest APK Size: {0} MB" -f $metrics.LastBuildSize) -ForegroundColor $Colors.Info
    Write-Host ""
    
    # Footer
    Write-Host ("-" * 80) -ForegroundColor DarkGray
    Write-Host "Press Ctrl+C to exit monitor | Refreshing every $RefreshInterval seconds" -ForegroundColor DarkGray
    Write-Host "Last Update: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor DarkGray
}

function Start-Monitoring {
    Write-Host "Starting continuous monitoring..." -ForegroundColor $Colors.Info
    Write-Host "Press Ctrl+C to stop" -ForegroundColor $Colors.Warning
    Write-Host ""
    
    while ($Continuous) {
        Display-Dashboard
        Start-Sleep -Seconds $RefreshInterval
    }
}

# Handle Ctrl+C gracefully
$null = Register-EngineEvent PowerShell.Exiting -Action {
    Clear-Host
    Write-Host "Monitor stopped." -ForegroundColor Yellow
}

# Main execution
try {
    if ($Continuous) {
        Start-Monitoring
    } else {
        Display-Dashboard
    }
} catch {
    if ($_.Exception.Message -notlike "*The operation was canceled*") {
        Write-Host "Monitor error: $_" -ForegroundColor Red
    }
} finally {
    Write-Host "`nMonitor terminated." -ForegroundColor Yellow
}