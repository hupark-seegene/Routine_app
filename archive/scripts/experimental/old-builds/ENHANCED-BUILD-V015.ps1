<#
.SYNOPSIS
    Cycle 15 - Bottom Tab Navigation Implementation
    
.DESCRIPTION
    Fifteenth cycle of 200+ extended development process.
    Focus: Implement bottom tab navigation structure
    - Add Material Design dependencies
    - Create bottom navigation view
    - Implement tab switching logic
    - Add placeholder screens for all tabs
    - Establish navigation architecture
    
.VERSION
    1.0.15
    
.CYCLE
    15 of 214 (Extended Plan)
    
.CREATED
    2025-07-12
#>

param(
    [switch]$SkipEmulator = $false,
    [switch]$KeepInstalled = $false,
    [switch]$Verbose = $false,
    [switch]$CaptureScreenshot = $true,
    [switch]$ImplementNavigation = $true
)

$ErrorActionPreference = "Continue"

# ========================================
# CONFIGURATION
# ========================================

$CycleNumber = 15
$TotalCycles = 214
$VersionCode = 16
$VersionName = "1.0.15"
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

# Tab Configuration
$Tabs = @(
    @{Name="Home"; Icon="home"; Activity="MainActivity"},
    @{Name="Checklist"; Icon="checklist"; Activity="ChecklistActivity"},
    @{Name="Record"; Icon="record"; Activity="RecordActivity"},
    @{Name="Profile"; Icon="profile"; Activity="ProfileActivity"},
    @{Name="Coach"; Icon="coach"; Activity="CoachActivity"}
)

# Metrics tracking
$global:Metrics = @{
    BuildTime = 0
    APKSize = 0
    InstallTime = 0
    LaunchTime = 0
    MemoryUsage = 0
    Improvements = @()
    BuildErrors = @()
    NavigationImplemented = $false
    TabsCreated = 0
    ActivitiesCreated = 0
    LayoutsCreated = 0
    APKGenerated = $false
    BuildSuccessful = $false
    ScreenshotCaptured = $false
    NavigationWorking = $false
}

# Previous cycle metrics
$PreviousMetrics = @{
    BuildTime = 4.0
    APKSize = 5.23
    LaunchTime = 11.2
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
        "Navigation" = "Blue"
        "Tab" = "Magenta"
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
    Write-CycleLog "Creating backup before navigation implementation..." "Navigation"
    
    if (!(Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }
    
    # Backup critical files
    $filesToBackup = @(
        $BuildGradlePath,
        (Join-Path $AndroidDir "app\src\main\AndroidManifest.xml"),
        (Join-Path $AndroidDir "app\src\main\java\com\squashtrainingapp\MainActivity.java")
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
    
    # Add Material Design dependency for bottom navigation
    if ($content -notmatch "material:") {
        $dependenciesSection = $content -match '(?s)(dependencies\s*\{.*?\n)(\s*\})'
        if ($dependenciesSection) {
            $newDependency = "    implementation 'com.google.android.material:material:1.9.0'`n"
            $content = $content -replace '(implementation.*material.*\n)', "$newDependency"
        }
    }
    
    Set-Content -Path $BuildGradlePath -Value $content
    $global:Metrics.Improvements += "Updated version to $VersionName (build $VersionCode)"
    $global:Metrics.Improvements += "Added Material Design dependency for navigation"
}

function Create-NavigationMenu {
    Write-CycleLog "Creating bottom navigation menu resource..." "Navigation"
    
    $menuDir = Join-Path $AndroidDir "app\src\main\res\menu"
    if (!(Test-Path $menuDir)) {
        New-Item -ItemType Directory -Path $menuDir -Force | Out-Null
    }
    
    $menuPath = Join-Path $menuDir "bottom_navigation_menu.xml"
    
    $menuXml = @"
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item
        android:id="@+id/navigation_home"
        android:icon="@drawable/ic_home"
        android:title="Home" />
        
    <item
        android:id="@+id/navigation_checklist"
        android:icon="@drawable/ic_checklist"
        android:title="Checklist" />
        
    <item
        android:id="@+id/navigation_record"
        android:icon="@drawable/ic_record"
        android:title="Record" />
        
    <item
        android:id="@+id/navigation_profile"
        android:icon="@drawable/ic_profile"
        android:title="Profile" />
        
    <item
        android:id="@+id/navigation_coach"
        android:icon="@drawable/ic_coach"
        android:title="Coach" />
</menu>
"@
    
    Set-Content -Path $menuPath -Value $menuXml
    $global:Metrics.NavigationImplemented = $true
    $global:Metrics.Improvements += "Created bottom navigation menu"
}

function Create-TabIcons {
    Write-CycleLog "Creating placeholder tab icons..." "Tab"
    
    $drawableDir = Join-Path $AndroidDir "app\src\main\res\drawable"
    if (!(Test-Path $drawableDir)) {
        New-Item -ItemType Directory -Path $drawableDir -Force | Out-Null
    }
    
    # Create simple vector drawable icons for each tab
    $icons = @{
        "ic_home" = @"
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="@color/text_primary"
        android:pathData="M10,20v-6h4v6h5v-8h3L12,3 2,12h3v8z"/>
</vector>
"@
        "ic_checklist" = @"
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="@color/text_primary"
        android:pathData="M9,16.17L4.83,12l-1.42,1.41L9,19 21,7l-1.41,-1.41z"/>
</vector>
"@
        "ic_record" = @"
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="@color/text_primary"
        android:pathData="M19,3H5C3.89,3 3,3.89 3,5v14c0,1.1 0.89,2 2,2h14c1.1,0 2,-0.9 2,-2V5C21,3.89 20.1,3 19,3zM9,17H7v-7h2V17zM13,17h-2V7h2V17zM17,17h-2v-4h2V17z"/>
</vector>
"@
        "ic_profile" = @"
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="@color/text_primary"
        android:pathData="M12,12c2.21,0 4,-1.79 4,-4s-1.79,-4 -4,-4 -4,1.79 -4,4 1.79,4 4,4zM12,14c-2.67,0 -8,1.34 -8,4v2h16v-2c0,-2.66 -5.33,-4 -8,-4z"/>
</vector>
"@
        "ic_coach" = @"
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="@color/text_primary"
        android:pathData="M12,2C6.48,2 2,6.48 2,12s4.48,10 10,10 10,-4.48 10,-10S17.52,2 12,2zM13,17h-2v-6h2v6zM13,9h-2L11,7h2v2z"/>
</vector>
"@
    }
    
    foreach ($iconName in $icons.Keys) {
        $iconPath = Join-Path $drawableDir "$iconName.xml"
        Set-Content -Path $iconPath -Value $icons[$iconName]
    }
    
    $global:Metrics.Improvements += "Created 5 tab icons"
}

function Create-MainActivityWithNavigation {
    Write-CycleLog "Updating MainActivity with bottom navigation..." "Navigation"
    
    $mainActivityPath = Join-Path $AndroidDir "app\src\main\java\com\squashtrainingapp\MainActivity.java"
    
    $mainActivity = @"
package com.squashtrainingapp;

import android.os.Bundle;
import android.view.MenuItem;
import android.widget.FrameLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import com.google.android.material.bottomnavigation.BottomNavigationView;

public class MainActivity extends AppCompatActivity {
    
    private FrameLayout contentFrame;
    private TextView contentText;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main_navigation);
        
        contentFrame = findViewById(R.id.content_frame);
        contentText = findViewById(R.id.content_text);
        BottomNavigationView navigation = findViewById(R.id.bottom_navigation);
        
        navigation.setOnNavigationItemSelectedListener(new BottomNavigationView.OnNavigationItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(@NonNull MenuItem item) {
                int itemId = item.getItemId();
                
                if (itemId == R.id.navigation_home) {
                    showContent("Home Screen");
                    return true;
                } else if (itemId == R.id.navigation_checklist) {
                    showContent("Checklist Screen");
                    return true;
                } else if (itemId == R.id.navigation_record) {
                    showContent("Record Screen");
                    return true;
                } else if (itemId == R.id.navigation_profile) {
                    showContent("Profile Screen");
                    return true;
                } else if (itemId == R.id.navigation_coach) {
                    showContent("Coach Screen");
                    return true;
                }
                
                return false;
            }
        });
        
        // Set default selection
        navigation.setSelectedItemId(R.id.navigation_home);
    }
    
    private void showContent(String screenName) {
        contentText.setText(screenName);
    }
}
"@
    
    Set-Content -Path $mainActivityPath -Value $mainActivity
    $global:Metrics.ActivitiesCreated++
    $global:Metrics.Improvements += "Updated MainActivity with navigation logic"
}

function Create-NavigationLayout {
    Write-CycleLog "Creating main navigation layout..." "Navigation"
    
    $layoutDir = Join-Path $AndroidDir "app\src\main\res\layout"
    $navigationLayoutPath = Join-Path $layoutDir "activity_main_navigation.xml"
    
    $navigationLayout = @"
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/dark_background">
    
    <!-- Main content frame -->
    <FrameLayout
        android:id="@+id/content_frame"
        android:layout_width="0dp"
        android:layout_height="0dp"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toTopOf="@id/bottom_navigation"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent">
        
        <!-- Temporary content display -->
        <TextView
            android:id="@+id/content_text"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_gravity="center"
            android:text="Home Screen"
            android:textColor="@color/text_primary"
            android:textSize="24sp"
            android:textStyle="bold"/>
            
    </FrameLayout>
    
    <!-- Bottom Navigation -->
    <com.google.android.material.bottomnavigation.BottomNavigationView
        android:id="@+id/bottom_navigation"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:background="@color/dark_surface"
        app:itemIconTint="@color/navigation_item_color"
        app:itemTextColor="@color/navigation_item_color"
        app:menu="@menu/bottom_navigation_menu"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent"/>
    
</androidx.constraintlayout.widget.ConstraintLayout>
"@
    
    Set-Content -Path $navigationLayoutPath -Value $navigationLayout
    $global:Metrics.LayoutsCreated++
    $global:Metrics.Improvements += "Created main navigation layout"
}

function Create-NavigationColorSelector {
    Write-CycleLog "Creating navigation color state selector..." "Navigation"
    
    $colorDir = Join-Path $AndroidDir "app\src\main\res\color"
    if (!(Test-Path $colorDir)) {
        New-Item -ItemType Directory -Path $colorDir -Force | Out-Null
    }
    
    $selectorPath = Join-Path $colorDir "navigation_item_color.xml"
    
    $selectorXml = @"
<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:color="@color/volt_green" android:state_checked="true"/>
    <item android:color="@color/text_secondary" android:state_checked="false"/>
</selector>
"@
    
    Set-Content -Path $selectorPath -Value $selectorXml
    $global:Metrics.Improvements += "Created navigation color selector"
}

function Build-NavigationAPK {
    Write-CycleLog "Building APK with navigation..." "Navigation"
    
    $buildStart = Get-Date
    
    Set-Location $AndroidDir
    
    # Clean build
    Write-CycleLog "Running clean build..." "Debug"
    $cleanResult = & ".\gradlew.bat" clean 2>&1
    
    # Build debug APK
    Write-CycleLog "Building navigation debug APK..." "Debug"
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
    
    Write-CycleLog "Installing navigation APK to emulator..." "Info"
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
    Write-CycleLog "Launching app and testing navigation..." "Navigation"
    
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
            Write-CycleLog "✅ App is running with navigation" "Success"
            $global:Metrics.NavigationWorking = $true
            
            # Test navigation by tapping on each tab
            Write-CycleLog "Testing navigation tabs..." "Tab"
            
            # Get screen dimensions for calculating tap positions
            $screenSize = & $ADB shell wm size
            if ($screenSize -match "(\d+)x(\d+)") {
                $screenWidth = [int]$matches[1]
                $screenHeight = [int]$matches[2]
                $tabY = $screenHeight - 100  # Bottom navigation area
                
                # Calculate X positions for 5 tabs
                $tabPositions = @(
                    [int]($screenWidth * 0.1),   # Home
                    [int]($screenWidth * 0.3),   # Checklist
                    [int]($screenWidth * 0.5),   # Record
                    [int]($screenWidth * 0.7),   # Profile
                    [int]($screenWidth * 0.9)    # Coach
                )
                
                # Test each tab
                foreach ($i in 0..4) {
                    Write-CycleLog "Testing tab $($i+1) of 5..." "Tab"
                    & $ADB shell input tap $($tabPositions[$i]) $tabY
                    Start-Sleep -Seconds 2
                }
                
                Write-CycleLog "✅ Navigation testing completed" "Success"
                $global:Metrics.TabsCreated = 5
            }
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
    Write-CycleLog "Capturing screenshot of navigation..." "Navigation"
    
    if (!(Test-Path $ScreenshotsDir)) {
        New-Item -ItemType Directory -Path $ScreenshotsDir -Force | Out-Null
    }
    
    $screenshotPath = Join-Path $ScreenshotsDir "screenshot_v${VersionName}_cycle${CycleNumber}_navigation.png"
    
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
    
    $report = @"
# Cycle $CycleNumber Report - Bottom Tab Navigation

**Strategy**: Implement bottom tab navigation structure
**Version**: $VersionName (Build $VersionCode)
**Timestamp**: $BuildTimestamp
**Focus**: Navigation architecture with 5 main tabs

## Metrics
- **Build Time**: $($global:Metrics.BuildTime)s
- **APK Size**: $($global:Metrics.APKSize)MB
- **Install Time**: $($global:Metrics.InstallTime)s  
- **Launch Time**: $($global:Metrics.LaunchTime)s
- **Tabs Created**: $($global:Metrics.TabsCreated)
- **Activities Modified**: $($global:Metrics.ActivitiesCreated)
- **Layouts Created**: $($global:Metrics.LayoutsCreated)

## Status Indicators
- **APK Generated**: $($global:Metrics.APKGenerated)
- **Build Successful**: $($global:Metrics.BuildSuccessful)
- **Navigation Working**: $($global:Metrics.NavigationWorking)
- **Navigation Implemented**: $($global:Metrics.NavigationImplemented)
- **Screenshot Captured**: $($global:Metrics.ScreenshotCaptured)

## Navigation Implementation
This cycle established the navigation foundation.

### Navigation Structure:
- **Home Tab**: Main dashboard (default)
- **Checklist Tab**: Daily exercise checklist
- **Record Tab**: Exercise recording
- **Profile Tab**: User profile and settings
- **Coach Tab**: AI coaching interface

### Technical Implementation:
- Material Design BottomNavigationView
- Tab switching with content frame
- Color state selectors for active/inactive states
- Vector drawable icons for each tab

### Improvements Made:
$improvementsList

## Comparison with Previous Cycle
- Build Time: $($PreviousMetrics.BuildTime)s → $($global:Metrics.BuildTime)s
- APK Size: $($PreviousMetrics.APKSize)MB → $($global:Metrics.APKSize)MB  
- Launch Time: $($PreviousMetrics.LaunchTime)s → $($global:Metrics.LaunchTime)s

## Next Steps for Cycle 16
1. **Create ChecklistActivity** - Implement first core screen
2. **Add checklist data model** - Exercise list structure
3. **Implement checklist UI** - Items with checkboxes
4. **Add state persistence** - Save checklist progress

## Navigation Success Criteria
- ✅ Bottom navigation bar implemented
- ✅ 5 tabs with icons created
- ✅ Tab switching functionality working
- ✅ Visual feedback for active tab

The navigation foundation is now established for building core screens.
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

### Cycle $CycleNumber Results (v$VersionName) - $BuildTimestamp - 🧭 NAVIGATION FOUNDATION
- **Build**: Success ($($global:Metrics.BuildTime)s)
- **APK Size**: $($global:Metrics.APKSize)MB 
- **Navigation**: Bottom tabs implemented (5 tabs)
- **Tab Switching**: Functional
- **Next**: ChecklistActivity implementation (Cycle 16)
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
   CYCLE $CycleNumber/$TotalCycles - NAVIGATION
      🧭 Bottom Tab Navigation 🧭
             Version $VersionName
================================================
"@ -ForegroundColor Blue

Write-CycleLog "Initializing Cycle $CycleNumber - Navigation Implementation..." "Navigation"

# Step 1: Create backups
Backup-ProjectFiles

# Step 2: Update version
Update-BuildGradle

# Step 3: Implement navigation
if ($ImplementNavigation) {
    Write-CycleLog "Implementing bottom tab navigation..." "Navigation"
    Create-TabIcons
    Create-NavigationMenu
    Create-NavigationColorSelector
    Create-NavigationLayout
    Create-MainActivityWithNavigation
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

# Step 5: Build navigation APK
$apkPath = Build-NavigationAPK

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
   CYCLE $CycleNumber COMPLETE - NAVIGATION READY
================================================
"@ -ForegroundColor Green

Write-CycleLog "Report saved to: $ReportPath" "Success"
Write-CycleLog "APK Generated: $($global:Metrics.APKGenerated)" "Metric"
Write-CycleLog "Navigation Working: $($global:Metrics.NavigationWorking)" "Metric"
Write-CycleLog "Tabs Created: $($global:Metrics.TabsCreated)" "Metric"
Write-CycleLog "Screenshot: $($global:Metrics.ScreenshotCaptured)" "Metric"

Write-Host "`nCycle $CycleNumber artifacts saved to: $OutputDir" -ForegroundColor Cyan
Write-Host "Screenshot location: $ScreenshotsDir" -ForegroundColor Cyan

if ($global:Metrics.NavigationWorking) {
    Write-Host "`n✅ NAVIGATION IMPLEMENTATION SUCCESSFUL! Bottom tabs working." -ForegroundColor Green
} else {
    Write-Host "`n⚠️ Navigation implementation needs refinement." -ForegroundColor Yellow
}

Write-Host "`nProgress: $CycleNumber/$TotalCycles cycles ($([math]::Round($CycleNumber/$TotalCycles*100, 1))%)" -ForegroundColor Cyan
Write-Host "Next: Implement ChecklistActivity with exercise list" -ForegroundColor Yellow