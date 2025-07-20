# 🚀 SquashTrainingApp 실행 가이드

## 빠른 시작

### 1. 기본 설치 및 실행
```batch
# Windows 탐색기에서 다음 파일 더블클릭:
quick-install.bat
```

### 2. 고급 옵션이 있는 설치
```batch
# Windows 탐색기에서 다음 파일 더블클릭:
install-and-run-advanced.bat
```

## BAT 파일 설명

### 📌 quick-install.bat
- **용도**: 가장 빠른 설치
- **기능**: APK 설치 → 앱 실행
- **사용 시기**: APK가 이미 빌드되어 있을 때

### 📌 install-and-run.bat
- **용도**: 표준 설치
- **기능**: 
  - 디바이스 확인
  - 이전 버전 제거
  - APK 설치
  - 권한 부여
  - 앱 실행
- **사용 시기**: 깔끔한 설치가 필요할 때

### 📌 install-and-run-advanced.bat
- **용도**: 전체 기능 제공
- **메뉴 옵션**:
  1. Quick Install - 빠른 설치
  2. Build and Install - 빌드 후 설치
  3. Install with Device Selection - 디바이스 선택
  4. Start Emulator with Mic - 마이크 지원 에뮬레이터
  5. View Logs - 로그 보기
  6. Clear App Data - 앱 데이터 삭제
  7. Take Screenshot - 스크린샷 촬영
- **사용 시기**: 개발/디버깅 시

## 사용 방법

### Windows 탐색기에서:
1. `C:\Git\Routine_app` 폴더 열기
2. 원하는 `.bat` 파일 더블클릭

### 명령 프롬프트에서:
```batch
cd C:\Git\Routine_app
install-and-run.bat
```

### PowerShell에서:
```powershell
cd C:\Git\Routine_app
.\install-and-run.bat
```

## 문제 해결

### "ADB not found" 에러
```batch
# Android SDK 경로 확인
echo %LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe

# 경로가 다르면 BAT 파일 수정
notepad install-and-run.bat
# ANDROID_HOME 변수 수정
```

### "No devices found" 에러
1. 에뮬레이터 시작:
   ```batch
   install-and-run-advanced.bat
   # 옵션 4 선택
   ```

2. 또는 Android Studio에서 에뮬레이터 시작

### "APK not found" 에러
1. 앱 빌드:
   ```batch
   cd SquashTrainingApp\android
   gradlew.bat assembleDebug
   ```

2. 또는 고급 설치 사용:
   ```batch
   install-and-run-advanced.bat
   # 옵션 2 선택 (Build and Install)
   ```

## 에뮬레이터 팁

### 마이크 지원 에뮬레이터 시작
```batch
# 고급 설치에서
install-and-run-advanced.bat
# 옵션 4 선택

# 또는 직접 실행
%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe -avd Pixel_6 -use-host-audio
```

### 권한 수동 부여
```batch
adb shell pm grant com.squashtrainingapp android.permission.RECORD_AUDIO
```

## 개발자 모드 활성화

앱 설치 후:
1. Profile 탭으로 이동
2. 버전 텍스트 5번 탭
3. Developer Options 표시됨
4. API Settings에서 OpenAI API 키 설정

## 유용한 명령어

### 로그 보기
```batch
adb logcat | findstr squashtraining
```

### 앱 데이터 삭제
```batch
adb shell pm clear com.squashtrainingapp
```

### 스크린샷 촬영
```batch
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png
```

### APK 정보 확인
```batch
aapt dump badging SquashTrainingApp\android\app\build\outputs\apk\debug\app-debug.apk
```