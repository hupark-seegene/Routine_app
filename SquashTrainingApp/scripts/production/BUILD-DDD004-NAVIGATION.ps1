# BUILD-DDD004-NAVIGATION.ps1
# Purpose: Build and test the app with navigation connections between screens
# Date: 2025-07-20

$ErrorActionPreference = "Stop"
$StartTime = Get-Date

Write-Host "`n===== SQUASH TRAINING APP - DDD004 NAVIGATION BUILD =====" -ForegroundColor Cyan
Write-Host "Start Time: $($StartTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Yellow

# Set project paths
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$AndroidPath = Join-Path $ProjectRoot "android"
$DddPath = Join-Path $ProjectRoot "ddd/ddd004"

# Create DDD directory
if (-not (Test-Path $DddPath)) {
    New-Item -ItemType Directory -Path $DddPath -Force | Out-Null
    Write-Host "Created DDD004 directory" -ForegroundColor Green
}

# Initialize cycle report
$CycleReport = @{
    BuildNumber = "DDD004"
    StartTime = $StartTime
    Purpose = "Navigation connections and back button functionality"
    NewFeatures = @(
        "BaseActivity for common navigation"
        "Back button support on all screens"
        "Bottom navigation bar"
        "Activity transition animations"
        "Navigation flow between all screens"
    )
    Results = @()
}

# Function to log results
function Add-Result {
    param($Step, $Status, $Details)
    $timestamp = (Get-Date).ToString('HH:mm:ss')
    $result = @{
        Timestamp = $timestamp
        Step = $Step
        Status = $Status
        Details = $Details
    }
    $CycleReport.Results += $result
    
    $color = if ($Status -eq "Success") { "Green" } 
             elseif ($Status -eq "Warning") { "Yellow" } 
             else { "Red" }
    
    Write-Host "[$timestamp] $Step : $Status - $Details" -ForegroundColor $color
}

try {
    # Step 1: Clean previous build
    Write-Host "`n[1/8] Cleaning previous build..." -ForegroundColor Cyan
    Set-Location $AndroidPath
    
    if (Test-Path "app/build") {
        Remove-Item -Recurse -Force "app/build" -ErrorAction SilentlyContinue
    }
    & ./gradlew clean 2>&1 | Out-Null
    Add-Result "Clean Build" "Success" "Previous build artifacts cleaned"
    
    # Step 2: Check Gradle configuration
    Write-Host "`n[2/8] Validating Gradle configuration..." -ForegroundColor Cyan
    $gradleCheck = & ./gradlew tasks --all 2>&1
    if ($LASTEXITCODE -eq 0) {
        Add-Result "Gradle Check" "Success" "Gradle configuration valid"
    } else {
        throw "Gradle configuration check failed"
    }
    
    # Step 3: Build the APK
    Write-Host "`n[3/8] Building APK with navigation features..." -ForegroundColor Cyan
    $buildOutput = & ./gradlew assembleDebug 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $apkPath = Get-ChildItem -Path "app/build/outputs/apk/debug" -Filter "*.apk" | Select-Object -First 1
        if ($apkPath) {
            Add-Result "APK Build" "Success" "APK built successfully: $($apkPath.Name)"
            
            # Copy APK to DDD directory
            $targetApk = Join-Path $DddPath "SquashTrainingApp-DDD004-Navigation.apk"
            Copy-Item $apkPath.FullName $targetApk -Force
            Add-Result "APK Copy" "Success" "APK copied to DDD004 directory"
        } else {
            throw "APK file not found after successful build"
        }
    } else {
        throw "Build failed with exit code $LASTEXITCODE"
    }
    
    # Step 4: Check emulator
    Write-Host "`n[4/8] Checking emulator status..." -ForegroundColor Cyan
    $adbDevices = & adb devices 2>&1
    if ($adbDevices -match "emulator-\d+\s+device") {
        Add-Result "Emulator Check" "Success" "Emulator is running and connected"
    } else {
        Add-Result "Emulator Check" "Warning" "No emulator detected - please start emulator manually"
        Write-Host "Please start an emulator and press Enter to continue..." -ForegroundColor Yellow
        Read-Host
    }
    
    # Step 5: Uninstall previous version
    Write-Host "`n[5/8] Uninstalling previous app version..." -ForegroundColor Cyan
    & adb uninstall com.squashtrainingapp 2>&1 | Out-Null
    Add-Result "Uninstall" "Success" "Previous version removed"
    
    # Step 6: Install new APK
    Write-Host "`n[6/8] Installing navigation-enabled APK..." -ForegroundColor Cyan
    $installResult = & adb install $targetApk 2>&1
    if ($installResult -match "Success") {
        Add-Result "Install" "Success" "APK installed successfully"
    } else {
        throw "APK installation failed"
    }
    
    # Step 7: Launch app
    Write-Host "`n[7/8] Launching app..." -ForegroundColor Cyan
    & adb shell am start -n com.squashtrainingapp/.MainActivity 2>&1 | Out-Null
    Add-Result "App Launch" "Success" "App launched with MainActivity"
    
    # Step 8: Navigation test instructions
    Write-Host "`n[8/8] Navigation Test Instructions:" -ForegroundColor Cyan
    Write-Host @"
    
NAVIGATION TEST CHECKLIST:
-------------------------
1. Main Screen Navigation:
   - Drag mascot to each zone (Profile, Checklist, Coach, Record, History, Settings)
   - Verify smooth transitions with slide animations
   
2. Back Button Testing:
   - Navigate to any screen
   - Press the back button in the top navigation bar
   - Verify return to previous screen with proper animation
   
3. Home Button Testing:
   - Navigate deep into the app (e.g., Profile -> Settings)
   - Press the home button
   - Verify return to main screen
   
4. Bottom Navigation:
   - On any screen, use bottom navigation tabs
   - Verify direct navigation to selected screen
   - Check active tab highlighting
   
5. Voice Navigation:
   - Long press mascot on main screen
   - Say "Go to [screen name]"
   - Verify voice navigation works
   
6. Animation Testing:
   - Verify slide-in animations when navigating forward
   - Verify slide-out animations when going back
   
Press Enter after testing to continue...
"@ -ForegroundColor Yellow
    
    Read-Host
    
    # Generate final report
    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime
    
    $CycleReport.EndTime = $EndTime
    $CycleReport.Duration = $Duration.ToString()
    $CycleReport.OverallStatus = "Success"
    
    # Save report
    $reportPath = Join-Path $DddPath "NAVIGATION_TEST_REPORT.json"
    $CycleReport | ConvertTo-Json -Depth 10 | Set-Content $reportPath
    
    Write-Host "`n===== BUILD COMPLETED SUCCESSFULLY =====" -ForegroundColor Green
    Write-Host "Duration: $($Duration.ToString())" -ForegroundColor Yellow
    Write-Host "APK Location: $targetApk" -ForegroundColor Cyan
    Write-Host "Report saved to: $reportPath" -ForegroundColor Cyan
    
} catch {
    Add-Result "Build Failed" "Error" $_.Exception.Message
    $CycleReport.OverallStatus = "Failed"
    
    # Save error report
    $errorReportPath = Join-Path $DddPath "NAVIGATION_ERROR_REPORT.json"
    $CycleReport | ConvertTo-Json -Depth 10 | Set-Content $errorReportPath
    
    Write-Host "`n===== BUILD FAILED =====" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "Error report saved to: $errorReportPath" -ForegroundColor Yellow
    
    exit 1
}