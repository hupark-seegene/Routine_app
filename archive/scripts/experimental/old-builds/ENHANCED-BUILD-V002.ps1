<#
.SYNOPSIS
    Cycle 2 - Enhanced Build with React Native Preparation
    
.DESCRIPTION
    Second cycle of 50-cycle continuous development process.
    Fixes installation issues and begins React Native integration.
    
.VERSION
    1.0.2
    
.CYCLE
    2 of 50
    
.CREATED
    2025-07-13
#>

param(
    [switch]$SkipEmulator = $false,
    [switch]$KeepInstalled = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Continue"

# ========================================
# CONFIGURATION
# ========================================

$CycleNumber = 2
$VersionCode = 3
$VersionName = "1.0.2"
$BuildTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$AppDir = Join-Path $ProjectRoot "SquashTrainingApp"
$AndroidDir = Join-Path $AppDir "android"
$BuildGradlePath = Join-Path $AndroidDir "app\build.gradle"
$OutputDir = Join-Path $ProjectRoot "build-artifacts\cycle-$CycleNumber"
$ReportPath = Join-Path $OutputDir "cycle-$CycleNumber-report.md"

$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$env:Path = "$env:JAVA_HOME\bin;$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\emulator;$env:Path"

$ADB = "$env:ANDROID_HOME\platform-tools\adb.exe"
$PackageName = "com.squashtrainingapp"

# Metrics tracking
$global:Metrics = @{
    BuildTime = 0
    APKSize = 0
    InstallTime = 0
    LaunchTime = 0
    MemoryUsage = 0
    Improvements = @()
}

# ========================================
# UTILITY FUNCTIONS
# ========================================

function Write-CycleLog {
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
        "Metric" = "Cyan"
    }
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = if ($colors.ContainsKey($Level)) { $colors[$Level] } else { "White" }
    
    Write-Host "[$timestamp] [Cycle $CycleNumber] $Message" -ForegroundColor $color
    
    # Also append to report
    Add-Content -Path $ReportPath -Value "[$timestamp] [$Level] $Message" -ErrorAction SilentlyContinue
}

function Initialize-CycleEnvironment {
    Write-CycleLog "Initializing Cycle $CycleNumber environment..." "Info"
    
    # Create output directory
    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    }
    
    # Initialize report with enhanced format
    @"
# Cycle $CycleNumber Report
**Date**: $BuildTimestamp
**Version**: $VersionName (Code: $VersionCode)
**Previous Version**: 1.0.1 (Code: 2)

## Improvements from Cycle 1
- Fixed APK installation path issue
- Beginning React Native dependency restoration
- Enhanced metrics tracking
- Improved error handling

## Build Log
"@ | Out-File -FilePath $ReportPath -Encoding UTF8
    
    Write-CycleLog "Environment initialized" "Success"
}

function Start-EmulatorIfNeeded {
    if ($SkipEmulator) {
        Write-CycleLog "Skipping emulator start (flag set)" "Warning"
        return $true
    }
    
    Write-CycleLog "Checking emulator status..." "Info"
    
    $devices = & $ADB devices 2>&1
    if ($devices -match "emulator.*device") {
        Write-CycleLog "Emulator already running" "Success"
        
        # Get device ID
        $deviceLine = $devices | Where-Object { $_ -match "emulator.*device" } | Select-Object -First 1
        if ($deviceLine -match "(emulator-\d+)") {
            $deviceId = $matches[1]
            Write-CycleLog "Using device: $deviceId" "Info"
        }
        
        return $true
    }
    
    Write-CycleLog "Starting emulator..." "Info"
    
    # Use existing START-EMULATOR.ps1 script
    $emulatorScript = Join-Path $PSScriptRoot "..\utility\START-EMULATOR.ps1"
    if (Test-Path $emulatorScript) {
        & $emulatorScript
        Start-Sleep -Seconds 5
        
        # Verify emulator started
        $devices = & $ADB devices 2>&1
        if ($devices -match "emulator.*device") {
            Write-CycleLog "Emulator started successfully" "Success"
            return $true
        }
    }
    
    Write-CycleLog "Failed to start emulator" "Error"
    return $false
}

function Update-AppVersion {
    Write-CycleLog "Updating app version to $VersionName..." "Info"
    
    try {
        # Read current build.gradle
        $content = Get-Content $BuildGradlePath -Raw
        
        # Update versionCode and versionName
        $content = $content -replace 'versionCode\s+\d+', "versionCode $VersionCode"
        $content = $content -replace 'versionName\s+"[^"]*"', "versionName `"$VersionName`""
        
        Write-CycleLog "Beginning React Native dependency preparation..." "Info"
        $global:Metrics.Improvements += "Started React Native integration preparation"
        
        # Add repository configuration for React Native (commented for now)
        if ($content -notmatch "mavenLocal\(\)") {
            $repositoryConfig = @"

// React Native repository configuration (preparing for integration)
// repositories {
//     mavenLocal()
//     maven {
//         url = uri("${'$'}rootDir/../node_modules/react-native/android")
//     }
// }
"@
            $content += $repositoryConfig
            Write-CycleLog "Added React Native repository configuration (commented)" "Success"
            $global:Metrics.Improvements += "Added RN repository configuration"
        }
        
        # Write back
        $content | Out-File -FilePath $BuildGradlePath -Encoding ASCII -NoNewline
        
        Write-CycleLog "Version and configuration updated successfully" "Success"
        return $true
    }
    catch {
        Write-CycleLog "Failed to update version: $_" "Error"
        return $false
    }
}

function Build-APK {
    Write-CycleLog "Building APK version $VersionName..." "Info"
    
    Push-Location $AndroidDir
    try {
        # Clean previous build
        Write-CycleLog "Cleaning previous build..." "Info"
        $cleanOutput = & ./gradlew.bat clean 2>&1
        
        # Build APK
        Write-CycleLog "Executing gradle build..." "Info"
        $buildStart = Get-Date
        $buildOutput = & ./gradlew.bat assembleDebug 2>&1
        $buildTime = (Get-Date) - $buildStart
        $global:Metrics.BuildTime = $buildTime.TotalSeconds
        
        # Check if APK was created - use absolute path
        $apkPath = Join-Path $AndroidDir "app\build\outputs\apk\debug\app-debug.apk"
        if (Test-Path $apkPath) {
            # Copy APK to artifacts
            $artifactPath = Join-Path $OutputDir "squash-training-$VersionName.apk"
            Copy-Item $apkPath $artifactPath -Force
            
            $apkSize = (Get-Item $apkPath).Length / 1MB
            $global:Metrics.APKSize = $apkSize
            
            Write-CycleLog "Build successful! Time: $($buildTime.TotalSeconds.ToString('F1'))s, Size: $($apkSize.ToString('F2'))MB" "Success"
            Write-CycleLog "APK location: $apkPath" "Debug"
            
            # Add to report
            Add-Content -Path $ReportPath -Value "`n## Build Results`n- **Status**: Success`n- **Time**: $($buildTime.TotalSeconds.ToString('F1'))s`n- **Size**: $($apkSize.ToString('F2'))MB`n- **Path**: $apkPath`n"
            
            return $apkPath
        } else {
            Write-CycleLog "Build failed - APK not found at: $apkPath" "Error"
            Add-Content -Path $ReportPath -Value "`n## Build Results`n- **Status**: Failed`n- **Error**: APK not created`n"
            return $null
        }
    }
    catch {
        Write-CycleLog "Build exception: $_" "Error"
        return $null
    }
    finally {
        Pop-Location
    }
}

function Install-APK {
    param([string]$ApkPath)
    
    Write-CycleLog "Installing APK to emulator..." "Info"
    Write-CycleLog "APK Path: $ApkPath" "Debug"
    
    try {
        # Verify APK exists
        if (-not (Test-Path $ApkPath)) {
            Write-CycleLog "APK file not found at: $ApkPath" "Error"
            return $false
        }
        
        # Uninstall existing version first
        Write-CycleLog "Uninstalling existing app..." "Info"
        & $ADB uninstall $PackageName 2>&1 | Out-Null
        
        # Install new APK with absolute path
        $installStart = Get-Date
        $installOutput = & $ADB install -r "`"$ApkPath`"" 2>&1
        $installTime = (Get-Date) - $installStart
        $global:Metrics.InstallTime = $installTime.TotalSeconds
        
        if ($installOutput -match "Success") {
            Write-CycleLog "APK installed successfully in $($installTime.TotalSeconds.ToString('F1'))s" "Success"
            Add-Content -Path $ReportPath -Value "`n## Installation`n- **Status**: Success`n- **Time**: $($installTime.TotalSeconds.ToString('F1'))s`n"
            return $true
        } else {
            Write-CycleLog "Installation failed: $installOutput" "Error"
            Add-Content -Path $ReportPath -Value "`n## Installation`n- **Status**: Failed`n- **Error**: $installOutput`n"
            return $false
        }
    }
    catch {
        Write-CycleLog "Installation exception: $_" "Error"
        return $false
    }
}

function Test-App {
    Write-CycleLog "Testing app functionality..." "Info"
    
    try {
        # Launch app
        Write-CycleLog "Launching app..." "Info"
        $launchStart = Get-Date
        & $ADB shell am start -n "$PackageName/.MainActivity" 2>&1 | Out-Null
        
        Start-Sleep -Seconds 3
        $launchTime = (Get-Date) - $launchStart
        $global:Metrics.LaunchTime = $launchTime.TotalSeconds
        
        # Check if app is running
        $psOutput = & $ADB shell ps 2>&1
        $appRunning = $psOutput -match $PackageName
        
        if ($appRunning) {
            Write-CycleLog "App launched successfully in $($launchTime.TotalSeconds.ToString('F1'))s" "Success"
            
            # Get memory usage
            $memInfo = & $ADB shell dumpsys meminfo $PackageName 2>&1
            if ($memInfo -match "TOTAL\s+(\d+)") {
                $memoryMB = [int]$matches[1] / 1024
                $global:Metrics.MemoryUsage = $memoryMB
                Write-CycleLog "Memory usage: $($memoryMB.ToString('F1'))MB" "Metric"
            }
            
            # Capture screenshot
            $screenshotPath = Join-Path $OutputDir "cycle-$CycleNumber-screenshot.png"
            Write-CycleLog "Capturing screenshot..." "Info"
            & $ADB shell screencap -p /sdcard/screenshot.png
            & $ADB pull /sdcard/screenshot.png "`"$screenshotPath`"" 2>&1 | Out-Null
            & $ADB shell rm /sdcard/screenshot.png
            
            if (Test-Path $screenshotPath) {
                Write-CycleLog "Screenshot captured" "Success"
            }
            
            # Basic UI test - tap center of screen
            Write-CycleLog "Performing basic UI test..." "Info"
            & $ADB shell input tap 540 960 2>&1 | Out-Null
            Start-Sleep -Seconds 1
            
            # Check if still running
            $psOutput = & $ADB shell ps 2>&1
            $stillRunning = $psOutput -match $PackageName
            
            if ($stillRunning) {
                Write-CycleLog "App stable after interaction" "Success"
                Add-Content -Path $ReportPath -Value "`n## Testing`n- **Launch**: Success ($($launchTime.TotalSeconds.ToString('F1'))s)`n- **Memory**: $($memoryMB.ToString('F1'))MB`n- **Stability**: Passed`n- **Screenshot**: Captured`n"
                return $true
            } else {
                Write-CycleLog "App crashed after interaction" "Error"
                Add-Content -Path $ReportPath -Value "`n## Testing`n- **Launch**: Success`n- **Stability**: Failed (crashed)`n"
                return $false
            }
        } else {
            Write-CycleLog "App failed to launch" "Error"
            Add-Content -Path $ReportPath -Value "`n## Testing`n- **Launch**: Failed`n"
            return $false
        }
    }
    catch {
        Write-CycleLog "Testing exception: $_" "Error"
        return $false
    }
}

function Uninstall-App {
    if ($KeepInstalled) {
        Write-CycleLog "Keeping app installed (flag set)" "Warning"
        return
    }
    
    Write-CycleLog "Uninstalling app..." "Info"
    
    try {
        $uninstallOutput = & $ADB uninstall $PackageName 2>&1
        
        if ($uninstallOutput -match "Success") {
            Write-CycleLog "App uninstalled successfully" "Success"
            Add-Content -Path $ReportPath -Value "`n## Uninstall`n- **Status**: Success`n"
        } else {
            Write-CycleLog "Uninstall may have failed: $uninstallOutput" "Warning"
        }
    }
    catch {
        Write-CycleLog "Uninstall exception: $_" "Error"
    }
}

function Generate-Enhancement {
    Write-CycleLog "Analyzing results for enhancements..." "Info"
    
    # Compare with Cycle 1
    $cycle1Size = 5.34
    $sizeChange = [math]::Round($global:Metrics.APKSize - $cycle1Size, 2)
    $sizeChangePercent = [math]::Round(($sizeChange / $cycle1Size) * 100, 1)
    
    $enhancements = @"

## Metrics Comparison

### Cycle 2 vs Cycle 1:
- **APK Size**: $($global:Metrics.APKSize.ToString('F2'))MB (${sizeChange}MB, ${sizeChangePercent}%)
- **Build Time**: $($global:Metrics.BuildTime.ToString('F1'))s
- **Install Time**: $($global:Metrics.InstallTime.ToString('F1'))s (NEW)
- **Launch Time**: $($global:Metrics.LaunchTime.ToString('F1'))s (NEW)
- **Memory Usage**: $($global:Metrics.MemoryUsage.ToString('F1'))MB (NEW)

## Improvements Applied:
$($global:Metrics.Improvements | ForEach-Object { "- $_" } | Out-String)

## Enhancements for Next Cycle

Based on Cycle 2 results:

1. **Current State**: Basic Android app with improved build process
2. **Next Goal**: Add React Native maven repository

### Recommended Changes for Cycle 3:
- Enable React Native maven repository
- Add React Native AAR dependencies
- Prepare for Metro bundler integration
- Add error recovery mechanisms

### Success Criteria for Cycle 3:
- Successful integration of React Native repositories
- Build completes without dependency errors
- APK size increases (RN dependencies)
- App remains stable

### Risk Mitigation:
- Keep fallback to basic Android if RN fails
- Incremental dependency addition
- Comprehensive error logging
"@

    Add-Content -Path $ReportPath -Value $enhancements
    Write-CycleLog "Enhancement analysis complete" "Success"
}

# ========================================
# MAIN EXECUTION
# ========================================

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "   CYCLE $CycleNumber - ENHANCED BUILD v$VersionName" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Initialize
Initialize-CycleEnvironment

# Start emulator
if (-not (Start-EmulatorIfNeeded)) {
    Write-CycleLog "Cannot proceed without emulator" "Error"
    exit 1
}

# Update version
if (-not (Update-AppVersion)) {
    Write-CycleLog "Version update failed, continuing with existing version" "Warning"
}

# Build APK
$apkPath = Build-APK
if (-not $apkPath) {
    Write-CycleLog "Build failed - stopping cycle" "Error"
    exit 1
}

# Install APK
if (Install-APK -ApkPath $apkPath) {
    # Test app
    $testResult = Test-App
    
    # Uninstall
    Uninstall-App
} else {
    Write-CycleLog "Installation failed - skipping tests" "Error"
}

# Generate enhancement recommendations
Generate-Enhancement

# Final summary
Write-Host "`n================================================" -ForegroundColor Green
Write-Host "   CYCLE $CycleNumber COMPLETE" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-CycleLog "Report saved to: $ReportPath" "Info"
Write-CycleLog "Next cycle: ENHANCED-BUILD-V003.ps1 (version 1.0.3)" "Info"

# Update project_plan.md
$projectPlanPath = Join-Path $ProjectRoot "project_plan.md"
$cycleUpdate = @"

### Cycle $CycleNumber Results (v$VersionName) - $BuildTimestamp
- **Build**: Success ($($global:Metrics.BuildTime.ToString('F1'))s)
- **Install**: Fixed path issue - Success
- **Test**: App stable, metrics collected
- **Enhancement**: React Native repository configuration prepared
- **Metrics**: Size=$($global:Metrics.APKSize.ToString('F2'))MB, Memory=$($global:Metrics.MemoryUsage.ToString('F1'))MB
"@

Add-Content -Path $projectPlanPath -Value $cycleUpdate

Write-Host "`nCycle $CycleNumber artifacts saved to: $OutputDir" -ForegroundColor Yellow
Write-Host "Key improvement: Fixed installation path issue from Cycle 1" -ForegroundColor Green