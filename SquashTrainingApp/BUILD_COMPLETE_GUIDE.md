# Squash Training App - Complete Build Guide

## Project Overview
- **Framework**: React Native 0.80.1
- **Language**: TypeScript
- **Target Platform**: Android
- **Development Environment**: Windows + WSL + Android Studio

## Pre-requisites

### System Requirements
1. **Windows**:
   - Windows 10/11
   - Android Studio installed
   - Java JDK 17 (Eclipse Adoptium recommended)
   - Android SDK (API level 34)

2. **WSL**:
   - Node.js 18+
   - npm or yarn
   - Git

### Environment Setup
```powershell
# Windows PowerShell
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
```

## Build Process

### Method 1: Android Studio (Recommended) ✅

1. **Prepare the project**:
   ```bash
   # In WSL
   cd /mnt/c/Git/Routine_app/SquashTrainingApp
   npm install
   ```

2. **Open in Android Studio**:
   - Launch Android Studio on Windows
   - File → Open → Select `C:\Git\Routine_app\SquashTrainingApp\android`
   - Wait for Gradle sync to complete

3. **Build APK**:
   - Build → Build Bundle(s) / APK(s) → Build APK(s)
   - APK location: `android/app/build/outputs/apk/debug/app-debug.apk`

### Method 2: Command Line (Alternative)

1. **Using React Native CLI**:
   ```bash
   # In project root
   cd SquashTrainingApp
   npx react-native build-android --mode=debug
   ```

2. **Using automated scripts**:
   ```powershell
   # Windows PowerShell
   cd C:\Git\Routine_app\SquashTrainingApp\android
   .\build-and-run.ps1 -LaunchApp
   ```

## Running the App

### 1. Connect Android Device
- Enable Developer Mode and USB Debugging
- Connect via USB cable
- Or use Android emulator

### 2. Install APK
```powershell
# Windows PowerShell
cd C:\Git\Routine_app\SquashTrainingApp\android
.\install-apk.ps1 -Launch
```

### 3. Start Metro Bundler
```bash
# In WSL
cd /mnt/c/Git/Routine_app/SquashTrainingApp
npx react-native start
```

### 4. Verify Connection
```powershell
# Windows PowerShell
adb devices
adb reverse tcp:8081 tcp:8081
```

## Project Structure

### Key Directories
```
SquashTrainingApp/
├── src/
│   ├── components/     # UI components
│   ├── screens/        # App screens
│   ├── services/       # API and database services
│   ├── database/       # SQLite models
│   ├── programs/       # Training programs
│   ├── navigation/     # React Navigation setup
│   ├── styles/         # Design system
│   └── types/          # TypeScript types
├── android/            # Android native code
└── ios/               # iOS native code (not configured)
```

### Key Features
1. **Training Programs**: 4-week, 12-week, and yearly plans
2. **AI Coaching**: OpenAI integration for personalized advice
3. **Offline Storage**: SQLite database for data persistence
4. **Dark Theme**: Volt (#C9FF00) accent color

## Troubleshooting

### Common Issues

1. **Gradle Plugin Error**:
   ```
   Plugin with id 'com.facebook.react' not found
   ```
   **Solution**: Use Android Studio or npx react-native build command

2. **Metro Connection Failed**:
   ```powershell
   adb reverse tcp:8081 tcp:8081
   ```

3. **Build Cache Issues**:
   ```powershell
   cd android
   .\gradlew.bat clean
   ```

4. **Java Version Error**:
   Ensure JAVA_HOME points to JDK 17

## Development Workflow

### 1. Make Code Changes
```bash
# In WSL
cd /mnt/c/Git/Routine_app/SquashTrainingApp
# Edit files with your preferred editor
```

### 2. Test Changes
- Metro bundler will auto-reload for JS changes
- For native changes, rebuild the app

### 3. Debug
- Use React Native DevTools (shake device)
- Check logs: `adb logcat`

## Production Build

### 1. Generate Release APK
```bash
cd android
./gradlew assembleRelease
```

### 2. Sign APK
- Create keystore (first time only)
- Configure signing in gradle.properties
- Build signed APK

## API Configuration

### Developer Mode Access
1. Go to Profile tab
2. Tap version text 5 times
3. Login with credentials
4. Enter OpenAI API key

### Required APIs
- OpenAI API (for AI coaching)
- YouTube Data API (for video recommendations)

## Database Management

### SQLite Tables
- user_profile
- training_programs
- workout_logs
- user_memos
- ai_advice
- notification_settings

### Data Migration
- Automatic migration from dummy storage
- Data persists between app sessions

## Performance Notes

### App Size
- Debug APK: ~50MB
- Release APK: ~25MB (after optimization)

### Memory Usage
- Average: 150MB
- Peak: 200MB during AI operations

### Startup Time
- Cold start: 2-3 seconds
- Warm start: <1 second

## Future Improvements

1. **iOS Support**: Configure iOS build
2. **Cloud Sync**: Add user accounts and sync
3. **Background Notifications**: When RN 0.80+ supports
4. **App Store Release**: Production signing and optimization

## Support

For issues or questions:
1. Check TECHNICAL_DEBT.md for known limitations
2. Review error logs with `adb logcat`
3. Ensure all dependencies are installed correctly

---
Last Updated: 2025-07-12