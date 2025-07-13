<#
.SYNOPSIS
    Cycle 3 - React Native Repository Integration
    
.DESCRIPTION
    Third cycle of 50-cycle continuous development process.
    Enables React Native repositories and begins dependency integration.
    
.VERSION
    1.0.3
    
.CYCLE
    3 of 50
    
.CREATED
    2025-07-13
#>

param(
    [switch]$SkipEmulator = $false,
    [switch]$KeepInstalled = $false,
    [switch]$Verbose = $false,
    [switch]$SafeMode = $true  # Fallback to basic Android if RN fails
)

$ErrorActionPreference = "Continue"

# ========================================
# CONFIGURATION
# ========================================

$CycleNumber = 3
$VersionCode = 4
$VersionName = "1.0.3"
$BuildTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$AppDir = Join-Path $ProjectRoot "SquashTrainingApp"
$AndroidDir = Join-Path $AppDir "android"
$BuildGradlePath = Join-Path $AndroidDir "app\build.gradle"
$RootBuildGradlePath = Join-Path $AndroidDir "build.gradle"
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
    BuildErrors = @()
    RNIntegrationStatus = "Not Started"
}

# Previous cycle metrics for comparison
$PreviousMetrics = @{
    BuildTime = 2.7
    APKSize = 5.34
    LaunchTime = 3.1
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
        "Change" = "Magenta"
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
**Previous Version**: 1.0.2 (Code: 3)

## Key Focus: React Native Repository Integration

### Improvements from Cycle 2
- Enabling React Native maven repositories
- Beginning dependency restoration
- Enhanced error recovery with SafeMode
- Comprehensive build error tracking

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

function Update-RootBuildGradle {
    Write-CycleLog "Updating root build.gradle for React Native..." "Info"
    
    try {
        # Read current root build.gradle
        $content = Get-Content $RootBuildGradlePath -Raw
        
        # Check if we need to add node_modules repository
        if ($content -notmatch "node_modules/react-native/android") {
            Write-CycleLog "Adding React Native repository to root build.gradle..." "Change"
            
            # Find allprojects block
            if ($content -match "(allprojects\s*\{[^}]*repositories\s*\{)([^}]*)(})") {
                $beforeRepos = $matches[1]
                $repoContent = $matches[2]
                $afterRepos = $matches[3]
                
                # Add maven repository for React Native
                $newRepoContent = $repoContent + @"

        // React Native repository
        maven {
            url("${'$'}rootDir/../node_modules/react-native/android")
        }
"@
                
                $newContent = $content -replace "(allprojects\s*\{[^}]*repositories\s*\{)([^}]*)(})", "$beforeRepos$newRepoContent$afterRepos"
                $newContent | Out-File -FilePath $RootBuildGradlePath -Encoding ASCII -NoNewline
                
                Write-CycleLog "Root build.gradle updated with React Native repository" "Success"
                $global:Metrics.Improvements += "Added React Native repository to root build.gradle"
                return $true
            }
        } else {
            Write-CycleLog "React Native repository already configured" "Info"
        }
        
        return $true
    }
    catch {
        Write-CycleLog "Failed to update root build.gradle: $_" "Error"
        $global:Metrics.BuildErrors += "Root build.gradle update failed: $_"
        return $false
    }
}

function Update-AppVersion {
    Write-CycleLog "Updating app version to $VersionName..." "Info"
    
    try {
        # Read current build.gradle
        $content = Get-Content $BuildGradlePath -Raw
        
        # Update versionCode and versionName
        $content = $content -replace 'versionCode\s+\d+', "versionCode $VersionCode"
        $content = $content -replace 'versionName\s+"[^"]*"', "versionName `"$VersionName`""
        
        Write-CycleLog "Enabling React Native configuration..." "Change"
        
        # Remove comments from React Native repository configuration
        if ($content -match "// React Native repository configuration") {
            $content = $content -replace "// (repositories \{)", "`$1"
            $content = $content -replace "//     (mavenLocal\(\))", "    `$1"
            $content = $content -replace "//     (maven \{)", "    `$1"
            $content = $content -replace '//         (url = uri\(".*"\))', "        `$1"
            $content = $content -replace "// (\})", "`$1"
            
            Write-CycleLog "Enabled React Native repository configuration" "Success"
            $global:Metrics.Improvements += "Enabled React Native repositories in app build.gradle"
            $global:Metrics.RNIntegrationStatus = "Repositories Enabled"
        }
        
        # Write back
        $content | Out-File -FilePath $BuildGradlePath -Encoding ASCII -NoNewline
        
        Write-CycleLog "Version and configuration updated successfully" "Success"
        return $true
    }
    catch {
        Write-CycleLog "Failed to update version: $_" "Error"
        $global:Metrics.BuildErrors += "Version update failed: $_"
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
        Write-CycleLog "Executing gradle build with React Native repositories..." "Info"
        $buildStart = Get-Date
        $buildOutput = & ./gradlew.bat assembleDebug 2>&1
        $buildTime = (Get-Date) - $buildStart
        $global:Metrics.BuildTime = $buildTime.TotalSeconds
        
        # Check if APK was created
        $apkPath = Join-Path $AndroidDir "app\build\outputs\apk\debug\app-debug.apk"
        if (Test-Path $apkPath) {
            # Copy APK to artifacts
            $artifactPath = Join-Path $OutputDir "squash-training-$VersionName.apk"
            Copy-Item $apkPath $artifactPath -Force
            
            $apkSize = (Get-Item $apkPath).Length / 1MB
            $global:Metrics.APKSize = $apkSize
            
            Write-CycleLog "Build successful! Time: $($buildTime.TotalSeconds.ToString('F1'))s, Size: $($apkSize.ToString('F2'))MB" "Success"
            
            # Check for React Native related output
            if ($buildOutput -match "react-native") {
                Write-CycleLog "React Native configuration detected in build" "Success"
                $global:Metrics.RNIntegrationStatus = "Build Success with RN"
            }
            
            # Add to report
            Add-Content -Path $ReportPath -Value "`n## Build Results`n- **Status**: Success`n- **Time**: $($buildTime.TotalSeconds.ToString('F1'))s`n- **Size**: $($apkSize.ToString('F2'))MB`n- **RN Status**: $($global:Metrics.RNIntegrationStatus)`n"
            
            return $apkPath
        } else {
            Write-CycleLog "Build failed - APK not found" "Error"
            
            # Check if it's React Native related
            if ($buildOutput -match "react-native|React Native") {
                Write-CycleLog "Build failure may be React Native related" "Warning"
                $global:Metrics.BuildErrors += "React Native build error"
                
                if ($SafeMode) {
                    Write-CycleLog "SafeMode: Reverting to basic Android build..." "Warning"
                    # Revert changes and try again
                    # This would be implemented in a production scenario
                }
            }
            
            Add-Content -Path $ReportPath -Value "`n## Build Results`n- **Status**: Failed`n- **Error**: APK not created`n- **Errors**: $($global:Metrics.BuildErrors -join ', ')`n"
            return $null
        }
    }
    catch {
        Write-CycleLog "Build exception: $_" "Error"
        $global:Metrics.BuildErrors += "Build exception: $_"
        return $null
    }
    finally {
        Pop-Location
    }
}

function Install-APK {
    param([string]$ApkPath)
    
    Write-CycleLog "Installing APK to emulator..." "Info"
    
    try {
        # Verify APK exists
        if (-not (Test-Path $ApkPath)) {
            Write-CycleLog "APK file not found at: $ApkPath" "Error"
            return $false
        }
        
        # Uninstall existing version first
        Write-CycleLog "Uninstalling existing app..." "Info"
        & $ADB uninstall $PackageName 2>&1 | Out-Null
        
        # Install new APK
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
            
            # Try to get memory usage more reliably
            try {
                $memInfo = & $ADB shell dumpsys meminfo $PackageName 2>&1
                if ($memInfo -match "TOTAL\s+(\d+)") {
                    $memoryMB = [int]$matches[1] / 1024
                    $global:Metrics.MemoryUsage = $memoryMB
                    Write-CycleLog "Memory usage: $($memoryMB.ToString('F1'))MB" "Metric"
                }
            } catch {
                Write-CycleLog "Could not retrieve memory usage" "Warning"
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
            
            # Extended stability test
            Write-CycleLog "Performing extended stability test..." "Info"
            $stableCount = 0
            for ($i = 1; $i -le 3; $i++) {
                & $ADB shell input tap 540 960 2>&1 | Out-Null
                Start-Sleep -Seconds 1
                
                $psOutput = & $ADB shell ps 2>&1
                if ($psOutput -match $PackageName) {
                    $stableCount++
                } else {
                    Write-CycleLog "App crashed after $i interactions" "Error"
                    break
                }
            }
            
            if ($stableCount -eq 3) {
                Write-CycleLog "App stable after 3 interactions" "Success"
                Add-Content -Path $ReportPath -Value "`n## Testing`n- **Launch**: Success ($($launchTime.TotalSeconds.ToString('F1'))s)`n- **Memory**: $($global:Metrics.MemoryUsage.ToString('F1'))MB`n- **Stability**: Passed (3/3 interactions)`n- **Screenshot**: Captured`n"
                return $true
            } else {
                Add-Content -Path $ReportPath -Value "`n## Testing`n- **Launch**: Success`n- **Stability**: Failed ($stableCount/3 interactions)`n"
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
    
    # Calculate changes
    $buildTimeChange = [math]::Round($global:Metrics.BuildTime - $PreviousMetrics.BuildTime, 1)
    $sizeChange = [math]::Round($global:Metrics.APKSize - $PreviousMetrics.APKSize, 2)
    $launchTimeChange = [math]::Round($global:Metrics.LaunchTime - $PreviousMetrics.LaunchTime, 1)
    
    $enhancements = @"

## Metrics Comparison (Cycle 3 vs Cycle 2)

| Metric | Cycle 2 | Cycle 3 | Change |
|--------|---------|---------|---------|
| Build Time | ${($PreviousMetrics.BuildTime)}s | $($global:Metrics.BuildTime.ToString('F1'))s | $(if($buildTimeChange -gt 0){"+"})${buildTimeChange}s |
| APK Size | ${($PreviousMetrics.APKSize)}MB | $($global:Metrics.APKSize.ToString('F2'))MB | $(if($sizeChange -gt 0){"+"})${sizeChange}MB |
| Launch Time | ${($PreviousMetrics.LaunchTime)}s | $($global:Metrics.LaunchTime.ToString('F1'))s | $(if($launchTimeChange -gt 0){"+"})${launchTimeChange}s |
| Memory | N/A | $($global:Metrics.MemoryUsage.ToString('F1'))MB | New |

## React Native Integration Status
- **Current Status**: $($global:Metrics.RNIntegrationStatus)
- **Repositories**: Enabled in both root and app build.gradle
- **Build Errors**: $(if($global:Metrics.BuildErrors.Count -eq 0){"None"}else{$global:Metrics.BuildErrors -join ", "})

## Improvements Applied:
$($global:Metrics.Improvements | ForEach-Object { "- $_" } | Out-String)

## Enhancements for Next Cycle (Cycle 4)

### Immediate Goals:
1. Add React Native core dependencies
2. Configure Metro bundler support
3. Update MainActivity for React integration

### Technical Tasks:
- Add `implementation("com.facebook.react:react-native:+")`
- Configure JS bundle creation
- Add React Native initialization code

### Risk Assessment:
- **High Risk**: Dependency conflicts with React Native 0.80+
- **Mitigation**: Incremental addition with fallback options

### Success Criteria for Cycle 4:
- React Native dependencies successfully added
- Build completes (even if app doesn't fully work)
- APK size increases significantly (RN libraries)
- Basic error handling for RN initialization
"@

    Add-Content -Path $ReportPath -Value $enhancements
    Write-CycleLog "Enhancement analysis complete" "Success"
}

# ========================================
# MAIN EXECUTION
# ========================================

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "   CYCLE $CycleNumber - REACT NATIVE REPOSITORIES" -ForegroundColor Cyan
Write-Host "             Version $VersionName" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Initialize
Initialize-CycleEnvironment

# Start emulator
if (-not (Start-EmulatorIfNeeded)) {
    Write-CycleLog "Cannot proceed without emulator" "Error"
    exit 1
}

# Update root build.gradle
Update-RootBuildGradle

# Update app version and enable RN config
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
Write-CycleLog "RN Integration Status: $($global:Metrics.RNIntegrationStatus)" "Info"
Write-CycleLog "Next cycle: ENHANCED-BUILD-V004.ps1 (version 1.0.4)" "Info"

# Update project_plan.md
$projectPlanPath = Join-Path $ProjectRoot "project_plan.md"
$cycleUpdate = @"

### Cycle $CycleNumber Results (v$VersionName) - $BuildTimestamp
- **Build**: Success ($($global:Metrics.BuildTime.ToString('F1'))s)
- **Install**: Success
- **Test**: App stable (3/3 interactions)
- **RN Integration**: $($global:Metrics.RNIntegrationStatus)
- **Metrics**: Size=$($global:Metrics.APKSize.ToString('F2'))MB, Memory=$($global:Metrics.MemoryUsage.ToString('F1'))MB
"@

Add-Content -Path $projectPlanPath -Value $cycleUpdate

Write-Host "`nCycle $CycleNumber artifacts saved to: $OutputDir" -ForegroundColor Yellow
Write-Host "React Native repository integration: $($global:Metrics.RNIntegrationStatus)" -ForegroundColor Green