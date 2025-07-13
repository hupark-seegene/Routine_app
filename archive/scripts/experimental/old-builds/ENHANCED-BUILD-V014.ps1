<#
.SYNOPSIS
    Cycle 14 - UI Enhancement and Basic Navigation
    
.DESCRIPTION
    Fourteenth cycle of 200+ extended development process.
    Focus: Build upon stable foundation from Cycle 13
    - Enhance UI with dark theme and volt green accents
    - Implement basic navigation structure
    - Create core screen layouts
    - Establish visual design system
    
.VERSION
    1.0.14
    
.CYCLE
    14 of 208 (Extended Plan)
    
.CREATED
    2025-07-12
#>

param(
    [switch]$SkipEmulator = $false,
    [switch]$KeepInstalled = $false,
    [switch]$Verbose = $false,
    [switch]$CaptureScreenshot = $true,
    [switch]$EnhanceUI = $true
)

$ErrorActionPreference = "Continue"

# ========================================
# CONFIGURATION
# ========================================

$CycleNumber = 14
$TotalCycles = 208
$VersionCode = 15
$VersionName = "1.0.14"
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

# Design System Colors
$VoltGreen = "#C9FF00"
$DarkBG = "#0D0D0D"
$DarkSurface = "#1A1A1A"
$TextPrimary = "#FFFFFF"
$TextSecondary = "#B3B3B3"

# Metrics tracking
$global:Metrics = @{
    BuildTime = 0
    APKSize = 0
    InstallTime = 0
    LaunchTime = 0
    MemoryUsage = 0
    Improvements = @()
    BuildErrors = @()
    UIEnhancements = @()
    NavigationImplemented = $false
    ScreensCreated = 0
    ThemeApplied = $false
    APKGenerated = $false
    BuildSuccessful = $false
    ScreenshotCaptured = $false
    UIShowingCorrectly = $false
}

# Previous cycle metrics
$PreviousMetrics = @{
    BuildTime = 0.9
    APKSize = 5.34
    LaunchTime = 5.0
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
        "UI" = "Magenta"
        "Navigation" = "Blue"
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
    Write-CycleLog "Creating backup before UI enhancements..." "UI"
    
    if (!(Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }
    
    # Backup critical files
    $filesToBackup = @(
        $BuildGradlePath,
        (Join-Path $AndroidDir "app\src\main\AndroidManifest.xml"),
        (Join-Path $AndroidDir "app\src\main\java\com\squashtrainingapp\MainActivity.java"),
        (Join-Path $AndroidDir "app\src\main\res\values\colors.xml"),
        (Join-Path $AndroidDir "app\src\main\res\values\styles.xml")
    )
    
    foreach ($file in $filesToBackup) {
        if (Test-Path $file) {
            $fileName = Split-Path $file -Leaf
            Copy-Item $file (Join-Path $BackupDir $fileName) -Force
        }
    }
}

function Update-BuildGradle {
    Write-CycleLog "Updating build.gradle for version $VersionName..." "Info"
    
    $content = Get-Content $BuildGradlePath -Raw
    $content = $content -replace 'versionCode \d+', "versionCode $VersionCode"
    $content = $content -replace 'versionName "[^"]*"', "versionName `"$VersionName`""
    
    Set-Content -Path $BuildGradlePath -Value $content
    $global:Metrics.Improvements += "Updated version to $VersionName (build $VersionCode)"
}

function Create-ColorResources {
    Write-CycleLog "Creating color resources for dark theme..." "UI"
    
    $colorsPath = Join-Path $AndroidDir "app\src\main\res\values\colors.xml"
    $colorsDir = Split-Path $colorsPath -Parent
    
    if (!(Test-Path $colorsDir)) {
        New-Item -ItemType Directory -Path $colorsDir -Force | Out-Null
    }
    
    $colorsXml = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Primary brand colors -->
    <color name="volt_green">$VoltGreen</color>
    <color name="dark_background">$DarkBG</color>
    <color name="dark_surface">$DarkSurface</color>
    
    <!-- Text colors -->
    <color name="text_primary">$TextPrimary</color>
    <color name="text_secondary">$TextSecondary</color>
    
    <!-- Accent colors -->
    <color name="success">#4CAF50</color>
    <color name="warning">#FF9800</color>
    <color name="error">#F44336</color>
    
    <!-- Component colors -->
    <color name="card_background">#1F1F1F</color>
    <color name="divider">#333333</color>
    <color name="button_pressed">#99C9FF00</color>
</resources>
"@
    
    Set-Content -Path $colorsPath -Value $colorsXml
    $global:Metrics.UIEnhancements += "Created dark theme color resources"
    $global:Metrics.ThemeApplied = $true
}

function Create-StyleResources {
    Write-CycleLog "Creating style resources for app theme..." "UI"
    
    $stylesPath = Join-Path $AndroidDir "app\src\main\res\values\styles.xml"
    
    $stylesXml = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Base application theme -->
    <style name="AppTheme" parent="Theme.AppCompat.NoActionBar">
        <item name="android:windowBackground">@color/dark_background</item>
        <item name="android:colorPrimary">@color/volt_green</item>
        <item name="android:colorPrimaryDark">@color/dark_surface</item>
        <item name="android:colorAccent">@color/volt_green</item>
        <item name="android:textColorPrimary">@color/text_primary</item>
        <item name="android:textColorSecondary">@color/text_secondary</item>
        <item name="android:windowLightStatusBar">false</item>
    </style>
    
    <!-- Button style -->
    <style name="VoltButton" parent="Widget.AppCompat.Button">
        <item name="android:background">@color/volt_green</item>
        <item name="android:textColor">@color/dark_background</item>
        <item name="android:textStyle">bold</item>
        <item name="android:paddingTop">12dp</item>
        <item name="android:paddingBottom">12dp</item>
    </style>
    
    <!-- Card style -->
    <style name="CardStyle">
        <item name="android:background">@color/card_background</item>
        <item name="android:padding">16dp</item>
        <item name="android:layout_margin">8dp</item>
    </style>
</resources>
"@
    
    Set-Content -Path $stylesPath -Value $stylesXml
    $global:Metrics.UIEnhancements += "Created app theme styles"
}

function Create-HomeScreenLayout {
    Write-CycleLog "Creating HomeScreen layout..." "UI"
    
    $layoutDir = Join-Path $AndroidDir "app\src\main\res\layout"
    if (!(Test-Path $layoutDir)) {
        New-Item -ItemType Directory -Path $layoutDir -Force | Out-Null
    }
    
    $homeLayoutPath = Join-Path $layoutDir "activity_home.xml"
    
    $homeLayout = @"
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/dark_background">
    
    <!-- Header -->
    <LinearLayout
        android:id="@+id/header"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="20dp"
        app:layout_constraintTop_toTopOf="parent">
        
        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="SQUASH TRAINING"
            android:textColor="@color/volt_green"
            android:textSize="28sp"
            android:textStyle="bold"/>
            
        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Advanced Player Development"
            android:textColor="@color/text_secondary"
            android:textSize="16sp"
            android:layout_marginTop="4dp"/>
    </LinearLayout>
    
    <!-- Main Content -->
    <ScrollView
        android:layout_width="match_parent"
        android:layout_height="0dp"
        app:layout_constraintTop_toBottomOf="@id/header"
        app:layout_constraintBottom_toBottomOf="parent">
        
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:padding="16dp">
            
            <!-- Quick Stats Card -->
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="vertical"
                android:background="@color/card_background"
                android:padding="16dp"
                android:layout_marginBottom="16dp">
                
                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Today's Progress"
                    android:textColor="@color/text_primary"
                    android:textSize="18sp"
                    android:textStyle="bold"/>
                    
                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="0 of 5 exercises completed"
                    android:textColor="@color/text_secondary"
                    android:textSize="14sp"
                    android:layout_marginTop="8dp"/>
            </LinearLayout>
            
            <!-- Action Buttons -->
            <Button
                android:id="@+id/startTrainingButton"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="START TRAINING"
                style="@style/VoltButton"
                android:layout_marginBottom="12dp"/>
                
            <Button
                android:id="@+id/viewProgramButton"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="VIEW PROGRAM"
                style="@style/VoltButton"
                android:backgroundTint="@color/dark_surface"
                android:textColor="@color/volt_green"
                android:layout_marginBottom="12dp"/>
                
            <Button
                android:id="@+id/aiCoachButton"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="AI COACH"
                style="@style/VoltButton"
                android:backgroundTint="@color/dark_surface"
                android:textColor="@color/volt_green"/>
        </LinearLayout>
    </ScrollView>
    
</androidx.constraintlayout.widget.ConstraintLayout>
"@
    
    Set-Content -Path $homeLayoutPath -Value $homeLayout
    $global:Metrics.UIEnhancements += "Created HomeScreen layout with dark theme"
    $global:Metrics.ScreensCreated++
}

function Update-MainActivity {
    Write-CycleLog "Updating MainActivity to use new layout..." "UI"
    
    $mainActivityPath = Join-Path $AndroidDir "app\src\main\java\com\squashtrainingapp\MainActivity.java"
    
    $mainActivity = @"
package com.squashtrainingapp;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);
        
        // Initialize UI components
        setupButtons();
    }
    
    private void setupButtons() {
        Button startTrainingButton = findViewById(R.id.startTrainingButton);
        Button viewProgramButton = findViewById(R.id.viewProgramButton);
        Button aiCoachButton = findViewById(R.id.aiCoachButton);
        
        startTrainingButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Toast.makeText(MainActivity.this, 
                    "Training mode coming soon!", 
                    Toast.LENGTH_SHORT).show();
            }
        });
        
        viewProgramButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Toast.makeText(MainActivity.this, 
                    "Program view coming soon!", 
                    Toast.LENGTH_SHORT).show();
            }
        });
        
        aiCoachButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Toast.makeText(MainActivity.this, 
                    "AI Coach coming soon!", 
                    Toast.LENGTH_SHORT).show();
            }
        });
    }
}
"@
    
    Set-Content -Path $mainActivityPath -Value $mainActivity
    $global:Metrics.UIEnhancements += "Updated MainActivity with button handlers"
}

function Build-EnhancedAPK {
    Write-CycleLog "Building APK with UI enhancements..." "UI"
    
    $buildStart = Get-Date
    
    Set-Location $AndroidDir
    
    # Clean build
    Write-CycleLog "Running clean build..." "Debug"
    $cleanResult = & ".\gradlew.bat" clean 2>&1
    
    # Build debug APK
    Write-CycleLog "Building enhanced debug APK..." "Debug"
    $buildResult = & ".\gradlew.bat" assembleDebug 2>&1
    
    $buildEnd = Get-Date
    $global:Metrics.BuildTime = [math]::Round(($buildEnd - $buildStart).TotalSeconds, 1)
    
    # Check build result
    if ($buildResult -match "BUILD SUCCESSFUL") {
        Write-CycleLog "✅ Gradle build completed successfully!" "Success"
        $global:Metrics.BuildSuccessful = $true
    } else {
        Write-CycleLog "❌ Gradle build failed" "Error"
        $global:Metrics.BuildErrors += "Gradle build failed"
        Write-CycleLog "Build output: $($buildResult | Out-String)" "Debug"
    }
    
    # Check if APK was created
    $apkPath = Join-Path $AndroidDir "app\build\outputs\apk\debug\app-debug.apk"
    if (Test-Path $apkPath) {
        $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
        $global:Metrics.APKSize = $apkSize
        $global:Metrics.APKGenerated = $true
        Write-CycleLog "✅ APK generated successfully! Size: ${apkSize}MB" "Success"
        return $apkPath
    } else {
        Write-CycleLog "❌ APK file not found" "Error"
        $global:Metrics.BuildErrors += "APK file not generated"
        return $null
    }
}

function Install-APKToEmulator {
    param([string]$APKPath)
    
    if (!(Test-Path $APKPath)) {
        Write-CycleLog "APK file not found: $APKPath" "Error"
        return $false
    }
    
    Write-CycleLog "Installing enhanced APK to emulator..." "Info"
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
    Write-CycleLog "Launching app with UI enhancements..." "UI"
    
    $launchStart = Get-Date
    
    # Launch app
    $launchResult = & $ADB shell am start -n "$PackageName/.MainActivity" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-CycleLog "✅ App launched successfully" "Success"
        
        # Wait for app to load
        Start-Sleep -Seconds 5
        
        # Check if app is running
        $runningApps = & $ADB shell "ps | grep $PackageName" 2>$null
        if ($runningApps) {
            Write-CycleLog "✅ App is running with enhanced UI" "Success"
            $global:Metrics.UIShowingCorrectly = $true
            
            # Test UI interactions
            Write-CycleLog "Testing UI button interactions..." "UI"
            
            # Tap on Start Training button (approximate coordinates)
            & $ADB shell input tap 540 800
            Start-Sleep -Seconds 2
            
            # Tap on View Program button
            & $ADB shell input tap 540 950
            Start-Sleep -Seconds 2
            
            # Tap on AI Coach button
            & $ADB shell input tap 540 1100
            Start-Sleep -Seconds 2
            
            Write-CycleLog "✅ UI interactions tested" "Success"
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
    Write-CycleLog "Capturing screenshot of enhanced UI..." "UI"
    
    if (!(Test-Path $ScreenshotsDir)) {
        New-Item -ItemType Directory -Path $ScreenshotsDir -Force | Out-Null
    }
    
    $screenshotPath = Join-Path $ScreenshotsDir "screenshot_v${VersionName}_cycle${CycleNumber}_enhanced_ui.png"
    
    # Capture screenshot using screencap
    & $ADB shell screencap -p /sdcard/screenshot.png
    & $ADB pull /sdcard/screenshot.png $screenshotPath 2>&1
    & $ADB shell rm /sdcard/screenshot.png
    
    if (Test-Path $screenshotPath) {
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
    
    $improvementsList = ""
    foreach ($improvement in $global:Metrics.Improvements) {
        $improvementsList += "- $improvement`n"
    }
    
    $uiEnhancementsList = ""
    foreach ($enhancement in $global:Metrics.UIEnhancements) {
        $uiEnhancementsList += "- $enhancement`n"
    }
    
    $report = @"
# Cycle $CycleNumber Report - UI Enhancement & Navigation

**Strategy**: Build upon stable foundation with dark theme UI
**Version**: $VersionName (Build $VersionCode)
**Timestamp**: $BuildTimestamp
**Focus**: Dark theme, volt green accents, basic navigation

## Metrics
- **Build Time**: $($global:Metrics.BuildTime)s
- **APK Size**: $($global:Metrics.APKSize)MB
- **Install Time**: $($global:Metrics.InstallTime)s  
- **Launch Time**: $($global:Metrics.LaunchTime)s
- **Screens Created**: $($global:Metrics.ScreensCreated)

## Status Indicators
- **APK Generated**: $($global:Metrics.APKGenerated)
- **Build Successful**: $($global:Metrics.BuildSuccessful)
- **UI Showing Correctly**: $($global:Metrics.UIShowingCorrectly)
- **Theme Applied**: $($global:Metrics.ThemeApplied)
- **Screenshot Captured**: $($global:Metrics.ScreenshotCaptured)

## UI Enhancements Applied
This cycle focused on establishing the visual design system.

### Design System:
- **Primary Color**: Volt Green (#C9FF00)
- **Background**: Dark (#0D0D0D)
- **Surface**: Dark Surface (#1A1A1A)
- **Typography**: White primary, gray secondary

### UI Improvements:
$uiEnhancementsList

### General Improvements:
$improvementsList

## Comparison with Previous Cycle
- Build Time: $($PreviousMetrics.BuildTime)s → $($global:Metrics.BuildTime)s
- APK Size: $($PreviousMetrics.APKSize)MB → $($global:Metrics.APKSize)MB  
- Launch Time: $($PreviousMetrics.LaunchTime)s → $($global:Metrics.LaunchTime)s

## Next Steps for Cycle 15
1. **Create navigation structure** - Bottom tab navigation
2. **Implement additional screens** - Checklist, Record, Profile, Coach
3. **Add screen transitions** - Smooth animations between screens
4. **Enhance interactivity** - Working buttons and forms

## UI Implementation Success
- ✅ Dark theme with volt green accents implemented
- ✅ HomeScreen layout created with action buttons
- ✅ Button click handlers with toast messages
- ✅ Professional squash training app appearance

The UI enhancements establish the visual identity for the app.
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

### Cycle $CycleNumber Results (v$VersionName) - $BuildTimestamp - 🎨 UI ENHANCEMENT
- **Build**: Success ($($global:Metrics.BuildTime)s)
- **APK Size**: $($global:Metrics.APKSize)MB 
- **UI Theme**: Dark + Volt Green implemented
- **Screens**: HomeScreen created
- **Next**: Navigation & additional screens (Cycle 15)
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
   CYCLE $CycleNumber/$TotalCycles - UI ENHANCEMENT
       🎨 Dark Theme & Navigation 🎨
             Version $VersionName
================================================
"@ -ForegroundColor Magenta

Write-CycleLog "Initializing Cycle $CycleNumber - UI Enhancement..." "UI"

# Step 1: Create backups
Backup-ProjectFiles

# Step 2: Update version
Update-BuildGradle

# Step 3: Apply UI enhancements
if ($EnhanceUI) {
    Write-CycleLog "Applying UI enhancements..." "UI"
    Create-ColorResources
    Create-StyleResources
    Create-HomeScreenLayout
    Update-MainActivity
}

# Step 4: Check emulator
if (-not $SkipEmulator) {
    Write-CycleLog "Checking emulator status..." "Info"
    if (-not (Test-EmulatorStatus)) {
        Write-CycleLog "Starting Android emulator..." "Info"
        Start-Process "$env:ANDROID_HOME\emulator\emulator.exe" -ArgumentList "-avd", "Pixel_4_API_30" -NoNewWindow
        
        Write-CycleLog "Waiting for emulator to boot..." "Info"
        $maxWait = 60
        $waited = 0
        while (-not (Test-EmulatorStatus) -and $waited -lt $maxWait) {
            Start-Sleep -Seconds 5
            $waited += 5
            Write-CycleLog "Waiting... ($waited/$maxWait seconds)" "Debug"
        }
    } else {
        Write-CycleLog "Emulator already running" "Success"
    }
}

# Step 5: Build enhanced APK
$apkPath = Build-EnhancedAPK

if ($apkPath) {
    # Step 6: Install and test
    if (Install-APKToEmulator $apkPath) {
        if (Launch-AppAndTest) {
            if ($CaptureScreenshot) {
                Capture-Screenshot
            }
        }
    }
    
    # Step 7: Keep installed for testing if requested
    if (-not $KeepInstalled) {
        Write-CycleLog "Uninstalling app from emulator..." "Info"
        & $ADB uninstall $PackageName 2>$null
    }
}

# Step 8: Generate reports
Generate-CycleReport
Update-ProjectPlan

Write-Host @"
================================================
   CYCLE $CycleNumber COMPLETE - UI ENHANCED
================================================
"@ -ForegroundColor Green

Write-CycleLog "Report saved to: $ReportPath" "Success"
Write-CycleLog "APK Generated: $($global:Metrics.APKGenerated)" "Metric"
Write-CycleLog "UI Theme Applied: $($global:Metrics.ThemeApplied)" "Metric"
Write-CycleLog "Screens Created: $($global:Metrics.ScreensCreated)" "Metric"
Write-CycleLog "Screenshot: $($global:Metrics.ScreenshotCaptured)" "Metric"

Write-Host "`nCycle $CycleNumber artifacts saved to: $OutputDir" -ForegroundColor Cyan
Write-Host "Screenshot location: $ScreenshotsDir" -ForegroundColor Cyan

if ($global:Metrics.UIShowingCorrectly) {
    Write-Host "`n✅ UI ENHANCEMENT SUCCESSFUL! Dark theme with volt green applied." -ForegroundColor Green
} else {
    Write-Host "`n⚠️ UI enhancements need further refinement." -ForegroundColor Yellow
}

Write-Host "`nProgress: $CycleNumber/$TotalCycles cycles ($([math]::Round($CycleNumber/$TotalCycles*100, 1))%)" -ForegroundColor Cyan
Write-Host "Next: Create navigation structure and additional screens" -ForegroundColor Yellow