# 🚨 Android Studio 빌드 문제 즉시 해결

## 문제
- Android Gradle Plugin 8.9.2는 React Native 0.80.1과 호환되지 않음
- `com/android/build/api/variant/AndroidComponentsExtension` 오류 발생

## 즉시 해결 방법 (2분 소요)

### PowerShell에서 실행:
```powershell
cd C:\Git\Routine_app\SquashTrainingApp\android
.\fix-android-studio-v3.ps1
```

### 이 스크립트가 하는 일:
1. ✅ Android Gradle Plugin을 8.3.2로 다운그레이드
2. ✅ Kotlin을 1.9.24로 다운그레이드
3. ✅ React Native gradle plugin JAR 파일 빌드
4. ✅ 모든 캐시 정리

### 스크립트 실행 후:
1. **Android Studio 완전히 종료**
2. **Android Studio 다시 시작**
3. **File → Invalidate Caches → Invalidate and Restart**
4. 재시작 후 자동으로 Sync 시작됨
5. **Build → Build Bundle(s) / APK(s) → Build APK(s)**

## 수동 수정 방법 (스크립트가 실패한 경우)

### 1. build.gradle 수정:
```gradle
// 이 줄을 찾아서:
classpath("com.android.tools.build:gradle:8.9.2")

// 이렇게 변경:
classpath("com.android.tools.build:gradle:8.3.2")

// 그리고 이 줄도:
kotlinVersion = "2.1.20"

// 이렇게 변경:
kotlinVersion = "1.9.24"
```

### 2. Android Studio에서:
- File → Invalidate Caches → **Invalidate and Restart** (중요!)
- 재시작 후 Sync가 성공해야 함

## 여전히 실패하는 경우

### 최후의 수단:
1. Android Studio 완전히 종료
2. PowerShell 관리자 권한으로:
```powershell
cd C:\Git\Routine_app\SquashTrainingApp\android
Remove-Item -Recurse -Force .gradle, build, app\build, app\.gradle
.\gradlew.bat --stop
```
3. Android Studio 다시 열고 Sync

## 성공 확인
- Sync가 오류 없이 완료됨
- Build → Build APK(s) 메뉴가 활성화됨
- 빌드가 성공적으로 APK 생성

---
⚡ **핵심: AGP 8.9.2 → 8.3.2 다운그레이드가 필수!**