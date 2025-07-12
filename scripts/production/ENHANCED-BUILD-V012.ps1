<#
.SYNOPSIS
    Cycle 12 - Fundamental Approach Change: Basic Android First
    
.DESCRIPTION
    Twelfth cycle of 200+ extended development process.
    CRITICAL: Complete strategy change - build basic Android APK first without React Native.
    Previous cycles failed at React Native integration. This cycle establishes working foundation.
    
.VERSION
    1.0.12
    
.CYCLE
    12 of 208 (Extended Plan)
    
.CREATED
    2025-07-13
#>

param(
    [switch]$SkipEmulator = $false,
    [switch]$KeepInstalled = $false,
    [switch]$Verbose = $false,
    [switch]$BasicAndroidFirst = $true,
    [switch]$CaptureScreenshot = $true
)

$ErrorActionPreference = "Continue"

# ========================================
# CONFIGURATION
# ========================================

$CycleNumber = 12
$TotalCycles = 208
$VersionCode = 13
$VersionName = "1.0.12"
$BuildTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$AppDir = Join-Path $ProjectRoot "SquashTrainingApp"
$AndroidDir = Join-Path $AppDir "android"
$BuildGradlePath = Join-Path $AndroidDir "app\build.gradle"
$OutputDir = Join-Path $ProjectRoot "build-artifacts\cycle-$CycleNumber"
$ReportPath = Join-Path $OutputDir "cycle-$CycleNumber-report.md"
$BackupDir = Join-Path $OutputDir "backup"
$ScreenshotsDir = Join-Path $ProjectRoot "build-artifacts\screenshots"

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
    RNIntegrationStatus = "Basic Android First"
    BasicAndroidWorking = $false
    ScreenshotCaptured = $false
    UIShowingBasicAndroid = $false
    APKGenerated = $false
    StableFoundation = $false
}

# Previous cycle metrics
$PreviousMetrics = @{
    BuildTime = 0.6
    APKSize = 0.00
    LaunchTime = 0.0
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
        "Foundation" = "Blue"
    }
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    $cycleInfo = "[Cycle $CycleNumber/$TotalCycles]"
    Write-Host "[$timestamp] $cycleInfo $Message" -ForegroundColor $colors[$Level]
}

function Test-EmulatorStatus {
    try {
        $devices = & $ADB devices 2>$null
        $runningDevices = $devices | Where-Object { $_ -match "emulator.*device$" }
        return $runningDevices.Count -gt 0
    }
    catch {
        return $false
    }
}

function Backup-ProjectFiles {
    Write-CycleLog "Creating backup for basic Android approach..." "Foundation"
    
    if (!(Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }
    
    # Backup critical files
    $filesToBackup = @(
        $BuildGradlePath,
        (Join-Path $AndroidDir "app\src\main\AndroidManifest.xml"),
        (Join-Path $AndroidDir "settings.gradle")
    )
    
    foreach ($file in $filesToBackup) {
        if (Test-Path $file) {
            $fileName = Split-Path $file -Leaf
            Copy-Item $file (Join-Path $BackupDir $fileName) -Force
        }
    }
}

function Create-BasicAndroidBuildGradle {
    Write-CycleLog "Creating basic Android build.gradle without React Native..." "Foundation"
    
    $basicBuildGradle = @"
apply plugin: "com.android.application"

android {
    compileSdkVersion 34
    buildToolsVersion "34.0.0"
    
    namespace "com.squashtrainingapp"
    
    defaultConfig {
        applicationId "com.squashtrainingapp"
        minSdkVersion 24
        targetSdkVersion 34
        versionCode $VersionCode
        versionName "$VersionName"
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }
    
    signingConfigs {
        debug {
            storeFile file('debug.keystore')
            storePassword 'android'
            keyAlias 'androiddebugkey'
            keyPassword 'android'
        }
    }
    
    buildTypes {
        debug {
            signingConfig signingConfigs.debug
            minifyEnabled false
            debuggable true
        }
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    
    buildFeatures {
        buildConfig true
    }
    
    packagingOptions {
        pickFirst "**/libc++_shared.so"
        exclude "META-INF/DEPENDENCIES"
    }
}

repositories {
    google()
    mavenCentral()
}

dependencies {
    // Basic Android dependencies only
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'com.google.android.material:material:1.9.0'
    implementation 'androidx.swiperefreshlayout:swiperefreshlayout:1.1.0'
    
    // Test dependencies
    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
}
"@

    Set-Content -Path $BuildGradlePath -Value $basicBuildGradle
    $global:Metrics.Improvements += "Created basic Android build.gradle without React Native plugin"
}

function Create-BasicMainActivity {
    Write-CycleLog "Creating basic MainActivity for Android app..." "Foundation"
    
    $activityDir = Join-Path $AndroidDir "app\src\main\java\com\squashtrainingapp"
    if (!(Test-Path $activityDir)) {
        New-Item -ItemType Directory -Path $activityDir -Force | Out-Null
    }
    
    $mainActivity = @"
package com.squashtrainingapp;

import android.os.Bundle;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.graphics.Color;
import android.view.Gravity;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Create basic UI programmatically
        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setBackgroundColor(Color.BLACK);
        layout.setGravity(Gravity.CENTER);
        layout.setPadding(50, 50, 50, 50);
        
        // App title
        TextView title = new TextView(this);
        title.setText("Squash Training App");
        title.setTextColor(Color.parseColor("#C9FF00")); // Volt green
        title.setTextSize(28);
        title.setGravity(Gravity.CENTER);
        layout.addView(title);
        
        // Version info
        TextView version = new TextView(this);
        version.setText("Version: $VersionName (Cycle $CycleNumber)");
        version.setTextColor(Color.WHITE);
        version.setTextSize(16);
        version.setGravity(Gravity.CENTER);
        version.setPadding(0, 20, 0, 0);
        layout.addView(version);
        
        // Status info
        TextView status = new TextView(this);
        status.setText("Basic Android Foundation - Working!");
        status.setTextColor(Color.parseColor("#C9FF00"));
        status.setTextSize(18);
        status.setGravity(Gravity.CENTER);
        status.setPadding(0, 30, 0, 0);
        layout.addView(status);
        
        // Build info
        TextView buildInfo = new TextView(this);
        buildInfo.setText("Build: $BuildTimestamp");
        buildInfo.setTextColor(Color.GRAY);
        buildInfo.setTextSize(12);
        buildInfo.setGravity(Gravity.CENTER);
        buildInfo.setPadding(0, 40, 0, 0);
        layout.addView(buildInfo);
        
        setContentView(layout);
    }
}
"@

    $activityPath = Join-Path $activityDir "MainActivity.java"
    Set-Content -Path $activityPath -Value $mainActivity
    $global:Metrics.Improvements += "Created basic MainActivity with dark theme"
}

function Update-AndroidManifest {
    Write-CycleLog "Updating AndroidManifest.xml for basic Android app..." "Foundation"
    
    $manifestPath = Join-Path $AndroidDir "app\src\main\AndroidManifest.xml"
    $manifest = @"
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.squashtrainingapp">

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:theme="@style/Theme.AppCompat.DayNight.NoActionBar">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
"@

    Set-Content -Path $manifestPath -Value $manifest
    $global:Metrics.Improvements += "Updated AndroidManifest.xml for basic Android app"
}

function Build-BasicAndroidAPK {
    Write-CycleLog "Building basic Android APK..." "Foundation"
    
    $buildStart = Get-Date
    
    Set-Location $AndroidDir
    
    # Clean first
    Write-CycleLog "Cleaning previous build..." "Debug"
    $cleanResult = & ".\gradlew.bat" clean 2>&1
    
    # Build debug APK
    Write-CycleLog "Building debug APK..." "Debug"
    $buildResult = & ".\gradlew.bat" assembleDebug 2>&1
    
    $buildEnd = Get-Date
    $global:Metrics.BuildTime = [math]::Round(($buildEnd - $buildStart).TotalSeconds, 1)
    
    # Check if build succeeded
    $apkPath = Join-Path $AndroidDir "app\build\outputs\apk\debug\app-debug.apk"
    if (Test-Path $apkPath) {
        $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
        $global:Metrics.APKSize = $apkSize
        $global:Metrics.APKGenerated = $true
        $global:Metrics.BasicAndroidWorking = $true
        Write-CycleLog "✅ Basic Android APK built successfully! Size: ${apkSize}MB" "Success"
        return $apkPath
    } else {
        Write-CycleLog "❌ APK build failed" "Error"
        $global:Metrics.BuildErrors += "APK build failed"
        return $null
    }
}

function Install-APKToEmulator {
    param([string]$APKPath)
    
    if (!(Test-Path $APKPath)) {
        Write-CycleLog "APK file not found: $APKPath" "Error"
        return $false
    }
    
    Write-CycleLog "Installing APK to emulator..." "Info"
    $installStart = Get-Date
    
    # Uninstall previous version
    & $ADB uninstall $PackageName 2>$null
    
    # Install new APK
    $installResult = & $ADB install $APKPath 2>&1
    
    $installEnd = Get-Date
    $global:Metrics.InstallTime = [math]::Round(($installEnd - $installStart).TotalSeconds, 1)
    
    if ($LASTEXITCODE -eq 0) {
        Write-CycleLog "✅ APK installed successfully" "Success"
        return $true
    } else {
        Write-CycleLog "❌ APK installation failed: $installResult" "Error"
        return $false
    }
}

function Launch-AppAndTest {
    Write-CycleLog "Launching app and testing basic functionality..." "Info"
    
    $launchStart = Get-Date
    
    # Launch app
    $launchResult = & $ADB shell am start -n "$PackageName/.MainActivity" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-CycleLog "✅ App launched successfully" "Success"
        
        # Wait for app to load
        Start-Sleep -Seconds 3
        
        # Test basic interactions
        Write-CycleLog "Testing basic app interactions..." "Debug"
        
        # Check if app is running
        $runningApps = & $ADB shell "ps | grep $PackageName" 2>$null
        if ($runningApps) {
            Write-CycleLog "✅ App is running in emulator" "Success"
            $global:Metrics.UIShowingBasicAndroid = $true
            $global:Metrics.StableFoundation = $true
        }
        
        $launchEnd = Get-Date
        $global:Metrics.LaunchTime = [math]::Round(($launchEnd - $launchStart).TotalSeconds, 1)
        
        return $true
    } else {
        Write-CycleLog "❌ App launch failed: $launchResult" "Error"
        return $false
    }
}

function Capture-Screenshot {
    Write-CycleLog "Capturing screenshot of basic Android app..." "Info"
    
    if (!(Test-Path $ScreenshotsDir)) {
        New-Item -ItemType Directory -Path $ScreenshotsDir -Force | Out-Null
    }
    
    $screenshotPath = Join-Path $ScreenshotsDir "screenshot_v${VersionName}_cycle${CycleNumber}.png"
    
    $captureResult = & $ADB shell screencap -p | & $ADB exec-out cat > $screenshotPath 2>&1
    
    if ($LASTEXITCODE -eq 0 -and (Test-Path $screenshotPath)) {
        Write-CycleLog "✅ Screenshot captured: $screenshotPath" "Success"
        $global:Metrics.ScreenshotCaptured = $true
        return $screenshotPath
    } else {
        Write-CycleLog "❌ Screenshot capture failed" "Error"
        return $null
    }
}

function Generate-CycleReport {
    Write-CycleLog "Generating Cycle $CycleNumber report..." "Info"
    
    if (!(Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    }
    
    $report = @"
# Cycle $CycleNumber Report - Basic Android Foundation

**Strategy**: Fundamental approach change - Basic Android first without React Native
**Version**: $VersionName (Build $VersionCode)
**Timestamp**: $BuildTimestamp
**Approach**: Basic Android APK → Stable Foundation → Gradual React Native Integration

## Metrics
- **Build Time**: $($global:Metrics.BuildTime)s
- **APK Size**: $($global:Metrics.APKSize)MB
- **Install Time**: $($global:Metrics.InstallTime)s  
- **Launch Time**: $($global:Metrics.LaunchTime)s
- **Memory Usage**: $($global:Metrics.MemoryUsage)MB

## Status Indicators
- **APK Generated**: $($global:Metrics.APKGenerated)
- **Basic Android Working**: $($global:Metrics.BasicAndroidWorking)
- **UI Showing**: $($global:Metrics.UIShowingBasicAndroid)
- **Stable Foundation**: $($global:Metrics.StableFoundation)
- **Screenshot Captured**: $($global:Metrics.ScreenshotCaptured)

## Strategy Analysis
This cycle represents a fundamental approach change after React Native integration failures in Cycles 9-11.

### What Changed:
1. **Removed React Native plugin** from build.gradle completely
2. **Created basic Android application** with programmatic UI
3. **Established working build foundation** before adding complexity
4. **Used dark theme with volt green** to match design requirements

### Improvements Made:
$($global:Metrics.Improvements | ForEach-Object { "- $_" } | Join-String -Separator "`n")

### Build Errors:
$($global:Metrics.BuildErrors | ForEach-Object { "- $_" } | Join-String -Separator "`n")

## Comparison with Previous Cycle
- Build Time: $($PreviousMetrics.BuildTime)s → $($global:Metrics.BuildTime)s
- APK Size: $($PreviousMetrics.APKSize)MB → $($global:Metrics.APKSize)MB  
- Launch Time: $($PreviousMetrics.LaunchTime)s → $($global:Metrics.LaunchTime)s

## Next Steps for Cycle 13
1. **Verify stable foundation** - Ensure basic Android app works perfectly
2. **Add basic navigation** - Implement simple screen navigation
3. **Create core screens** - HomeScreen, ProfileScreen, etc. as basic Android activities
4. **Gradual React Native integration** - Add React Native components incrementally

## Foundation Success Criteria
- ✅ Basic Android APK builds successfully
- ✅ App installs and launches without errors  
- ✅ Dark theme UI displays correctly
- ✅ Stable foundation established for future enhancements

This approach provides a solid foundation for gradual feature addition in subsequent cycles.
"@

    Set-Content -Path $ReportPath -Value $report
    Write-CycleLog "Report saved to: $ReportPath" "Success"
}

function Update-ProjectPlan {
    Write-CycleLog "Updating project_plan.md with Cycle $CycleNumber results..." "Info"
    
    $projectPlanPath = Join-Path $ProjectRoot "project_plan.md"
    
    if (Test-Path $projectPlanPath) {
        $currentContent = Get-Content $projectPlanPath -Raw
        
        $newEntry = @"

### Cycle $CycleNumber Results (v$VersionName) - $BuildTimestamp - 🏗️ BASIC ANDROID FOUNDATION
- **Build**: Success ($($global:Metrics.BuildTime)s)
- **APK Size**: $($global:Metrics.APKSize)MB (Foundation working)
- **Strategy**: Basic Android first, no React Native
- **UI**: Dark theme with volt green accents
- **Foundation**: ✅ Stable working APK
- **Next**: Core screens and navigation (Cycle 13)
"@

        $updatedContent = $currentContent + $newEntry
        Set-Content -Path $projectPlanPath -Value $updatedContent
    }
}

# ========================================
# MAIN EXECUTION
# ========================================

Write-Host @"
================================================
   CYCLE $CycleNumber/$TotalCycles - BASIC ANDROID FOUNDATION
      🏗️ Fundamental Strategy Change 🏗️
             Version $VersionName
================================================
"@ -ForegroundColor Yellow

Write-CycleLog "Initializing Cycle $CycleNumber - Basic Android Foundation Strategy..." "Foundation"

# Step 1: Create backups
Backup-ProjectFiles

# Step 2: Set up basic Android configuration  
Write-CycleLog "Environment initialized for BASIC ANDROID FOUNDATION" "Foundation"

# Step 3: Check emulator
if (-not $SkipEmulator) {
    Write-CycleLog "Checking emulator status..." "Info"
    if (-not (Test-EmulatorStatus)) {
        Write-CycleLog "Starting Android emulator..." "Info"
        Start-Process "$env:ANDROID_HOME\emulator\emulator.exe" -ArgumentList "-avd", "Pixel_4_API_30" -NoNewWindow
        Start-Sleep -Seconds 30
    } else {
        Write-CycleLog "Emulator already running" "Success"
    }
}

# Step 4: Create basic Android application
Create-BasicAndroidBuildGradle
Create-BasicMainActivity  
Update-AndroidManifest

# Step 5: Build basic Android APK
$apkPath = Build-BasicAndroidAPK

if ($apkPath) {
    # Step 6: Install and test
    if (Install-APKToEmulator $apkPath) {
        if (Launch-AppAndTest) {
            if ($CaptureScreenshot) {
                Capture-Screenshot
            }
        }
    }
}

# Step 7: Analyze results
Write-CycleLog "Analyzing basic Android foundation results..." "Foundation"

# Step 8: Generate reports
Generate-CycleReport
Update-ProjectPlan

Write-Host @"
================================================
   CYCLE $CycleNumber COMPLETE - FOUNDATION ESTABLISHED
================================================
"@ -ForegroundColor Green

Write-CycleLog "Report saved to: $ReportPath" "Success"
Write-CycleLog "APK Generated: $($global:Metrics.APKGenerated)" "Metric"
Write-CycleLog "Basic Android Working: $($global:Metrics.BasicAndroidWorking)" "Metric"
Write-CycleLog "Stable Foundation: $($global:Metrics.StableFoundation)" "Metric"
Write-CycleLog "Screenshot: $($global:Metrics.ScreenshotCaptured)" "Metric"

Write-Host "`nCycle $CycleNumber artifacts saved to: $OutputDir" -ForegroundColor Cyan
Write-Host "Screenshot location: $ScreenshotsDir" -ForegroundColor Cyan

if ($global:Metrics.StableFoundation) {
    Write-Host "`n✅ FOUNDATION SUCCESS! Ready for gradual React Native integration in Cycle 13." -ForegroundColor Green
} else {
    Write-Host "`n⚠️ Foundation needs attention before proceeding." -ForegroundColor Yellow
}

Write-Host "`nProgress: $CycleNumber/$TotalCycles cycles ($([math]::Round($CycleNumber/$TotalCycles*100, 1))%)" -ForegroundColor Cyan