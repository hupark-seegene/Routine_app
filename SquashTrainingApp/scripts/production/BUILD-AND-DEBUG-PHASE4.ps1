# BUILD-AND-DEBUG-PHASE4.ps1
# Build, install and debug Phase 4 APK with emulator

param(
    [switch]$SkipEmulator = $false,
    [switch]$SkipBuild = $false
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Phase 4 Build, Install & Debug" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Setup paths
$androidHome = $env:ANDROID_HOME
if (-not $androidHome) {
    $androidHome = "$env:LOCALAPPDATA\Android\Sdk"
}

$emulatorPath = "$androidHome\emulator\emulator.exe"
$adbPath = "$androidHome\platform-tools\adb.exe"
$projectRoot = "$PSScriptRoot\..\.."
$androidDir = "$projectRoot\android"

# Check if emulator is running
if (-not $SkipEmulator) {
    Write-Host "Checking emulator status..." -ForegroundColor Yellow
    $devices = & $adbPath devices 2>$null
    
    if ($devices -notmatch "emulator") {
        Write-Host "Starting emulator..." -ForegroundColor Yellow
        
        # Get available AVDs
        $avds = & $emulatorPath -list-avds
        if (-not $avds) {
            Write-Host "No AVDs found! Please create one in Android Studio" -ForegroundColor Red
            exit 1
        }
        
        $selectedAvd = $avds[0]
        Write-Host "Starting AVD: $selectedAvd" -ForegroundColor Green
        
        # Start emulator
        Start-Process -FilePath $emulatorPath -ArgumentList "-avd", $selectedAvd, "-no-snapshot-load" -WindowStyle Normal
        
        # Wait for boot
        Write-Host "Waiting for emulator boot..." -ForegroundColor Yellow
        $maxWait = 120
        $waited = 0
        
        while ($waited -lt $maxWait) {
            Start-Sleep -Seconds 3
            $waited += 3
            
            $bootComplete = & $adbPath shell getprop sys.boot_completed 2>$null
            if ($bootComplete -eq "1") {
                Write-Host "Emulator ready!" -ForegroundColor Green
                break
            }
            
            Write-Host -NoNewline "."
        }
        
        if ($waited -ge $maxWait) {
            Write-Host "`nEmulator boot timeout!" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Emulator already running!" -ForegroundColor Green
    }
}

# Build APK
if (-not $SkipBuild) {
    Write-Host ""
    Write-Host "Building Phase 4 APK..." -ForegroundColor Cyan
    Set-Location $androidDir
    
    # Clean build
    Write-Host "Cleaning previous build..." -ForegroundColor Yellow
    & .\gradlew.bat clean
    
    # Build debug APK
    Write-Host "Building debug APK..." -ForegroundColor Yellow
    & .\gradlew.bat assembleDebug
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Build successful!" -ForegroundColor Green
}

# Find APK
$apkPath = Get-ChildItem -Path "$androidDir\app\build\outputs\apk\debug" -Filter "*.apk" | Select-Object -First 1
if (-not $apkPath) {
    Write-Host "APK not found!" -ForegroundColor Red
    exit 1
}

$fullApkPath = $apkPath.FullName
Write-Host ""
Write-Host "APK: $($apkPath.Name)" -ForegroundColor Green
Write-Host "Size: $([math]::Round($apkPath.Length / 1MB, 2)) MB" -ForegroundColor Gray

# Uninstall existing app
Write-Host ""
Write-Host "Uninstalling existing app..." -ForegroundColor Yellow
& $adbPath uninstall com.squashtrainingapp 2>$null

# Install new APK
Write-Host "Installing Phase 4 APK..." -ForegroundColor Yellow
& $adbPath install -r $fullApkPath

if ($LASTEXITCODE -ne 0) {
    Write-Host "Installation failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Installation successful!" -ForegroundColor Green

# Grant permissions
Write-Host ""
Write-Host "Granting permissions..." -ForegroundColor Yellow
& $adbPath shell pm grant com.squashtrainingapp android.permission.INTERNET
& $adbPath shell pm grant com.squashtrainingapp android.permission.ACCESS_NETWORK_STATE
& $adbPath shell pm grant com.squashtrainingapp android.permission.RECORD_AUDIO
& $adbPath shell pm grant com.squashtrainingapp android.permission.VIBRATE
& $adbPath shell pm grant com.squashtrainingapp android.permission.POST_NOTIFICATIONS

# Clear app data for fresh start
Write-Host "Clearing app data for fresh onboarding..." -ForegroundColor Yellow
& $adbPath shell pm clear com.squashtrainingapp

# Launch app
Write-Host ""
Write-Host "Launching app..." -ForegroundColor Cyan
& $adbPath shell am start -n com.squashtrainingapp/.ui.activities.SplashActivity

# Start logcat monitoring
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Phase 4 App Launched!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Features to test:" -ForegroundColor Cyan
Write-Host "1. Splash screen animation" -ForegroundColor White
Write-Host "2. Onboarding flow (5 screens)" -ForegroundColor White
Write-Host "3. A/B test variant selection" -ForegroundColor White
Write-Host "4. Premium feature showcase" -ForegroundColor White
Write-Host "5. Goal personalization" -ForegroundColor White
Write-Host "6. Login/Registration flow" -ForegroundColor White
Write-Host "7. Referral program access" -ForegroundColor White
Write-Host "8. Social sharing features" -ForegroundColor White
Write-Host ""
Write-Host "Starting LogCat..." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop monitoring" -ForegroundColor Gray
Write-Host ""

# Monitor logcat with filters
& $adbPath logcat -c  # Clear previous logs
& $adbPath logcat "SquashTraining:V" "AndroidRuntime:E" "*:S" | ForEach-Object {
    if ($_ -match "ERROR|FATAL|Exception") {
        Write-Host $_ -ForegroundColor Red
    } elseif ($_ -match "WARN") {
        Write-Host $_ -ForegroundColor Yellow
    } elseif ($_ -match "ABTestVariant|Onboarding|Referral|Share") {
        Write-Host $_ -ForegroundColor Cyan
    } elseif ($_ -match "onCreate|onStart|onClick") {
        Write-Host $_ -ForegroundColor Green
    } else {
        Write-Host $_
    }
}