# Quick Build Guide - Immediate Solution

## 🚀 Fastest Way to Build (Recommended)

### Option 1: Use React Native CLI (Simplest)

Open PowerShell in the **project root** (not android folder):

```powershell
cd C:\Git\Routine_app\SquashTrainingApp

# Clean build
npx react-native clean

# Build Android app
npx react-native build-android --mode=debug
```

**Why this works:**
- React Native CLI handles all the gradle plugin complexity
- No need to worry about plugin configurations
- Automatically manages all dependencies

### Option 2: Direct Gradle with Environment Setup

If you must use gradlew directly, set up environment first:

```powershell
cd C:\Git\Routine_app\SquashTrainingApp\android

# Set environment
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

# Build
.\gradlew.bat assembleDebug --no-daemon --no-build-cache
```

### Option 3: Use Android Studio (Most Stable)

1. Open Android Studio
2. File → Open → Select `C:\Git\Routine_app\SquashTrainingApp\android`
3. Wait for "Gradle sync" to complete
4. Build → Build APK(s)

## 📱 Installing the APK

Once built, install using:

```powershell
# Find your APK
dir C:\Git\Routine_app\SquashTrainingApp\android\app\build\outputs\apk\debug\

# Install (make sure device/emulator is connected)
adb install C:\Git\Routine_app\SquashTrainingApp\android\app\build\outputs\apk\debug\app-debug.apk

# Or use the new automated scripts:
.\build-and-run.ps1              # Build, install, and run with device detection
.\build-simple.ps1 -AutoInstall   # Build and auto-install
```

## 🔧 If Build Still Fails

1. **Clear all caches:**
   ```powershell
   cd C:\Git\Routine_app\SquashTrainingApp
   npx react-native clean
   cd android
   .\gradlew.bat clean
   rmdir /s /q .gradle
   rmdir /s /q build
   rmdir /s /q app\build
   ```

2. **Reset node_modules:**
   ```powershell
   cd C:\Git\Routine_app\SquashTrainingApp
   rmdir /s /q node_modules
   npm install
   ```

3. **Try the npx command again**

## 💡 Why Traditional gradlew Fails

React Native 0.80+ introduced a complex gradle plugin system that:
- Requires plugins to be built before use
- Uses `includeBuild()` which is fragile on Windows
- Has circular dependency issues

The `npx react-native` command bypasses these issues by handling everything internally.

---

**For permanent solution, see the refactored build configuration in the next section.**