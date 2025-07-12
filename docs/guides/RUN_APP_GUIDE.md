# Quick Guide: Build and Run App on Device

This guide explains the new automated build and run scripts for the Squash Training App.

## Prerequisites

- Android device connected via USB with debugging enabled OR Android emulator running
- ADB installed at: `C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools\adb.exe`
- Java JDK installed at: `C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot`

## New Automated Scripts

### 1. Full Build & Run Script: `build-and-run.ps1`

The most comprehensive option - handles everything from build to launch:

```powershell
# Basic usage - builds and installs the app
.\build-and-run.ps1

# Skip build if APK already exists
.\build-and-run.ps1 -SkipBuild

# Build, install, and launch the app
.\build-and-run.ps1 -LaunchApp

# Build and install without starting Metro
.\build-and-run.ps1 -NoMetro

# Force reinstall even if app exists
.\build-and-run.ps1 -ForceInstall

# Combine options
.\build-and-run.ps1 -SkipBuild -LaunchApp
```

**Features:**
- Automatically detects connected devices
- Handles multiple device selection
- Installs APK after successful build
- Starts Metro bundler automatically
- Sets up port forwarding
- Optionally launches the app

### 2. Enhanced Build Script: `build-simple.ps1`

Now supports automatic installation:

```powershell
# Build only (traditional behavior)
.\build-simple.ps1

# Build and auto-install on connected device
.\build-simple.ps1 -AutoInstall
```

## Common Workflows

### First Time Setup
```powershell
cd C:\Git\Routine_app\SquashTrainingApp\android
.\build-and-run.ps1 -LaunchApp
```

### Quick Rebuild and Run
```powershell
# If you've already built once and just made code changes
.\build-and-run.ps1 -SkipBuild -LaunchApp
```

### Manual Step-by-Step
```powershell
# 1. Build the app
.\build-simple.ps1

# 2. Check connected devices
C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools\adb.exe devices

# 3. Install manually
C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools\adb.exe install app\build\outputs\apk\debug\app-debug.apk

# 4. Set up port forwarding
C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools\adb.exe reverse tcp:8081 tcp:8081

# 5. Start Metro bundler (in project root)
cd ..
npx react-native start
```

## Troubleshooting

### No Devices Found
- Ensure USB debugging is enabled on your Android device
- Check device connection: `adb devices`
- Try reconnecting the USB cable
- For emulators, ensure one is running in Android Studio

### Build Failures
- Check Java version: `java -version` (should be 17)
- Clean build: `.\gradlew.bat clean`
- Check for error messages in build output

### App Crashes or Red Screen
- Shake device to open developer menu
- Select "Reload" to refresh the app
- Check Metro bundler is running
- View logs: `adb logcat *:S ReactNative:V ReactNativeJS:V`

### Metro Connection Issues
- Ensure port forwarding: `adb reverse tcp:8081 tcp:8081`
- Check Metro is running on http://localhost:8081
- Try restarting Metro bundler

## Script Comparison

| Feature | build-simple.ps1 | build-and-run.ps1 |
|---------|-----------------|-------------------|
| Build app | ✓ | ✓ |
| Auto-detect devices | ✓ (basic) | ✓ (advanced) |
| Device selection | ✗ | ✓ |
| Auto-install | Optional (-AutoInstall) | ✓ |
| Start Metro | ✗ | ✓ |
| Launch app | ✗ | Optional (-LaunchApp) |
| Skip build | ✗ | Optional (-SkipBuild) |

## Quick Commands Reference

```powershell
# Create ADB alias for easier access
Set-Alias adb "C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools\adb.exe"

# Common ADB commands
adb devices                    # List connected devices
adb install <apk-path>         # Install APK
adb uninstall com.squashtrainingapp  # Uninstall app
adb reverse tcp:8081 tcp:8081  # Set up port forwarding
adb logcat                     # View all logs
adb shell am start -n com.squashtrainingapp/.MainActivity  # Launch app
```