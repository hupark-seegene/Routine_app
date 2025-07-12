<#
.SYNOPSIS
    DDD State Management and Tracking Utility
    
.DESCRIPTION
    Provides state management, persistence, and reporting for the Domain-Driven
    Development approach used in the Squash Training App iteration system.
    
.STATUS
    ACTIVE
    
.VERSION
    1.0.0
    
.CREATED
    2025-07-12
    
.MODIFIED
    2025-07-12
    
.DEPENDENCIES
    - PowerShell 5.0+
    
.REPLACES
    - None (new implementation)
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Load", "Save", "Report", "Reset", "Export")]
    [string]$Action = "Report",
    
    [Parameter(Mandatory=$false)]
    [string]$StatePath = "$PSScriptRoot\ddd-state.json",
    
    [Parameter(Mandatory=$false)]
    [hashtable]$StateData
)

# ========================================
# STATE STRUCTURE DEFINITION
# ========================================

function Get-EmptyDDDState {
    return @{
        BuildDomain = @{
            CurrentIteration = 0
            TotalBuilds = 0
            SuccessfulBuilds = 0
            FailedBuilds = 0
            LastBuildError = ""
            BuildTimes = @()
            AverageBuildTime = 0
        }
        
        DeploymentDomain = @{
            TotalInstalls = 0
            SuccessfulInstalls = 0
            FailedInstalls = 0
            DeviceId = ""
            LastInstallError = ""
            DeploymentTimes = @()
        }
        
        TestingDomain = @{
            TestedFeatures = @{
                HomeScreen = $false
                ChecklistScreen = $false
                RecordScreen = $false
                CoachScreen = $false
                ProfileScreen = $false
            }
            PassedTests = 0
            FailedTests = 0
            CrashCount = 0
            TestResults = @()
            FeatureSuccessRate = @{}
        }
        
        DebugDomain = @{
            IdentifiedIssues = @()
            AppliedFixes = @()
            KnownErrors = @{}
            FixStrategies = @{}
            MostCommonErrors = @()
        }
        
        IterationDomain = @{
            StartTime = $null
            EndTime = $null
            SuccessfulIterations = 0
            FailedIterations = 0
            AverageIterationTime = 0
            TargetAchieved = $false
            BestStreak = 0
            CurrentStreak = 0
        }
        
        MetricsDomain = @{
            SuccessRate = 0
            CrashRate = 0
            FixEffectiveness = 0
            TimeToSuccess = 0
            IterationsToStability = 0
        }
    }
}

# ========================================
# STATE MANAGEMENT FUNCTIONS
# ========================================

function Save-DDDState {
    param(
        [hashtable]$State,
        [string]$Path = $StatePath
    )
    
    try {
        # Calculate metrics before saving
        Update-StateMetrics -State $State
        
        # Convert to JSON with proper formatting
        $json = $State | ConvertTo-Json -Depth 10 -Compress:$false
        
        # Ensure directory exists
        $dir = Split-Path $Path -Parent
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
        
        # Save to file
        $json | Out-File -FilePath $Path -Encoding UTF8
        
        Write-Host "✓ State saved to: $Path" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ Failed to save state: $_" -ForegroundColor Red
        return $false
    }
}

function Load-DDDState {
    param(
        [string]$Path = $StatePath
    )
    
    try {
        if (-not (Test-Path $Path)) {
            Write-Host "⚠ No saved state found, creating new state" -ForegroundColor Yellow
            return Get-EmptyDDDState
        }
        
        $json = Get-Content -Path $Path -Raw
        $state = $json | ConvertFrom-Json
        
        # Convert PSCustomObject back to hashtable
        $hashtable = @{}
        foreach ($domain in $state.PSObject.Properties) {
            $hashtable[$domain.Name] = @{}
            foreach ($prop in $domain.Value.PSObject.Properties) {
                $hashtable[$domain.Name][$prop.Name] = $prop.Value
            }
        }
        
        Write-Host "✓ State loaded from: $Path" -ForegroundColor Green
        return $hashtable
    }
    catch {
        Write-Host "✗ Failed to load state: $_" -ForegroundColor Red
        return Get-EmptyDDDState
    }
}

function Reset-DDDState {
    param(
        [string]$Path = $StatePath
    )
    
    $newState = Get-EmptyDDDState
    $newState.IterationDomain.StartTime = Get-Date
    
    if (Save-DDDState -State $newState -Path $Path) {
        Write-Host "✓ State reset successfully" -ForegroundColor Green
        return $newState
    }
    
    return $null
}

# ========================================
# METRICS CALCULATION
# ========================================

function Update-StateMetrics {
    param(
        [hashtable]$State
    )
    
    $metrics = $State.MetricsDomain
    
    # Calculate success rate
    $totalIterations = $State.IterationDomain.SuccessfulIterations + $State.IterationDomain.FailedIterations
    if ($totalIterations -gt 0) {
        $metrics.SuccessRate = [math]::Round(($State.IterationDomain.SuccessfulIterations / $totalIterations) * 100, 2)
    }
    
    # Calculate crash rate
    $totalTests = $State.TestingDomain.PassedTests + $State.TestingDomain.FailedTests
    if ($totalTests -gt 0) {
        $metrics.CrashRate = [math]::Round(($State.TestingDomain.CrashCount / $totalTests) * 100, 2)
    }
    
    # Calculate fix effectiveness
    if ($State.DebugDomain.IdentifiedIssues.Count -gt 0) {
        $metrics.FixEffectiveness = [math]::Round(($State.DebugDomain.AppliedFixes.Count / $State.DebugDomain.IdentifiedIssues.Count) * 100, 2)
    }
    
    # Calculate average build time
    if ($State.BuildDomain.BuildTimes.Count -gt 0) {
        $State.BuildDomain.AverageBuildTime = [math]::Round(($State.BuildDomain.BuildTimes | Measure-Object -Average).Average, 2)
    }
    
    # Calculate feature success rates
    $featureTests = @{}
    foreach ($result in $State.TestingDomain.TestResults) {
        foreach ($feature in $result.Results.Keys) {
            if (-not $featureTests.ContainsKey($feature)) {
                $featureTests[$feature] = @{Passed = 0; Total = 0}
            }
            $featureTests[$feature].Total++
            if ($result.Results[$feature]) {
                $featureTests[$feature].Passed++
            }
        }
    }
    
    foreach ($feature in $featureTests.Keys) {
        $rate = [math]::Round(($featureTests[$feature].Passed / $featureTests[$feature].Total) * 100, 2)
        $State.TestingDomain.FeatureSuccessRate[$feature] = $rate
    }
}

# ========================================
# REPORTING FUNCTIONS
# ========================================

function Show-DDDReport {
    param(
        [hashtable]$State
    )
    
    Write-Host "`n╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║          DDD STATE REPORT - SQUASH TRAINING APP      ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    
    # Overall Progress
    Write-Host "`n📊 OVERALL PROGRESS" -ForegroundColor Yellow
    Write-Host "  Current Iteration: $($State.BuildDomain.CurrentIteration)" -ForegroundColor White
    Write-Host "  Success Rate: $($State.MetricsDomain.SuccessRate)%" -ForegroundColor $(if ($State.MetricsDomain.SuccessRate -gt 80) {"Green"} else {"Yellow"})
    Write-Host "  Target Achieved: $(if ($State.IterationDomain.TargetAchieved) {'✅ Yes'} else {'❌ No'})" -ForegroundColor White
    
    # Build Domain
    Write-Host "`n🔨 BUILD DOMAIN" -ForegroundColor Cyan
    Write-Host "  Total Builds: $($State.BuildDomain.TotalBuilds)"
    Write-Host "  Successful: $($State.BuildDomain.SuccessfulBuilds)" -ForegroundColor Green
    Write-Host "  Failed: $($State.BuildDomain.FailedBuilds)" -ForegroundColor Red
    Write-Host "  Average Build Time: $($State.BuildDomain.AverageBuildTime)s" -ForegroundColor Gray
    
    # Deployment Domain
    Write-Host "`n📦 DEPLOYMENT DOMAIN" -ForegroundColor Green
    Write-Host "  Total Installs: $($State.DeploymentDomain.TotalInstalls)"
    Write-Host "  Successful: $($State.DeploymentDomain.SuccessfulInstalls)" -ForegroundColor Green
    Write-Host "  Failed: $($State.DeploymentDomain.FailedInstalls)" -ForegroundColor Red
    
    # Testing Domain
    Write-Host "`n🧪 TESTING DOMAIN" -ForegroundColor Yellow
    Write-Host "  Tests Passed: $($State.TestingDomain.PassedTests)" -ForegroundColor Green
    Write-Host "  Tests Failed: $($State.TestingDomain.FailedTests)" -ForegroundColor Red
    Write-Host "  Crash Count: $($State.TestingDomain.CrashCount)" -ForegroundColor Red
    Write-Host "  Crash Rate: $($State.MetricsDomain.CrashRate)%" -ForegroundColor $(if ($State.MetricsDomain.CrashRate -lt 10) {"Green"} else {"Red"})
    
    # Feature Success Rates
    if ($State.TestingDomain.FeatureSuccessRate.Count -gt 0) {
        Write-Host "`n  Feature Success Rates:" -ForegroundColor White
        foreach ($feature in $State.TestingDomain.FeatureSuccessRate.Keys | Sort-Object) {
            $rate = $State.TestingDomain.FeatureSuccessRate[$feature]
            $color = if ($rate -eq 100) {"Green"} elseif ($rate -gt 80) {"Yellow"} else {"Red"}
            Write-Host "    $feature`: $rate%" -ForegroundColor $color
        }
    }
    
    # Debug Domain
    Write-Host "`n🔧 DEBUG DOMAIN" -ForegroundColor Magenta
    Write-Host "  Issues Identified: $($State.DebugDomain.IdentifiedIssues.Count)" -ForegroundColor Yellow
    Write-Host "  Fixes Applied: $($State.DebugDomain.AppliedFixes.Count)" -ForegroundColor Green
    Write-Host "  Fix Effectiveness: $($State.MetricsDomain.FixEffectiveness)%" -ForegroundColor White
    
    # Iteration Metrics
    Write-Host "`n📈 ITERATION METRICS" -ForegroundColor White
    Write-Host "  Successful Iterations: $($State.IterationDomain.SuccessfulIterations)" -ForegroundColor Green
    Write-Host "  Failed Iterations: $($State.IterationDomain.FailedIterations)" -ForegroundColor Red
    Write-Host "  Best Success Streak: $($State.IterationDomain.BestStreak)" -ForegroundColor Cyan
    Write-Host "  Current Streak: $($State.IterationDomain.CurrentStreak)" -ForegroundColor White
    
    # Time Analysis
    if ($State.IterationDomain.StartTime) {
        $runtime = if ($State.IterationDomain.EndTime) {
            $State.IterationDomain.EndTime - $State.IterationDomain.StartTime
        } else {
            (Get-Date) - $State.IterationDomain.StartTime
        }
        Write-Host "`n⏱️  TIME ANALYSIS" -ForegroundColor Gray
        Write-Host "  Total Runtime: $($runtime.ToString('hh\:mm\:ss'))" -ForegroundColor White
        Write-Host "  Average Iteration Time: $($State.IterationDomain.AverageIterationTime)s" -ForegroundColor White
    }
    
    Write-Host "`n════════════════════════════════════════════════════════" -ForegroundColor DarkGray
}

function Export-DDDReport {
    param(
        [hashtable]$State,
        [string]$OutputPath = "$PSScriptRoot\ddd-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
    )
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>DDD State Report - Squash Training App</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #1a1a1a; color: #fff; margin: 20px; }
        h1 { color: #C9FF00; text-align: center; }
        .domain { background-color: #2a2a2a; padding: 20px; margin: 10px 0; border-radius: 8px; }
        .domain h2 { margin-top: 0; }
        .build { border-left: 4px solid #00CED1; }
        .deployment { border-left: 4px solid #32CD32; }
        .testing { border-left: 4px solid #FFD700; }
        .debug { border-left: 4px solid #FF1493; }
        .metrics { border-left: 4px solid #C9FF00; }
        .stat { display: inline-block; margin: 10px 20px 10px 0; }
        .stat-value { font-size: 24px; font-weight: bold; }
        .success { color: #32CD32; }
        .warning { color: #FFD700; }
        .error { color: #FF6347; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 8px; text-align: left; border-bottom: 1px solid #444; }
        th { background-color: #333; }
    </style>
</head>
<body>
    <h1>DDD State Report - Squash Training App</h1>
    <p style="text-align: center;">Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
    
    <div class="domain metrics">
        <h2>📊 Overall Metrics</h2>
        <div class="stat">
            <div class="stat-label">Current Iteration</div>
            <div class="stat-value">$($State.BuildDomain.CurrentIteration)</div>
        </div>
        <div class="stat">
            <div class="stat-label">Success Rate</div>
            <div class="stat-value $(if ($State.MetricsDomain.SuccessRate -gt 80) {'success'} else {'warning'})">$($State.MetricsDomain.SuccessRate)%</div>
        </div>
        <div class="stat">
            <div class="stat-label">Target Achieved</div>
            <div class="stat-value">$(if ($State.IterationDomain.TargetAchieved) {'✅'} else {'❌'})</div>
        </div>
    </div>
    
    <div class="domain build">
        <h2>🔨 Build Domain</h2>
        <table>
            <tr><td>Total Builds</td><td>$($State.BuildDomain.TotalBuilds)</td></tr>
            <tr><td>Successful</td><td class="success">$($State.BuildDomain.SuccessfulBuilds)</td></tr>
            <tr><td>Failed</td><td class="error">$($State.BuildDomain.FailedBuilds)</td></tr>
            <tr><td>Average Build Time</td><td>$($State.BuildDomain.AverageBuildTime)s</td></tr>
        </table>
    </div>
    
    <div class="domain deployment">
        <h2>📦 Deployment Domain</h2>
        <table>
            <tr><td>Total Installs</td><td>$($State.DeploymentDomain.TotalInstalls)</td></tr>
            <tr><td>Successful</td><td class="success">$($State.DeploymentDomain.SuccessfulInstalls)</td></tr>
            <tr><td>Failed</td><td class="error">$($State.DeploymentDomain.FailedInstalls)</td></tr>
        </table>
    </div>
    
    <div class="domain testing">
        <h2>🧪 Testing Domain</h2>
        <table>
            <tr><td>Tests Passed</td><td class="success">$($State.TestingDomain.PassedTests)</td></tr>
            <tr><td>Tests Failed</td><td class="error">$($State.TestingDomain.FailedTests)</td></tr>
            <tr><td>Crash Count</td><td class="error">$($State.TestingDomain.CrashCount)</td></tr>
            <tr><td>Crash Rate</td><td class="$(if ($State.MetricsDomain.CrashRate -lt 10) {'success'} else {'error'})">$($State.MetricsDomain.CrashRate)%</td></tr>
        </table>
"@

    if ($State.TestingDomain.FeatureSuccessRate.Count -gt 0) {
        $html += @"
        <h3>Feature Success Rates</h3>
        <table>
            <tr><th>Feature</th><th>Success Rate</th></tr>
"@
        foreach ($feature in $State.TestingDomain.FeatureSuccessRate.Keys | Sort-Object) {
            $rate = $State.TestingDomain.FeatureSuccessRate[$feature]
            $class = if ($rate -eq 100) {"success"} elseif ($rate -gt 80) {"warning"} else {"error"}
            $html += "            <tr><td>$feature</td><td class='$class'>$rate%</td></tr>`n"
        }
        $html += "        </table>`n"
    }
    
    $html += @"
    </div>
    
    <div class="domain debug">
        <h2>🔧 Debug Domain</h2>
        <table>
            <tr><td>Issues Identified</td><td class="warning">$($State.DebugDomain.IdentifiedIssues.Count)</td></tr>
            <tr><td>Fixes Applied</td><td class="success">$($State.DebugDomain.AppliedFixes.Count)</td></tr>
            <tr><td>Fix Effectiveness</td><td>$($State.MetricsDomain.FixEffectiveness)%</td></tr>
        </table>
    </div>
</body>
</html>
"@
    
    $html | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "✓ Report exported to: $OutputPath" -ForegroundColor Green
}

# ========================================
# MAIN EXECUTION
# ========================================

switch ($Action) {
    "Load" {
        $state = Load-DDDState -Path $StatePath
        Show-DDDReport -State $state
    }
    
    "Save" {
        if ($StateData) {
            Save-DDDState -State $StateData -Path $StatePath
        } else {
            Write-Host "✗ No state data provided to save" -ForegroundColor Red
        }
    }
    
    "Report" {
        $state = Load-DDDState -Path $StatePath
        Show-DDDReport -State $state
    }
    
    "Reset" {
        $state = Reset-DDDState -Path $StatePath
        if ($state) {
            Write-Host "State has been reset to initial values" -ForegroundColor Green
        }
    }
    
    "Export" {
        $state = Load-DDDState -Path $StatePath
        Export-DDDReport -State $state
    }
    
    default {
        Write-Host "Invalid action. Use: Load, Save, Report, Reset, or Export" -ForegroundColor Red
    }
}