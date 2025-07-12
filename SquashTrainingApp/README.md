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
   ```

3. **Build the app**:
   - Open `android` folder in Android Studio
   - Build → Build APK(s)

4. **Run the app**:
   ```bash
   npx react-native start
   ```

For detailed instructions, see [BUILD_COMPLETE_GUIDE.md](BUILD_COMPLETE_GUIDE.md)

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

### Developer Mode
1. Go to Profile tab
2. Tap version text 5 times
3. Enter credentials and API key

## 📄 Documentation

- [Build Guide](BUILD_COMPLETE_GUIDE.md) - Complete build instructions
- [Technical Debt](TECHNICAL_DEBT.md) - Known limitations
- [Project Plan](../project_plan.md) - Development history

## 🤝 Contributing

This project is optimized for development with Claude Code. See [CLAUDE.md](../CLAUDE.md) for AI-assisted development guidelines.

## 📄 License

Private project - All rights reserved

---
**Version**: 1.0.0  
**Last Updated**: 2025-07-12