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
Write-Info "Options: -use-host-audio -show-kernel"

# Set environment variable for better audio support
$env:ANDROID_EMULATOR_USE_SYSTEM_LIBS = "1"

# Start emulator in background
$emulatorProcess = Start-Process -FilePath "$EMULATOR_PATH\emulator.exe" `
    -ArgumentList "-avd", $AVD_NAME, "-use-host-audio", "-show-kernel" `
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

# Grant microphone permissions to our app
Write-Info "`nGranting microphone permission to SquashTrainingApp..."
& "$ANDROID_HOME\platform-tools\adb.exe" shell pm grant com.squashtrainingapp android.permission.RECORD_AUDIO

Write-Success "`n✓ Emulator is ready with microphone support!"
Write-Info "`nTo test microphone:"
Write-Host "1. Open SquashTrainingApp"
Write-Host "2. Long press mascot for 2 seconds"
Write-Host "3. Tap the microphone button"
Write-Host "4. Speak into your computer's microphone"

Write-Info "`nTroubleshooting tips:"
Write-Host "- Make sure your computer's microphone is working"
Write-Host "- Check Windows sound settings"
Write-Host "- In emulator: Settings > System > Advanced > Microphone"
Write-Host "- Try: adb shell pm grant com.squashtrainingapp android.permission.RECORD_AUDIO"