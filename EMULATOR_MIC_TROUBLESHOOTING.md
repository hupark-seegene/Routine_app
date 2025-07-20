# Android Emulator 마이크 문제 해결 가이드

## 🎤 에뮬레이터 마이크 설정

### 1. 기본 설정 확인
- Windows 마이크가 정상 작동하는지 확인
- Windows 설정 → 개인 정보 → 마이크 → 앱이 마이크 액세스 허용

### 2. 에뮬레이터 시작 방법

#### 방법 1: 명령줄에서 실행
```bash
# PowerShell에서
cd $env:LOCALAPPDATA\Android\Sdk\emulator
.\emulator.exe -avd Pixel_6 -use-host-audio
```

#### 방법 2: 스크립트 사용
```powershell
cd C:\Git\Routine_app\SquashTrainingApp\scripts\production
.\START-EMULATOR-WITH-MIC.ps1
```

### 3. 에뮬레이터 내부 설정

1. **Extended Controls 열기**
   - 에뮬레이터 사이드바 → `...` (More) 클릭

2. **Microphone 설정**
   - Microphone 탭 선택
   - "Virtual microphone uses host audio input" 활성화

3. **앱 권한 부여**
   ```bash
   adb shell pm grant com.squashtrainingapp android.permission.RECORD_AUDIO
   ```

### 4. 테스트 방법

1. **Google 음성 검색으로 테스트**
   - Google 앱 열기
   - 마이크 아이콘 탭
   - 말하기 테스트

2. **SquashTrainingApp에서 테스트**
   - 앱 실행
   - 마스코트 2초 길게 누르기
   - AI 챗봇에서 마이크 버튼 탭
   - 말하기 시작

### 5. 일반적인 문제와 해결책

#### 문제: "Audio input is not supported" 에러
**해결책:**
```bash
# 환경변수 설정
set ANDROID_EMULATOR_USE_SYSTEM_LIBS=1

# 에뮬레이터 재시작
emulator -avd Pixel_6 -use-host-audio
```

#### 문제: 마이크 버튼이 작동하지 않음
**해결책:**
1. 권한 확인:
   ```bash
   adb shell dumpsys package com.squashtrainingapp | grep RECORD_AUDIO
   ```

2. 권한 부여:
   ```bash
   adb shell pm grant com.squashtrainingapp android.permission.RECORD_AUDIO
   ```

#### 문제: 소리가 녹음되지 않음
**해결책:**
1. Windows 마이크 테스트:
   - Windows 설정 → 시스템 → 소리 → 입력
   - 마이크 테스트

2. 에뮬레이터 오디오 재설정:
   - AVD Manager → Edit → Wipe Data

### 6. 대안: 텍스트 입력 사용

마이크가 작동하지 않을 경우:
1. AI 챗봇에서 텍스트 입력 사용
2. 음성 명령 대신 텍스트로 명령 입력

### 7. 실제 기기 테스트

가장 확실한 방법:
1. 실제 Android 기기 사용
2. USB 디버깅 활성화
3. `adb install app-debug.apk`로 설치
4. 실제 마이크로 테스트

## 🔧 추가 팁

### Cold Boot 사용
```bash
# 깨끗한 상태로 시작
emulator -avd Pixel_6 -no-snapshot-load -use-host-audio
```

### 로그 확인
```bash
# 오디오 관련 로그 확인
adb logcat | grep -i audio
adb logcat | grep -i microphone
adb logcat | grep -i speech
```

### 디버그 모드
```bash
# 자세한 로그와 함께 실행
emulator -avd Pixel_6 -use-host-audio -debug-all
```