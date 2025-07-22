# TEST-MICROPHONE-PERMISSION.ps1
# Script to test and verify microphone permissions in Android Emulator

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing Microphone Permissions" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Function to check if emulator is running
function Check-EmulatorRunning {
    $adbDevices = & adb devices
    if ($adbDevices -match "emulator") {
        return $true
    }
    return $false
}

# Check emulator
if (-not (Check-EmulatorRunning)) {
    Write-Host "No emulator running! Please start emulator first." -ForegroundColor Red
    exit 1
}

Write-Host "`n1. Checking app permissions..." -ForegroundColor Yellow
$permissions = & adb shell dumpsys package com.squashtrainingapp | Select-String -Pattern "android.permission.RECORD_AUDIO"
if ($permissions) {
    Write-Host "RECORD_AUDIO permission found in manifest" -ForegroundColor Green
} else {
    Write-Host "RECORD_AUDIO permission NOT found!" -ForegroundColor Red
}

Write-Host "`n2. Checking runtime permission status..." -ForegroundColor Yellow
$grantedPerms = & adb shell dumpsys package com.squashtrainingapp | Select-String -Pattern "android.permission.RECORD_AUDIO.*granted=true"
if ($grantedPerms) {
    Write-Host "Microphone permission is GRANTED" -ForegroundColor Green
} else {
    Write-Host "Microphone permission is NOT GRANTED" -ForegroundColor Red
    Write-Host "Granting permission now..." -ForegroundColor Yellow
    & adb shell pm grant com.squashtrainingapp android.permission.RECORD_AUDIO
    Write-Host "Permission granted!" -ForegroundColor Green
}

Write-Host "`n3. Checking audio input devices..." -ForegroundColor Yellow
Write-Host "Available audio devices:" -ForegroundColor Cyan
& adb shell dumpsys media.audio_policy | Select-String -Pattern "Input device" -Context 0,2

Write-Host "`n4. Checking microphone state..." -ForegroundColor Yellow
$micMute = & adb shell settings get system microphone_mute
Write-Host "Microphone mute state: $micMute (0=unmuted, 1=muted)" -ForegroundColor Cyan

if ($micMute -eq "1") {
    Write-Host "Unmuting microphone..." -ForegroundColor Yellow
    & adb shell settings put system microphone_mute 0
    Write-Host "Microphone unmuted!" -ForegroundColor Green
}

Write-Host "`n5. Testing voice recognition service..." -ForegroundColor Yellow
$voiceService = & adb shell dumpsys package com.google.android.googlequicksearchbox | Select-String -Pattern "android.permission.RECORD_AUDIO.*granted=true"
if ($voiceService) {
    Write-Host "Google voice service has microphone access" -ForegroundColor Green
} else {
    Write-Host "Google voice service lacks microphone access" -ForegroundColor Yellow
    Write-Host "Granting permission to Google app..." -ForegroundColor Cyan
    & adb shell pm grant com.google.android.googlequicksearchbox android.permission.RECORD_AUDIO 2>$null
}

Write-Host "`n6. Opening app settings for manual check..." -ForegroundColor Yellow
Write-Host "Opening Squash Training app permissions..." -ForegroundColor Cyan
& adb shell am start -a android.settings.APPLICATION_DETAILS_SETTINGS -d package:com.squashtrainingapp

Write-Host "`n======================================" -ForegroundColor Green
Write-Host "Microphone Test Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

Write-Host "`nTo test microphone in the app:" -ForegroundColor Yellow
Write-Host "1. Open Squash Training app" -ForegroundColor White
Write-Host "2. Go to Record screen" -ForegroundColor White
Write-Host "3. Tap the microphone button" -ForegroundColor White
Write-Host "4. Say: '3세트 기록해줘' or 'Record 3 sets'" -ForegroundColor White

Write-Host "`nIf microphone still doesn't work:" -ForegroundColor Yellow
Write-Host "1. Restart emulator with: emulator -avd <name> -feature WindowsWhpx" -ForegroundColor White
Write-Host "2. Check Windows microphone privacy settings" -ForegroundColor White
Write-Host "3. Test with Google Assistant first" -ForegroundColor White

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")