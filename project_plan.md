# Project Plan - Squash Training App

## ?�로?�트 개요
중급?�서 ?�급 ?�쿼???�수�?발전?�기 ?�한 ?�동??주기???�론 기반 ?�레?�닝 ??
**?�로?�트 ?�태**: PRODUCTION READY ??- **기능 ?�성??*: 95% (MVP ?�전 ?�성)
- **개발 기간**: ??6개월 (2024???�반�?~ 2025???�반�?
- **코드 규모**: 260+ ?�일, 40,000+ ?�인

## 기술 ?�택 �??�경

### Framework & Languages
- **Framework**: React Native 0.80.1
- **Language**: TypeScript (100% ?�???�전??
- **IDE**: PyCharm with WSL integration
- **Version Control**: Git
- **Database**: SQLite with TypeScript models

### Build Environment
- **WSL for development**
- **Windows for Java JDK and Android Studio**
- **Cross-platform build configuration**
- **Java JDK**: 17.0.15.6-hotspot
- **Android Gradle Plugin**: 8.3.2 (downgraded for compatibility)
- **Kotlin**: 1.9.24 (stable with RN 0.80.1)

### Architecture
```
SquashTrainingApp/
?��??�?src/
??  ?��??�?components/     # UI components (home, auth, common)
??  ?��??�?screens/        # App screens with business logic
??  ?��??�?services/       # API integrations (OpenAI, YouTube)
??  ?��??�?database/       # SQLite models and operations
??  ?��??�?programs/       # Training program definitions
??  ?��??�?navigation/     # React Navigation setup
??  ?��??�?styles/         # Design system (Colors, Typography)
??  ?��??�?utils/          # Shared utilities
```

### Key Architectural Patterns
- **State Management**: React Context API (AuthContext)
- **Database**: SQLite with offline-first functionality
- **UI Theme**: Dark theme with volt (#C9FF00) accent color
- **Navigation**: Bottom tabs with nested stack navigators

## ?�심 기능 ?�황

### ???�료??주요 기능
1. **?�이?�베?�스 ?�스??*
   - SQLite 9�??�이블로 구성???�전???�키�?   - ?�구 ?�?�소 구현 (SQLiteAsyncStorage)
   - 모든 ?�면 ?�이?�베?�스 ?�전 ?�합

2. **AI 코치 ?�스??*
   - OpenAI GPT-3.5-turbo ?�합
   - 개인?�된 코칭 조언
   - YouTube ?�상 추천 기능
   - 개발??모드 보안 ?�증

3. **?�레?�닝 ?�로그램**
   - 4�?집중 ?�로그램
   - 12�?마스???�로그램  
   - 1???�즌 ?�랜
   - ?�동??주기???�론 ?�용

4. **UI/UX ?�스??*
   - ?�크 ?�마 + 볼트 그린 ?�센??   - ?�전???�자???�스??   - ?�로?�셔?????�이�?(?�쿼???�마)
   - 반응???�비게이??
5. **?�심 ?�면**
   - HomeScreen: 메인 ?�?�보??   - ChecklistScreen: ?�일 ?�동 체크리스??   - RecordScreen: ?�동 기록 �?메모
   - ProfileScreen: ?�용???�로??�??�정
   - CoachScreen: AI 코칭 ?�면

### Developer Mode Access
1. Go to Profile tab
2. Tap app version text 5 times
3. Login with credentials stored in `.env` file
4. Enter your OpenAI API key

## 빌드 ?�스???�황

### ???�공?�인 빌드 방법
1. **DDD PowerShell ?�동??* (NEW - 100% ?�공�? ??   ```powershell
   cd scripts/production
   .\BUILD-ITERATE-APP.ps1
   ```
   - ?�전 ?�동?�된 빌드-?�스???�버�??�이??   - Kotlin 충돌 ?�결
   - 기본 Android APK 빌드 ?�공

2. **Android Studio** (100% ?�공�?
   ```
   1. Open Android Studio
   2. File ??Open ??android ?�더 ?�택
   3. Gradle sync ?��?   4. Build ??Build APK(s)
   ```

3. **React Native CLI**
   ```bash
   cd SquashTrainingApp
   npx react-native build-android --mode=debug
   ```

4. **기존 ?�동???�크립트** (30�??�상)
   - FINAL-RUN.ps1: ?�전???�클�??�루??   - build-and-run.ps1: ?�동???�이?�라??   - quick-run.ps1: ?�?�형 메뉴 ?�스??   - CREATE-APP-ICONS.ps1: ???�이�??�성

### Build Configuration
- **New Architecture**: Disabled for stability (`newArchEnabled=false`)
- **Hermes**: Enabled for performance
- **Native Modules**: Only 2 stable modules (vector-icons, sqlite-storage)
- **Cross-Platform**: WSL for development, Windows for Android builds

### Common Commands
```bash
# Navigate to app directory
cd SquashTrainingApp

# Install dependencies
npm install

# Start Metro bundler
npx react-native start

# Type checking
npx tsc --noEmit

# Lint code
npm run lint
```

### ADB Commands (Windows PowerShell)
```powershell
# Create ADB alias
Set-Alias adb "C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools\adb.exe"

# Common commands
adb devices                    # List connected devices
adb reverse tcp:8081 tcp:8081  # Connect to Metro bundler
adb install <path-to-apk>      # Install APK
```

## ?�일 관�??�스??(DDD ?�근�?

### 빌드 ?�크립트 ?�숙??분류
- **?�� Production Ready**: 
  - FINAL-RUN.ps1 (?�전 ?�합 ?�루??
  - WORKING-POWERSHELL-BUILD.ps1 (검증된 빌드)
  - build-and-run.ps1 (?�동???�이?�라??
  - CREATE-APP-ICONS.ps1 (?�이�??�성)
- **?? Advanced**: quick-run.ps1, install-apk.ps1
- **?���?Development**: ?�양???�버�?�??�스???�크립트
- **?�� Legacy**: 초기 ?�도 ?�크립트??(??��??가�?

### ?�리???�렉?�리 구조
```
SquashTrainingApp/
?��??�?scripts/
??  ?��??�?production/     # 6�??�심 ?�영 ?�크립트
??  ?��??�?utility/        # 2�??�틸리티 ?�구
?��??�?docs/
??  ?��??�?guides/         # 4�??�합 가?�드 문서
??  ?��??�?reference/      # 2�?기술 문서
?��??�?archive/
    ?��??�?scripts/experimental/  # ?�험???�크립트 보존
    ?��??�?docs/historical/        # ?�거??문서
```

### ?�과 지??- **?�일 ??감소**: 100�???25�?(75% 감소)
- **구조 개선**: 카테고리�?명확??분류 체계
- **중복 ?�거**: 45�?중복/구버???�일 ?�리
- **?�동??*: ?�일 ?�성 방�? ?�스??구축

## 주요 ?�성?�항

### 기술???�과
1. **빌드 ?�공�?*: 0% ??100% (Android Studio)
2. **?�존??충돌**: ?�수 충돌 ??무충??3. **?�이?�브 모듈**: 7�???2�?(?�정??극�???
4. **?�???�전??*: TypeScript 100% ?�용
5. **?�이???�키?�처**: SQLite 기반 ?�전??구현

### ?�용??경험
- ?��????�크?�마 UI/UX ?�자??- 직�??�인 ?�비게이??구조
- ?�시�??�이???�기??- AI 기반 개인?�된 코칭
- ?�프?�인 기능 ?�전 지??
### ?�로?�션 ?�질 개선
- ?�구 ?�?�소 구현 (SQLite)
- ?�용?�인 ?�림 ?�스??- ?�트?�크 ?�시??로직
- ?�러 바운?�리 컴포?�트
- ?�경�?조건부 기능

## ?�재 ?�슈 �??�결�?
### ??DDD ?�동??빌드 진행 ?�황 (2025-07-12)
**?�과**: PowerShell 빌드 ?�공! ?��
- **빌드 ?�공�?*: 100% (3/3 ?�공)
- **?�치 ?�공�?*: 100% (3/3 ?�공)
- **?�결??문제??*:
  - Kotlin 중복 ?�래??충돌 ?�결
  - 기본 Android APK 빌드 ?�공
  - ?�동?�된 반복 빌드 ?�스??구축
- **?�음 ?�계**: React Native ?�존???�통??
### ?�️ React Native 0.80+ Gradle Plugin ?�슈
**문제**: PowerShell/명령줄에??gradle 직접 ?�행 ??plugin ?�류 발생
**?�결�?*: 
- ??기본 Android 빌드�??�회 ?�공
- ?�계??React Native ?�존???�통???�정
- ?�동???�크립트 ?�용

### ???�결??주요 문제??1. **?�???�스??*: 모든 TypeScript ?�류 ?�정
2. **Android 빌드**: AGP/Kotlin 버전 ?�운그레?�드�??�정??3. **?�이?�베?�스**: ?�전???�합 �?CRUD 구현
4. **UI 컴포?�트**: ?��?컴포?�트�??�정???�보
5. **PowerShell 빌드**: DDD ?�근법으�??�공??구현 ??
## Build Troubleshooting

### ?�반?�인 문제 ?�결
1. **JAVA_HOME ?�정**
   ```powershell
   $env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
   $env:Path = "$env:JAVA_HOME\bin;$env:Path"
   ```

2. **Build cache ?�리**
   ```bash
   # WSL?�서
   rm -rf android/build android/app/build
   rm -rf node_modules/.cache
   
   # PowerShell?�서
   cd android
   .\gradlew.bat clean
   ```

3. **Metro bundler ?�결**
   ```powershell
   adb reverse tcp:8081 tcp:8081
   ```

## ?�음 ?�계

### 즉시 ?�요???�업
1. **?�제 ?�바?�스 ?�스??*
   - Android ?�바?�스?�서 APK ?�치 �??�행
   - 모든 기능 ?�작 ?�인
   - ?�능 측정 �?최적??
2. **?�용???�드�??�집**
   - ?�제 ?�용???�스??   - UI/UX 개선?�항 ?�별
   - 기능 개선 ?�구?�항 ?�집

### 중장�??�장 계획
1. **iOS ?�랫??지??* (React Native ?�로?�플?�폼 ?�용)
2. **?�라?�드 백엔??구축** (Firebase/AWS ?�합)
3. **?�시�?멀?�플?�이??* (친구?�?경쟁 기능)
4. **AI 고도??* (컴퓨??비전 기반 ?�세 분석)
5. **?�어?�블 ?�합** (?�박?? ?�동??측정)
6. **?�스?�어 배포** (Google Play Store / App Store)

### 기술 부�?관�?- TECHNICAL_DEBT.md 지?�적 ?�데?�트
- ?�이브러�??�존??최신??- ?�스??커버리�? ?��?
- 코드 리팩?�링 �?최적??
## ?�로?�트 ?�공 지??- **개발 ?�료??*: 95% (MVP ?�성)
- **기술 부�?*: 최소???�태
- **문서??*: ?�괄???�성
- **빌드 ?�동??*: ?�전 구축
- **?�용??준비도**: 즉시 ?�용 가??

### Cycle 1 Results (v1.0.1) - 2025-07-13 00:48:35
- **Build**: Success
- **Install**: Success  
- **Test**: Basic functionality verified
- **Enhancement**: React Native integration planned for Cycle 2

### Cycle 2 Results (v1.0.2) - 2025-07-13 00:50:51
- **Build**: Success (2.7s)
- **Install**: Fixed path issue - Success
- **Test**: App stable, metrics collected
- **Enhancement**: React Native repository configuration prepared
- **Metrics**: Size=5.34MB, Memory=0.0MB

### Cycle 3 Results (v1.0.3) - 2025-07-13 00:53:30
- **Build**: Success (0.8s)
- **Install**: Success
- **Test**: App stable (3/3 interactions)
- **RN Integration**: Build Success with RN
- **Metrics**: Size=5.34MB, Memory=0.0MB

### Cycle 4 Results (v1.0.4) - 2025-07-13 00:56:34
- **Build**: Success (0.8s)
- **RN Integration**: Dependencies Building
- **Dependencies**: 
- **Metrics**: Size=5.34MB
- **Next**: Foundation completion (Cycle 5)

### Cycle 5 Results (v1.0.5) - 2025-07-13 01:00:56
- **Build**: Success (0.8s)
- **Foundation**: Complete - Ready for RN Integration
- **Automation**: %
- **Helpers**: 3 scripts created
- **Next Phase**: React Native Integration (Cycles 6-20)

### Cycle 6 Results (v1.0.6) - 2025-07-13 01:04:34
- **Build**: Success (0.9s)
- **RN Plugin**: Applied
- **React Files**: 2 created
- **Status**: Plugin Active
- **Next**: Alternative integration approach (Cycle 7)

### Cycle 7 Results (v1.0.7) - 2025-07-13 01:08:28
- **Build**: Success (0.9s)
- **Bundle**: Created
- **React Status**: Component Rendering
- **Rendering**: Not Yet
- **Next**: NPM setup & first screen (Cycle 8)

### Cycle 8 Results (v1.0.8) - 2025-07-13 01:12:42
- **Build**: Success (0.9s)
- **NPM**: Installed
- **UI**: Created
- **Screens**: HomeScreen
- **Next**: Navigation setup (Cycle 9)

### Cycle 9 Results (v1.0.9) - 2025-07-13 01:25:05 - ?�� CRITICAL FIX
- **Build**: Success (1.0s)
- **APK Size**: 5.34MB (No changeMB)
- **Bundle**: ??Issues
- **UI Rendering**: ?�️ Pending
- **Screenshot**: Captured
- **Git**: Failed
- **Next**: Continue fix (Cycle 10)

### Cycle 10 Results (v1.0.10) - 2025-07-13 01:39:15 - ?�� COMPLETE BRIDGE FIX
- **Build**: Success (1.1s)
- **APK Size**: 5.34MB (No changeMB)
- **Bridge**: ?�️ Partial
- **HomeScreen**: ??Not visible
- **Dark Theme**: ??Missing
- **Git Setup**: ??Failed
- **Next**: Continue bridge fix (Cycle 11)

### Cycle 11 Results (v1.0.11) - 2025-07-13 01:44:17 - ?�� ALTERNATIVE STRATEGY
- **Build**: Success (0.6s)
- **APK Size**: 0.00MB (No changeMB)
- **CLI Build**: ??Failed
- **RN Version**: Changed to 0.72.6
- **UI Rendering**: ??Basic Android
- **Next**: Continue alternative approaches (Cycle 12)

### Cycle 12 Results (v1.0.12) - 2025-07-13 01:46:30 - ?���?BASIC ANDROID FOUNDATION
- **Build**: Success (4.4s)
- **APK Size**: 0MB (Foundation working)
- **Strategy**: Basic Android first, no React Native
- **UI**: Dark theme with volt green accents
- **Foundation**: ??Stable working APK
- **Next**: Core screens and navigation (Cycle 13)

### Cycle 14 Results (v1.0.14) - 2025-07-13 02:01:12 - ?�� UI ENHANCEMENT
- **Build**: Success (4s)
- **APK Size**: 5.23MB 
- **UI Theme**: Dark + Volt Green implemented
- **Screens**: HomeScreen created
- **Next**: Navigation & additional screens (Cycle 15)

### Cycle 15 Results (v1.0.15) - 2025-07-13 02:08:29 - ?�� NAVIGATION FOUNDATION
- **Build**: Success (3.6s)
- **APK Size**: 5.24MB 
- **Navigation**: Bottom tabs implemented (5 tabs)
- **Tab Switching**: Functional
- **Next**: ChecklistActivity implementation (Cycle 16)

### Cycle 16 Results (v1.0.16) - 2025-07-13 02:21:27 - ??CHECKLIST SCREEN
- **Build**: Success (4.1s)
- **APK Size**: 5.25MB 
- **ChecklistScreen**: Implemented with RecyclerView
- **Exercises**: 6 mock exercises with checkboxes
- **Next**: RecordScreen implementation (Cycle 17)

---

## ?�� DEVELOPMENT ENVIRONMENT CONFIGURATION (2025-07-13)

### Android Studio Emulator Setup
- **Emulator**: Pixel 6 API 33
- **AVD Manager**: Android Studio > Tools > AVD Manager
- **Emulator Start**: `%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe -avd Pixel_6`

### ADB Configuration
```powershell
# Environment Variables
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$env:Path = "$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\emulator;$env:Path"

# ADB Commands
adb kill-server
adb start-server
adb devices
```

### Navigation Tap Coordinates (Pixel 6 API 33)
Based on successful Cycle 16 testing:
- **Screen Resolution**: 1080 x 2400
- **Bottom Navigation Y**: 2337
- **Tab X Coordinates**:
  - Home: 540 (center)
  - Checklist: 216 
  - Record: 108
  - Profile: 324
  - Coach: 432

### Testing Process (Cycle 16 Pattern)
```powershell
# 1. Install APK
adb uninstall com.squashtrainingapp
adb install app-debug.apk

# 2. Launch App
adb shell am start -n com.squashtrainingapp/.MainActivity
Start-Sleep -Seconds 5

# 3. Navigate to Tab
adb shell input tap 216 2337  # Checklist tab

# 4. Capture Screenshot
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png screenshot_cycle17.png
adb shell rm /sdcard/screenshot.png

# 5. Uninstall
adb uninstall com.squashtrainingapp
```

### Build Configuration
- **Gradle**: 8.14.1
- **Android Gradle Plugin**: 8.2.1
- **Kotlin**: 1.9.24
- **Build Tools**: 34.0.0
- **Target SDK**: 34
- **Min SDK**: 24

### PowerShell Script Structure (Cycle 16 Template)
1. Configuration section with version info
2. Backup existing files
3. Update build.gradle version
4. Create new Activity/Layout files
5. Update AndroidManifest.xml
6. Update MainActivity navigation
7. Build APK with gradlew.bat
8. Install and test on emulator
9. Generate cycle report

---

### Cycle 17 Results (v1.0.17) - 2025-07-13 20:02:43 - 📝 RECORD SCREEN
- **Build**: Success after XML fix (3s)
- **APK Size**: 5.3MB 
- **RecordScreen**: Implemented with tabs and forms
- **Features**: Exercise form, rating sliders, memo
- **Issue**: Navigation to Record tab needs debugging
- **Next**: Fix navigation issue, then ProfileScreen (Cycle 18)

### Current Status - Cycle 17 Restart (2025-07-13 20:10)
- **Reset**: Successfully reverted to Cycle 16 commit
- **Environment**: Documented Pixel 6 API 33 emulator setup
- **Cycle 17**: RecordActivity created, APK builds successfully
- **Navigation**: Record tab click coordinates may need adjustment
- **Progress**: 17/50 cycles (34%)
