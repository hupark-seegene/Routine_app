# Claude AI 자동화 시스템 가이드

## 시스템 개요

이 자동화 시스템은 여러 개의 WSL 터미널에서 서로 다른 Claude 모델을 사용하여 React Native 앱 개발을 자동화합니다.

### AI 모델 분배
- **🧠 Claude 4 Opus**: 계획 및 아키텍처 설계
- **🔨 Claude 4 Sonnet**: 주요 코드 구현  
- **🔧 Claude 4 Sonnet**: 테스트 및 디버깅
- **⚙️ Claude 4 Sonnet**: 빌드 및 배포
- **📊 Claude 4 Sonnet**: 모니터링 및 조정

## 빠른 시작

### 1. 자동화 시스템 시작
```powershell
.\LAUNCH-AUTOMATION.ps1 -Quick
```

### 2. 각 터미널에서 수동 설정
각 터미널에서 다음 명령을 실행하세요:

```bash
# WSL 환경 진입
wsl

# 프로젝트 디렉토리 이동
cd /mnt/c/Git/Routine_app/SquashTrainingApp

# Claude Code 시작 (모델별로 다름)
claude --model claude-3-opus-20240229       # 플래너 터미널
claude --model claude-3-5-sonnet-20241022   # 코더 터미널들
```

### 3. 자동화 조정 스크립트 실행
```powershell
.\automation-coordinator.ps1
```

## 중요사항

⚠️ **Claude Code에서는 Enter를 두 번 눌러야 명령이 전달됩니다!**

## 사용 가능한 스크립트

### 메인 런처
- `LAUNCH-AUTOMATION.ps1`: 통합 자동화 시스템 런처
  - `-Quick`: 빠른 시작
  - `-Setup`: 환경 설정
  - `-Status`: 상태 확인  
  - `-Stop`: 시스템 중단

### 터미널 관리
- `TERMINAL-OPENER.ps1`: 터미널 열기 및 관리
  - `-OpenAll`: 모든 터미널 열기
  - `-Status`: 터미널 상태 확인
  - `-Close`: 모든 터미널 닫기

### 자동화 실행
- `START-CLAUDE-AUTOMATION.ps1`: 단순 자동화 시작
- `automation-coordinator.ps1`: 작업 조정 스크립트

## 터미널 역할 분배

| 터미널 | 역할 | 모델 | 주요 작업 |
|--------|------|------|----------|
| 🧠 Planner | 계획 및 아키텍처 | Claude 4 Opus | 개발 계획 수립, 아키텍처 설계 |
| 🔨 Coder1 | 주요 구현 | Claude 4 Sonnet | 핵심 기능 구현, 컴포넌트 작성 |
| 🔧 Coder2 | 테스트 및 디버깅 | Claude 4 Sonnet | 테스트 작성, 버그 수정 |
| ⚙️ Coder3 | 빌드 및 배포 | Claude 4 Sonnet | 빌드 설정, APK 생성 |
| 📊 Monitor | 모니터링 | Claude 4 Sonnet | 진행 상황 모니터링, 조정 |

## 개발 사이클

시스템은 다음과 같은 50회 반복 사이클을 실행합니다:

1. **설치** → **실행** → **테스트** → **디버그** → **수정** → **반복**

각 사이클에서:
- 플래너가 다음 단계 계획 수립
- 코더들이 병렬로 기능 구현
- 테스터가 품질 확인
- 빌더가 배포 준비
- 모니터가 전체 조정

## 문제 해결

### 일반적인 문제
1. **WSL 환경 오류**: `wsl --install` 실행
2. **Windows Terminal 없음**: Microsoft Store에서 설치
3. **Claude Code 없음**: WSL에서 Claude Code 설치
4. **Python 의존성 오류**: `pip install pyautogui pywin32 psutil`

### 디버깅
- 로그 파일 위치: `scripts/production/logs/`
- 상태 확인: `.\LAUNCH-AUTOMATION.ps1 -Status`
- 시스템 중단: `.\LAUNCH-AUTOMATION.ps1 -Stop`

## 추가 정보

이 시스템은 SquashTrainingApp React Native 프로젝트의 완전한 자동화 개발을 목표로 합니다. 각 AI 에이전트는 특정 역할을 맡아 효율적인 개발 워크플로우를 구현합니다.

문제가 발생하면 `.\LAUNCH-AUTOMATION.ps1` 메뉴에서 도움말을 확인하세요.