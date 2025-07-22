# BUILD-PHASE4-APK.ps1
# Build and install the Squash Training App with all Phase 4 features

param(
    [switch]$SkipClean = $false,
    [switch]$SkipInstall = $false
)

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Phase 4 Build Script" -ForegroundColor Cyan
Write-Host "Premium Onboarding & Marketing Features" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to Android directory
$androidDir = "$PSScriptRoot\..\..\android"
Set-Location $androidDir

# Clean build if not skipped
if (-not $SkipClean) {
    Write-Host "Cleaning build directories..." -ForegroundColor Yellow
    & .\gradlew.bat clean
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Clean failed! Exit code: $LASTEXITCODE" -ForegroundColor Red
        exit 1
    }
}

# Build APK
Write-Host "Building APK with Phase 4 features..." -ForegroundColor Green
Write-Host "- Splash Screen with animations" -ForegroundColor Gray
Write-Host "- Premium Onboarding Flow" -ForegroundColor Gray
Write-Host "- A/B Testing variants" -ForegroundColor Gray
Write-Host "- Referral System" -ForegroundColor Gray
Write-Host "- Social Sharing" -ForegroundColor Gray
Write-Host ""

& .\gradlew.bat assembleDebug
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed! Exit code: $LASTEXITCODE" -ForegroundColor Red
    exit 1
}

# Find the built APK
$apkPath = Get-ChildItem -Path "app\build\outputs\apk\debug" -Filter "*.apk" | Select-Object -First 1
if (-not $apkPath) {
    Write-Host "APK not found!" -ForegroundColor Red
    exit 1
}

$fullApkPath = $apkPath.FullName
Write-Host "APK built successfully: $fullApkPath" -ForegroundColor Green
Write-Host "Size: $([math]::Round($apkPath.Length / 1MB, 2)) MB" -ForegroundColor Gray

# Install APK if not skipped
if (-not $SkipInstall) {
    Write-Host ""
    Write-Host "Installing APK to device..." -ForegroundColor Yellow
    
    # Check for connected devices
    $devices = & adb devices | Select-String -Pattern "device$"
    if ($devices.Count -eq 0) {
        Write-Host "No devices connected! Please start an emulator or connect a device." -ForegroundColor Red
        exit 1
    }
    
    # Uninstall existing app
    Write-Host "Uninstalling existing app..." -ForegroundColor Gray
    & adb uninstall com.squashtrainingapp 2>$null
    
    # Install new APK
    & adb install -r $fullApkPath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Installation failed!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Installation successful!" -ForegroundColor Green
    
    # Launch the app
    Write-Host "Launching app..." -ForegroundColor Yellow
    & adb shell am start -n com.squashtrainingapp/.ui.activities.SplashActivity
    
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "Phase 4 Features to Test:" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "1. Splash Screen Animation" -ForegroundColor White
    Write-Host "2. Onboarding Flow (5 screens)" -ForegroundColor White
    Write-Host "3. Premium Features Showcase" -ForegroundColor White
    Write-Host "4. Referral Program Access" -ForegroundColor White
    Write-Host "5. Social Sharing Options" -ForegroundColor White
    Write-Host ""
    Write-Host "Check LogCat for A/B test variant:" -ForegroundColor Yellow
    Write-Host "adb logcat | findstr 'ABTestVariant'" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Build complete!" -ForegroundColor Green