# Emulator Voice Recognition Setup Guide

This guide helps you set up voice recognition for the Squash Training App in Android emulators.

## Prerequisites

- Android Studio installed with SDK tools
- Android emulator with Google Play Services (API 28+)
- Microphone access on your host machine

## Setup Steps

### 1. Create/Configure AVD with Audio Support

1. Open Android Studio
2. Go to Tools → AVD Manager
3. Create a new Virtual Device or edit existing
4. Choose a device with Play Store support (has Play Store icon)
5. System Image: Select one with Google APIs or Google Play
6. In Advanced Settings:
   - Enable "Host audio input" 
   - Microphone: Enabled
   - Audio: Host audio input and output

### 2. Enable Microphone in Emulator

1. Start the emulator
2. Click "..." (Extended controls)
3. Go to "Microphone" section
4. Toggle "Virtual microphone uses host audio input" to ON

### 3. Configure Google App

1. Open Google app in emulator
2. Sign in with Google account
3. Go to Settings → Voice
4. Download offline speech recognition:
   - Languages & input → Offline speech recognition
   - Download Korean and English language packs

### 4. Grant Permissions

When you first launch the Squash Training App:

1. Allow microphone permission when prompted
2. If not prompted, go to:
   - Settings → Apps → Squash Training Pro
   - Permissions → Microphone → Allow

### 5. Test Voice Input

1. Launch the app
2. Tap the floating microphone button (FAB)
3. Say a command like:
   - English: "Open profile" or "Show coach"
   - Korean: "프로필 열어" or "코치 보여줘"

## Troubleshooting

### Voice not working?

1. **Check host microphone**: Ensure your PC microphone is working
2. **Restart emulator**: Sometimes audio needs a fresh start
3. **Check volume**: Ensure emulator volume is not muted
4. **Re-enable permissions**: Settings → Apps → Reset app preferences

### Common Issues

- **"Voice recognition not available"**: Install Google app updates from Play Store
- **No response to voice**: Check if host microphone is being used by another app
- **Korean not recognized**: Download Korean language pack in Google Voice settings

### Voice Commands

The app supports these voice commands:

**Navigation (English)**
- "Open profile" / "Go to profile"
- "Show checklist" / "Open checklist"
- "Start recording" / "Open record"
- "Show coach" / "Open coach"
- "View history" / "Show history"
- "Open settings"

**Navigation (Korean)**
- "프로필 열어" / "프로필 보여줘"
- "체크리스트 열어"
- "기록 시작해"
- "코치 보여줘"
- "히스토리 보여줘"
- "설정 열어"

**AI Chat**
- Any other spoken text will open AI Coach chat with your question

## Performance Tips

1. Use x86/x86_64 images for better performance
2. Allocate sufficient RAM (4GB+) to emulator
3. Enable hardware acceleration (Intel HAXM or AMD-V)
4. Close unnecessary apps on host machine

## Alternative: Physical Device Testing

For best voice recognition experience:

1. Enable Developer Options on Android device
2. Enable USB debugging
3. Connect via USB
4. Run: `adb install app-debug.apk`

Physical devices typically provide better voice recognition accuracy than emulators.