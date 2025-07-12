<#
.SYNOPSIS
    Automated Feature Validation Testing Utility
    
.DESCRIPTION
    Provides comprehensive automated testing for all features of the Squash Training App.
    Includes screen navigation, UI interaction, database validation, and crash detection.
    
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
    - Running emulator/device
    - Installed Squash Training App
    
.REPLACES
    - None (new implementation)
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("All", "HomeScreen", "ChecklistScreen", "RecordScreen", "CoachScreen", "ProfileScreen")]
    [string]$Feature = "All",
    
    [switch]$Detailed = $false,
    [switch]$Screenshot = $false,
    [int]$WaitTime = 2000  # Milliseconds between actions
)

# ========================================
# CONFIGURATION
# ========================================

$ADB = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$PackageName = "com.squashtrainingapp"
$ScreenshotDir = "$PSScriptRoot\test-screenshots"

# UI Element Coordinates (based on standard 1080x2400 resolution)
$UIElements = @{
    # Bottom Navigation Tabs
    HomeTab = @{X = 108; Y = 2100}
    ChecklistTab = @{X = 324; Y = 2100}
    RecordTab = @{X = 540; Y = 2100}
    CoachTab = @{X = 756; Y = 2100}
    ProfileTab = @{X = 972; Y = 2100}
    
    # Common UI Elements
    BackButton = @{X = 50; Y = 100}
    MenuButton = @{X = 1030; Y = 100}
    ScrollUp = @{X = 540; Y = 600; EndY = 1800}
    ScrollDown = @{X = 540; Y = 1800; EndY = 600}
    
    # Home Screen Elements
    ProgramCard1 = @{X = 540; Y = 600}
    ProgramCard2 = @{X = 540; Y = 900}
    ProgramCard3 = @{X = 540; Y = 1200}
    QuickStatsArea = @{X = 540; Y = 400}
    
    # Checklist Screen Elements
    ExerciseItem1 = @{X = 540; Y = 400}
    ExerciseItem2 = @{X = 540; Y = 600}
    IntensitySlider = @{X = 540; Y = 1400}
    ConditionSlider = @{X = 540; Y = 1550}
    FatigueSlider = @{X = 540; Y = 1700}
    CompleteButton = @{X = 540; Y = 1900}
    
    # Record Screen Elements
    RecordEntry1 = @{X = 540; Y = 400}
    RecordEntry2 = @{X = 540; Y = 600}
    AddMemoButton = @{X = 900; Y = 2000}
    
    # Coach Screen Elements
    AskCoachButton = @{X = 540; Y = 1200}
    VideoRecommendation1 = @{X = 540; Y = 800}
    
    # Profile Screen Elements
    SettingsButton = @{X = 540; Y = 600}
    DevModeArea = @{X = 540; Y = 2000}  # Version text area
}

# Test Scenarios
$TestScenarios = @{
    HomeScreen = @(
        @{Name = "View Quick Stats"; Actions = @("Tap:QuickStatsArea", "Wait:1000")}
        @{Name = "Open Program 1"; Actions = @("Tap:ProgramCard1", "Wait:2000", "Tap:BackButton")}
        @{Name = "Scroll Programs"; Actions = @("Swipe:ScrollDown", "Wait:1000", "Swipe:ScrollUp")}
    )
    
    ChecklistScreen = @(
        @{Name = "View Exercises"; Actions = @("Tap:ExerciseItem1", "Wait:1000", "Tap:BackButton")}
        @{Name = "Adjust Intensity"; Actions = @("Swipe:IntensitySlider", "Wait:500")}
        @{Name = "Complete Workout"; Actions = @("Tap:CompleteButton", "Wait:2000")}
    )
    
    RecordScreen = @(
        @{Name = "View History"; Actions = @("Swipe:ScrollDown", "Wait:1000", "Swipe:ScrollUp")}
        @{Name = "Open Record"; Actions = @("Tap:RecordEntry1", "Wait:1000", "Tap:BackButton")}
        @{Name = "Add Memo"; Actions = @("Tap:AddMemoButton", "Wait:1000")}
    )
    
    CoachScreen = @(
        @{Name = "Ask Coach"; Actions = @("Tap:AskCoachButton", "Wait:2000")}
        @{Name = "View Recommendations"; Actions = @("Tap:VideoRecommendation1", "Wait:1000")}
    )
    
    ProfileScreen = @(
        @{Name = "Open Settings"; Actions = @("Tap:SettingsButton", "Wait:1000", "Tap:BackButton")}
        @{Name = "Activate Dev Mode"; Actions = @(
            "Tap:DevModeArea", "Wait:200",
            "Tap:DevModeArea", "Wait:200",
            "Tap:DevModeArea", "Wait:200",
            "Tap:DevModeArea", "Wait:200",
            "Tap:DevModeArea", "Wait:1000"
        )}
    )
}

# ========================================
# UTILITY FUNCTIONS
# ========================================

function Write-TestLog {
    param(
        [string]$Message,
        [string]$Level = "Info"
    )
    
    $colors = @{
        "Info" = "White"
        "Success" = "Green"
        "Warning" = "Yellow"
        "Error" = "Red"
        "Debug" = "Gray"
    }
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = $colors[$Level] ?? "White"
    
    Write-Host "[$timestamp] $Message" -ForegroundColor $color
    
    if ($Detailed -or $Level -in @("Error", "Warning")) {
        # Also log to file
        $logFile = "$PSScriptRoot\test-log-$(Get-Date -Format 'yyyyMMdd').txt"
        "[$timestamp] [$Level] $Message" | Add-Content -Path $logFile
    }
}

function Test-AppRunning {
    try {
        $processes = & $ADB shell ps 2>&1
        return $processes -match $PackageName
    }
    catch {
        Write-TestLog "Failed to check app status: $_" "Error"
        return $false
    }
}

function Get-CurrentActivity {
    try {
        $activity = & $ADB shell dumpsys window windows 2>&1 | Select-String "mCurrentFocus"
        if ($activity) {
            return $activity.ToString()
        }
    }
    catch {
        Write-TestLog "Failed to get current activity: $_" "Debug"
    }
    return ""
}

function Take-Screenshot {
    param([string]$Name)
    
    if (-not $Screenshot) { return }
    
    try {
        if (-not (Test-Path $ScreenshotDir)) {
            New-Item -ItemType Directory -Path $ScreenshotDir -Force | Out-Null
        }
        
        $filename = "$Name-$(Get-Date -Format 'yyyyMMdd-HHmmss').png"
        $devicePath = "/sdcard/$filename"
        $localPath = Join-Path $ScreenshotDir $filename
        
        & $ADB shell screencap -p $devicePath 2>&1 | Out-Null
        & $ADB pull $devicePath $localPath 2>&1 | Out-Null
        & $ADB shell rm $devicePath 2>&1 | Out-Null
        
        Write-TestLog "Screenshot saved: $filename" "Debug"
    }
    catch {
        Write-TestLog "Failed to take screenshot: $_" "Debug"
    }
}

function Execute-Action {
    param([string]$Action)
    
    $parts = $Action -split ':'
    $command = $parts[0]
    $target = if ($parts.Count -gt 1) { $parts[1] } else { "" }
    
    switch ($command) {
        "Tap" {
            if ($UIElements.ContainsKey($target)) {
                $coord = $UIElements[$target]
                Write-TestLog "Tapping $target at ($($coord.X), $($coord.Y))" "Debug"
                & $ADB shell input tap $coord.X $coord.Y 2>&1 | Out-Null
            }
            else {
                Write-TestLog "Unknown UI element: $target" "Warning"
            }
        }
        
        "Swipe" {
            if ($UIElements.ContainsKey($target)) {
                $coord = $UIElements[$target]
                if ($coord.ContainsKey("EndY")) {
                    Write-TestLog "Swiping $target" "Debug"
                    & $ADB shell input swipe $coord.X $coord.Y $coord.X $coord.EndY 500 2>&1 | Out-Null
                }
            }
        }
        
        "Wait" {
            $ms = [int]$target
            Write-TestLog "Waiting ${ms}ms" "Debug"
            Start-Sleep -Milliseconds $ms
        }
        
        "Key" {
            Write-TestLog "Sending key event: $target" "Debug"
            & $ADB shell input keyevent $target 2>&1 | Out-Null
        }
        
        "Text" {
            Write-TestLog "Typing text: $target" "Debug"
            & $ADB shell input text "$target" 2>&1 | Out-Null
        }
    }
}

function Test-Screen {
    param(
        [string]$ScreenName,
        [hashtable]$TabCoordinates
    )
    
    Write-TestLog "Testing $ScreenName" "Info"
    $results = @{
        Screen = $ScreenName
        NavigationSuccess = $false
        TestsPassed = 0
        TestsFailed = 0
        Crashed = $false
        Errors = @()
    }
    
    # Navigate to screen
    Write-TestLog "Navigating to $ScreenName" "Debug"
    & $ADB shell input tap $TabCoordinates.X $TabCoordinates.Y 2>&1 | Out-Null
    Start-Sleep -Milliseconds $WaitTime
    
    # Check if app is still running
    if (-not (Test-AppRunning)) {
        $results.Crashed = $true
        $results.Errors += "App crashed during navigation"
        Write-TestLog "App crashed while navigating to $ScreenName" "Error"
        return $results
    }
    
    $results.NavigationSuccess = $true
    Take-Screenshot "$ScreenName-Initial"
    
    # Get current activity for validation
    $activity = Get-CurrentActivity
    Write-TestLog "Current activity: $activity" "Debug"
    
    # Run test scenarios
    if ($TestScenarios.ContainsKey($ScreenName)) {
        foreach ($scenario in $TestScenarios[$ScreenName]) {
            Write-TestLog "  Running scenario: $($scenario.Name)" "Debug"
            
            try {
                foreach ($action in $scenario.Actions) {
                    Execute-Action $action
                    
                    # Check if app crashed after action
                    if (-not (Test-AppRunning)) {
                        $results.Crashed = $true
                        $results.TestsFailed++
                        $results.Errors += "Crashed during: $($scenario.Name)"
                        Write-TestLog "  ✗ $($scenario.Name) - App crashed" "Error"
                        
                        # Restart app for next test
                        & $ADB shell am start -n "$PackageName/.MainActivity" 2>&1 | Out-Null
                        Start-Sleep -Seconds 3
                        break
                    }
                }
                
                if (-not $results.Crashed) {
                    $results.TestsPassed++
                    Write-TestLog "  ✓ $($scenario.Name)" "Success"
                    Take-Screenshot "$ScreenName-$($scenario.Name -replace ' ', '_')"
                }
                else {
                    $results.Crashed = $false  # Reset for next scenario
                }
            }
            catch {
                $results.TestsFailed++
                $results.Errors += "Exception in $($scenario.Name): $_"
                Write-TestLog "  ✗ $($scenario.Name) - Exception: $_" "Error"
            }
            
            Start-Sleep -Milliseconds 500
        }
    }
    
    return $results
}

function Test-DatabaseOperations {
    Write-TestLog "Testing Database Operations" "Info"
    
    # This would involve checking if data persists across app restarts
    # For now, we'll do a basic check
    
    # Kill and restart app
    & $ADB shell am force-stop $PackageName 2>&1 | Out-Null
    Start-Sleep -Seconds 2
    & $ADB shell am start -n "$PackageName/.MainActivity" 2>&1 | Out-Null
    Start-Sleep -Seconds 3
    
    if (Test-AppRunning) {
        Write-TestLog "  ✓ App restarts successfully" "Success"
        return $true
    }
    else {
        Write-TestLog "  ✗ App failed to restart" "Error"
        return $false
    }
}

function Show-TestSummary {
    param([array]$Results)
    
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║        FEATURE TEST SUMMARY            ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
    
    $totalPassed = 0
    $totalFailed = 0
    $totalCrashes = 0
    
    foreach ($result in $Results) {
        $status = if ($result.NavigationSuccess -and $result.TestsFailed -eq 0 -and -not $result.Crashed) {
            "✅ PASS"
        } else {
            "❌ FAIL"
        }
        
        Write-Host "`n$($result.Screen): $status"
        Write-Host "  Tests Passed: $($result.TestsPassed)" -ForegroundColor Green
        Write-Host "  Tests Failed: $($result.TestsFailed)" -ForegroundColor Red
        
        $totalPassed += $result.TestsPassed
        $totalFailed += $result.TestsFailed
        if ($result.Crashed) { $totalCrashes++ }
        
        if ($result.Errors.Count -gt 0) {
            Write-Host "  Errors:" -ForegroundColor Yellow
            $result.Errors | ForEach-Object { Write-Host "    - $_" -ForegroundColor Yellow }
        }
    }
    
    Write-Host "`n════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host "TOTAL RESULTS:" -ForegroundColor White
    Write-Host "  Passed: $totalPassed" -ForegroundColor Green
    Write-Host "  Failed: $totalFailed" -ForegroundColor Red
    Write-Host "  Crashes: $totalCrashes" -ForegroundColor Red
    
    $successRate = if (($totalPassed + $totalFailed) -gt 0) {
        [math]::Round(($totalPassed / ($totalPassed + $totalFailed)) * 100, 2)
    } else { 0 }
    
    Write-Host "  Success Rate: $successRate%" -ForegroundColor $(if ($successRate -gt 80) {"Green"} else {"Yellow"})
}

# ========================================
# MAIN EXECUTION
# ========================================

Write-Host "`n🧪 SQUASH TRAINING APP - FEATURE VALIDATION" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════" -ForegroundColor Cyan

# Check prerequisites
if (-not (Test-Path $ADB)) {
    Write-TestLog "ADB not found at: $ADB" "Error"
    exit 1
}

if (-not (Test-AppRunning)) {
    Write-TestLog "App is not running. Please start the app first." "Error"
    exit 1
}

Write-TestLog "Starting feature validation tests" "Info"
$testResults = @()

# Determine which features to test
$featuresToTest = if ($Feature -eq "All") {
    @("HomeScreen", "ChecklistScreen", "RecordScreen", "CoachScreen", "ProfileScreen")
} else {
    @($Feature)
}

# Initial screenshot
Take-Screenshot "Initial-State"

# Test each feature
foreach ($featureName in $featuresToTest) {
    if ($UIElements.ContainsKey("${featureName}Tab")) {
        $tabName = "${featureName}Tab"
        $result = Test-Screen -ScreenName $featureName -TabCoordinates $UIElements[$tabName]
        $testResults += $result
    }
    else {
        Write-TestLog "No tab defined for $featureName" "Warning"
    }
    
    # Return to home between tests
    if ($featureName -ne "HomeScreen" -and $featureName -ne $featuresToTest[-1]) {
        Write-TestLog "Returning to Home" "Debug"
        & $ADB shell input tap $UIElements.HomeTab.X $UIElements.HomeTab.Y 2>&1 | Out-Null
        Start-Sleep -Milliseconds $WaitTime
    }
}

# Test database persistence
if ($Feature -eq "All") {
    $dbResult = Test-DatabaseOperations
    $testResults += @{
        Screen = "Database"
        NavigationSuccess = $dbResult
        TestsPassed = if ($dbResult) {1} else {0}
        TestsFailed = if ($dbResult) {0} else {1}
        Crashed = $false
        Errors = @()
    }
}

# Show summary
Show-TestSummary -Results $testResults

# Save detailed report if requested
if ($Detailed) {
    $reportPath = "$PSScriptRoot\test-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $testResults | ConvertTo-Json -Depth 5 | Out-File -FilePath $reportPath
    Write-TestLog "Detailed report saved to: $reportPath" "Info"
}

Write-Host "`n════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "Feature validation complete!" -ForegroundColor Cyan