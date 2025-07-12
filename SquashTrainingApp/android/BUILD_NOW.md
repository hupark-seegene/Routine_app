# 🚀 Android Studio로 즉시 빌드하기

## 빠른 빌드 가이드 (5분 소요)

### 1단계: Android Studio 준비
```powershell
cd C:\Git\Routine_app\SquashTrainingApp\android
.\fix-android-studio.ps1
```

### 2단계: Android Studio에서 열기
1. Android Studio 실행
2. **File → Open**
3. `C:\Git\Routine_app\SquashTrainingApp\android` 폴더 선택
4. **Trust Project** 클릭 (물어보면)

### 3단계: Sync 대기
- 우측 상단에 "Sync Now" 나타나면 클릭
- 1-2분 대기 (자동으로 모든 설정 처리됨)

### 4단계: APK 빌드
1. **Build → Build Bundle(s) / APK(s) → Build APK(s)**
2. 2-3분 대기
3. 우측 하단에 "Build APK(s)" 알림 클릭
4. "locate" 클릭하여 APK 위치 확인

### 5단계: 설치 및 실행
APK 위치: `app\build\outputs\apk\debug\app-debug.apk`

PowerShell에서:
```powershell
cd C:\Git\Routine_app\SquashTrainingApp\android
.\install-apk.ps1 -Launch
```

또는 수동으로:
```powershell
adb install app\build\outputs\apk\debug\app-debug.apk
```

## ✅ 완료!

앱이 성공적으로 빌드되고 설치됩니다. 
React Native 0.80+의 gradle plugin 문제는 Android Studio가 자동으로 해결합니다.

## 문제 발생 시
1. **File → Invalidate Caches → Invalidate and Restart**
2. Android Studio 재시작 후 다시 시도
3. 여전히 실패하면 `.\ANDROID_STUDIO_FIX.md` 참고