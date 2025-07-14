# 🐛 Comprehensive Debug Guide for Squash Training App

## Overview
완전 자동화된 디버깅 스크립트가 준비되었습니다. 이 스크립트는 에뮬레이터를 실행하고, APK를 빌드/설치하며, 모든 기능을 테스트합니다.

## 🚀 Quick Start
Windows에서 실행:
```batch
RUN_DEBUG.bat
```

또는 PowerShell에서 직접 실행:
```powershell
.\scripts\production\DEBUG-ALL-FEATURES.ps1
```

## 📋 테스트 항목

### 1. **에뮬레이터 설정**
- Pixel_6 AVD 자동 실행
- 에뮬레이터 부팅 대기
- ADB 연결 확인

### 2. **APK 빌드 및 설치**
- Gradle clean & build
- Debug APK 생성
- 에뮬레이터에 자동 설치
- 앱 자동 실행

### 3. **마스코트 네비게이션 테스트**
각 존으로의 드래그 테스트:
- **Profile Zone** (상단 중앙): 사용자 프로필
- **Checklist Zone** (왼쪽 중간): 운동 체크리스트
- **Coach Zone** (오른쪽 중간): AI 코치
- **Record Zone** (왼쪽 하단): 운동 기록
- **History Zone** (오른쪽 하단): 운동 히스토리
- **Settings Zone** (하단 중앙): 설정

### 4. **음성 인식 테스트**
- 2초 롱프레스로 음성 인식 활성화
- 음성 오버레이 표시 확인
- 음성 인식 취소 테스트

### 5. **각 화면 기능 테스트**
- **Profile**: 사용자 정보 표시
- **Checklist**: 운동 항목 선택/체크
- **Record**: 운동 시작/중지 기능
- **History**: 과거 운동 기록 표시
- **Coach**: AI 챗봇 대화 테스트

### 6. **애니메이션 및 시각 효과**
- 마스코트 아이들 애니메이션
- 존 호버 시 네온 글로우 효과
- 탭 애니메이션
- 화면 전환 효과

### 7. **성능 측정**
- 메모리 사용량
- CPU 사용률
- 그래픽 성능
- 액티비티 상태

## 📸 생성되는 스크린샷

1. `01_home_screen.png` - 홈 화면
2. `02_drag_to_[zone].png` - 각 존으로 드래그
3. `03_[zone]_screen.png` - 각 화면 캡처
4. `04_voice_recognition_active.png` - 음성 인식 활성화
5. `05_[screen]_main.png` - 각 메인 화면
6. `06_checklist_item_selected.png` - 체크리스트 선택
7. `07_recording_active.png` - 운동 기록 중
8. `08_recording_stopped.png` - 운동 기록 완료
9. `09_history_list.png` - 히스토리 목록
10. `10_coach_chat.png` - AI 코치 대화
11. `11_mascot_tap_animation.png` - 마스코트 탭 애니메이션
12. `12_zone_hover_effect.png` - 존 호버 효과

## 📁 생성되는 파일

```
debug-results-[timestamp]/
├── *.png                    # 모든 스크린샷
├── debug-log.txt           # 전체 디버그 로그
├── gradle-build.log        # 빌드 출력
├── gradle-clean.log        # 클린 출력
├── app-debug.apk          # 빌드된 APK 복사본
├── meminfo.txt            # 메모리 상세 정보
├── gfxinfo.txt            # 그래픽 성능 정보
├── activity.txt           # 액티비티 상태 덤프
└── TEST-REPORT.txt        # 종합 테스트 리포트
```

## 🔧 옵션

```powershell
# 빌드 건너뛰기 (기존 APK 사용)
.\DEBUG-ALL-FEATURES.ps1 -SkipBuild

# 테스트 후 앱 유지
.\DEBUG-ALL-FEATURES.ps1 -KeepAppInstalled
```

## ⚠️ 필요 사항

1. **Android Studio** 설치
2. **Android SDK** 설정 (API 34)
3. **Pixel_6 AVD** 생성
4. **PowerShell** 실행 권한

## 🎯 예상 실행 시간

- 에뮬레이터 시작: 1-2분
- APK 빌드: 2-3분
- 전체 테스트: 5-10분
- **총 소요 시간**: 약 10-15분

## 💡 문제 해결

### 에뮬레이터가 시작되지 않는 경우:
```powershell
# AVD 목록 확인
C:\Users\hwpar\AppData\Local\Android\Sdk\emulator\emulator.exe -list-avds

# 수동으로 에뮬레이터 시작
C:\Users\hwpar\AppData\Local\Android\Sdk\emulator\emulator.exe -avd Pixel_6
```

### 빌드 실패 시:
```bash
cd SquashTrainingApp/android
./gradlew clean
./gradlew assembleDebug --stacktrace
```

### ADB 연결 문제:
```bash
adb kill-server
adb start-server
adb devices
```

## ✅ 테스트 완료 후

1. `debug-results-[timestamp]` 폴더가 자동으로 열립니다
2. `TEST-REPORT.txt`에서 전체 결과 확인
3. 스크린샷으로 각 기능 시각적 확인
4. 로그 파일로 상세 분석 가능

---

**이제 `RUN_DEBUG.bat`를 실행하면 모든 테스트가 자동으로 진행됩니다!** 🚀