<#
.SYNOPSIS
    Log Analysis and Debugging Utility for Squash Training App
    
.DESCRIPTION
    Analyzes Android logcat output, React Native logs, and crash reports to identify
    issues and suggest fixes. Provides pattern matching, error categorization, and
    automated fix recommendations.
    
.STATUS
    ACTIVE
    
.VERSION
    1.0.0
    
.CREATED
    2025-07-12
    
.MODIFIED
    2025-07-12
    
.DEPENDENCIES
    - Android SDK (ADB)
    - PowerShell 5.0+
    
.REPLACES
    - None (new implementation)
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Live", "File", "Last")]
    [string]$Mode = "Last",
    
    [Parameter(Mandatory=$false)]
    [string]$LogFile = "",
    
    [Parameter(Mandatory=$false)]
    [int]$Lines = 1000,
    
    [switch]$AutoFix = $false,
    [switch]$SaveReport = $false,
    [switch]$Verbose = $false
)

# ========================================
# CONFIGURATION
# ========================================

$ADB = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$PackageName = "com.squashtrainingapp"
$ReportDir = "$PSScriptRoot\debug-reports"

# Error Pattern Database
$ErrorPatterns = @{
    # JavaScript/React Native Errors
    "TypeError: Cannot read property '(\w+)' of undefined" = @{
        Category = "JavaScript"
        Severity = "High"
        Description = "Undefined property access"
        PossibleCauses = @(
            "Component not properly initialized"
            "Async data not loaded"
            "Missing null checks"
        )
        Fixes = @(
            "Add null/undefined checks"
            "Use optional chaining (?.)"
            "Initialize state properly"
        )
    }
    
    "TypeError: Cannot read properties of null" = @{
        Category = "JavaScript"
        Severity = "High"
        Description = "Null reference error"
        PossibleCauses = @(
            "Component unmounted during async operation"
            "State not initialized"
            "API returned null"
        )
        Fixes = @(
            "Add null checks"
            "Use useEffect cleanup"
            "Set default state values"
        )
    }
    
    "Network request failed" = @{
        Category = "Network"
        Severity = "Medium"
        Description = "Network connectivity issue"
        PossibleCauses = @(
            "No internet connection"
            "API endpoint down"
            "CORS issues"
            "SSL certificate problems"
        )
        Fixes = @(
            "Check network connectivity"
            "Verify API endpoint"
            "Add retry logic"
            "Check SSL certificates"
        )
    }
    
    "Unable to resolve module '(.*?)'" = @{
        Category = "Dependencies"
        Severity = "High"
        Description = "Missing module/dependency"
        PossibleCauses = @(
            "Module not installed"
            "Incorrect import path"
            "Case sensitivity issue"
            "Module deleted or moved"
        )
        Fixes = @(
            "Run npm install"
            "Check import paths"
            "Verify file exists"
            "Clear Metro cache"
        )
    }
    
    "Invariant Violation" = @{
        Category = "React Native"
        Severity = "High"
        Description = "React Native constraint violation"
        PossibleCauses = @(
            "Invalid JSX structure"
            "Text outside Text component"
            "Invalid style properties"
            "Component lifecycle issues"
        )
        Fixes = @(
            "Check JSX structure"
            "Wrap text in Text components"
            "Validate style properties"
            "Review component lifecycle"
        )
    }
    
    # Metro Bundler Errors
    "ECONNREFUSED.*:8081" = @{
        Category = "Metro"
        Severity = "High"
        Description = "Metro bundler connection refused"
        PossibleCauses = @(
            "Metro bundler not running"
            "Port 8081 blocked"
            "ADB reverse not set"
        )
        Fixes = @(
            "Start Metro bundler"
            "Run: adb reverse tcp:8081 tcp:8081"
            "Check firewall settings"
            "Kill process on port 8081"
        )
    }
    
    # Android/Java Errors
    "java\.lang\.ClassNotFoundException: (.*)" = @{
        Category = "Android"
        Severity = "High"
        Description = "Java class not found"
        PossibleCauses = @(
            "ProGuard/R8 removed class"
            "Missing dependency"
            "Incorrect package name"
            "Build configuration issue"
        )
        Fixes = @(
            "Check ProGuard rules"
            "Verify dependencies in build.gradle"
            "Clean and rebuild"
            "Check package names"
        )
    }
    
    "java\.lang\.NullPointerException" = @{
        Category = "Android"
        Severity = "High"
        Description = "Java null pointer exception"
        PossibleCauses = @(
            "Uninitialized object"
            "Missing null checks"
            "Activity/Context null"
        )
        Fixes = @(
            "Add null checks in Java code"
            "Ensure proper initialization"
            "Check Activity lifecycle"
        )
    }
    
    "android\.database\.sqlite\.SQLiteException" = @{
        Category = "Database"
        Severity = "High"
        Description = "SQLite database error"
        PossibleCauses = @(
            "Database corruption"
            "Schema mismatch"
            "Invalid SQL query"
            "Permission issues"
        )
        Fixes = @(
            "Clear app data"
            "Check database schema"
            "Validate SQL queries"
            "Check file permissions"
        )
    }
    
    # Performance Issues
    "Excessive number of pending callbacks: (\d+)" = @{
        Category = "Performance"
        Severity = "Medium"
        Description = "Too many pending callbacks"
        PossibleCauses = @(
            "Memory leak"
            "Infinite loop"
            "Excessive re-renders"
        )
        Fixes = @(
            "Check for memory leaks"
            "Review useEffect dependencies"
            "Optimize component renders"
            "Use React.memo"
        )
    }
}

# Fix Commands Database
$FixCommands = @{
    "Clear Metro cache" = @{
        Commands = @(
            "npx react-native start --reset-cache"
        )
        Description = "Clears Metro bundler cache"
    }
    
    "Rebuild app" = @{
        Commands = @(
            "cd android && ./gradlew clean"
            "cd android && ./gradlew assembleDebug"
        )
        Description = "Clean and rebuild Android app"
    }
    
    "Fix ADB connection" = @{
        Commands = @(
            "adb kill-server"
            "adb start-server"
            "adb reverse tcp:8081 tcp:8081"
        )
        Description = "Reset ADB and port forwarding"
    }
    
    "Clear app data" = @{
        Commands = @(
            "adb shell pm clear com.squashtrainingapp"
        )
        Description = "Clear app data and cache"
    }
    
    "Reinstall node modules" = @{
        Commands = @(
            "rm -rf node_modules"
            "npm install"
        )
        Description = "Clean install of dependencies"
    }
}

# ========================================
# UTILITY FUNCTIONS
# ========================================

function Write-DebugLog {
    param(
        [string]$Message,
        [string]$Level = "Info"
    )
    
    $colors = @{
        "Info" = "Gray"
        "Warning" = "Yellow"
        "Error" = "Red"
        "Success" = "Green"
        "Debug" = "DarkGray"
    }
    
    if ($Level -ne "Debug" -or $Verbose) {
        Write-Host $Message -ForegroundColor $(if ($colors.ContainsKey($Level)) { $colors[$Level] } else { "White" })
    }
}

function Get-LogContent {
    switch ($Mode) {
        "Live" {
            Write-DebugLog "Capturing live logs..." "Info"
            $logs = & $ADB logcat -d -t $Lines 2>&1
            return $logs -join "`n"
        }
        
        "File" {
            if (-not $LogFile -or -not (Test-Path $LogFile)) {
                Write-DebugLog "Log file not found: $LogFile" "Error"
                return ""
            }
            return Get-Content $LogFile -Raw
        }
        
        "Last" {
            Write-DebugLog "Getting last $Lines lines from device..." "Info"
            $logs = & $ADB logcat -d -t $Lines 2>&1
            return $logs -join "`n"
        }
    }
}

function Find-ErrorPatterns {
    param([string]$LogContent)
    
    $foundErrors = @()
    
    foreach ($pattern in $ErrorPatterns.Keys) {
        $matches = [regex]::Matches($LogContent, $pattern)
        
        if ($matches.Count -gt 0) {
            $errorInfo = $ErrorPatterns[$pattern]
            $capturedGroups = @()
            
            foreach ($match in $matches) {
                if ($match.Groups.Count -gt 1) {
                    $capturedGroups += $match.Groups[1].Value
                }
            }
            
            $foundErrors += @{
                Pattern = $pattern
                Count = $matches.Count
                Category = $errorInfo.Category
                Severity = $errorInfo.Severity
                Description = $errorInfo.Description
                PossibleCauses = $errorInfo.PossibleCauses
                Fixes = $errorInfo.Fixes
                CapturedValues = $capturedGroups | Select-Object -Unique
                Sample = $matches[0].Value
            }
        }
    }
    
    return $foundErrors | Sort-Object -Property @{Expression={
        switch($_.Severity) {
            "High" {1}
            "Medium" {2}
            "Low" {3}
        }
    }}
}

function Analyze-StackTrace {
    param([string]$LogContent)
    
    $stackTraces = @()
    $stackPattern = "at\s+.*?\(.*?:\d+:\d+\)|at\s+\w+\.\w+\(.*?\.java:\d+\)"
    
    $lines = $LogContent -split "`n"
    $currentTrace = @()
    $inTrace = $false
    
    foreach ($line in $lines) {
        if ($line -match "FATAL EXCEPTION|AndroidRuntime.*FATAL|ERROR.*Exception") {
            $inTrace = $true
            $currentTrace = @($line)
        }
        elseif ($inTrace -and $line -match $stackPattern) {
            $currentTrace += $line
        }
        elseif ($inTrace -and $currentTrace.Count -gt 0 -and $line -notmatch $stackPattern) {
            $stackTraces += @{
                Exception = $currentTrace[0]
                Trace = $currentTrace -join "`n"
                LineCount = $currentTrace.Count
            }
            $inTrace = $false
            $currentTrace = @()
        }
    }
    
    return $stackTraces
}

function Get-ComponentFromError {
    param([string]$ErrorText)
    
    # Try to extract component names from error messages
    $componentPatterns = @(
        "in (\w+Screen)",
        "component (\w+)",
        "at (\w+)\.render",
        "in (\w+) \(at",
        "(\w+Screen)\.tsx"
    )
    
    foreach ($pattern in $componentPatterns) {
        if ($ErrorText -match $pattern) {
            return $Matches[1]
        }
    }
    
    return "Unknown"
}

function Show-ErrorSummary {
    param($Errors)
    
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║         ERROR ANALYSIS SUMMARY         ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Red
    
    if ($Errors.Count -eq 0) {
        Write-Host "`n✅ No errors found in logs!" -ForegroundColor Green
        return
    }
    
    # Group by category
    $categories = $Errors | Group-Object -Property Category
    
    Write-Host "`nERROR CATEGORIES:" -ForegroundColor Yellow
    foreach ($category in $categories) {
        $severityCounts = $category.Group | Group-Object -Property Severity
        Write-Host "  $($category.Name): $($category.Count) errors" -ForegroundColor White
        foreach ($severity in $severityCounts) {
            $color = switch($severity.Name) {
                "High" {"Red"}
                "Medium" {"Yellow"}
                "Low" {"Gray"}
            }
            Write-Host "    - $($severity.Name): $($severity.Count)" -ForegroundColor $color
        }
    }
    
    Write-Host "`nTOP ERRORS:" -ForegroundColor Yellow
    $Errors | Select-Object -First 5 | ForEach-Object {
        Write-Host "`n  [$($_.Severity)] $($_.Description)" -ForegroundColor $(
            switch($_.Severity) {
                "High" {"Red"}
                "Medium" {"Yellow"}
                "Low" {"Gray"}
            }
        )
        Write-Host "  Pattern: $($_.Pattern)" -ForegroundColor DarkGray
        Write-Host "  Count: $($_.Count)" -ForegroundColor White
        Write-Host "  Sample: $($_.Sample)" -ForegroundColor Gray
        
        if ($_.CapturedValues.Count -gt 0) {
            Write-Host "  Captured: $($_.CapturedValues -join ', ')" -ForegroundColor Cyan
        }
    }
}

function Show-FixRecommendations {
    param($Errors)
    
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║        FIX RECOMMENDATIONS             ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
    
    $recommendedFixes = @{}
    $fixPriority = @()
    
    foreach ($error in $Errors) {
        foreach ($fix in $error.Fixes) {
            if (-not $recommendedFixes.ContainsKey($fix)) {
                $recommendedFixes[$fix] = @{
                    Count = 0
                    Errors = @()
                    TotalSeverityScore = 0
                }
            }
            
            $recommendedFixes[$fix].Count++
            $recommendedFixes[$fix].Errors += $error.Description
            $recommendedFixes[$fix].TotalSeverityScore += switch($error.Severity) {
                "High" {3}
                "Medium" {2}
                "Low" {1}
            }
        }
    }
    
    # Sort by priority (severity score * count)
    $fixPriority = $recommendedFixes.GetEnumerator() | Sort-Object -Property {
        $_.Value.TotalSeverityScore * $_.Value.Count
    } -Descending
    
    Write-Host "`nRECOMMENDED ACTIONS (by priority):" -ForegroundColor Yellow
    
    $actionNumber = 1
    foreach ($fix in $fixPriority | Select-Object -First 10) {
        Write-Host "`n  $actionNumber. $($fix.Key)" -ForegroundColor White
        Write-Host "     Addresses $($fix.Value.Count) error(s)" -ForegroundColor Gray
        
        if ($FixCommands.ContainsKey($fix.Key)) {
            $commands = $FixCommands[$fix.Key]
            Write-Host "     Commands:" -ForegroundColor Cyan
            foreach ($cmd in $commands.Commands) {
                Write-Host "       $cmd" -ForegroundColor DarkCyan
            }
        }
        
        $actionNumber++
    }
}

function Apply-AutoFixes {
    param($Errors)
    
    if (-not $AutoFix) { return }
    
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║          APPLYING AUTO-FIXES           ║" -ForegroundColor Magenta
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Magenta
    
    $appliedFixes = @()
    
    # Check for Metro connection issues
    if ($Errors | Where-Object { $_.Pattern -match "ECONNREFUSED.*:8081" }) {
        Write-Host "`n→ Fixing Metro bundler connection..." -ForegroundColor Yellow
        & $ADB reverse tcp:8081 tcp:8081 2>&1 | Out-Null
        Write-Host "  ✓ ADB reverse configured" -ForegroundColor Green
        $appliedFixes += "Metro connection fix"
    }
    
    # Check for app crash - restart if needed
    $appRunning = & $ADB shell ps 2>&1 | Select-String $PackageName
    if (-not $appRunning) {
        Write-Host "`n→ Restarting crashed app..." -ForegroundColor Yellow
        & $ADB shell am start -n "$PackageName/.MainActivity" 2>&1 | Out-Null
        Write-Host "  ✓ App restarted" -ForegroundColor Green
        $appliedFixes += "App restart"
    }
    
    return $appliedFixes
}

function Save-DebugReport {
    param($Errors, $StackTraces, $AppliedFixes)
    
    if (-not $SaveReport) { return }
    
    if (-not (Test-Path $ReportDir)) {
        New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $reportPath = Join-Path $ReportDir "debug-report-$timestamp.json"
    
    $report = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Mode = $Mode
        TotalErrors = $Errors.Count
        ErrorsByCategory = $Errors | Group-Object -Property Category | ForEach-Object {
            @{
                Category = $_.Name
                Count = $_.Count
                Errors = $_.Group
            }
        }
        StackTraces = $StackTraces
        AppliedFixes = $AppliedFixes
        SystemInfo = @{
            DeviceId = (& $ADB devices | Select-String "device$" | Select-Object -First 1).ToString().Split("`t")[0]
            AppVersion = "1.0"  # Would need to extract from app
        }
    }
    
    $report | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath
    Write-Host "`n📄 Debug report saved: $reportPath" -ForegroundColor Green
}

# ========================================
# MAIN EXECUTION
# ========================================

Write-Host "`n🔍 SQUASH TRAINING APP - LOG ANALYZER" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan

# Get log content
$logContent = Get-LogContent
if (-not $logContent) {
    Write-DebugLog "No log content to analyze" "Error"
    exit 1
}

Write-DebugLog "Analyzing $(($logContent -split "`n").Count) lines of logs..." "Info"

# Find errors
$errors = Find-ErrorPatterns -LogContent $logContent
Write-DebugLog "Found $($errors.Count) error patterns" "Info"

# Analyze stack traces
$stackTraces = Analyze-StackTrace -LogContent $logContent
Write-DebugLog "Found $($stackTraces.Count) stack traces" "Info"

# Show error summary
Show-ErrorSummary -Errors $errors

# Show fix recommendations
if ($errors.Count -gt 0) {
    Show-FixRecommendations -Errors $errors
}

# Apply auto-fixes if requested
$appliedFixes = @()
if ($AutoFix -and $errors.Count -gt 0) {
    $appliedFixes = Apply-AutoFixes -Errors $errors
}

# Save report if requested
Save-DebugReport -Errors $errors -StackTraces $stackTraces -AppliedFixes $appliedFixes

# Show final summary
Write-Host "`n════════════════════════════════════════" -ForegroundColor DarkGray
if ($errors.Count -eq 0) {
    Write-Host "✅ No errors found - app appears to be running well!" -ForegroundColor Green
} else {
    $highSeverity = @($errors | Where-Object { $_.Severity -eq "High" }).Count
    Write-Host "⚠️  Found $($errors.Count) errors ($highSeverity high severity)" -ForegroundColor Yellow
    Write-Host "Run with -AutoFix to apply automatic fixes" -ForegroundColor Gray
}

Write-Host "════════════════════════════════════════" -ForegroundColor DarkGray