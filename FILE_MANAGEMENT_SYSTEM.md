# File Management System - Squash Training App

## 파일 명명 규칙 (Naming Conventions)

### PowerShell Scripts (.ps1)

#### 1. 기본 명명 패턴
```
[CATEGORY]-[ACTION]-[TARGET].[VARIANT].ps1
```

#### 2. 카테고리 (Category)
- **BUILD**: 빌드 관련 스크립트
- **RUN**: 실행 관련 스크립트  
- **SETUP**: 환경 설정 스크립트
- **FIX**: 문제 해결 스크립트
- **DEPLOY**: 배포 관련 스크립트
- **UTIL**: 유틸리티 스크립트

#### 3. 액션 (Action)
- **CREATE**: 생성
- **INSTALL**: 설치
- **START**: 시작
- **STOP**: 중지
- **DEBUG**: 디버그
- **CLEAN**: 정리

#### 4. 타겟 (Target)
- **APP**: 애플리케이션
- **APK**: APK 파일
- **ICONS**: 아이콘
- **ENV**: 환경
- **STUDIO**: Android Studio

#### 5. 변형 (Variant) - 선택사항
- **SIMPLE**: 간단한 버전
- **ADVANCED**: 고급 버전
- **QUICK**: 빠른 버전
- **FULL**: 완전한 버전

### 예시
```
BUILD-CREATE-APK.ps1          # APK 빌드 생성
RUN-START-APP.QUICK.ps1       # 앱 빠른 실행
SETUP-FIX-STUDIO.ps1          # Android Studio 설정 수정
UTIL-CREATE-ICONS.ps1         # 아이콘 생성 유틸리티
```

### Markdown Documents (.md)

#### 1. 문서 카테고리
- **GUIDE**: 사용 가이드
- **README**: 프로젝트 소개
- **TECH**: 기술 문서
- **API**: API 문서
- **BUILD**: 빌드 문서

#### 2. 명명 패턴
```
[CATEGORY]_[TOPIC]_[VERSION].md
```

### 예시
```
GUIDE_BUILD_PROCESS.md        # 빌드 프로세스 가이드
TECH_ARCHITECTURE.md          # 기술 아키텍처 문서
BUILD_ANDROID_STUDIO.md       # Android Studio 빌드 가이드
```

## 디렉토리 구조 (Directory Structure)

### 권장 구조
```
SquashTrainingApp/
├── scripts/                  # 활성 스크립트
│   ├── build/                # 빌드 스크립트
│   ├── deploy/               # 배포 스크립트
│   ├── setup/                # 설정 스크립트
│   └── utils/                # 유틸리티 스크립트
├── docs/                     # 활성 문서
│   ├── guides/               # 사용 가이드
│   ├── technical/            # 기술 문서
│   └── api/                  # API 문서
├── archive/                  # 아카이브
│   ├── scripts/              # 구버전 스크립트
│   ├── docs/                 # 구버전 문서
│   └── configs/              # 구버전 설정
└── android/
    ├── BUILD-*.ps1           # 빌드 스크립트 (임시)
    └── configs/              # 설정 파일
        ├── active/           # 활성 설정
        └── backup/           # 백업 설정
```

## 파일 생명주기 관리

### 1. 파일 상태
- **ACTIVE**: 현재 사용 중
- **DEPRECATED**: 사용 중단 예정
- **ARCHIVED**: 아카이브됨
- **OBSOLETE**: 완전히 제거 대상

### 2. 파일 태그 시스템
파일 헤더에 다음 정보 포함:
```powershell
<#
.SYNOPSIS
    스크립트 간단 설명
    
.DESCRIPTION
    상세 설명
    
.STATUS
    ACTIVE | DEPRECATED | ARCHIVED | OBSOLETE
    
.VERSION
    1.0.0
    
.CREATED
    2025-07-12
    
.MODIFIED
    2025-07-12
    
.DEPENDENCIES
    - dependency1
    - dependency2
    
.REPLACES
    - old-script.ps1
    
.REPLACED_BY
    - new-script.ps1
#>
```

## 중복 방지 규칙

### 1. 파일 생성 전 체크리스트
- [ ] 기존에 유사한 기능의 파일이 있는가?
- [ ] 기존 파일을 수정/확장할 수 있는가?
- [ ] 새 파일의 명명이 규칙을 따르는가?
- [ ] 파일 헤더가 완전한가?
- [ ] 의존성이 명확한가?

### 2. 파일 생성 가드
새 파일 생성 시 자동으로 다음 확인:
- 이름 중복 체크
- 기능 중복 체크
- 명명 규칙 준수 체크

## 정리 작업 우선순위

### Phase 1: 긴급 정리 (HIGH)
1. **중복 스크립트 제거**
   - 동일 기능의 여러 버전 통합
   - 실패한 실험적 스크립트 아카이브
   
2. **백업 파일 정리**
   - .backup, .original 파일 중 최신만 유지
   - 임시 파일 (.temp, .old) 제거

### Phase 2: 구조 정리 (MEDIUM)
3. **디렉토리 재구성**
   - scripts/ 디렉토리 생성
   - 카테고리별 분류
   
4. **문서 통합**
   - 중복 가이드 통합
   - 구버전 문서 아카이브

### Phase 3: 시스템 구축 (LOW)
5. **자동화 도구 구축**
   - 파일 생성 가드 스크립트
   - 중복 탐지 도구
   
6. **문서 업데이트**
   - 새 구조 반영
   - 사용법 가이드 업데이트

## 핵심 파일 목록 (보존 필수)

### PowerShell Scripts
- **FINAL-RUN.ps1**: 메인 실행 스크립트
- **android/WORKING-POWERSHELL-BUILD.ps1**: 검증된 빌드
- **android/build-and-run.ps1**: 자동화 파이프라인
- **android/quick-run.ps1**: 대화형 메뉴
- **android/CREATE-APP-ICONS.ps1**: 아이콘 생성

### Configuration Files
- **android/build.gradle** (+ .original 백업)
- **android/settings.gradle** (+ .original 백업)
- **android/gradle.properties** (+ .backup)
- **android/app/build.gradle** (+ .original 백업)

### Documentation
- **README.md**: 프로젝트 메인 문서
- **TECHNICAL_DEBT.md**: 기술 부채 관리
- **android/ANDROID_STUDIO_FIX.md**: 중요 참조 문서
- **project_plan.md**: 프로젝트 계획 (가장 중요)

## 제거 대상 파일 패턴

### 즉시 제거
- `*.log` (빌드 로그)
- `*temp*`, `*tmp*` (임시 파일)
- `nul` (빈 파일)
- 중복된 여러 백업 (예: .backup, .current_backup, .final-backup)

### 아카이브 대상
- 실험적 스크립트 (여러 시도 버전)
- 구버전 문서
- 사용하지 않는 설정 파일 변형

## 자동화 도구

### 1. 파일 분석 스크립트
```powershell
# UTIL-ANALYZE-FILES.ps1
# 프로젝트 파일 구조 분석 및 중복 탐지
```

### 2. 정리 스크립트
```powershell
# UTIL-CLEANUP-PROJECT.ps1
# 자동 파일 정리 및 아카이브
```

### 3. 가드 스크립트
```powershell
# UTIL-FILE-GUARD.ps1
# 새 파일 생성 시 중복 체크
```

이 시스템을 통해 프로젝트 파일을 체계적으로 관리하고 무분별한 파일 생성을 방지할 수 있습니다.