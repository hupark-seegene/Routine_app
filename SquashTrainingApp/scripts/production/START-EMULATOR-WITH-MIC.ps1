# START-EMULATOR-WITH-MIC.ps1
# Start Android emulator with microphone support

$ErrorActionPreference = "Stop"

# Configuration
$ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$EMULATOR_PATH = "$ANDROID_HOME\emulator"
$AVD_NAME = "Pixel_6"  # Change this to your AVD name

# Colors
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

Write-Info "`n========================================="
Write-Info " Android Emulator with Microphone Support"
Write-Info "========================================="

# Check if emulator is already running
Write-Info "`n[1/4] Checking emulator status..."
$adbDevices = & "$ANDROID_HOME\platform-tools\adb.exe" devices 2>$null
if ($adbDevices -match "emulator-\d+\s+device") {
    Write-Warning "Emulator is already running!"
    $response = Read-Host "Do you want to kill it and restart with mic support? (y/n)"
    if ($response -eq 'y') {
        Write-Info "Killing existing emulator..."
        & "$ANDROID_HOME\platform-tools\adb.exe" emu kill
        Start-Sleep -Seconds 3
    } else {
        Write-Info "Keeping existing emulator."
        exit 0
    }
}

# List available AVDs
Write-Info "`n[2/4] Available AVDs:"
& "$EMULATOR_PATH\emulator.exe" -list-avds

# Start emulator with microphone
Write-Info "`n[3/4] Starting emulator with microphone support..."
Write-Info "AVD: $AVD_NAME"
Write-Info "Options: Audio input enabled with multiple features"

# Set environment variable for better audio support
$env:ANDROID_EMULATOR_USE_SYSTEM_LIBS = "1"

# Start emulator with enhanced audio features
$emulatorArgs = @(
    "-avd", $AVD_NAME,
    "-feature", "VirtualMicrophone",
    "-feature", "AudioInput",
    "-feature", "WindowsHypervisorPlatform",
    "-no-snapshot-load"
)

Write-Info "Starting with args: $($emulatorArgs -join ' ')"

$emulatorProcess = Start-Process -FilePath "$EMULATOR_PATH\emulator.exe" `
    -ArgumentList $emulatorArgs `
    -PassThru -WindowStyle Normal

Write-Success "Emulator starting with PID: $($emulatorProcess.Id)"

# Wait for emulator to boot
Write-Info "`n[4/4] Waiting for emulator to boot..."
$maxWaitTime = 120 # seconds
$waitTime = 0

while ($waitTime -lt $maxWaitTime) {
    Start-Sleep -Seconds 5
    $waitTime += 5
    
    $bootCompleted = & "$ANDROID_HOME\platform-tools\adb.exe" shell getprop sys.boot_completed 2>$null
    if ($bootCompleted -eq "1") {
        Write-Success "Emulator booted successfully!"
        break
    }
    
    Write-Host "." -NoNewline
}

if ($waitTime -ge $maxWaitTime) {
    Write-Error "Emulator failed to boot within $maxWaitTime seconds"
    exit 1
}

# Configure audio settings
Write-Info "`nConfiguring audio settings..."
& "$ANDROID_HOME\platform-tools\adb.exe" shell settings put system microphone_mute 0
Write-Success "Microphone unmuted"

# Grant microphone permissions to our app
Write-Info "`nGranting microphone permission to SquashTrainingApp..."
& "$ANDROID_HOME\platform-tools\adb.exe" shell pm grant com.squashtrainingapp android.permission.RECORD_AUDIO
Write-Success "Permission granted to SquashTrainingApp"

# Grant permission to Google app for testing
Write-Info "Granting microphone permission to Google app..."
& "$ANDROID_HOME\platform-tools\adb.exe" shell pm grant com.google.android.googlequicksearchbox android.permission.RECORD_AUDIO 2>$null
Write-Success "Permission granted to Google app"

# Grant overlay permission for floating button
Write-Info "Granting overlay permission for floating voice button..."
& "$ANDROID_HOME\platform-tools\adb.exe" shell appops set com.squashtrainingapp SYSTEM_ALERT_WINDOW allow 2>$null

Write-Success "`n✓ Emulator is ready with microphone support!"
Write-Info "`nTo test microphone:"
Write-Host "1. Test with Google app first:"
Write-Host "   - Open Google app"
Write-Host "   - Say 'Ok Google' or tap mic icon"
Write-Host ""
Write-Host "2. Test in SquashTrainingApp:"
Write-Host "   - Open the app"
Write-Host "   - Navigate to Record screen"
Write-Host "   - Tap the microphone button"
Write-Host "   - Say: '3세트 기록해줘' or 'Record 3 sets'"
Write-Host ""
Write-Host "3. Test wake word:"
Write-Host "   - Say '헤이 코치' or 'Hey Coach'"
Write-Host "   - The floating mic button should appear"

Write-Info "`nTroubleshooting tips:"
Write-Host "- Ensure Windows microphone privacy is enabled"
Write-Host "- Check your PC microphone is not muted"
Write-Host "- In emulator: Settings > Apps > SquashTraining > Permissions"
Write-Host "- Monitor logs: adb logcat | grep -i 'speech\|voice\|audio'"