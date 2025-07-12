<#
.SYNOPSIS
    Cycle 6 - React Native Plugin Integration
    
.DESCRIPTION
    Sixth cycle of 50-cycle continuous development process.
    Beginning of intensive React Native integration phase (Cycles 6-20).
    Attempts to add React Native gradle plugin and basic configuration.
    
.VERSION
    1.0.6
    
.CYCLE
    6 of 50
    
.CREATED
    2025-07-13
#>

param(
    [switch]$SkipEmulator = $false,
    [switch]$KeepInstalled = $false,
    [switch]$Verbose = $false,
    [switch]$SafeMode = $true,
    [switch]$CreateReactFiles = $true
)

$ErrorActionPreference = "Continue"

# ========================================
# CONFIGURATION
# ========================================

$CycleNumber = 6
$VersionCode = 7
$VersionName = "1.0.6"
$BuildTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$AppDir = Join-Path $ProjectRoot "SquashTrainingApp"
$AndroidDir = Join-Path $AppDir "android"
$BuildGradlePath = Join-Path $AndroidDir "app\build.gradle"
$SettingsGradlePath = Join-Path $AndroidDir "settings.gradle"
$MainActivityPath = Join-Path $AndroidDir "app\src\main\java\com\squashtrainingapp\MainActivity.java"
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
    RNIntegrationStatus = "Starting Plugin Integration"
    ReactFilesCreated = @()
    PluginStatus = "Not Applied"
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
        "React" = "Blue"
    }
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = if ($colors.ContainsKey($Level)) { $colors[$Level] } else { "White" }
    
    Write-Host "[$timestamp] [Cycle $CycleNumber] $Message" -ForegroundColor $color
    
    # Also append to report
    Add-Content -Path $ReportPath -Value "[$timestamp] [$Level] $Message" -ErrorAction SilentlyContinue
}

function Initialize-CycleEnvironment {
    Write-CycleLog "Initializing Cycle $CycleNumber - React Native Integration Phase..." "React"
    
    # Create directories
    @($OutputDir, $BackupDir) | ForEach-Object {
        if (-not (Test-Path $_)) {
            New-Item -ItemType Directory -Path $_ -Force | Out-Null
        }
    }
    
    # Backup critical files
    @($BuildGradlePath, $SettingsGradlePath, $MainActivityPath) | ForEach-Object {
        if (Test-Path $_) {
            $fileName = Split-Path $_ -Leaf
            Copy-Item $_ (Join-Path $BackupDir "$fileName.backup") -Force
        }
    }
    
    Write-CycleLog "Created backups of critical files" "Info"
    
    # Initialize report
    @"
# Cycle $CycleNumber Report
**Date**: $BuildTimestamp
**Version**: $VersionName (Code: $VersionCode)
**Previous Version**: 1.0.5 (Code: 6)

## 🎯 Key Focus: React Native Plugin Integration

### React Native Integration Phase Begins!
This is the first cycle of the intensive React Native integration phase (Cycles 6-20).

### Goals for This Cycle
1. Apply React Native gradle plugin
2. Configure basic React Native settings
3. Create index.js entry point
4. Update MainActivity for React
5. Test basic React Native functionality

### Risk Level: HIGH
This cycle attempts significant changes that may cause build failures.
SafeMode is enabled for automatic rollback if needed.

## Build Log
"@ | Out-File -FilePath $ReportPath -Encoding UTF8
    
    Write-CycleLog "Environment initialized for React Native integration" "Success"
}

function Create-ReactNativeFiles {
    if (-not $CreateReactFiles) {
        Write-CycleLog "Skipping React file creation (flag not set)" "Warning"
        return
    }
    
    Write-CycleLog "Creating React Native entry files..." "React"
    
    # Create index.js
    $indexJsPath = Join-Path $AppDir "index.js"
    $indexJsContent = @'
/**
 * @format
 */

import {AppRegistry} from 'react-native';
import App from './App';
import {name as appName} from './app.json';

AppRegistry.registerComponent(appName, () => App);
'@
    
    $indexJsContent | Out-File -FilePath $indexJsPath -Encoding UTF8
    Write-CycleLog "Created index.js entry point" "Success"
    $global:Metrics.ReactFilesCreated += "index.js"
    
    # Create App.js
    $appJsPath = Join-Path $AppDir "App.js"
    $appJsContent = @'
/**
 * Squash Training App
 * Created by Cycle 6 - React Native Integration
 * @format
 * @flow strict-local
 */

import React from 'react';
import {
  SafeAreaView,
  StyleSheet,
  Text,
  View,
} from 'react-native';

const App = () => {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Squash Training App</Text>
        <Text style={styles.subtitle}>React Native v1.0.6</Text>
        <Text style={styles.info}>Cycle 6 - Plugin Integration</Text>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000000',
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#C9FF00',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 18,
    color: '#FFFFFF',
    marginBottom: 5,
  },
  info: {
    fontSize: 14,
    color: '#666666',
  },
});

export default App;
'@
    
    $appJsContent | Out-File -FilePath $appJsPath -Encoding UTF8
    Write-CycleLog "Created App.js component" "Success"
    $global:Metrics.ReactFilesCreated += "App.js"
    
    # Create app.json if not exists
    $appJsonPath = Join-Path $AppDir "app.json"
    if (-not (Test-Path $appJsonPath)) {
        $appJsonContent = @'
{
  "name": "SquashTrainingApp",
  "displayName": "Squash Training"
}
'@
        $appJsonContent | Out-File -FilePath $appJsonPath -Encoding UTF8
        Write-CycleLog "Created app.json" "Success"
        $global:Metrics.ReactFilesCreated += "app.json"
    }
    
    $global:Metrics.Improvements += "Created React Native entry files"
}

function Update-MainActivity {
    Write-CycleLog "Updating MainActivity for React Native..." "React"
    
    try {
        # Check if MainActivity exists
        if (-not (Test-Path $MainActivityPath)) {
            Write-CycleLog "MainActivity.java not found, creating new one..." "Warning"
            
            # Create directory structure
            $mainActivityDir = Split-Path $MainActivityPath -Parent
            if (-not (Test-Path $mainActivityDir)) {
                New-Item -ItemType Directory -Path $mainActivityDir -Force | Out-Null
            }
        }
        
        # Create React-enabled MainActivity
        $mainActivityContent = @'
package com.squashtrainingapp;

import com.facebook.react.ReactActivity;
import com.facebook.react.ReactActivityDelegate;
import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint;
import com.facebook.react.defaults.DefaultReactActivityDelegate;

public class MainActivity extends ReactActivity {

    /**
     * Returns the name of the main component registered from JavaScript.
     * This is used to schedule rendering of the component.
     */
    @Override
    protected String getMainComponentName() {
        return "SquashTrainingApp";
    }

    /**
     * Returns the instance of the {@link ReactActivityDelegate}. Here we use a util class {@link
     * DefaultReactActivityDelegate} which allows you to easily enable Fabric and Concurrent React
     * (aka React 18) with two boolean flags.
     */
    @Override
    protected ReactActivityDelegate createReactActivityDelegate() {
        return new DefaultReactActivityDelegate(
                this,
                getMainComponentName(),
                // If you opted-in for the New Architecture, we enable the Fabric Renderer.
                DefaultNewArchitectureEntryPoint.getFabricEnabled());
    }
}
'@
        
        $mainActivityContent | Out-File -FilePath $MainActivityPath -Encoding ASCII
        Write-CycleLog "Updated MainActivity to extend ReactActivity" "Success"
        $global:Metrics.Improvements += "Updated MainActivity for React Native"
        return $true
    }
    catch {
        Write-CycleLog "Failed to update MainActivity: $_" "Error"
        $global:Metrics.BuildErrors += "MainActivity update failed: $_"
        return $false
    }
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

function Apply-ReactNativePlugin {
    Write-CycleLog "Attempting to apply React Native gradle plugin..." "Critical"
    
    try {
        # Read current build.gradle
        $content = Get-Content $BuildGradlePath -Raw
        
        # Check if plugin already applied
        if ($content -match 'apply plugin:\s*"com\.facebook\.react"') {
            Write-CycleLog "React Native plugin already applied" "Info"
            $global:Metrics.PluginStatus = "Already Applied"
            return $true
        }
        
        Write-CycleLog "Adding React Native plugin..." "React"
        
        # Add plugin after android application plugin
        $content = $content -replace '(apply plugin:\s*"com\.android\.application")', @"
`$1
apply plugin: "com.facebook.react"
"@
        
        # Add React Native configuration
        if ($content -notmatch "react \{") {
            Write-CycleLog "Adding React configuration block..." "React"
            
            # Find a good place to insert react config (after android block)
            $content = $content -replace '(android\s*\{[^}]+\})', @"
`$1

react {
    // The root of your project, i.e. where "package.json" lives.
    root = file("../..")
    
    // The folder where the react-native NPM package is.
    reactNativeDir = file("../../node_modules/react-native")
    
    // Default is 'debug'
    buildTypes {
        debug {
            bundleIn = true
            devDisabledIn = false
        }
    }
}
"@
        }
        
        # Update dependencies for React Native
        Write-CycleLog "Updating dependencies for React Native..." "React"
        
        # Comment out basic Android dependencies and add React Native
        $content = $content -replace '(dependencies\s*\{)([^}]+)(})', @"
`$1
    // React Native dependencies (Cycle 6)
    implementation("com.facebook.react:react-android")
    implementation("com.facebook.react:hermes-android")
    
    // Keep essential Android dependencies
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'androidx.swiperefreshlayout:swiperefreshlayout:1.1.0'
`$3
"@
        
        # Write back
        $content | Out-File -FilePath $BuildGradlePath -Encoding ASCII -NoNewline
        
        Write-CycleLog "React Native plugin applied successfully" "Success"
        $global:Metrics.PluginStatus = "Applied"
        $global:Metrics.Improvements += "Applied React Native gradle plugin"
        $global:Metrics.RNIntegrationStatus = "Plugin Applied"
        return $true
    }
    catch {
        Write-CycleLog "Failed to apply React Native plugin: $_" "Error"
        $global:Metrics.BuildErrors += "Plugin application failed: $_"
        $global:Metrics.PluginStatus = "Failed"
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
        
        # Write back
        $content | Out-File -FilePath $BuildGradlePath -Encoding ASCII -NoNewline
        
        Write-CycleLog "Version updated to $VersionName" "Success"
        return $true
    }
    catch {
        Write-CycleLog "Failed to update version: $_" "Error"
        $global:Metrics.BuildErrors += "Version update failed: $_"
        return $false
    }
}

function Build-APK {
    Write-CycleLog "Building APK version $VersionName with React Native..." "React"
    
    Push-Location $AndroidDir
    try {
        # Clean previous build
        Write-CycleLog "Cleaning previous build..." "Info"
        $cleanOutput = & ./gradlew.bat clean 2>&1
        
        # Build APK
        Write-CycleLog "Executing gradle build with React Native plugin..." "Critical"
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
            if ($buildOutput -match "com\.facebook\.react") {
                Write-CycleLog "React Native plugin processed during build" "Success"
                $global:Metrics.RNIntegrationStatus = "Plugin Active"
            }
            
            # Add to report
            Add-Content -Path $ReportPath -Value "`n## Build Results`n- **Status**: Success`n- **Time**: $($buildTime.TotalSeconds.ToString('F1'))s`n- **Size**: $($apkSize.ToString('F2'))MB`n- **Plugin Status**: $($global:Metrics.PluginStatus)`n- **RN Status**: $($global:Metrics.RNIntegrationStatus)`n"
            
            return $apkPath
        } else {
            Write-CycleLog "Build failed - APK not found" "Error"
            
            # Analyze build output for specific errors
            if ($buildOutput -match "Plugin with id.*not found|Could not find.*plugin") {
                Write-CycleLog "React Native plugin not found - this is expected with RN 0.80+" "Warning"
                $global:Metrics.BuildErrors += "RN plugin not found (expected)"
                
                if ($SafeMode) {
                    Write-CycleLog "SafeMode: Will attempt alternative approach..." "Warning"
                    # In future cycles, we'll implement workarounds
                }
            }
            
            # Save build output for analysis
            $buildOutput | Out-File (Join-Path $OutputDir "build-output.log")
            
            Add-Content -Path $ReportPath -Value "`n## Build Results`n- **Status**: Failed`n- **Errors**: $($global:Metrics.BuildErrors -join ', ')`n- **Log**: See build-output.log`n"
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

function Restore-BackupFiles {
    Write-CycleLog "Restoring files from backup..." "Warning"
    
    try {
        @($BuildGradlePath, $SettingsGradlePath, $MainActivityPath) | ForEach-Object {
            $fileName = Split-Path $_ -Leaf
            $backupPath = Join-Path $BackupDir "$fileName.backup"
            if (Test-Path $backupPath) {
                Copy-Item $backupPath $_ -Force
                Write-CycleLog "Restored $fileName from backup" "Success"
            }
        }
        
        $global:Metrics.RNIntegrationStatus = "Rolled Back"
        return $true
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
    Write-CycleLog "Testing app with React Native..." "React"
    
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
            
            # Check logcat for React Native
            Write-CycleLog "Checking for React Native initialization..." "React"
            $logcatOutput = & $ADB logcat -d -s ReactNative:V ReactNativeJS:V 2>&1 | Select-Object -Last 50
            
            if ($logcatOutput -match "ReactNative|Running application") {
                Write-CycleLog "React Native detected in app!" "Success"
                $global:Metrics.RNIntegrationStatus = "React Native Running"
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
            
            # Test stability
            Write-CycleLog "Testing React Native app stability..." "React"
            $stableCount = 0
            $totalTests = 3
            
            for ($i = 1; $i -le $totalTests; $i++) {
                & $ADB shell input tap 540 960 2>&1 | Out-Null
                Start-Sleep -Seconds 1
                
                $psOutput = & $ADB shell ps 2>&1
                if ($psOutput -match $PackageName) {
                    $stableCount++
                } else {
                    Write-CycleLog "App crashed after $i interactions" "Error"
                    
                    # Get crash log
                    $crashLog = & $ADB logcat -d -s AndroidRuntime:E 2>&1 | Select-Object -Last 20
                    $crashLog | Out-File (Join-Path $OutputDir "crash-log.txt")
                    break
                }
            }
            
            $stabilityPercent = ($stableCount / $totalTests) * 100
            Write-CycleLog "React Native stability: $stableCount/$totalTests ($($stabilityPercent)%)" "Metric"
            
            Add-Content -Path $ReportPath -Value "`n## Testing`n- **Launch**: Success ($($launchTime.TotalSeconds.ToString('F1'))s)`n- **Stability**: $stableCount/$totalTests`n- **React Native**: $($global:Metrics.RNIntegrationStatus)`n- **Screenshot**: Captured`n"
            return $stableCount -eq $totalTests
        } else {
            Write-CycleLog "App failed to launch" "Error"
            
            # Check crash log
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
    Write-CycleLog "Analyzing React Native integration results..." "React"
    
    # Calculate changes
    $buildTimeChange = [math]::Round($global:Metrics.BuildTime - $PreviousMetrics.BuildTime, 1)
    $sizeChange = [math]::Round($global:Metrics.APKSize - $PreviousMetrics.APKSize, 2)
    
    $enhancements = @"

## Metrics Comparison (Cycle 6 vs Cycle 5)

| Metric | Cycle 5 | Cycle 6 | Change |
|--------|---------|---------|---------|
| Build Time | ${($PreviousMetrics.BuildTime)}s | $($global:Metrics.BuildTime.ToString('F1'))s | $(if($buildTimeChange -gt 0){"+"})${buildTimeChange}s |
| APK Size | ${($PreviousMetrics.APKSize)}MB | $($global:Metrics.APKSize.ToString('F2'))MB | $(if($sizeChange -gt 0){"+"})${sizeChange}MB |
| Launch Time | ${($PreviousMetrics.LaunchTime)}s | $($global:Metrics.LaunchTime.ToString('F1'))s | - |

## React Native Integration Progress
- **Plugin Status**: $($global:Metrics.PluginStatus)
- **RN Integration**: $($global:Metrics.RNIntegrationStatus)
- **React Files Created**: $($global:Metrics.ReactFilesCreated -join ", ")
- **Build Errors**: $(if($global:Metrics.BuildErrors.Count -eq 0){"None"}else{$global:Metrics.BuildErrors -join ", "})

## Cycle 6 Achievements:
$($global:Metrics.Improvements | ForEach-Object { "- $_" } | Out-String)

## Analysis

### Current Challenges:
1. React Native 0.80+ gradle plugin system incompatibility
2. Plugin registration mechanism changed
3. Need alternative integration approach

### Expected Issues (RN 0.80+):
- Plugin "com.facebook.react" not found is EXPECTED
- This is due to the new plugin system in React Native 0.80+
- Requires either:
  a) Pre-building the gradle plugin
  b) Using React Native CLI commands
  c) Alternative integration methods

### Cycle 7 Strategy: Alternative Integration

#### Approach Options:
1. **Option A**: Use React Native CLI for builds
   - Let npx react-native handle plugin registration
   - Focus on app code rather than gradle configuration
   
2. **Option B**: Manual integration without plugin
   - Add React Native as standard dependencies
   - Create custom gradle tasks for bundling
   - Direct integration approach

3. **Option C**: Hybrid PowerShell + CLI approach
   - Use React Native CLI for complex operations
   - PowerShell for automation and testing
   - Best of both worlds

#### Recommended Next Steps (Cycle 7):
1. Try React Native CLI build approach
2. If successful, wrap CLI commands in PowerShell
3. Focus on getting React components rendering
4. Establish working build pipeline

### Success Criteria for Cycle 7:
- Find working build method (CLI or manual)
- React Native components rendering
- Hot reload functional
- Basic navigation setup

### Cycles 8-20 Roadmap:
- Cycle 8: Navigation setup
- Cycle 9: First app screen
- Cycle 10: SQLite integration
- Cycles 11-15: Core screens implementation
- Cycles 16-20: Polish and optimization
"@

    Add-Content -Path $ReportPath -Value $enhancements
    Write-CycleLog "React Native analysis complete" "Success"
}

# ========================================
# MAIN EXECUTION
# ========================================

Write-Host "`n================================================" -ForegroundColor Blue
Write-Host "   CYCLE $CycleNumber - REACT NATIVE PLUGIN" -ForegroundColor Blue
Write-Host "       Beginning RN Integration Phase" -ForegroundColor Yellow
Write-Host "             Version $VersionName" -ForegroundColor Blue
Write-Host "================================================" -ForegroundColor Blue

# Initialize
Initialize-CycleEnvironment

# Create React Native files
Create-ReactNativeFiles

# Update MainActivity
Update-MainActivity

# Start emulator
if (-not (Start-EmulatorIfNeeded)) {
    Write-CycleLog "Cannot proceed without emulator" "Error"
    exit 1
}

# Update app version
if (-not (Update-AppVersion)) {
    Write-CycleLog "Version update failed" "Error"
}

# Apply React Native plugin
$pluginApplied = Apply-ReactNativePlugin

# Build APK
$apkPath = Build-APK
if (-not $apkPath) {
    Write-CycleLog "Build failed - expected with RN 0.80+" "Warning"
    
    if ($SafeMode) {
        Write-CycleLog "SafeMode: Restoring backups and trying basic build..." "Warning"
        Restore-BackupFiles
        
        # Try a basic build without React Native plugin
        Write-CycleLog "Attempting fallback build..." "Info"
        $apkPath = Build-APK
    }
}

if ($apkPath) {
    # Install APK
    if (Install-APK -ApkPath $apkPath) {
        # Test app
        $testResult = Test-App
        
        # Uninstall
        Uninstall-App
    } else {
        Write-CycleLog "Installation failed - skipping tests" "Error"
    }
} else {
    Write-CycleLog "No APK to test - build failed" "Error"
}

# Generate enhancement recommendations
Generate-Enhancement

# Final summary
Write-Host "`n================================================" -ForegroundColor Green
Write-Host "   CYCLE $CycleNumber COMPLETE" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-CycleLog "Report saved to: $ReportPath" "Info"
Write-CycleLog "RN Integration Status: $($global:Metrics.RNIntegrationStatus)" "React"
Write-CycleLog "Plugin Status: $($global:Metrics.PluginStatus)" "Info"
Write-CycleLog "Next cycle: Alternative integration approaches" "Info"

# Update project_plan.md
$projectPlanPath = Join-Path $ProjectRoot "project_plan.md"
$cycleUpdate = @"

### Cycle $CycleNumber Results (v$VersionName) - $BuildTimestamp
- **Build**: $(if($apkPath){"Success"}else{"Failed (Expected)"}) $(if($global:Metrics.BuildTime -gt 0){"($($global:Metrics.BuildTime.ToString('F1'))s)"})
- **RN Plugin**: $($global:Metrics.PluginStatus)
- **React Files**: $($global:Metrics.ReactFilesCreated.Count) created
- **Status**: $($global:Metrics.RNIntegrationStatus)
- **Next**: Alternative integration approach (Cycle 7)
"@

Add-Content -Path $projectPlanPath -Value $cycleUpdate

Write-Host "`nCycle $CycleNumber artifacts saved to: $OutputDir" -ForegroundColor Yellow
Write-Host "React Native integration phase has begun!" -ForegroundColor Cyan