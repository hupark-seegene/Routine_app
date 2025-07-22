# Android Emulator Microphone Setup Guide

This guide explains how to enable microphone access in Android Emulator for voice recognition features.

## Quick Setup

Run the automated setup script:
```powershell
cd SquashTrainingApp/scripts/production
.\SETUP-EMULATOR-MICROPHONE.ps1
```

## Manual Setup Steps

### 1. Configure AVD Settings

Before starting the emulator, configure your AVD:

1. Open Android Studio
2. Go to Tools > AVD Manager
3. Click Edit (pencil icon) on your AVD
4. Click "Show Advanced Settings"
5. Under "Microphone", select "Virtual microphone uses host audio input"
6. Save the AVD

### 2. Start Emulator with Audio Features

Start emulator with specific flags:
```bash
emulator -avd <your_avd_name> -feature VirtualMicrophone -feature AudioInput
```

Or use Windows Hypervisor Platform (better audio support):
```bash
emulator -avd <your_avd_name> -feature WindowsHypervisorPlatform
```

### 3. Grant Permissions

After emulator boots, grant microphone permission:
```bash
adb shell pm grant com.squashtrainingapp android.permission.RECORD_AUDIO
```

### 4. Configure Audio Settings

Ensure microphone is not muted:
```bash
adb shell settings put system microphone_mute 0
```

## Windows-Specific Setup

### Check Windows Microphone Privacy

1. Open Windows Settings
2. Go to Privacy & Security > Microphone
3. Ensure "Microphone access" is ON
4. Allow desktop apps to access microphone
5. Check that Android Studio/Emulator has permission

### Windows Sound Settings

1. Right-click speaker icon in system tray
2. Select "Sound settings"
3. Under Input, select your microphone
4. Test microphone and adjust volume
5. Ensure it's not muted

## Troubleshooting

### Issue: No Audio Input Detected

**Solution 1: Cold Boot**
```bash
# Stop emulator
adb emu kill

# Start with cold boot
emulator -avd <avd_name> -no-snapshot-load -feature AudioInput
```

**Solution 2: Use x86 Images**
- x86/x86_64 images have better audio support than ARM images
- Use Google APIs image (not Google Play)

**Solution 3: Check AVD Config**
Edit `~/.android/avd/<avd_name>.avd/config.ini`:
```ini
hw.audioInput=yes
hw.microphone=yes
```

### Issue: Permission Denied

**Solution:**
1. Uninstall and reinstall app:
```bash
adb uninstall com.squashtrainingapp
adb install app-debug.apk
adb shell pm grant com.squashtrainingapp android.permission.RECORD_AUDIO
```

2. Or reset permissions:
```bash
adb shell pm reset-permissions com.squashtrainingapp
adb shell pm grant com.squashtrainingapp android.permission.RECORD_AUDIO
```

### Issue: Voice Recognition Not Working

**Test with Google App:**
```bash
# Open Google app
adb shell am start com.google.android.googlequicksearchbox

# Grant permission if needed
adb shell pm grant com.google.android.googlequicksearchbox android.permission.RECORD_AUDIO
```

If Google voice search works but your app doesn't, check:
- Internet connection in emulator
- Language settings (Settings > System > Languages)
- Speech recognition service enabled

## Testing Voice Features

### 1. Test Microphone Hardware
```bash
# Open sound recorder
adb shell am start -a android.provider.MediaStore.RECORD_SOUND_ACTION
```

### 2. Test in Squash Training App
1. Open the app
2. Navigate to Record screen
3. Tap microphone button
4. Say: "3세트 기록해줘" or "Record 3 sets"
5. Check if input is recognized

### 3. Run Permission Test Script
```powershell
.\TEST-MICROPHONE-PERMISSION.ps1
```

## Best Practices

1. **Use Physical Device**: For best voice recognition, use a real Android device
2. **Emulator API Level**: Use API 30+ for better audio support
3. **Network**: Ensure emulator has internet access for cloud speech recognition
4. **Language**: Set system language to Korean for better Korean recognition

## Alternative: Use Physical Device

For most reliable voice recognition:
```bash
# Connect Android device via USB
adb devices

# Install app
adb install app-debug.apk

# Grant permission
adb shell pm grant com.squashtrainingapp android.permission.RECORD_AUDIO
```

## Emulator Command Reference

```bash
# List AVDs
emulator -list-avds

# Start with all audio features
emulator -avd <name> -feature VirtualMicrophone,AudioInput,WindowsHypervisorPlatform

# Start with verbose logging
emulator -avd <name> -verbose -feature AudioInput

# Check audio devices
adb shell dumpsys media.audio_policy

# Monitor logcat for audio
adb logcat | grep -i "audio\|speech\|voice\|microphone"
```