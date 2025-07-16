# WSL Claude Code 터미널 자동화 시스템 사용 가이드

## 개요
이 시스템은 5개의 터미널을 자동으로 생성하고, 각 터미널에서 WSL 모드로 전환 후 Claude Code를 실행하는 "ultrathink" 접근 방식을 구현합니다.

## 🚀 빠른 시작

### 1단계: 환경 문제 해결 (필수)
관리자 권한으로 실행하세요:
```cmd
fix_environment.bat
```

### 2단계: WSL Claude Code 터미널 자동화 시작
다음 중 하나를 선택하여 실행하세요:

#### 옵션 A: 새로운 통합 시스템 (권장)
```cmd
WSL-CLAUDE-AUTOMATION.bat
```

#### 옵션 B: 기존 시스템 (개선됨)
```cmd
SquashTrainingApp\scripts\production\OPEN-TERMINALS.bat
```

#### 옵션 C: 기존 전체 자동화 시스템
```cmd
start_automation.bat
```

## 📋 실행 방법

### Windows 터미널에서 실행
1. **명령 프롬프트(cmd)에서 실행**
   ```cmd
   # 프로젝트 디렉토리로 이동
   cd C:\Git\Routine_app
   
   # 환경 문제 해결
   fix_environment.bat
   
   # WSL Claude Code 터미널 자동화 시작
   WSL-CLAUDE-AUTOMATION.bat
   ```

2. **PowerShell에서 실행**
   ```powershell
   # 프로젝트 디렉토리로 이동
   cd C:\Git\Routine_app
   
   # 환경 문제 해결
   .\fix_environment.bat
   
   # WSL Claude Code 터미널 자동화 시작
   .\WSL-CLAUDE-AUTOMATION.bat
   ```

3. **파일 탐색기에서 실행**
   - bat 파일을 더블클릭하여 실행

### 관리자 권한으로 실행하기
- 시작 메뉴에서 "cmd" 검색 → 마우스 우클릭 → "관리자 권한으로 실행"
- 또는 PowerShell을 관리자 권한으로 실행

## 🖥️ 터미널 구성

시스템 실행 후 다음 5개 터미널이 생성됩니다:

### 터미널 1: 🧠 Claude4-Opus-Planner
- **역할**: 계획 및 아키텍처 설계
- **모델**: claude-3-opus-20240229
- **기능**: 
  - 전체 개발 사이클 계획 수립
  - 아키텍처 설계 및 개선
  - 다른 에이전트들에게 작업 분배

### 터미널 2: 🔨 Claude4-Sonnet-Coder1
- **역할**: 주요 코드 구현
- **모델**: claude-3-5-sonnet-20241022
- **기능**:
  - React Native 컴포넌트 구현
  - 핵심 비즈니스 로직 작성
  - 상태 관리 및 API 연동

### 터미널 3: 🔧 Claude4-Sonnet-Coder2
- **역할**: 테스트 및 디버깅
- **모델**: claude-3-5-sonnet-20241022
- **기능**:
  - 빌드 테스트 및 디버깅
  - 기능 테스트 수행
  - 버그 수정 및 최적화

### 터미널 4: ⚙️ Claude4-Sonnet-Coder3
- **역할**: 빌드 및 배포
- **모델**: claude-3-5-sonnet-20241022
- **기능**:
  - APK 빌드 및 배포
  - 에뮬레이터 테스트
  - 설치/삭제 사이클 관리

### 터미널 5: 📊 Claude4-Sonnet-Monitor
- **역할**: 모니터링 및 조정
- **모델**: claude-3-5-sonnet-20241022
- **기능**:
  - 전체 진행 상황 모니터링
  - 팀 간 조정 및 협업
  - 성과 측정 및 리포팅

## 🎯 Claude Code 시작 방법

각 터미널에서 다음 명령을 실행하세요:

### 플래너 터미널 (Terminal 1)
```bash
claude --model claude-3-opus-20240229
```

### 코더 터미널 (Terminal 2-5)
```bash
claude --model claude-3-5-sonnet-20241022
```

### 간단한 방법
```bash
claude
```

### ⚠️ 중요 사항
- **Claude Code에서는 Enter를 두 번 눌러야 명령이 전달됩니다!**
- 각 터미널은 자동으로 WSL 모드로 진입됩니다
- 프로젝트 디렉토리 `/mnt/c/Git/Routine_app/SquashTrainingApp`에 자동 이동됩니다

## 🔄 50+ 사이클 자동화 (Ultrathink)

### 자동화 사이클 프로세스
1. **설치** - APK 빌드 및 에뮬레이터 설치
2. **실행** - 앱 실행 및 기능 테스트
3. **모든 기능 디버그** - 전체 기능 검증
4. **앱 삭제** - 에뮬레이터에서 앱 제거
5. **수정** - 발견된 이슈 수정

### 사이클 목표
- 이 과정을 fail/issue가 없을 때까지 50회 이상 반복 수행
- 각 터미널의 역할에 따라 병렬 작업 수행
- 지속적인 품질 개선 달성

### 각 터미널의 사이클 역할
- **🧠 플래너**: 사이클 계획 수립 및 조정
- **🔨 코더1**: 핵심 기능 구현 및 수정
- **🔧 코더2**: 테스트 및 버그 수정
- **⚙️ 코더3**: 빌드 및 배포 관리
- **📊 모니터**: 전체 진행 상황 추적

## 🛠️ 터미널 조작 방법

### 터미널 탭 전환
- **Ctrl+Tab**: 다음 탭
- **Ctrl+Shift+Tab**: 이전 탭
- **Ctrl+Shift+숫자**: 특정 탭으로 이동

### 터미널 종료
- **Ctrl+C**: 현재 프로세스 종료
- **exit**: 터미널 종료

## 🔧 문제 해결

### WSL 관련 문제
1. **WSL이 설치되지 않은 경우**:
   ```cmd
   # 관리자 권한으로 PowerShell 실행
   wsl --install
   # 재부팅 후 다시 시도
   ```

2. **WSL 배포판 문제**:
   ```cmd
   wsl --list --verbose
   wsl --set-default Ubuntu
   ```

### Claude Code 관련 문제
1. **Claude Code가 설치되지 않은 경우**:
   ```bash
   # WSL에서 실행
   curl -fsSL https://claude.ai/install.sh | bash
   # 또는
   npm install -g @anthropic-ai/claude-cli
   ```

2. **인증 문제**:
   ```bash
   claude auth login
   ```

### 환경 문제
1. **Python 패키지 오류**:
   ```cmd
   # 관리자 권한으로 실행
   fix_environment.bat
   ```

2. **권한 문제**:
   - 모든 bat 파일을 관리자 권한으로 실행

## 📁 파일 구조

```
C:\Git\Routine_app\
├── WSL-CLAUDE-AUTOMATION.bat           # 새로운 통합 자동화 시스템
├── fix_environment.bat                 # 환경 문제 해결 (필수)
├── start_automation.bat                # 기존 자동화 시스템
├── quick_start.bat                     # 원클릭 실행
├── SquashTrainingApp\
│   └── scripts\
│       └── production\
│           └── OPEN-TERMINALS.bat      # 개선된 터미널 생성기
└── WSL-CLAUDE-AUTOMATION-GUIDE.md     # 이 문서
```

## 📞 지원 및 문의

문제가 발생하면 다음 순서로 해결하세요:

1. **환경 재설정**: `fix_environment.bat` 재실행
2. **WSL 상태 확인**: `wsl --status`
3. **Claude Code 재설치**: WSL에서 Claude Code 재설치
4. **관리자 권한 확인**: 모든 스크립트를 관리자 권한으로 실행

## 🎉 성공적인 사용을 위한 팁

1. **준비 단계**:
   - 항상 관리자 권한으로 실행
   - 먼저 `fix_environment.bat` 실행
   - WSL과 Claude Code가 설치되어 있는지 확인

2. **실행 단계**:
   - 터미널이 모두 생성될 때까지 기다리기
   - 각 터미널에서 역할에 맞는 Claude Code 모델 사용
   - Enter를 두 번 눌러서 명령 전달

3. **작업 단계**:
   - 각 터미널의 역할에 맞는 작업 수행
   - 정기적으로 진행 상황 공유
   - 50+ 사이클 자동화 목표 달성

**성공적인 자동화를 위해 화이팅! 🚀**