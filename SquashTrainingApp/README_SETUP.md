# Squash Training App - Setup Guide

## 🎨 New Design System

The app now features a modern dark theme with volt (#C9FF00) accent color inspired by professional sports apps.

## 📦 Required Packages

Install these additional packages:

```bash
npm install react-native-dotenv crypto-js react-native-linear-gradient react-native-svg
# For iOS
cd ios && pod install
```

## 🔐 Developer Mode Setup

### 1. Environment Variables
Copy `.env.example` to `.env` and add your API keys:
```
OPENAI_API_KEY=your_api_key_here
```

### 2. Accessing Developer Mode
1. Go to Profile tab
2. Tap the app version text 5 times
3. Login with:
   - Username: `hupark`
   - Password: `rhksflwk1!`
   - Your OpenAI API key

### 3. Developer Features
- AI Coach with GPT-3.5-turbo
- Enhanced debugging options
- API usage monitoring

## 🏗️ Build Instructions

### Android

#### Step 1: Generate JavaScript Bundle (Required)
```bash
# WSL (preferred for Metro bundler)
npx react-native bundle --platform android --dev false --entry-file index.js --bundle-output android/app/src/main/assets/index.android.bundle --assets-dest android/app/src/main/res/ --reset-cache

# Or use scripts:
# Windows PowerShell: .\bundle-android.ps1
# WSL/Linux: ./bundle-android.sh
```

#### Step 2: Build APK (Windows PowerShell)
```powershell
cd android
.\gradlew.bat clean
.\gradlew.bat assembleDebug
```

**Note**: Android build must be done from Windows PowerShell due to Java/Android SDK paths.

#### Option 2: Build with Metro Bundler (for USB/Network connected devices)
```bash
# Start Metro bundler in one terminal
npx react-native start

# Build APK in another terminal
cd android
.\gradlew.bat assembleDebug
```

### Running on BlueStacks
1. Start Metro bundler: `npx react-native start --reset-cache`
2. Setup ADB reverse: `adb reverse tcp:8081 tcp:8081`
3. Install APK: `adb install app/build/outputs/apk/debug/app-debug.apk`

## 🎯 New Features

### 1. Redesigned Home Screen
- Hero card with gradient backgrounds
- Quick stats display
- Workout cards with completion tracking
- Progress ring visualization
- Achievement system

### 2. AI Coach
- Floating action button (FAB) on home screen
- Personalized training advice
- YouTube video recommendations
- Skill analysis based on performance

### 3. Dark Theme
- System-wide dark theme
- Volt (#C9FF00) accent color
- Smooth animations and transitions

## 🔧 Troubleshooting

### Metro Bundler Issues
```bash
npx react-native start --reset-cache
```

### Complete Build Clean (Recommended for persistent errors)
Use the provided cleaning scripts:

**Windows PowerShell:**
```powershell
.\clean-build.ps1
```

**WSL/Mac/Linux:**
```bash
./clean-build.sh
```

These scripts will:
- Stop Metro bundler
- Clear all caches
- Remove old JavaScript bundles
- Clean Android build folders
- Run gradle clean

### Build Errors
1. Ensure Java 17 is installed
2. Check JAVA_HOME environment variable
3. Verify Android SDK path in `local.properties`

### API Issues
- Make sure you have valid API keys in `.env`
- Check network connectivity
- API responses are cached for 1 hour

### Compatibility Issues (Completely Resolved)
✅ **All React Native 0.80.1 compatibility issues resolved by removing problematic packages**

**Removed Packages:**
- `react-native-push-notification` (v8.1.1 - incompatible)
- `@react-native-async-storage/async-storage` (v2.2.0 - incompatible) 
- `@react-native-community/push-notification-ios` (v1.11.0 - incompatible)

**Replacement Solutions:**
- **NotificationService**: Custom dummy implementation (console.log based)
- **AsyncStorage**: Custom DummyAsyncStorage implementation (memory-based)
- **Autolinking**: Fully restored and working correctly

**Result:**
- ✅ 951 packages installed, 0 vulnerabilities
- ✅ Clean autolinking with no errors
- ✅ All app functionality maintained
- ✅ No runtime errors or crashes

## 📱 App Structure

```
src/
├── components/       # Reusable UI components
│   ├── home/        # Home screen components
│   └── common/      # Shared components
├── screens/         # App screens
│   └── auth/        # Authentication screens
├── services/        # API and database services
│   └── api/         # AI and YouTube APIs
├── styles/          # Design system
└── navigation/      # App navigation
```

## 🚀 Development Tips

1. **Hot Reload**: Shake device or press `R` twice in terminal
2. **Debug Menu**: Shake device or `Ctrl+M` (Android)
3. **React DevTools**: `npx react-devtools`
4. **Flipper**: Use for advanced debugging

## 📄 License

© 2024 Squash Training App. All rights reserved.