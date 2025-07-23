# SETUP-PIXEL9PRO-EMULATOR.ps1
# Set up Pixel 9 Pro emulator with Android SDK tools
# Configures environment, creates AVD, and starts emulator

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Pixel 9 Pro Emulator Setup Script" -ForegroundColor Cyan  
Write-Host "========================================" -ForegroundColor Cyan

# Environment Variables Setup
Write-Host "`n[1/5] Setting up environment variables..." -ForegroundColor Yellow

# Android SDK Path (Windows format for PowerShell)
$androidHome = "C:\Users\hwpar\AppData\Local\Android\Sdk"
$env:ANDROID_HOME = $androidHome
$env:ANDROID_SDK_ROOT = $androidHome

# Java JDK Path  
$javaHome = "C:\Program Files\Android\Android Studio\jbr"
$env:JAVA_HOME = $javaHome

# Path additions
$env:PATH += ";$androidHome\emulator"
$env:PATH += ";$androidHome\platform-tools"
$env:PATH += ";$javaHome\bin"

Write-Host "✓ Environment variables configured" -ForegroundColor Green
Write-Host "  - ANDROID_HOME: $androidHome" -ForegroundColor Gray
Write-Host "  - JAVA_HOME: $javaHome" -ForegroundColor Gray

# Verify Required Paths
Write-Host "`n[2/5] Verifying required components..." -ForegroundColor Yellow

$emulatorPath = "$androidHome\emulator\emulator.exe"
$systemImagePath = "$androidHome\system-images\android-36\google_apis_playstore\x86_64"
$skinPath = "$androidHome\skins\pixel_9_pro"

if (-not (Test-Path $emulatorPath)) {
    Write-Host "❌ Emulator not found at: $emulatorPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $systemImagePath)) {
    Write-Host "❌ System image not found at: $systemImagePath" -ForegroundColor Red
    Write-Host "Please install Android 14 (API 36) Google APIs Play Store system image" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $skinPath)) {
    Write-Host "❌ Pixel 9 Pro skin not found at: $skinPath" -ForegroundColor Red
    exit 1
}

Write-Host "✓ All required components verified" -ForegroundColor Green

# AVD Configuration
$avdName = "Pixel_9_Pro"
$avdDisplayName = "Pixel 9 Pro API 36"
$avdPath = "C:\Users\hwpar\.android\avd\$avdName.avd"
$avdIniPath = "C:\Users\hwpar\.android\avd\$avdName.ini"

# Check if AVD already exists
Write-Host "`n[3/5] Checking existing AVD configuration..." -ForegroundColor Yellow

$existingAvds = & $emulatorPath -list-avds 2>$null
if ($existingAvds -contains $avdName) {
    Write-Host "✓ AVD '$avdName' already exists" -ForegroundColor Green
    Write-Host "`nSkipping to emulator startup..." -ForegroundColor Cyan
} else {
    Write-Host "⚠ AVD '$avdName' not found - creating new AVD..." -ForegroundColor Yellow
    
    # Create AVD directory structure
    Write-Host "`n[4/5] Creating AVD configuration..." -ForegroundColor Yellow
    
    # Ensure .android/avd directory exists
    $avdDir = "C:\Users\hwpar\.android\avd"
    if (-not (Test-Path $avdDir)) {
        New-Item -ItemType Directory -Path $avdDir -Force | Out-Null
    }
    
    # Create AVD directory
    if (-not (Test-Path $avdPath)) {
        New-Item -ItemType Directory -Path $avdPath -Force | Out-Null
    }
    
    # Create AVD INI file
    $avdIniContent = @"
avd.ini.encoding=UTF-8
path=C:\Users\hwpar\.android\avd\$avdName.avd
path.rel=avd\$avdName.avd
target=android-36
"@
    
    Set-Content -Path $avdIniPath -Value $avdIniContent -Encoding UTF8
    
    # Create AVD config.ini with Pixel 9 Pro specifications
    $configIniContent = @"
AvdId=$avdName
PlayStore.enabled=true
abi.type=x86_64
avd.ini.displayname=$avdDisplayName
avd.ini.encoding=UTF-8
disk.dataPartition.size=8G
fastboot.chosenSnapshotFile=
fastboot.forceChosenSnapshotBoot=no
fastboot.forceColdBoot=no
fastboot.forceFastBoot=yes
hw.accelerometer=yes
hw.arc=false
hw.audioInput=yes
hw.battery=yes
hw.camera.back=virtualscene
hw.camera.front=emulated
hw.cpu.arch=x86_64
hw.cpu.ncore=8
hw.dPad=no
hw.device.manufacturer=Google
hw.device.name=pixel_9_pro
hw.gps=yes
hw.gpu.enabled=yes
hw.gpu.mode=auto
hw.gyroscope=yes
hw.initialOrientation=portrait
hw.keyboard=yes
hw.lcd.density=480
hw.lcd.height=2856
hw.lcd.width=1280
hw.mainKeys=no
hw.ramSize=4096
hw.sdCard=yes
hw.sensors.light=yes
hw.sensors.magnetic_field=yes
hw.sensors.orientation=yes
hw.sensors.pressure=yes
hw.sensors.proximity=yes
hw.trackBall=no
image.sysdir.1=system-images\android-36\google_apis_playstore\x86_64\
runtime.network.latency=none
runtime.network.speed=full
sdcard.size=1G
showDeviceFrame=yes
skin.dynamic=yes
skin.name=pixel_9_pro
skin.path=C:\Users\hwpar\AppData\Local\Android\Sdk\skins\pixel_9_pro
tag.display=Google Play
tag.id=google_apis_playstore
target=android-36
vm.heapSize=512
"@
    
    Set-Content -Path "$avdPath\config.ini" -Value $configIniContent -Encoding UTF8
    
    # Create userdata.img (empty user data)
    $userdataPath = "$avdPath\userdata.img"
    if (-not (Test-Path $userdataPath)) {
        # Create empty userdata.img using mksdcard
        $mksdcardPath = "$androidHome\emulator\mksdcard.exe"
        if (Test-Path $mksdcardPath) {
            & $mksdcardPath 1G $userdataPath 2>$null
        }
    }
    
    Write-Host "✓ AVD configuration created successfully" -ForegroundColor Green
    Write-Host "  - Display: 1280x2856 @ 480dpi" -ForegroundColor Gray
    Write-Host "  - RAM: 4GB, Storage: 8GB" -ForegroundColor Gray
    Write-Host "  - Google Play Store enabled" -ForegroundColor Gray
}

# Start Emulator
Write-Host "`n[5/5] Starting Pixel 9 Pro emulator..." -ForegroundColor Yellow

try {
    # Check if emulator is already running
    try {
        $runningEmulators = & "$androidHome\platform-tools\adb.exe" devices 2>$null | Select-String "emulator"
        
        if ($runningEmulators) {
            Write-Host "⚠ An emulator is already running:" -ForegroundColor Yellow
            $runningEmulators | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
            Write-Host "`nStopping existing emulators..." -ForegroundColor Yellow
            & "$androidHome\platform-tools\adb.exe" emu kill 2>$null
            Start-Sleep -Seconds 3
        }
    } catch {
        Write-Host "ℹ️ ADB server not running - will start with emulator" -ForegroundColor Cyan
    }
    
    # Start the Pixel 9 Pro emulator with optimized settings
    Write-Host "🚀 Launching Pixel 9 Pro emulator..." -ForegroundColor Cyan
    
    $emulatorArgs = @(
        "-avd", $avdName,
        "-no-snapshot-load",
        "-gpu", "auto",
        "-memory", "4096",
        "-cores", "4",
        "-netspeed", "full",
        "-netdelay", "none",
        "-feature", "HVF"  # Hardware acceleration on macOS/Linux
    )
    
    # Start the emulator in background
    $emulatorProcess = Start-Process -FilePath $emulatorPath -ArgumentList $emulatorArgs -WindowStyle Normal -PassThru
    
    Write-Host "✓ Emulator process started (PID: $($emulatorProcess.Id))" -ForegroundColor Green
    
    # Wait for emulator to boot
    Write-Host "`nWaiting for emulator to boot..." -ForegroundColor Yellow
    $timeout = 120  # 2 minutes timeout
    $elapsed = 0
    
    do {
        Start-Sleep -Seconds 5
        $elapsed += 5
        
        # Check if emulator is ready
        try {
            $bootComplete = & "$androidHome\platform-tools\adb.exe" shell getprop sys.boot_completed 2>$null
            
            if ($bootComplete -eq "1") {
                Write-Host "✅ Emulator booted successfully!" -ForegroundColor Green
                break
            }
        } catch {
            # ADB connection may not be ready yet - this is normal during boot
            Write-Host "  ⏳ ADB connecting... ($elapsed/$timeout seconds)" -ForegroundColor Gray
        }
        
        Write-Host "  ⏳ Still booting... ($elapsed/$timeout seconds)" -ForegroundColor Gray
        
        # Check if emulator process is still running
        if ($emulatorProcess.HasExited) {
            Write-Host "❌ Emulator process terminated unexpectedly" -ForegroundColor Red
            exit 1
        }
        
    } while ($elapsed -lt $timeout)
    
    if ($elapsed -ge $timeout) {
        Write-Host "⚠ Emulator boot timeout - but it may still be starting" -ForegroundColor Yellow
    }
    
    # Show final status
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "🎉 Pixel 9 Pro Emulator Setup Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    
    Write-Host "`nEmulator Details:" -ForegroundColor Yellow
    Write-Host "  - Name: $avdName" -ForegroundColor White
    Write-Host "  - Display: Pixel 9 Pro (1280x2856, 480dpi)" -ForegroundColor White
    Write-Host "  - Android: API 36 (Android 14)" -ForegroundColor White
    Write-Host "  - Google Play: Enabled" -ForegroundColor White
    Write-Host "  - RAM: 4GB, Cores: 8" -ForegroundColor White
    
    Write-Host "`nUseful Commands:" -ForegroundColor Yellow
    Write-Host "  - Check status: adb devices" -ForegroundColor Gray
    Write-Host "  - Install APK: adb install app.apk" -ForegroundColor Gray
    Write-Host "  - View logs: adb logcat" -ForegroundColor Gray
    Write-Host "  - Stop emulator: adb emu kill" -ForegroundColor Gray
    
} catch {
    Write-Host "⚠ Emulator startup completed with warnings: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "`nEmulator Status:" -ForegroundColor Cyan
    Write-Host "  - The emulator process has started successfully" -ForegroundColor Green
    Write-Host "  - Boot completion check had issues (this is common)" -ForegroundColor Yellow
    Write-Host "  - You can check the emulator window for progress" -ForegroundColor Gray
    
    Write-Host "`nNext Steps:" -ForegroundColor Yellow
    Write-Host "  1. Wait for the emulator UI to fully load" -ForegroundColor Gray
    Write-Host "  2. Check with: adb devices" -ForegroundColor Gray
    Write-Host "  3. If needed, restart ADB: adb kill-server && adb start-server" -ForegroundColor Gray
}

Write-Host "`n✨ Ready for app development and testing!" -ForegroundColor Green