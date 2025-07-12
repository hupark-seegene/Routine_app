# Android Studio Fix for React Native 0.80+

## Quick Fix (Try This First!)

### From Windows PowerShell:
```powershell
cd C:\Git\Routine_app\SquashTrainingApp\android

# Step 1: Build the React Native gradle plugin (REQUIRED!)
.\build-rn-plugin.ps1

# Step 2: Apply Android Studio fixes
.\fix-android-studio.ps1
```

Then open Android Studio and sync the project.

## Why This Is Needed

React Native 0.80+ requires gradle plugin JARs to be built from source, but these JARs don't exist by default. The `build-rn-plugin.ps1` script builds these required JARs before Android Studio can use them.

## Manual Fix Steps

### 1. Build React Native Plugin First
```powershell
cd C:\Git\Routine_app\SquashTrainingApp\node_modules\@react-native\gradle-plugin
.\gradlew.bat build -x test
```

### 2. Clear Android Studio Caches
1. Close Android Studio
2. Delete these directories:
   - `C:\Git\Routine_app\SquashTrainingApp\android\.gradle`
   - `C:\Git\Routine_app\SquashTrainingApp\android\.idea`
   - `C:\Users\[YourUsername]\.gradle\caches`

### 3. Open in Android Studio
1. Open Android Studio
2. File → Open → Navigate to `C:\Git\Routine_app\SquashTrainingApp\android`
3. Wait for sync to complete

### 4. If Sync Still Fails
1. File → Invalidate Caches → Invalidate and Restart
2. After restart, let it sync again
3. If still failing, try Build → Clean Project

## Alternative: Use Studio-Compatible Configuration

The project includes `*.studio` gradle files that are optimized for Android Studio:

```powershell
# Apply studio configuration
Copy-Item settings.gradle.studio settings.gradle -Force
Copy-Item build.gradle.studio build.gradle -Force
```

## Understanding the Issue

React Native 0.80+ uses a new gradle plugin system that:
- Requires the plugin to be built from source
- Uses `includeBuild()` which has issues on Windows
- Android Studio sometimes can't resolve the plugin path

The fix applies a configuration that:
- Uses direct JAR references instead of `includeBuild()`
- Adds all required dependencies to classpath
- Properly registers the plugin classes

## If Everything Fails

### Option 1: Use Command Line Build
```powershell
cd C:\Git\Routine_app\SquashTrainingApp
npm install
cd android
.\gradlew.bat assembleDebug
```

### Option 2: Downgrade React Native
Edit `package.json`:
```json
"react-native": "0.73.9"
```

Then:
```powershell
npm install
cd android
.\gradlew.bat clean assembleDebug
```

### Option 3: Use Minimal Configuration
```powershell
Copy-Item settings.gradle.minimal settings.gradle -Force
Copy-Item build.gradle.minimal build.gradle -Force
Copy-Item app\build.gradle.minimal app\build.gradle -Force
```

This bypasses the React Native plugin entirely but still allows building.

## Verification

After successful sync in Android Studio:
1. Build → Build Bundle(s) / APK(s) → Build APK(s)
2. The APK will be in: `app\build\outputs\apk\debug\app-debug.apk`

## Troubleshooting

**Error: "com/android/build/api/variant/AndroidComponentsExtension"**
- This means the React Native gradle plugin JARs are missing
- Solution: Run `.\build-rn-plugin.ps1` first, then `.\fix-android-studio.ps1`
- If still failing, check that JARs exist in:
  - `node_modules\@react-native\gradle-plugin\settings-plugin\build\libs\`
  - `node_modules\@react-native\gradle-plugin\react-native-gradle-plugin\build\libs\`

**Error: "Could not find com.facebook.react:react-native:0.80.1"**
- Run `npm install` in project root
- Make sure `node_modules` exists

**Error: "Plugin with id 'com.facebook.react' not found"**
- Run `.\build-rn-plugin.ps1` to build the plugin JARs
- Then run `.\fix-android-studio.ps1`
- Make sure plugin JARs exist in node_modules

**Error: "Cannot resolve symbol 'ReactApplication'"**
- This is normal during sync, will resolve after successful build
- Try Build → Rebuild Project

## Support

This is a known issue with React Native 0.80+ on Windows. The React Native team is aware and working on improvements. For now, these workarounds are necessary.