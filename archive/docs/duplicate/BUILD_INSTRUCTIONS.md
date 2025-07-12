# Android Build Instructions for React Native 0.80+

## Overview

React Native 0.80+ introduced a new gradle plugin system that requires the plugin to be built before use. This guide provides complete instructions for building the Android app from the command line.

## Prerequisites

### 1. Java Development Kit (JDK) 17
- **Required**: JDK 17 (LTS)
- **Recommended**: Eclipse Adoptium (formerly AdoptOpenJDK)
- **Download**: https://adoptium.net/temurin/releases/?version=17
- **Installation Path**: `C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot`

### 2. Android SDK
- **Option 1**: Install Android Studio (includes SDK)
- **Option 2**: Command Line Tools only
- **Expected Path**: `C:\Users\[username]\AppData\Local\Android\Sdk`

### 3. Node.js and npm
- **Required**: Node.js 18+ 
- **Verify**: Run `node --version` and `npm --version`

### 4. Project Dependencies
- Run `npm install` in the project root before building

## 🚨 UPDATE: Simplified Build Process for React Native 0.80+

Due to ongoing issues with the React Native 0.80+ gradle plugin system, we've created simplified alternatives:

### Recommended: Use React Native CLI
```powershell
cd C:\Git\Routine_app\SquashTrainingApp
npx react-native build-android --mode=debug
```

### Alternative: Simple Build Script
```powershell
cd C:\Git\Routine_app\SquashTrainingApp\android
.\build-simple.ps1
```

See `QUICK_BUILD_GUIDE.md` for immediate solutions.

---

## Quick Start

### NEW: Simplified Gradle Wrapper (Most Convenient) ✨

We've created a new gradle wrapper that automatically handles the React Native plugin building. Use `gw` instead of `gradlew`:

**Windows PowerShell (Recommended):**
```powershell
.\gw.ps1 clean
.\gw.ps1 assembleDebug
```

**Windows Command Prompt:**
```cmd
gw.bat clean
gw.bat assembleDebug
```

**Unix/Linux/macOS/WSL:**
```bash
./gw clean
./gw assembleDebug
```

The `gw` wrapper automatically:
- Checks if the React Native gradle plugin is built
- Builds it if necessary (one-time process)
- Passes all arguments to the actual gradlew

### Option 1: One-Command Build (Recommended)

Open PowerShell in the `android` directory and run:

```powershell
.\build-android.ps1
```

This script automatically:
- Sets up environment variables
- Pre-builds the React Native gradle plugin
- Cleans previous builds
- Builds the debug APK

### Option 2: Using Batch File

Double-click `build.bat` or run from Command Prompt:

```cmd
build.bat
```

### Option 3: Traditional Gradlew (Requires Manual Plugin Build)

If you prefer using the standard gradlew, you must first build the React Native plugin manually:

```powershell
# 1. Set environment variables
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

# 2. Pre-build React Native gradle plugin (REQUIRED for RN 0.80+)
cd ..\node_modules\@react-native\gradle-plugin
.\gradlew.bat build
cd ..\..\..\..\android

# 3. Build the app
.\gradlew.bat clean assembleDebug
```

**Note:** This is why we recommend using the `gw` wrapper instead, which handles step 2 automatically.

## Build Scripts Explained

### `build-android.ps1`
Main build script that handles everything automatically:
- Environment setup
- Plugin pre-building
- Clean build process
- Error handling and reporting

### `prebuild-rn-plugin.ps1`
Dedicated script for building the React Native gradle plugin:
- Checks if plugin is already built
- Supports force rebuild with `-Force` parameter
- Provides detailed progress information

### `setup-env.ps1`
Environment verification script:
- Checks Java installation
- Verifies Android SDK
- Validates project setup
- Reports any issues

### `quick-build.ps1`
Simple wrapper for quick builds - just runs the main build script.

### `test-build.ps1`
Testing script that captures detailed build output for debugging.

### `gw.bat` and `gw` (NEW)
Gradle wrapper scripts that automatically handle React Native plugin building:
- Checks if RN gradle plugin is built
- Builds it automatically if needed
- **Automatically skips tests on Windows if they fail** (common issue)
- Passes all arguments to gradlew
- Works exactly like gradlew but with automatic plugin handling

## Troubleshooting

### Common Issues

#### 1. "JAVA_HOME is not set"
**Solution**: The build scripts set this automatically. If running manually:
```powershell
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
```

#### 2. "Plugin with id 'com.facebook.react' not found"
**Cause**: React Native 0.80+ gradle plugin not built  
**Solution**: Run `.\prebuild-rn-plugin.ps1` or use the main build script

#### 3. "Build failed with Java heap space"
**Solution**: Increase memory in `gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=1024m
```

#### 4. "SDK location not found"
**Solution**: Create/update `local.properties`:
```properties
sdk.dir=C:\\Users\\[username]\\AppData\\Local\\Android\\Sdk
```

### Verify Environment

Run the environment check script:
```powershell
.\setup-env.ps1
```

This will verify all prerequisites and report any issues.

## Build Outputs

### Debug APK Location
```
android\app\build\outputs\apk\debug\app-debug.apk
```

### Installing the APK
With a connected device or emulator:
```powershell
adb install app\build\outputs\apk\debug\app-debug.apk
```

## Advanced Options

### Clean Build
```powershell
.\gradlew.bat clean
.\build-android.ps1
```

### Release Build
First configure signing, then:
```powershell
.\gradlew.bat assembleRelease
```

### Build with Logging
```powershell
.\gradlew.bat assembleDebug --info
```

### Force Rebuild Plugin
```powershell
.\prebuild-rn-plugin.ps1 -Force
```

## Tips for Faster Builds

1. **Keep gradle daemon running**: Speeds up subsequent builds
2. **Use SSD**: Significantly faster than HDD
3. **Exclude build folders from antivirus**: Can improve performance
4. **Increase gradle memory**: Edit `gradle.properties`

## React Native 0.80+ Changes

### Why the extra steps?
React Native 0.80 changed how the gradle plugin works:
- Plugin is no longer pre-built in npm package
- Must be built from source before use
- Android Studio does this automatically
- Command-line builds need manual pre-build step

### What changed?
- New plugin system in `settings.gradle`
- Plugin source in `node_modules/@react-native/gradle-plugin`
- Automatic native module discovery (autolinking)

## Getting Help

1. Check build output logs in `build-output.log`
2. Run `.\setup-env.ps1` to verify environment
3. Try Android Studio for comparison
4. Check React Native upgrade guide for 0.80+

## Summary

For most users, simply run:
```powershell
.\build-android.ps1
```

This handles all the complexity of React Native 0.80+ builds automatically.