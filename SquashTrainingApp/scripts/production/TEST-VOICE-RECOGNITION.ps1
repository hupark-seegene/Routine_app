# Test Voice Recognition System
# Tests the 2-second long press voice recognition functionality

param(
    [switch]$SkipBuild = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Continue"

# Configuration
$EMULATOR_NAME = "Pixel_6"
$PACKAGE_NAME = "com.squashtrainingapp"
$MAIN_ACTIVITY = ".MainActivity"
$ADB = "/mnt/c/Users/hwpar/AppData/Local/Android/Sdk/platform-tools/adb.exe"
$EMULATOR_PATH = "C:\Users\hwpar\AppData\Local\Android\Sdk\emulator\emulator.exe"

function Write-Status {
    param([string]$Message, [string]$Color = "Green")
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor $Color
}

function Write-Error {
    param([string]$Message)
    Write-Status $Message "Red"
}

function Test-EmulatorRunning {
    try {
        $devices = & $ADB devices 2>&1
        return $devices -match "emulator.*device$"
    }
    catch {
        return $false
    }
}

function Start-EmulatorIfNeeded {
    if (Test-EmulatorRunning) {
        Write-Status "Emulator already running"
        return $true
    }
    
    Write-Status "Starting emulator $EMULATOR_NAME"
    Start-Process -FilePath $EMULATOR_PATH -ArgumentList @("-avd", $EMULATOR_NAME) -NoNewWindow
    
    Write-Status "Waiting for emulator to boot..."
    $timeout = 120
    $elapsed = 0
    while (-not (Test-EmulatorRunning) -and $elapsed -lt $timeout) {
        Start-Sleep 5
        $elapsed += 5
        Write-Host "." -NoNewline
    }
    Write-Host ""
    
    if (Test-EmulatorRunning) {
        Write-Status "Emulator started successfully"
        Start-Sleep 10  # Additional boot time
        return $true
    } else {
        Write-Error "Failed to start emulator"
        return $false
    }
}

function Build-App {
    if ($SkipBuild) {
        Write-Status "Skipping build as requested"
        return $true
    }
    
    Write-Status "Building app..."
    Set-Location "android"
    
    # Clean first
    Write-Status "Cleaning previous build..."
    & .\gradlew.bat clean | Out-Null
    
    # Build debug APK
    Write-Status "Building debug APK..."
    & .\gradlew.bat assembleDebug --no-daemon 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Status "Build successful"
        Set-Location ".."
        return $true
    } else {
        Write-Error "Build failed with exit code $LASTEXITCODE"
        Set-Location ".."
        return $false
    }
}

function Install-App {
    $apkPath = "android/app/build/outputs/apk/debug/app-debug.apk"
    
    if (-not (Test-Path $apkPath)) {
        Write-Error "APK not found at $apkPath"
        return $false
    }
    
    Write-Status "Uninstalling previous version..."
    & $ADB uninstall $PACKAGE_NAME 2>&1 | Out-Null
    
    Write-Status "Installing new APK..."
    $result = & $ADB install $apkPath 2>&1
    
    if ($result -match "Success") {
        Write-Status "App installed successfully"
        return $true
    } else {
        Write-Error "Failed to install app: $result"
        return $false
    }
}

function Grant-Permissions {
    Write-Status "Granting audio recording permission..."
    & $ADB shell pm grant $PACKAGE_NAME android.permission.RECORD_AUDIO 2>&1 | Out-Null
    
    Write-Status "Granting other permissions..."
    & $ADB shell pm grant $PACKAGE_NAME android.permission.VIBRATE 2>&1 | Out-Null
    
    Write-Status "Permissions granted"
}

function Start-App {
    Write-Status "Starting app..."
    & $ADB shell am start -n "${PACKAGE_NAME}/${MAIN_ACTIVITY}" 2>&1 | Out-Null
    Start-Sleep 3
    Write-Status "App started"
}

function Take-Screenshot {
    param([string]$Name)
    $filename = "screenshot_${Name}.png"
    & $ADB shell screencap -p "/sdcard/$filename" 2>&1 | Out-Null
    & $ADB pull "/sdcard/$filename" $filename 2>&1 | Out-Null
    & $ADB shell rm "/sdcard/$filename" 2>&1 | Out-Null
    Write-Status "Screenshot saved: $filename"
}

function Test-VoiceRecognition {
    Write-Status "Testing voice recognition system..."
    
    # Take initial screenshot
    Take-Screenshot "01_home_screen"
    
    # Test mascot tap (should show hint)
    Write-Status "Testing mascot tap..."
    & $ADB shell input tap 540 1200  # Center of screen
    Start-Sleep 1
    Take-Screenshot "02_mascot_tap"
    
    # Test 2-second long press for voice recognition
    Write-Status "Testing 2-second long press for voice recognition..."
    & $ADB shell input swipe 540 1200 540 1200 2000  # 2-second hold
    Start-Sleep 1
    Take-Screenshot "03_voice_overlay_should_appear"
    
    # Wait for voice overlay to appear
    Start-Sleep 3
    Take-Screenshot "04_voice_overlay_active"
    
    # Test cancel voice recognition
    Write-Status "Testing voice recognition cancel..."
    & $ADB shell input tap 540 1600  # Tap cancel area
    Start-Sleep 1
    Take-Screenshot "05_voice_overlay_cancelled"
    
    # Test voice recognition again
    Write-Status "Testing voice recognition again..."
    & $ADB shell input swipe 540 1200 540 1200 2000  # 2-second hold
    Start-Sleep 3
    Take-Screenshot "06_voice_overlay_second_test"
    
    # Test drag navigation to different zones
    Write-Status "Testing drag navigation..."
    
    # Drag to Profile zone (top)
    & $ADB shell input swipe 540 1200 540 400 500
    Start-Sleep 1
    Take-Screenshot "07_profile_zone_navigation"
    
    # Go back to home
    & $ADB shell input keyevent 4  # Back button
    Start-Sleep 1
    
    # Drag to Coach zone (right)
    & $ADB shell input swipe 540 1200 800 1200 500
    Start-Sleep 1
    Take-Screenshot "08_coach_zone_navigation"
    
    Write-Status "Voice recognition test completed"
}

function Check-LogMessages {
    Write-Status "Checking log messages for voice recognition..."
    $logOutput = & $ADB logcat -d | Select-String "MainActivity|VoiceRecognition" | Select-Object -Last 20
    
    if ($logOutput) {
        Write-Status "Recent voice recognition log messages:"
        $logOutput | ForEach-Object { Write-Host "  $_" }
    } else {
        Write-Status "No voice recognition log messages found"
    }
}

function Main {
    Write-Status "=== Voice Recognition Test Started ===" "Cyan"
    
    # Navigate to project directory
    Set-Location "C:\Git\Routine_app\SquashTrainingApp"
    
    # Step 1: Start emulator
    if (-not (Start-EmulatorIfNeeded)) {
        Write-Error "Failed to start emulator - aborting test"
        return
    }
    
    # Step 2: Build app
    if (-not (Build-App)) {
        Write-Error "Failed to build app - aborting test"
        return
    }
    
    # Step 3: Install app
    if (-not (Install-App)) {
        Write-Error "Failed to install app - aborting test"
        return
    }
    
    # Step 4: Grant permissions
    Grant-Permissions
    
    # Step 5: Start app
    Start-App
    
    # Step 6: Test voice recognition
    Test-VoiceRecognition
    
    # Step 7: Check logs
    Check-LogMessages
    
    Write-Status "=== Voice Recognition Test Completed ===" "Cyan"
    Write-Status "Check the screenshots to verify voice recognition functionality" "Yellow"
}

# Run the test
Main