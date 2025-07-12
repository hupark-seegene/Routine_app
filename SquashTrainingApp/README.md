# Squash Training App 🎾

A comprehensive training application for intermediate to advanced squash players, featuring AI-powered coaching and periodization-based training programs.

## ✨ Features

- **Training Programs**: 4-week, 12-week, and yearly periodized plans
- **AI Coach**: Personalized advice powered by OpenAI GPT-3.5
- **Progress Tracking**: SQLite database for offline data persistence
- **Dark Mode UI**: Elegant design with volt (#C9FF00) accent color
- **Video Recommendations**: YouTube integration for technique videos

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- Android Studio
- Java JDK 17
- Android device or emulator

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd SquashTrainingApp
   ```

2. **Install dependencies**:
   ```bash
   npm install
   # Additional packages for full functionality:
   npm install react-native-dotenv crypto-js react-native-linear-gradient react-native-svg
   ```

3. **Environment Setup**:
   ```bash
   # Copy environment template
   cp .env.example .env
   # Add your OpenAI API key to .env:
   # OPENAI_API_KEY=your_api_key_here
   ```

4. **Build Options**:

   **Option A: Android Studio (Recommended)**
   - Open `android` folder in Android Studio
   - Build → Build APK(s)

   **Option B: PowerShell (Windows)**
   ```powershell
   cd android
   .\WORKING-POWERSHELL-BUILD.ps1
   ```

   **Option C: Automated Build & Run**
   ```powershell
   cd android
   .\build-and-run.ps1 -LaunchApp
   ```

5. **Run the app**:
   ```bash
   npx react-native start
   ```

## 📱 App Structure

- **Home**: Dashboard with progress overview
- **Checklist**: Daily workout tracking
- **Record**: Training history and notes
- **AI Coach**: Real-time coaching advice
- **Profile**: Settings and developer mode

## 🔧 Development

### Tech Stack
- React Native 0.80.1
- TypeScript
- SQLite Storage
- React Navigation
- OpenAI API

### Developer Mode Access
1. Go to Profile tab
2. Tap the app version text 5 times
3. Login with:
   - Username: `hupark`
   - Password: `rhksflwk1!`
   - Your OpenAI API key

**Developer Features:**
- AI Coach with GPT-3.5-turbo
- Enhanced debugging options
- API usage monitoring

## 🏗️ Build Instructions

### Android Build Methods

#### Method 1: Automated Scripts (Recommended)
```powershell
# One-command build and run
cd android
.\FINAL-RUN.ps1

# Interactive menu system
.\quick-run.ps1

# Full automation with device detection
.\build-and-run.ps1 -LaunchApp
```

#### Method 2: React Native CLI
```bash
# From project root
cd SquashTrainingApp
npx react-native build-android --mode=debug
```

#### Method 3: Manual Gradle Build
```powershell
# Windows PowerShell
cd android
.\gradlew.bat clean
.\gradlew.bat assembleDebug
```

### JavaScript Bundle Generation
```bash
# Required for standalone APK
npx react-native bundle --platform android --dev false --entry-file index.js --bundle-output android/app/src/main/assets/index.android.bundle --assets-dest android/app/src/main/res/ --reset-cache
```

### Running on Emulator/Device
```bash
# Start Metro bundler
npx react-native start

# Setup ADB reverse (for development)
adb reverse tcp:8081 tcp:8081

# Install APK
adb install android/app/build/outputs/apk/debug/app-debug.apk
```

## 🔧 Troubleshooting

### Build Issues
- **Java/JAVA_HOME**: Ensure Java 17 is installed and JAVA_HOME is set
- **Android SDK**: Verify Android SDK path in `local.properties`
- **Metro Cache**: Run `npx react-native start --reset-cache`

### Clean Build
```powershell
# Windows
.\clean-build.ps1

# WSL/Linux
./clean-build.sh
```

### Common Solutions
- **Red Screen**: Press 'R' twice in Metro window or shake device → Reload
- **API Issues**: Check `.env` file and network connectivity
- **Build Conflicts**: Use Android Studio for complex builds

## 🎨 Design System

The app features a modern dark theme with:
- **Primary Color**: Dark backgrounds (#1a1a1a)
- **Accent Color**: Volt green (#C9FF00)
- **Typography**: Clean, sports-focused design
- **Components**: Hero cards, progress rings, floating action buttons

## 📄 Documentation

- [Technical Debt](TECHNICAL_DEBT.md) - Known limitations and future improvements
- [Project Plan](../project_plan.md) - Complete development history
- [Build Scripts](scripts/) - Automated build and deployment tools

## 🤝 Contributing

This project is optimized for development with Claude Code. See [CLAUDE.md](../CLAUDE.md) for AI-assisted development guidelines.

## 📄 License

Private project - All rights reserved

---
**Version**: 1.0.0  
**Last Updated**: 2025-07-12