# SETUP-EMULATOR-MICROPHONE.ps1
# Configure emulator microphone for voice recognition testing

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Emulator Microphone Setup" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$emulatorPath = "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe"

# Check connected devices
Write-Host "`nChecking connected devices..." -ForegroundColor Yellow
$devices = & $adbPath devices | Select-String -Pattern "\tdevice$" | ForEach-Object { $_.Line.Split("`t")[0] }

if ($devices.Count -eq 0) {
    Write-Host "No devices connected!" -ForegroundColor Red
    Write-Host "Please start an emulator first." -ForegroundColor Yellow
    exit 1
}

Write-Host "Found $($devices.Count) device(s):" -ForegroundColor Green
$devices | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }

# Configure microphone permissions
Write-Host "`nConfiguring microphone permissions..." -ForegroundColor Yellow

foreach ($device in $devices) {
    Write-Host "`n[$device] Setting up microphone..." -ForegroundColor Cyan
    
    # Grant RECORD_AUDIO permission
    & $adbPath -s $device shell pm grant com.squashtrainingapp android.permission.RECORD_AUDIO
    Write-Host "✓ RECORD_AUDIO permission granted" -ForegroundColor Green
    
    # Enable microphone in settings
    & $adbPath -s $device shell settings put secure voice_interaction_service com.google.android.googlequicksearchbox/com.google.android.voiceinteraction.GsaVoiceInteractionService
    Write-Host "✓ Voice interaction service configured" -ForegroundColor Green
    
    # Check if Google App is installed
    $googleApp = & $adbPath -s $device shell pm list packages | Select-String "com.google.android.googlequicksearchbox"
    if ($googleApp) {
        Write-Host "✓ Google App found" -ForegroundColor Green
    } else {
        Write-Host "✗ Google App not found - voice recognition may not work" -ForegroundColor Yellow
    }
}

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "Host Microphone Configuration" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

Write-Host "`nIMPORTANT: For voice recognition to work in emulator:" -ForegroundColor Yellow
Write-Host "1. Open Android Studio" -ForegroundColor White
Write-Host "2. Go to Tools -> AVD Manager" -ForegroundColor White
Write-Host "3. Click Edit (pencil icon) on your emulator" -ForegroundColor White
Write-Host "4. Click 'Show Advanced Settings'" -ForegroundColor White
Write-Host "5. Under 'Microphone', select:" -ForegroundColor White
Write-Host "   ✓ 'Virtual microphone uses host audio input'" -ForegroundColor Green
Write-Host "6. Save and restart the emulator" -ForegroundColor White

Write-Host "`nAlternatively, start emulator with microphone enabled:" -ForegroundColor Cyan
Write-Host "emulator -avd <AVD_NAME> -feature VirtualMic" -ForegroundColor Gray

Write-Host "`n======================================" -ForegroundColor Green
Write-Host "Microphone Setup Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Restart the emulator with microphone enabled" -ForegroundColor White
Write-Host "2. Run TEST-VOICE-RECOGNITION.ps1 to test" -ForegroundColor White
Write-Host "3. Or use a physical device for best results" -ForegroundColor White