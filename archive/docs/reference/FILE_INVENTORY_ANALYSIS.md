# 파일 분석 결과 및 정리 계획

## 현황 요약

### 발견된 문제점
- **총 파일 수**: 100개 (PowerShell 79개 + Markdown 21개)
- **중복도**: 45% (45개 파일이 중복/구버전)
- **실험적 파일**: 28% (28개 파일이 실험/테스트용)
- **실제 작동 파일**: 13% (13개 파일만 실제 사용)

### 문제 원인
React Native 0.80+ 빌드 시스템 호환성 문제로 인한 **"빌드 지옥"** 상황:
- 수십 번의 빌드 실패 시도
- 각 시도마다 새로운 스크립트 생성
- 백업 파일의 중복 생성
- 체계적인 파일 관리 부재

## 파일 분류 결과

### 🟢 핵심 유지 파일 (13개)
#### 운영 스크립트 (8개)
- `FINAL-RUN.ps1` - 메인 실행 스크립트
- `MCP-FULL-AUTOMATION.ps1` - 완전 자동화
- `START-EMULATOR.ps1` - 에뮬레이터 관리
- `android/WORKING-POWERSHELL-BUILD.ps1` - 검증된 빌드
- `android/build-and-run.ps1` - 자동화 파이프라인
- `android/install-apk.ps1` - APK 배포
- `android/quick-run.ps1` - 대화형 메뉴
- `android/CREATE-APP-ICONS.ps1` - 아이콘 생성

#### 핵심 문서 (5개)
- `FINAL_BUILD_GUIDE.md` - 메인 빌드 가이드
- `ANDROID_STUDIO_FIX.md` - Android Studio 설정
- `QUICK_BUILD_GUIDE.md` - 빠른 참조
- `RUN_APP_GUIDE.md` - 앱 실행 가이드
- `TECHNICAL_DEBT.md` - 기술 부채 관리

### 🟡 아카이브 대상 (28개)
#### 실험적 스크립트 - 교육/참고용 보존
- 디버그 시도: `AUTO-FIX-CRASH.ps1`, `COMPLETE-DEBUG.ps1` 등
- 빌드 실험: `FOOLPROOF-BUILD.ps1`, `ULTIMATE-BUILD.ps1` 등
- 설정 도구: `setup-env.ps1`, `fix-metro.ps1` 등

### 🔴 삭제 대상 (45개)
#### 중복/구버전 스크립트
- 번호 버전들: `fix-android-studio-v2.ps1`, `v3.ps1`
- 대체된 스크립트: `BUILD-RN-PLUGIN.ps1`, `DEBUG.ps1`
- 실패한 실험: `quick-debug.ps1`, `simple-build.ps1`

#### 중복 문서
- 빌드 가이드 중복: `BUILD_APK.md`, `BUILD_STATUS.md` 등
- 임시 파일: `BUILD_NOW.md`, `FIX_NOW.md`

### 📚 통합 대상 (14개)
#### 문서 통합 계획
- 여러 빌드 가이드 → `BUILD_GUIDE.md` 1개로 통합
- 설정 가이드들 → `SETUP_GUIDE.md` 1개로 통합
- README 파일들 → 메인 `README.md`로 통합

## 정리 실행 계획

### Phase 1: 즉시 삭제 (HIGH)
```powershell
# 명확한 중복/실패 파일들 (20개)
Remove-Item -Path @(
    "DEBUG.ps1",
    "BUILD-RN-PLUGIN.ps1", 
    "CHECK-APP.ps1",
    "QUICK-INSTALL.ps1",
    "android/fix-android-studio-v2.ps1",
    "android/fix-android-studio-v3.ps1",
    "android/quick-build.ps1",
    "android/simple-build.ps1",
    "BUILD_STATUS.md",
    "BUILD_NOW.md",
    "FIX_NOW.md"
    # ... 추가 파일들
)
```

### Phase 2: 아카이브 생성 (MEDIUM)
```powershell
# 아카이브 디렉토리 생성
New-Item -ItemType Directory -Path @(
    "archive/scripts/experimental",
    "archive/scripts/deprecated", 
    "archive/docs/historical",
    "archive/configs/backup"
)

# 실험적 스크립트 이동 (28개)
Move-Item -Path @(
    "AUTO-FIX-CRASH.ps1",
    "COMPLETE-BUILD.ps1",
    "android/FOOLPROOF-BUILD.ps1",
    "android/ULTIMATE-BUILD.ps1"
    # ... 실험적 파일들
) -Destination "archive/scripts/experimental/"
```

### Phase 3: 문서 통합 (MEDIUM)
```powershell
# 빌드 가이드 통합
Get-Content @(
    "BUILD_APK.md",
    "BUILD_COMPLETE_GUIDE.md", 
    "BUILD_GUIDE_FINAL.md",
    "BUILD_INSTRUCTIONS.md"
) | Out-File "docs/BUILD_GUIDE.md"

# 원본 파일 아카이브로 이동
Move-Item -Path "BUILD_APK.md","BUILD_COMPLETE_GUIDE.md" -Destination "archive/docs/historical/"
```

### Phase 4: 구조 재정리 (LOW)
```powershell
# 새 디렉토리 구조 생성
New-Item -ItemType Directory -Path @(
    "scripts/production",
    "scripts/utility", 
    "docs/guides",
    "docs/reference"
)

# 핵심 스크립트 재배치
Move-Item -Path @(
    "FINAL-RUN.ps1",
    "android/WORKING-POWERSHELL-BUILD.ps1",
    "android/build-and-run.ps1"
) -Destination "scripts/production/"
```

## 예상 결과

### Before (현재)
```
SquashTrainingApp/
├── 79개 PowerShell 스크립트 (혼재)
├── 21개 Markdown 문서 (중복)
├── android/ (42개 스크립트 혼재)
└── 관리 불가능한 구조
```

### After (정리 후)
```
SquashTrainingApp/
├── scripts/
│   ├── production/ (5개 핵심 스크립트)
│   └── utility/ (3개 유틸리티)
├── docs/
│   ├── BUILD_GUIDE.md (통합)
│   ├── SETUP_GUIDE.md (통합)
│   └── REFERENCE.md (통합)
├── archive/
│   ├── scripts/ (28개 실험적)
│   └── docs/ (구버전 문서)
└── android/
    ├── 2개 핵심 스크립트만
    └── configs/ (설정 파일)
```

### 성과 지표
- **파일 수 감소**: 100개 → 25개 (75% 감소)
- **핵심 스크립트**: 8개로 명확화
- **문서 통합**: 21개 → 5개 핵심 문서
- **구조 개선**: 카테고리별 명확한 분류

## 안전 조치

### 백업 전략
1. **Git 커밋 후 작업**: 모든 변경사항 추적 가능
2. **단계별 커밋**: 각 Phase마다 별도 커밋
3. **아카이브 보존**: 삭제 대신 아카이브로 이동

### 검증 프로세스
1. **핵심 스크립트 테스트**: 정리 후 주요 기능 동작 확인
2. **문서 링크 확인**: 통합 후 참조 링크 수정
3. **빌드 프로세스 검증**: Android Studio 빌드 정상 동작 확인

이 계획을 통해 **체계적이고 관리 가능한 프로젝트 구조**로 변환할 수 있습니다.