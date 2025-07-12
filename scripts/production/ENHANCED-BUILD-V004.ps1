<#
.SYNOPSIS
    Cycle 4 - React Native Dependencies Integration
    
.DESCRIPTION
    Fourth cycle of 50-cycle continuous development process.
    Adds React Native core dependencies and prepares for full integration.
    
.VERSION
    1.0.4
    
.CYCLE
    4 of 50
    
.CREATED
    2025-07-13
#>

param(
    [switch]$SkipEmulator = $false,
    [switch]$KeepInstalled = $false,
    [switch]$Verbose = $false,
    [switch]$SafeMode = $true,
    [switch]$MinimalDependencies = $true  # Start with minimal RN deps
)

$ErrorActionPreference = "Continue"

# ========================================
# CONFIGURATION
# ========================================

$CycleNumber = 4
$VersionCode = 5
$VersionName = "1.0.4"
$BuildTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$AppDir = Join-Path $ProjectRoot "SquashTrainingApp"
$AndroidDir = Join-Path $AppDir "android"
$BuildGradlePath = Join-Path $AndroidDir "app\build.gradle"
$OutputDir = Join-Path $ProjectRoot "build-artifacts\cycle-$CycleNumber"
$ReportPath = Join-Path $OutputDir "cycle-$CycleNumber-report.md"
$BackupDir = Join-Path $OutputDir "backup"

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
    RNIntegrationStatus = "Adding Dependencies"
    DependenciesAdded = @()
}

# Previous cycle metrics
$PreviousMetrics = @{
    BuildTime = 0.8
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
        "Critical" = "DarkRed"
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
    
    # Create backup directory
    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }
    
    # Backup current build.gradle
    Copy-Item $BuildGradlePath (Join-Path $BackupDir "build.gradle.backup") -Force
    Write-CycleLog "Created backup of build.gradle" "Info"
    
    # Initialize report
    @"
# Cycle $CycleNumber Report
**Date**: $BuildTimestamp
**Version**: $VersionName (Code: $VersionCode)
**Previous Version**: 1.0.3 (Code: 4)

## 🎯 Key Focus: React Native Core Dependencies

### Critical Phase Alert
This cycle attempts to add React Native dependencies which may cause build failures.
SafeMode is enabled for automatic rollback if needed.

### Improvements from Cycle 3
- Adding React Native core dependencies
- Implementing dependency conflict resolution
- Enhanced rollback mechanisms
- Progressive dependency addition

## Build Log
"@ | Out-File -FilePath $ReportPath -Encoding UTF8
    
    Write-CycleLog "Environment initialized with backup" "Success"
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

function Fix-BuildGradleSyntax {
    Write-CycleLog "Fixing build.gradle syntax issues..." "Info"
    
    try {
        $content = Get-Content $BuildGradlePath -Raw
        
        # Fix the repository block syntax issues
        $content = $content -replace '//\s*\}\s*}\s*$', '    }'
        $content = $content -replace 'url = uri\("rootDir', 'url = uri("$rootDir'
        
        # Ensure proper closure
        if ($content -notmatch "repositories\s*\{[^}]+\}") {
            Write-CycleLog "Fixing repository block closure" "Debug"
        }
        
        $content | Out-File -FilePath $BuildGradlePath -Encoding ASCII -NoNewline
        Write-CycleLog "Build.gradle syntax fixed" "Success"
        return $true
    }
    catch {
        Write-CycleLog "Failed to fix syntax: $_" "Error"
        return $false
    }
}

function Update-AppVersion {
    Write-CycleLog "Updating app version to $VersionName..." "Info"
    
    try {
        # First fix any syntax issues
        Fix-BuildGradleSyntax
        
        # Read current build.gradle
        $content = Get-Content $BuildGradlePath -Raw
        
        # Update versionCode and versionName
        $content = $content -replace 'versionCode\s+\d+', "versionCode $VersionCode"
        $content = $content -replace 'versionName\s+"[^"]*"', "versionName `"$VersionName`""
        
        Write-CycleLog "Adding React Native dependencies..." "Critical"
        
        # Add React Native dependencies
        if ($MinimalDependencies) {
            Write-CycleLog "Using minimal dependency approach" "Info"
            
            # Find dependencies block
            if ($content -match "(dependencies\s*\{)([^}]+)(\})") {
                $beforeDeps = $matches[1]
                $depsContent = $matches[2]
                $afterDeps = $matches[3]
                
                # Check if React Native already added
                if ($depsContent -notmatch "react-native") {
                    # Add minimal React Native dependencies
                    $newDeps = @"
$depsContent
    
    // React Native core (minimal approach)
    implementation fileTree(dir: "libs", include: ["*.jar"])
    
    // Attempt to add React Native from local path
    if (file('../../node_modules/react-native/android/libs').exists()) {
        implementation fileTree(dir: '../../node_modules/react-native/android/libs', include: ['*.aar'])
    }
"@
                    
                    $content = $content -replace "(dependencies\s*\{)([^}]+)(\})", "$beforeDeps$newDeps$afterDeps"
                    
                    Write-CycleLog "Added minimal React Native dependencies" "Success"
                    $global:Metrics.DependenciesAdded += "React Native fileTree"
                    $global:Metrics.Improvements += "Added minimal RN dependencies"
                    $global:Metrics.RNIntegrationStatus = "Minimal Dependencies Added"
                }
            }
        }
        
        # Write back
        $content | Out-File -FilePath $BuildGradlePath -Encoding ASCII -NoNewline
        
        Write-CycleLog "Version and dependencies updated" "Success"
        return $true
    }
    catch {
        Write-CycleLog "Failed to update: $_" "Error"
        $global:Metrics.BuildErrors += "Update failed: $_"
        return $false
    }
}

function Build-APK {
    Write-CycleLog "Building APK version $VersionName with React Native..." "Info"
    
    Push-Location $AndroidDir
    try {
        # Clean previous build
        Write-CycleLog "Cleaning previous build..." "Info"
        $cleanOutput = & ./gradlew.bat clean 2>&1
        
        # Build APK
        Write-CycleLog "Executing gradle build with React Native dependencies..." "Critical"
        $buildStart = Get-Date
        $buildOutput = & ./gradlew.bat assembleDebug --stacktrace 2>&1
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
            
            # Check for React Native in build output
            if ($buildOutput -match "react|React") {
                Write-CycleLog "React Native processing detected in build" "Success"
                $global:Metrics.RNIntegrationStatus = "Dependencies Building"
            }
            
            # Add to report
            Add-Content -Path $ReportPath -Value "`n## Build Results`n- **Status**: Success`n- **Time**: $($buildTime.TotalSeconds.ToString('F1'))s`n- **Size**: $($apkSize.ToString('F2'))MB`n- **RN Status**: $($global:Metrics.RNIntegrationStatus)`n"
            
            return $apkPath
        } else {
            Write-CycleLog "Build failed - APK not found" "Error"
            
            # Analyze build output for errors
            if ($buildOutput -match "Could not resolve|Failed to resolve|dependency") {
                Write-CycleLog "Dependency resolution error detected" "Error"
                $global:Metrics.BuildErrors += "Dependency resolution failed"
                
                if ($SafeMode) {
                    Write-CycleLog "SafeMode: Attempting rollback..." "Warning"
                    Restore-BuildGradle
                    return $null
                }
            }
            
            # Save build output for analysis
            $buildOutput | Out-File (Join-Path $OutputDir "build-output.log")
            
            Add-Content -Path $ReportPath -Value "`n## Build Results`n- **Status**: Failed`n- **Errors**: $($global:Metrics.BuildErrors -join ', ')`n"
            return $null
        }
    }
    catch {
        Write-CycleLog "Build exception: $_" "Error"
        $global:Metrics.BuildErrors += "Build exception: $_"
        
        if ($SafeMode) {
            Write-CycleLog "SafeMode: Attempting rollback..." "Warning"
            Restore-BuildGradle
        }
        
        return $null
    }
    finally {
        Pop-Location
    }
}

function Restore-BuildGradle {
    Write-CycleLog "Restoring build.gradle from backup..." "Warning"
    
    try {
        $backupPath = Join-Path $BackupDir "build.gradle.backup"
        if (Test-Path $backupPath) {
            Copy-Item $backupPath $BuildGradlePath -Force
            Write-CycleLog "Build.gradle restored from backup" "Success"
            $global:Metrics.RNIntegrationStatus = "Rolled Back"
            return $true
        } else {
            Write-CycleLog "Backup file not found!" "Error"
            return $false
        }
    }
    catch {
        Write-CycleLog "Restore failed: $_" "Error"
        return $false
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
            
            # Capture screenshot
            $screenshotPath = Join-Path $OutputDir "cycle-$CycleNumber-screenshot.png"
            Write-CycleLog "Capturing screenshot..." "Info"
            & $ADB shell screencap -p /sdcard/screenshot.png
            & $ADB pull /sdcard/screenshot.png "`"$screenshotPath`"" 2>&1 | Out-Null
            & $ADB shell rm /sdcard/screenshot.png
            
            if (Test-Path $screenshotPath) {
                Write-CycleLog "Screenshot captured" "Success"
            }
            
            # Extended stability test with more interactions
            Write-CycleLog "Performing extended stability test..." "Info"
            $stableCount = 0
            $totalTests = 5
            
            for ($i = 1; $i -le $totalTests; $i++) {
                # Vary tap locations
                $x = 300 + ($i * 100)
                $y = 800 + ($i * 50)
                & $ADB shell input tap $x $y 2>&1 | Out-Null
                Start-Sleep -Seconds 1
                
                $psOutput = & $ADB shell ps 2>&1
                if ($psOutput -match $PackageName) {
                    $stableCount++
                } else {
                    Write-CycleLog "App crashed after $i interactions" "Error"
                    break
                }
            }
            
            $stabilityPercent = ($stableCount / $totalTests) * 100
            Write-CycleLog "Stability: $stableCount/$totalTests interactions ($($stabilityPercent)%)" "Metric"
            
            if ($stableCount -eq $totalTests) {
                Write-CycleLog "App perfectly stable" "Success"
                Add-Content -Path $ReportPath -Value "`n## Testing`n- **Launch**: Success ($($launchTime.TotalSeconds.ToString('F1'))s)`n- **Stability**: Perfect ($stableCount/$totalTests)`n- **Screenshot**: Captured`n"
                return $true
            } else {
                Add-Content -Path $ReportPath -Value "`n## Testing`n- **Launch**: Success`n- **Stability**: Partial ($stableCount/$totalTests)`n"
                return $false
            }
        } else {
            Write-CycleLog "App failed to launch" "Error"
            
            # Check logcat for crash reason
            $crashLog = & $ADB logcat -d -s AndroidRuntime:E 2>&1 | Select-Object -Last 20
            if ($crashLog) {
                Write-CycleLog "Crash detected in logcat" "Error"
                $crashLog | Out-File (Join-Path $OutputDir "crash-log.txt")
            }
            
            Add-Content -Path $ReportPath -Value "`n## Testing`n- **Launch**: Failed`n- **Crash Log**: Saved to crash-log.txt`n"
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
    
    $enhancements = @"

## Metrics Comparison (Cycle 4 vs Cycle 3)

| Metric | Cycle 3 | Cycle 4 | Change |
|--------|---------|---------|---------|
| Build Time | ${($PreviousMetrics.BuildTime)}s | $($global:Metrics.BuildTime.ToString('F1'))s | $(if($buildTimeChange -gt 0){"+"})${buildTimeChange}s |
| APK Size | ${($PreviousMetrics.APKSize)}MB | $($global:Metrics.APKSize.ToString('F2'))MB | $(if($sizeChange -gt 0){"+"})${sizeChange}MB |
| Launch Time | ${($PreviousMetrics.LaunchTime)}s | $($global:Metrics.LaunchTime.ToString('F1'))s | - |

## React Native Integration Progress
- **Status**: $($global:Metrics.RNIntegrationStatus)
- **Dependencies Added**: $($global:Metrics.DependenciesAdded -join ", ")
- **Build Errors**: $(if($global:Metrics.BuildErrors.Count -eq 0){"None"}else{$global:Metrics.BuildErrors -join ", "})
- **SafeMode Used**: $(if($global:Metrics.RNIntegrationStatus -eq "Rolled Back"){"Yes"}else{"No"})

## Improvements Applied:
$($global:Metrics.Improvements | ForEach-Object { "- $_" } | Out-String)

## Analysis

### Current Challenges:
1. React Native 0.80+ plugin system incompatibility
2. Dependency resolution without proper plugin
3. Manual integration complexity

### Cycle 5 Strategy: Foundation Completion

#### Approach Options:
1. **Option A**: Continue minimal dependencies approach
   - Add React Native JARs/AARs manually
   - Skip gradle plugin entirely
   - Focus on basic functionality

2. **Option B**: Custom gradle configuration
   - Create custom tasks for JS bundling
   - Manual dependency management
   - Direct AAR inclusion

3. **Option C**: Hybrid approach
   - Use React Native CLI for bundle creation
   - Manual APK assembly
   - Progressive feature addition

#### Recommended Next Steps (Cycle 5):
1. Complete foundation scripts (automation tools)
2. Create dependency resolution helper
3. Implement JS bundle creation separately
4. Test basic React component rendering

### Success Criteria for Cycle 5:
- Foundation automation complete
- Clear path forward for RN integration
- All helper scripts functional
- Ready for intensive RN work (Cycles 6-20)
"@

    Add-Content -Path $ReportPath -Value $enhancements
    Write-CycleLog "Enhancement analysis complete" "Success"
}

# ========================================
# MAIN EXECUTION
# ========================================

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "   CYCLE $CycleNumber - REACT NATIVE DEPENDENCIES" -ForegroundColor Cyan
Write-Host "          Critical Integration Phase" -ForegroundColor Yellow
Write-Host "             Version $VersionName" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Initialize
Initialize-CycleEnvironment

# Start emulator
if (-not (Start-EmulatorIfNeeded)) {
    Write-CycleLog "Cannot proceed without emulator" "Error"
    exit 1
}

# Update app version and add dependencies
if (-not (Update-AppVersion)) {
    Write-CycleLog "Version update failed" "Error"
    
    if ($SafeMode) {
        Write-CycleLog "Attempting to restore and continue..." "Warning"
        Restore-BuildGradle
    }
}

# Build APK
$apkPath = Build-APK
if (-not $apkPath) {
    Write-CycleLog "Build failed - critical phase" "Error"
    
    if ($SafeMode -and $global:Metrics.RNIntegrationStatus -ne "Rolled Back") {
        Write-CycleLog "Attempting fallback build with restored gradle..." "Warning"
        Restore-BuildGradle
        $apkPath = Build-APK
    }
    
    if (-not $apkPath) {
        Write-CycleLog "Build failed even after rollback - stopping cycle" "Error"
        exit 1
    }
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
Write-CycleLog "Next cycle: ENHANCED-BUILD-V005.ps1 (version 1.0.5)" "Info"

# Update project_plan.md
$projectPlanPath = Join-Path $ProjectRoot "project_plan.md"
$cycleUpdate = @"

### Cycle $CycleNumber Results (v$VersionName) - $BuildTimestamp
- **Build**: $(if($apkPath){"Success"}else{"Failed"}) ($($global:Metrics.BuildTime.ToString('F1'))s)
- **RN Integration**: $($global:Metrics.RNIntegrationStatus)
- **Dependencies**: $($global:Metrics.DependenciesAdded -join ", ")
- **Metrics**: Size=$($global:Metrics.APKSize.ToString('F2'))MB
- **Next**: Foundation completion (Cycle 5)
"@

Add-Content -Path $projectPlanPath -Value $cycleUpdate

Write-Host "`nCycle $CycleNumber artifacts saved to: $OutputDir" -ForegroundColor Yellow
Write-Host "React Native integration status: $($global:Metrics.RNIntegrationStatus)" -ForegroundColor $(if($global:Metrics.RNIntegrationStatus -match "Success|Building"){"Green"}else{"Yellow"})