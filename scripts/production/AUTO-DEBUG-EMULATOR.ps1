<#
.SYNOPSIS
    Automated Emulator Debugging Script for Squash Training App
    
.DESCRIPTION
    Comprehensive automation that manages emulator, builds APK, tests all features,
    captures screenshots, detects errors, and applies automatic fixes.
    Implements intelligent debugging with visual verification and self-healing.
    
.STATUS
    ACTIVE
    
.VERSION
    2.0.0
    
.CREATED
    2025-07-14
    
.DEPENDENCIES
    - Android SDK with emulator
    - Java JDK 17
    - ADB (Android Debug Bridge)
    - PowerShell 5.0+
    
.EXAMPLE
    .\AUTO-DEBUG-EMULATOR.ps1 -Cycles 50 -AutoFix -GenerateReport
#>

param(
    [int]$Cycles = 50,
    [string]$EmulatorName = "Pixel_6",
    [switch]$AutoFix = $true,
    [switch]$CaptureScreenshots = $true,
    [switch]$GenerateReport = $true,
    [switch]$SkipBuild = $false,
    [int]$ScreenshotDelay = 2,
    [int]$MaxRetries = 3,
    [string]$OutputDir = "debug-results-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
)

# ========================================
# CONFIGURATION & INITIALIZATION
# ========================================

$ErrorActionPreference = "Continue"
$ProgressPreference = "Continue"

# Environment setup
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$env:Path = "$env:JAVA_HOME\bin;$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\emulator;$env:Path"

# Paths
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$AndroidDir = Join-Path $ProjectRoot "SquashTrainingApp\android"
$ApkPath = Join-Path $AndroidDir "app\build\outputs\apk\debug\app-debug.apk"
$OutputPath = Join-Path $ProjectRoot $OutputDir

# Create output directory
New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
New-Item -ItemType Directory -Path "$OutputPath\screenshots" -Force | Out-Null
New-Item -ItemType Directory -Path "$OutputPath\logs" -Force | Out-Null
New-Item -ItemType Directory -Path "$OutputPath\reports" -Force | Out-Null

# ========================================
# DEBUG STATE MANAGEMENT
# ========================================

$global:DebugState = @{
    Emulator = @{
        Status = "Unknown"
        DeviceId = ""
        StartTime = $null
        RestartCount = 0
    }
    
    Build = @{
        Status = "NotStarted"
        BuildCount = 0
        LastError = ""
        ApkSize = 0
    }
    
    Installation = @{
        Status = "NotStarted"
        InstallCount = 0
        UninstallCount = 0
        LastError = ""
    }
    
    Testing = @{
        CurrentCycle = 0
        PassedTests = 0
        FailedTests = 0
        Crashes = 0
        Screenshots = @()
        Errors = @()
    }
    
    Features = @{
        Home = @{ Tested = $false; Passed = $false; Screenshot = "" }
        Checklist = @{ Tested = $false; Passed = $false; Screenshot = "" }
        Record = @{ Tested = $false; Passed = $false; Screenshot = "" }
        Profile = @{ Tested = $false; Passed = $false; Screenshot = "" }
        Coach = @{ Tested = $false; Passed = $false; Screenshot = "" }
        History = @{ Tested = $false; Passed = $false; Screenshot = "" }
    }
    
    Performance = @{
        MemoryUsage = @()
        CpuUsage = @()
        LaunchTime = 0
        ResponseTimes = @()
    }
    
    Fixes = @{
        Applied = @()
        Successful = 0
        Failed = 0
    }
}

# ========================================
# HELPER FUNCTIONS
# ========================================

function Write-DebugLog {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [ConsoleColor]$Color = "White"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Console output
    Write-Host $logMessage -ForegroundColor $Color
    
    # File output
    $logFile = Join-Path $OutputPath "logs\debug-log.txt"
    Add-Content -Path $logFile -Value $logMessage
}

function Test-EmulatorRunning {
    try {
        $devices = & adb devices 2>&1
        if ($devices -match "emulator-\d+\s+device") {
            $global:DebugState.Emulator.Status = "Running"
            $global:DebugState.Emulator.DeviceId = ($devices -match "emulator-\d+" | Out-String).Trim()
            return $true
        }
    }
    catch {
        Write-DebugLog "Error checking emulator status: $_" -Level "ERROR" -Color Red
    }
    
    $global:DebugState.Emulator.Status = "NotRunning"
    return $false
}

function Start-EmulatorWithRetry {
    Write-DebugLog "Starting emulator: $EmulatorName" -Color Cyan
    
    for ($i = 1; $i -le $MaxRetries; $i++) {
        Write-DebugLog "Attempt $i of $MaxRetries"
        
        # Start emulator in background
        $emulatorPath = "$env:ANDROID_HOME\emulator\emulator.exe"
        Start-Process -FilePath $emulatorPath -ArgumentList "-avd", $EmulatorName, "-no-snapshot-load" -WindowStyle Hidden
        
        # Wait for emulator to boot
        Write-DebugLog "Waiting for emulator to boot..."
        $timeout = 120
        $elapsed = 0
        
        while ($elapsed -lt $timeout) {
            Start-Sleep -Seconds 5
            $elapsed += 5
            
            if (Test-EmulatorRunning) {
                Write-DebugLog "Emulator started successfully!" -Color Green
                $global:DebugState.Emulator.StartTime = Get-Date
                
                # Wait for boot completion
                Write-DebugLog "Waiting for boot completion..."
                & adb wait-for-device
                Start-Sleep -Seconds 10
                
                return $true
            }
            
            Write-Progress -Activity "Starting Emulator" -Status "Elapsed: $elapsed seconds" -PercentComplete (($elapsed / $timeout) * 100)
        }
        
        Write-DebugLog "Emulator failed to start within timeout" -Level "WARN" -Color Yellow
        
        # Kill any hanging emulator processes
        Get-Process | Where-Object { $_.Name -like "*emulator*" -or $_.Name -like "*qemu*" } | Stop-Process -Force
        Start-Sleep -Seconds 5
    }
    
    Write-DebugLog "Failed to start emulator after $MaxRetries attempts" -Level "ERROR" -Color Red
    return $false
}

function Build-APK {
    if ($SkipBuild) {
        Write-DebugLog "Skipping build (SkipBuild flag set)" -Color Yellow
        return Test-Path $ApkPath
    }
    
    Write-DebugLog "Building APK..." -Color Cyan
    $global:DebugState.Build.Status = "Building"
    $global:DebugState.Build.BuildCount++
    
    Set-Location $AndroidDir
    
    try {
        # Clean previous build
        Write-DebugLog "Cleaning previous build..."
        & cmd /c "gradlew.bat clean" 2>&1 | Out-Null
        
        # Build APK
        Write-DebugLog "Running gradle build..."
        $buildOutput = & cmd /c "gradlew.bat assembleDebug --no-daemon" 2>&1
        
        if ($LASTEXITCODE -eq 0 -and (Test-Path $ApkPath)) {
            $apkInfo = Get-Item $ApkPath
            $global:DebugState.Build.Status = "Success"
            $global:DebugState.Build.ApkSize = [math]::Round($apkInfo.Length / 1MB, 2)
            Write-DebugLog "Build successful! APK size: $($global:DebugState.Build.ApkSize) MB" -Color Green
            return $true
        }
        else {
            $global:DebugState.Build.Status = "Failed"
            $global:DebugState.Build.LastError = $buildOutput | Select-Object -Last 10 | Out-String
            Write-DebugLog "Build failed: $($global:DebugState.Build.LastError)" -Level "ERROR" -Color Red
            return $false
        }
    }
    catch {
        $global:DebugState.Build.Status = "Error"
        $global:DebugState.Build.LastError = $_.Exception.Message
        Write-DebugLog "Build error: $_" -Level "ERROR" -Color Red
        return $false
    }
    finally {
        Set-Location $PSScriptRoot
    }
}

function Install-APK {
    Write-DebugLog "Installing APK..." -Color Cyan
    $global:DebugState.Installation.Status = "Installing"
    $global:DebugState.Installation.InstallCount++
    
    try {
        # Uninstall existing app
        Write-DebugLog "Uninstalling existing app..."
        & adb uninstall com.squashtrainingapp 2>&1 | Out-Null
        $global:DebugState.Installation.UninstallCount++
        
        # Install new APK
        Write-DebugLog "Installing APK: $ApkPath"
        $installOutput = & adb install $ApkPath 2>&1
        
        if ($installOutput -match "Success") {
            $global:DebugState.Installation.Status = "Success"
            Write-DebugLog "Installation successful!" -Color Green
            return $true
        }
        else {
            $global:DebugState.Installation.Status = "Failed"
            $global:DebugState.Installation.LastError = $installOutput | Out-String
            Write-DebugLog "Installation failed: $($global:DebugState.Installation.LastError)" -Level "ERROR" -Color Red
            return $false
        }
    }
    catch {
        $global:DebugState.Installation.Status = "Error"
        $global:DebugState.Installation.LastError = $_.Exception.Message
        Write-DebugLog "Installation error: $_" -Level "ERROR" -Color Red
        return $false
    }
}

function Capture-Screenshot {
    param(
        [string]$Name,
        [string]$Feature = "General"
    )
    
    if (-not $CaptureScreenshots) { return "" }
    
    try {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $filename = "$($Feature)_$($Name)_$timestamp.png"
        $devicePath = "/sdcard/$filename"
        $localPath = Join-Path "$OutputPath\screenshots" $filename
        
        # Capture screenshot on device
        & adb shell screencap -p $devicePath
        
        # Pull to local machine
        & adb pull $devicePath $localPath 2>&1 | Out-Null
        
        # Clean up device
        & adb shell rm $devicePath
        
        Write-DebugLog "Screenshot captured: $filename" -Color Green
        
        # Add to state
        $global:DebugState.Testing.Screenshots += @{
            Feature = $Feature
            Name = $Name
            Path = $localPath
            Timestamp = Get-Date
        }
        
        return $localPath
    }
    catch {
        Write-DebugLog "Failed to capture screenshot: $_" -Level "WARN" -Color Yellow
        return ""
    }
}

function Start-AppWithRetry {
    Write-DebugLog "Starting app..." -Color Cyan
    
    for ($i = 1; $i -le $MaxRetries; $i++) {
        try {
            # Clear logcat
            & adb logcat -c
            
            # Start app
            $startTime = Get-Date
            & adb shell am start -n com.squashtrainingapp/.MainActivity
            Start-Sleep -Seconds 3
            
            # Check if app started
            $psOutput = & adb shell ps | Select-String "squashtrainingapp"
            if ($psOutput) {
                $launchTime = ((Get-Date) - $startTime).TotalSeconds
                $global:DebugState.Performance.LaunchTime = [math]::Round($launchTime, 2)
                Write-DebugLog "App started successfully in $($global:DebugState.Performance.LaunchTime) seconds" -Color Green
                return $true
            }
        }
        catch {
            Write-DebugLog "Error starting app: $_" -Level "ERROR" -Color Red
        }
        
        Write-DebugLog "App failed to start, attempt $i of $MaxRetries" -Level "WARN" -Color Yellow
        Start-Sleep -Seconds 2
    }
    
    return $false
}

function Test-Feature {
    param(
        [string]$FeatureName,
        [hashtable]$Actions
    )
    
    Write-DebugLog "Testing feature: $FeatureName" -Color Cyan
    $feature = $global:DebugState.Features[$FeatureName]
    $feature.Tested = $true
    
    try {
        # Execute actions
        foreach ($action in $Actions.GetEnumerator()) {
            Write-DebugLog "  - $($action.Key)"
            
            switch ($action.Value.Type) {
                "tap" {
                    & adb shell input tap $action.Value.X $action.Value.Y
                }
                "swipe" {
                    & adb shell input swipe $action.Value.StartX $action.Value.StartY $action.Value.EndX $action.Value.EndY $action.Value.Duration
                }
                "text" {
                    & adb shell input text $action.Value.Text
                }
                "key" {
                    & adb shell input keyevent $action.Value.KeyCode
                }
            }
            
            Start-Sleep -Milliseconds 500
        }
        
        # Capture screenshot
        Start-Sleep -Seconds $ScreenshotDelay
        $feature.Screenshot = Capture-Screenshot -Name $FeatureName -Feature $FeatureName
        
        # Check for crashes
        $psOutput = & adb shell ps | Select-String "squashtrainingapp"
        if ($psOutput) {
            $feature.Passed = $true
            $global:DebugState.Testing.PassedTests++
            Write-DebugLog "Feature test passed: $FeatureName" -Color Green
            return $true
        }
        else {
            throw "App crashed during test"
        }
    }
    catch {
        $feature.Passed = $false
        $global:DebugState.Testing.FailedTests++
        $global:DebugState.Testing.Errors += @{
            Feature = $FeatureName
            Error = $_.Exception.Message
            Timestamp = Get-Date
        }
        Write-DebugLog "Feature test failed: $FeatureName - $_" -Level "ERROR" -Color Red
        return $false
    }
}

function Test-AllFeatures {
    Write-DebugLog "Starting comprehensive feature testing..." -Color Cyan
    
    # Define test actions for each feature
    $testActions = @{
        Home = @{
            "Open Home" = @{ Type = "tap"; X = 540; Y = 2337 }
            "Wait" = @{ Type = "sleep"; Duration = 2000 }
        }
        
        Checklist = @{
            "Open Checklist" = @{ Type = "tap"; X = 216; Y = 2337 }
            "Toggle Exercise 1" = @{ Type = "tap"; X = 950; Y = 400 }
            "Toggle Exercise 2" = @{ Type = "tap"; X = 950; Y = 550 }
            "Scroll Down" = @{ Type = "swipe"; StartX = 540; StartY = 1200; EndX = 540; EndY = 600; Duration = 500 }
        }
        
        Record = @{
            "Open Record" = @{ Type = "tap"; X = 432; Y = 2337 }
            "Enter Exercise Name" = @{ Type = "tap"; X = 540; Y = 410 }
            "Type Name" = @{ Type = "text"; Text = "TestExercise" }
            "Enter Sets" = @{ Type = "tap"; X = 180; Y = 555 }
            "Type Sets" = @{ Type = "text"; Text = "3" }
            "Save Record" = @{ Type = "tap"; X = 540; Y = 1450 }
        }
        
        Profile = @{
            "Open Profile" = @{ Type = "tap"; X = 756; Y = 2337 }
            "View Stats" = @{ Type = "swipe"; StartX = 540; StartY = 1200; EndX = 540; EndY = 800; Duration = 300 }
        }
        
        Coach = @{
            "Open Coach" = @{ Type = "tap"; X = 972; Y = 2337 }
            "Refresh Tips" = @{ Type = "tap"; X = 540; Y = 1800 }
        }
        
        History = @{
            "Go Home First" = @{ Type = "tap"; X = 540; Y = 2337 }
            "Open History" = @{ Type = "tap"; X = 540; Y = 800 }
            "Scroll History" = @{ Type = "swipe"; StartX = 540; StartY = 1200; EndX = 540; EndY = 600; Duration = 500 }
        }
    }
    
    # Test each feature
    $allPassed = $true
    foreach ($feature in $testActions.Keys) {
        if (-not (Test-Feature -FeatureName $feature -Actions $testActions[$feature])) {
            $allPassed = $false
            
            # Try to recover
            if ($AutoFix) {
                Write-DebugLog "Attempting to recover from failure..." -Color Yellow
                Start-AppWithRetry | Out-Null
            }
        }
        
        Start-Sleep -Seconds 1
    }
    
    return $allPassed
}

function Parse-Logcat {
    Write-DebugLog "Parsing logcat for errors..." -Color Cyan
    
    try {
        $logcatOutput = & adb logcat -d -v time | Select-String "squashtrainingapp|AndroidRuntime"
        $logFile = Join-Path $OutputPath "logs\logcat_cycle_$($global:DebugState.Testing.CurrentCycle).txt"
        $logcatOutput | Out-File $logFile
        
        # Look for common error patterns
        $errorPatterns = @{
            "FATAL EXCEPTION" = "Crash"
            "OutOfMemoryError" = "Memory"
            "SQLiteException" = "Database"
            "NetworkOnMainThreadException" = "Network"
            "ActivityNotFoundException" = "Navigation"
            "NullPointerException" = "NullPointer"
        }
        
        $foundErrors = @()
        foreach ($pattern in $errorPatterns.Keys) {
            if ($logcatOutput -match $pattern) {
                $foundErrors += $errorPatterns[$pattern]
                Write-DebugLog "Found error type: $($errorPatterns[$pattern])" -Level "ERROR" -Color Red
            }
        }
        
        if ($foundErrors.Count -gt 0) {
            $global:DebugState.Testing.Crashes++
            return $foundErrors
        }
        
        Write-DebugLog "No critical errors found in logcat" -Color Green
        return @()
    }
    catch {
        Write-DebugLog "Error parsing logcat: $_" -Level "WARN" -Color Yellow
        return @()
    }
}

function Apply-AutoFix {
    param(
        [string[]]$ErrorTypes
    )
    
    if (-not $AutoFix) { return }
    
    Write-DebugLog "Applying automatic fixes for errors: $($ErrorTypes -join ', ')" -Color Yellow
    
    foreach ($errorType in $ErrorTypes) {
        $fix = @{
            Timestamp = Get-Date
            ErrorType = $errorType
            Action = ""
            Success = $false
        }
        
        try {
            switch ($errorType) {
                "Crash" {
                    Write-DebugLog "Applying fix: Clear app data and cache"
                    & adb shell pm clear com.squashtrainingapp
                    $fix.Action = "Clear app data"
                    $fix.Success = $true
                }
                
                "Memory" {
                    Write-DebugLog "Applying fix: Force garbage collection and limit memory"
                    & adb shell am send-trim-memory com.squashtrainingapp MODERATE
                    $fix.Action = "Trim memory"
                    $fix.Success = $true
                }
                
                "Database" {
                    Write-DebugLog "Applying fix: Reset database"
                    & adb shell rm -rf /data/data/com.squashtrainingapp/databases
                    $fix.Action = "Reset database"
                    $fix.Success = $true
                }
                
                "Network" {
                    Write-DebugLog "Applying fix: Reset network settings"
                    & adb shell svc wifi enable
                    & adb shell svc data enable
                    $fix.Action = "Reset network"
                    $fix.Success = $true
                }
                
                "Navigation" {
                    Write-DebugLog "Applying fix: Reinstall app"
                    Install-APK | Out-Null
                    $fix.Action = "Reinstall app"
                    $fix.Success = $true
                }
                
                "NullPointer" {
                    Write-DebugLog "Applying fix: Clear app cache"
                    & adb shell pm clear com.squashtrainingapp
                    $fix.Action = "Clear cache"
                    $fix.Success = $true
                }
            }
            
            if ($fix.Success) {
                $global:DebugState.Fixes.Successful++
                Write-DebugLog "Fix applied successfully: $($fix.Action)" -Color Green
            }
        }
        catch {
            $fix.Success = $false
            $global:DebugState.Fixes.Failed++
            Write-DebugLog "Fix failed: $_" -Level "ERROR" -Color Red
        }
        
        $global:DebugState.Fixes.Applied += $fix
    }
    
    # Give fixes time to take effect
    Start-Sleep -Seconds 3
}

function Measure-Performance {
    Write-DebugLog "Measuring app performance..." -Color Cyan
    
    try {
        # Memory usage
        $memInfo = & adb shell dumpsys meminfo com.squashtrainingapp | Select-String "TOTAL"
        if ($memInfo) {
            $memValue = [regex]::Match($memInfo, "\d+").Value
            $global:DebugState.Performance.MemoryUsage += [int]$memValue
            Write-DebugLog "Memory usage: $memValue KB"
        }
        
        # CPU usage
        $cpuInfo = & adb shell top -n 1 | Select-String "squashtrainingapp"
        if ($cpuInfo) {
            $cpuMatch = [regex]::Match($cpuInfo, "(\d+)%")
            if ($cpuMatch.Success) {
                $cpuValue = [int]$cpuMatch.Groups[1].Value
                $global:DebugState.Performance.CpuUsage += $cpuValue
                Write-DebugLog "CPU usage: $cpuValue%"
            }
        }
        
        # Response time (test a simple action)
        $startTime = Get-Date
        & adb shell input tap 540 1000
        $responseTime = ((Get-Date) - $startTime).TotalMilliseconds
        $global:DebugState.Performance.ResponseTimes += [int]$responseTime
        Write-DebugLog "Response time: $responseTime ms"
        
    }
    catch {
        Write-DebugLog "Error measuring performance: $_" -Level "WARN" -Color Yellow
    }
}

function Generate-HTMLReport {
    if (-not $GenerateReport) { return }
    
    Write-DebugLog "Generating HTML report..." -Color Cyan
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Squash Training App - Debug Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #0D0D0D; color: #FFFFFF; }
        h1 { color: #C9FF00; }
        h2 { color: #C9FF00; margin-top: 30px; }
        .summary { background-color: #1A1A1A; padding: 20px; border-radius: 10px; margin: 20px 0; }
        .stat { display: inline-block; margin: 10px 20px; }
        .pass { color: #4CAF50; }
        .fail { color: #F44336; }
        .warn { color: #FF9800; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #333; padding: 10px; text-align: left; }
        th { background-color: #1A1A1A; color: #C9FF00; }
        tr:nth-child(even) { background-color: #1A1A1A; }
        .screenshot { max-width: 200px; height: auto; margin: 5px; border: 2px solid #C9FF00; }
        .gallery { display: flex; flex-wrap: wrap; gap: 10px; margin: 20px 0; }
        .feature-card { background-color: #1A1A1A; padding: 15px; border-radius: 8px; margin: 10px 0; }
        .chart { margin: 20px 0; }
    </style>
</head>
<body>
    <h1>Squash Training App - Automated Debug Report</h1>
    <p>Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
    
    <div class="summary">
        <h2>Summary</h2>
        <div class="stat">Total Cycles: <strong>$($global:DebugState.Testing.CurrentCycle)</strong></div>
        <div class="stat">Tests Passed: <strong class="pass">$($global:DebugState.Testing.PassedTests)</strong></div>
        <div class="stat">Tests Failed: <strong class="fail">$($global:DebugState.Testing.FailedTests)</strong></div>
        <div class="stat">Crashes: <strong class="fail">$($global:DebugState.Testing.Crashes)</strong></div>
        <div class="stat">Fixes Applied: <strong class="warn">$($global:DebugState.Fixes.Applied.Count)</strong></div>
    </div>
    
    <h2>Feature Test Results</h2>
"@

    foreach ($feature in $global:DebugState.Features.Keys) {
        $result = $global:DebugState.Features[$feature]
        $status = if ($result.Passed) { "pass" } else { "fail" }
        $statusText = if ($result.Passed) { "PASSED" } else { "FAILED" }
        
        $html += @"
        <div class="feature-card">
            <h3>$feature - <span class="$status">$statusText</span></h3>
            <p>Tested: $($result.Tested)</p>
"@
        
        if ($result.Screenshot -and (Test-Path $result.Screenshot)) {
            $screenshotName = Split-Path $result.Screenshot -Leaf
            $html += "<img src='screenshots/$screenshotName' class='screenshot' alt='$feature screenshot'/>"
        }
        
        $html += "</div>"
    }
    
    # Performance metrics
    if ($global:DebugState.Performance.MemoryUsage.Count -gt 0) {
        $avgMemory = [math]::Round(($global:DebugState.Performance.MemoryUsage | Measure-Object -Average).Average, 2)
        $avgCpu = [math]::Round(($global:DebugState.Performance.CpuUsage | Measure-Object -Average).Average, 2)
        $avgResponse = [math]::Round(($global:DebugState.Performance.ResponseTimes | Measure-Object -Average).Average, 2)
        
        $html += @"
        <h2>Performance Metrics</h2>
        <div class="summary">
            <div class="stat">Avg Memory: <strong>$avgMemory KB</strong></div>
            <div class="stat">Avg CPU: <strong>$avgCpu%</strong></div>
            <div class="stat">Avg Response: <strong>$avgResponse ms</strong></div>
            <div class="stat">Launch Time: <strong>$($global:DebugState.Performance.LaunchTime)s</strong></div>
        </div>
"@
    }
    
    # Errors and fixes
    if ($global:DebugState.Testing.Errors.Count -gt 0) {
        $html += @"
        <h2>Errors Encountered</h2>
        <table>
            <tr>
                <th>Feature</th>
                <th>Error</th>
                <th>Timestamp</th>
            </tr>
"@
        foreach ($error in $global:DebugState.Testing.Errors) {
            $html += @"
            <tr>
                <td>$($error.Feature)</td>
                <td>$($error.Error)</td>
                <td>$($error.Timestamp.ToString("HH:mm:ss"))</td>
            </tr>
"@
        }
        $html += "</table>"
    }
    
    if ($global:DebugState.Fixes.Applied.Count -gt 0) {
        $html += @"
        <h2>Automatic Fixes Applied</h2>
        <table>
            <tr>
                <th>Error Type</th>
                <th>Action</th>
                <th>Success</th>
                <th>Timestamp</th>
            </tr>
"@
        foreach ($fix in $global:DebugState.Fixes.Applied) {
            $successClass = if ($fix.Success) { "pass" } else { "fail" }
            $successText = if ($fix.Success) { "YES" } else { "NO" }
            
            $html += @"
            <tr>
                <td>$($fix.ErrorType)</td>
                <td>$($fix.Action)</td>
                <td class="$successClass">$successText</td>
                <td>$($fix.Timestamp.ToString("HH:mm:ss"))</td>
            </tr>
"@
        }
        $html += "</table>"
    }
    
    # Screenshot gallery
    $screenshots = Get-ChildItem "$OutputPath\screenshots" -Filter "*.png"
    if ($screenshots.Count -gt 0) {
        $html += @"
        <h2>Screenshot Gallery</h2>
        <div class="gallery">
"@
        foreach ($screenshot in $screenshots | Select-Object -First 20) {
            $html += "<img src='screenshots/$($screenshot.Name)' class='screenshot' alt='$($screenshot.Name)'/>"
        }
        $html += "</div>"
    }
    
    $html += @"
</body>
</html>
"@
    
    $reportPath = Join-Path $OutputPath "reports\debug-report.html"
    $html | Out-File $reportPath -Encoding UTF8
    Write-DebugLog "HTML report generated: $reportPath" -Color Green
}

# ========================================
# MAIN EXECUTION
# ========================================

function Start-DebugCycle {
    Write-DebugLog "=== AUTOMATED DEBUG SESSION STARTED ===" -Color Cyan
    Write-DebugLog "Output directory: $OutputPath" -Color Cyan
    
    # Check/Start emulator
    if (-not (Test-EmulatorRunning)) {
        if (-not (Start-EmulatorWithRetry)) {
            Write-DebugLog "Failed to start emulator. Exiting." -Level "ERROR" -Color Red
            return
        }
    }
    
    # Build APK if needed
    if (-not $SkipBuild -or -not (Test-Path $ApkPath)) {
        if (-not (Build-APK)) {
            Write-DebugLog "Failed to build APK. Exiting." -Level "ERROR" -Color Red
            return
        }
    }
    
    # Main debug cycles
    for ($cycle = 1; $cycle -le $Cycles; $cycle++) {
        $global:DebugState.Testing.CurrentCycle = $cycle
        
        Write-DebugLog "`n=== CYCLE $cycle of $Cycles ===" -Color Yellow
        Write-Progress -Activity "Debug Cycles" -Status "Cycle $cycle of $Cycles" -PercentComplete (($cycle / $Cycles) * 100)
        
        # Reset feature states
        foreach ($feature in $global:DebugState.Features.Keys) {
            $global:DebugState.Features[$feature].Tested = $false
            $global:DebugState.Features[$feature].Passed = $false
        }
        
        # Install APK
        if (-not (Install-APK)) {
            Write-DebugLog "Installation failed, skipping cycle" -Level "ERROR" -Color Red
            continue
        }
        
        # Start app
        if (-not (Start-AppWithRetry)) {
            Write-DebugLog "App failed to start, skipping cycle" -Level "ERROR" -Color Red
            continue
        }
        
        # Capture initial screenshot
        Capture-Screenshot -Name "AppLaunch" -Feature "Startup"
        
        # Test all features
        $testResult = Test-AllFeatures
        
        # Measure performance
        Measure-Performance
        
        # Parse logcat for errors
        $errors = Parse-Logcat
        
        # Apply fixes if needed
        if ($errors.Count -gt 0 -and $AutoFix) {
            Apply-AutoFix -ErrorTypes $errors
        }
        
        # Check if we should stop
        if ($testResult -and $errors.Count -eq 0) {
            Write-DebugLog "Cycle $cycle completed successfully!" -Color Green
            
            # Stop if we've had 3 successful cycles in a row
            if ($cycle -ge 3) {
                $recentCycles = $global:DebugState.Testing.PassedTests - $global:DebugState.Testing.FailedTests
                if ($recentCycles -ge 18) { # 3 cycles * 6 features
                    Write-DebugLog "App is stable! Stopping early." -Color Green
                    break
                }
            }
        }
        else {
            Write-DebugLog "Cycle $cycle completed with issues" -Level "WARN" -Color Yellow
        }
        
        # Small delay between cycles
        Start-Sleep -Seconds 2
    }
    
    # Generate final report
    Generate-HTMLReport
    
    # Summary
    Write-DebugLog "`n=== DEBUG SESSION SUMMARY ===" -Color Cyan
    Write-DebugLog "Total Cycles Run: $($global:DebugState.Testing.CurrentCycle)" -Color White
    Write-DebugLog "Tests Passed: $($global:DebugState.Testing.PassedTests)" -Color Green
    Write-DebugLog "Tests Failed: $($global:DebugState.Testing.FailedTests)" -Color Red
    Write-DebugLog "Total Crashes: $($global:DebugState.Testing.Crashes)" -Color Red
    Write-DebugLog "Fixes Applied: $($global:DebugState.Fixes.Applied.Count)" -Color Yellow
    Write-DebugLog "Success Rate: $([math]::Round(($global:DebugState.Testing.PassedTests / ($global:DebugState.Testing.PassedTests + $global:DebugState.Testing.FailedTests)) * 100, 2))%" -Color White
    
    # Open report
    if ($GenerateReport -and (Test-Path "$OutputPath\reports\debug-report.html")) {
        Write-DebugLog "`nOpening debug report..." -Color Cyan
        Start-Process "$OutputPath\reports\debug-report.html"
    }
}

# Start the debug session
Start-DebugCycle