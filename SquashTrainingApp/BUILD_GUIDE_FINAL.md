# 🚀 Final Build Guide - Choose Your Method

## Method 1: PowerShell (⭐ RECOMMENDED - Fastest)

**Open Windows PowerShell and run:**

```powershell
cd C:\Git\Routine_app\SquashTrainingApp
npx react-native build-android --mode=debug
```

**Why this is best:**
- ✅ All Java/Android SDK already configured on Windows
- ✅ Best performance (no filesystem translation)
- ✅ Works immediately
- ✅ gradle.properties already has correct paths

## Method 2: WSL with Windows Java (Alternative)

**If you prefer WSL, run this one-time setup:**

```bash
cd /mnt/c/Git/Routine_app/SquashTrainingApp
./setup-wsl-build.sh
source ~/.bashrc

# Then build
npx react-native build-android --mode=debug
```

**Pros/Cons:**
- ✅ Stay in WSL terminal
- ⚠️ Slower due to filesystem overhead
- ⚠️ May have permission issues

## Method 3: Simple Build Script (Most Reliable)

**In PowerShell:**

```powershell
cd C:\Git\Routine_app\SquashTrainingApp\android
.\build-simple.ps1
```

**Why use this:**
- ✅ Handles all edge cases
- ✅ Applies simplified gradle configuration
- ✅ Most reliable for problematic builds

## Quick Troubleshooting

### If build fails in WSL:
```bash
# Check Java is accessible
java -version

# If not, run setup again
./setup-wsl-build.sh
source ~/.bashrc
```

### If build fails in PowerShell:
```powershell
# Clean everything
cd android
.\gradlew clean
cd ..
npx react-native clean

# Try again
npx react-native build-android --mode=debug
```

### Nuclear option - Reset everything:
```powershell
cd C:\Git\Routine_app\SquashTrainingApp
rmdir /s /q node_modules
rmdir /s /q android\.gradle
rmdir /s /q android\build
rmdir /s /q android\app\build
npm install
npx react-native build-android --mode=debug
```

## 📱 After Successful Build

**Install the APK:**
```powershell
adb install android\app\build\outputs\apk\debug\app-debug.apk
```

---

**💡 Pro Tip:** Use PowerShell for Android builds. It's simply faster and more reliable with your current setup.