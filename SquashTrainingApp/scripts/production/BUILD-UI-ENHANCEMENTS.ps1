# BUILD-UI-ENHANCEMENTS.ps1
# Purpose: Build and test UI enhancements including Stats, CSV export, and language switching
# Date: 2025-07-20

$ErrorActionPreference = "Stop"
$StartTime = Get-Date

Write-Host "`n===== SQUASH TRAINING APP - UI ENHANCEMENTS BUILD =====" -ForegroundColor Cyan
Write-Host "Start Time: $($StartTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Yellow

# Set project paths
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$AndroidPath = Join-Path $ProjectRoot "android"
$ApkOutputPath = Join-Path $AndroidPath "app/build/outputs/apk/debug"

# Features to test
Write-Host "`n[NEW FEATURES]" -ForegroundColor Green
Write-Host "1. Statistics Dashboard with Charts" -ForegroundColor Yellow
Write-Host "2. CSV Data Export Functionality" -ForegroundColor Yellow  
Write-Host "3. Language Setting (Korean/English)" -ForegroundColor Yellow
Write-Host "4. Navigation Improvements" -ForegroundColor Yellow

try {
    # Step 1: Clean previous build
    Write-Host "`n[1/7] Cleaning previous build..." -ForegroundColor Cyan
    Set-Location $AndroidPath
    
    if (Test-Path "app/build") {
        Remove-Item -Recurse -Force "app/build" -ErrorAction SilentlyContinue
    }
    & ./gradlew clean 2>&1 | Out-Null
    Write-Host "✓ Clean completed" -ForegroundColor Green
    
    # Step 2: Build APK
    Write-Host "`n[2/7] Building APK with UI enhancements..." -ForegroundColor Cyan
    $buildOutput = & ./gradlew assembleDebug 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $apkFile = Get-ChildItem -Path $ApkOutputPath -Filter "*.apk" | Select-Object -First 1
        if ($apkFile) {
            Write-Host "✓ APK built successfully: $($apkFile.Name)" -ForegroundColor Green
            Write-Host "  Size: $([math]::Round($apkFile.Length / 1MB, 2)) MB" -ForegroundColor Gray
        }
    } else {
        throw "Build failed with exit code $LASTEXITCODE"
    }
    
    # Step 3: Check emulator
    Write-Host "`n[3/7] Checking emulator status..." -ForegroundColor Cyan
    $devices = & adb devices 2>&1
    if ($devices -match "emulator-\d+\s+device") {
        Write-Host "✓ Emulator is running" -ForegroundColor Green
    } else {
        Write-Host "! No emulator detected - please start one" -ForegroundColor Yellow
        Write-Host "Press Enter after starting emulator..." -ForegroundColor Yellow
        Read-Host
    }
    
    # Step 4: Uninstall previous version
    Write-Host "`n[4/7] Uninstalling previous version..." -ForegroundColor Cyan
    & adb uninstall com.squashtrainingapp 2>&1 | Out-Null
    Write-Host "✓ Previous version removed" -ForegroundColor Green
    
    # Step 5: Install new APK
    Write-Host "`n[5/7] Installing enhanced APK..." -ForegroundColor Cyan
    $installResult = & adb install $apkFile.FullName 2>&1
    if ($installResult -match "Success") {
        Write-Host "✓ APK installed successfully" -ForegroundColor Green
    } else {
        throw "Installation failed"
    }
    
    # Step 6: Launch app
    Write-Host "`n[6/7] Launching app..." -ForegroundColor Cyan
    & adb shell am start -n com.squashtrainingapp/.MainActivity 2>&1 | Out-Null
    Write-Host "✓ App launched" -ForegroundColor Green
    
    # Step 7: Test instructions
    Write-Host "`n[7/7] UI ENHANCEMENT TEST CHECKLIST:" -ForegroundColor Cyan
    Write-Host @"

STATISTICS TESTING:
==================
1. Go to Profile screen
2. Click "View Stats" button
3. Verify:
   - Charts display correctly
   - Time range selector works (Week/Month/Year/All)
   - Progress line chart shows data
   - Weekly bar chart displays activity
   - Category pie chart shows exercise breakdown
   - Stats cards show correct totals

CSV EXPORT TESTING:
==================
1. In Stats screen, click Export button (top right)
2. Verify:
   - CSV file is created
   - Toast shows file location
   - File contains workout data with headers
   - Summary section is included

LANGUAGE TESTING:
================
1. Go to Settings screen
2. Select Korean language
3. Verify:
   - App restarts automatically
   - All text changes to Korean
   - Language persists after app restart
4. Switch back to English
5. Test "Auto" setting (follows system language)

NAVIGATION TESTING:
==================
1. Test back button on all screens
2. Verify smooth transitions
3. Check that settings persist
4. Ensure no crashes during navigation

Press Enter when testing is complete...
"@ -ForegroundColor Yellow
    
    Read-Host
    
    # Generate test report
    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime
    
    Write-Host "`n===== BUILD COMPLETED SUCCESSFULLY =====" -ForegroundColor Green
    Write-Host "Duration: $($Duration.ToString())" -ForegroundColor Yellow
    Write-Host "APK Location: $($apkFile.FullName)" -ForegroundColor Cyan
    
    # Create summary report
    $summaryReport = @"
UI ENHANCEMENTS BUILD SUMMARY
============================
Build Time: $($StartTime.ToString('yyyy-MM-dd HH:mm:ss'))
Duration: $($Duration.ToString())
APK Size: $([math]::Round($apkFile.Length / 1MB, 2)) MB

Features Added:
- Statistics Dashboard with MPAndroidChart
- CSV Export functionality  
- Working language switching (Korean/English)
- Navigation improvements

Next Steps:
- Test all features thoroughly
- Check memory usage with new charts
- Verify language persistence
- Test CSV export on different data sets
"@

    $summaryPath = Join-Path $ProjectRoot "UI_ENHANCEMENTS_SUMMARY.txt"
    $summaryReport | Set-Content $summaryPath
    Write-Host "`nSummary saved to: $summaryPath" -ForegroundColor Cyan
    
} catch {
    Write-Host "`n===== BUILD FAILED =====" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "Stack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    
    exit 1
}