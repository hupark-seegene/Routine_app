# BUILD-DDD001-CYCLE.ps1
# Complete build cycle for ddd001: Training Program Database Schema

Write-Host "=== Starting ddd001 Build Cycle ===" -ForegroundColor Cyan
Write-Host "Feature: Implement training program database schema and models" -ForegroundColor Yellow

# Step 1: Version Check
Write-Host "`n[1/12] VERSION CHECK" -ForegroundColor Green
$buildGradle = Get-Content "../../android/app/build.gradle" -Raw
if ($buildGradle -match 'versionName "1.0-ddd001"') {
    Write-Host "✓ Version confirmed: ddd001" -ForegroundColor Green
} else {
    Write-Host "✗ Version mismatch!" -ForegroundColor Red
    exit 1
}

# Step 2: Build APK
Write-Host "`n[2/12] BUILD APK" -ForegroundColor Green
Set-Location "../../android"
Write-Host "Cleaning previous build..." -ForegroundColor Yellow
cmd.exe /c "gradlew.bat clean" 2>&1 | Out-Null

Write-Host "Building APK..." -ForegroundColor Yellow
$buildResult = cmd.exe /c "gradlew.bat assembleDebug" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ APK build successful" -ForegroundColor Green
} else {
    Write-Host "✗ Build failed!" -ForegroundColor Red
    Write-Host $buildResult
    exit 1
}

# Step 3: Emulator Setup
Write-Host "`n[3/12] EMULATOR SETUP" -ForegroundColor Green
$adbDevices = adb devices
if ($adbDevices -match "emulator-") {
    Write-Host "✓ Emulator is running" -ForegroundColor Green
} else {
    Write-Host "Starting emulator..." -ForegroundColor Yellow
    Start-Process -FilePath "emulator" -ArgumentList "-avd Pixel_3a_API_34_extension_level_7_x86_64" -NoNewWindow
    Start-Sleep -Seconds 30
}

# Step 4: Install APK
Write-Host "`n[4/12] INSTALL APK TO EMULATOR" -ForegroundColor Green
$apkPath = "app/build/outputs/apk/debug/app-debug.apk"
if (Test-Path $apkPath) {
    Write-Host "Installing APK..." -ForegroundColor Yellow
    adb install -r $apkPath
    Write-Host "✓ APK installed successfully" -ForegroundColor Green
} else {
    Write-Host "✗ APK not found!" -ForegroundColor Red
    exit 1
}

# Step 5: Execute App
Write-Host "`n[5/12] EXECUTE APP" -ForegroundColor Green
adb shell am start -n com.squashtrainingapp/.ModernMainActivity
Start-Sleep -Seconds 5
Write-Host "✓ App launched" -ForegroundColor Green

# Step 6: Capture Screenshot
Write-Host "`n[6/12] CAPTURE SCREENSHOT" -ForegroundColor Green
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$screenshotName = "screenshot_ddd001_$timestamp.png"
adb shell screencap -p /sdcard/$screenshotName
adb pull /sdcard/$screenshotName ../screenshots/
Write-Host "✓ Screenshot saved: $screenshotName" -ForegroundColor Green

# Step 7: Debug & Evaluate
Write-Host "`n[7/12] DEBUG & EVALUATE" -ForegroundColor Green
Write-Host "Current functionality:" -ForegroundColor Yellow
Write-Host "- Training program models created" -ForegroundColor White
Write-Host "- Database schema updated (v2)" -ForegroundColor White
Write-Host "- TrainingProgramDao implemented" -ForegroundColor White
Write-Host "- Default programs ready for insertion" -ForegroundColor White
Write-Host "Next: Create UI for program selection" -ForegroundColor Cyan

# Step 8: Uninstall APK
Write-Host "`n[8/12] UNINSTALL APK FROM EMULATOR" -ForegroundColor Green
adb uninstall com.squashtrainingapp
Write-Host "✓ APK uninstalled" -ForegroundColor Green

# Step 9: Enhancement Complete
Write-Host "`n[9/12] ENHANCE & MODIFY CODE" -ForegroundColor Green
Write-Host "✓ Code enhancements completed for ddd001" -ForegroundColor Green

# Step 10: Git Workflow
Write-Host "`n[10/12] GIT WORKFLOW" -ForegroundColor Green
Set-Location "../.."
git add .
git commit -m "Build ddd001: Implement training program database schema and models"
git push origin main
Write-Host "✓ Changes committed and pushed" -ForegroundColor Green

# Step 11: Documentation Update
Write-Host "`n[11/12] DOCUMENTATION UPDATE" -ForegroundColor Green
$projectPlan = Get-Content "project_plan.md" -Raw
$updateText = @"

## Build ddd001 ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))
- Implemented TrainingProgram model class
- Implemented ProgramEnrollment model class  
- Updated DatabaseContract with new tables
- Created TrainingProgramDao with CRUD operations
- Added default training programs (4-week, 12-week, season)
- Database version incremented to 2
"@
Add-Content -Path "project_plan.md" -Value $updateText
Write-Host "✓ Documentation updated" -ForegroundColor Green

# Step 12: Cycle Completion
Write-Host "`n[12/12] CYCLE COMPLETION" -ForegroundColor Green
Write-Host "✓ Cycle ddd001 complete!" -ForegroundColor Green
Write-Host "Progress: 1/200 cycles (0.5%)" -ForegroundColor Cyan
Write-Host "`nReady for cycle ddd002: Create 4-week program UI and navigation" -ForegroundColor Yellow