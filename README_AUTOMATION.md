# 🤖 PyCharm 다중 에이전트 자동화 시스템

Windows 환경에서 PyCharm을 사용하여 여러 Claude Code 인스턴스를 자동으로 관리하는 시스템입니다.

## 🚀 빠른 시작 (3단계)

### 1단계: 환경 복구
```batch
fix_environment.bat
```
- Python 가상환경 문제 해결
- 필수 패키지 자동 설치
- 시스템 호환성 확인

### 2단계: 시스템 시작
```batch
start_automation.bat
```
- 전체 자동화 시스템 실행
- PyCharm 터미널 자동 설정
- 자동 응답 시스템 가동

### 3단계: 작업 시작
PyCharm에서 자동 생성된 7개 터미널에서 병렬 작업 진행!

## 📁 배치 파일 설명

### 🔧 `fix_environment.bat`
**Python 환경 문제 해결**
- 손상된 가상환경 재생성
- pip 업그레이드 및 패키지 설치
- Python 3.13 호환성 문제 해결

```batch
# 실행 후 자동으로:
# 1. 기존 .venv 삭제
# 2. 새 가상환경 생성
# 3. 필수 패키지 설치 (pyautogui, pywin32 등)
# 4. 설치 확인 테스트
```

### 🎯 `start_automation.bat`
**메인 자동화 시스템**
- PyCharm 터미널 자동 설정
- 자동 응답 시스템 시작
- 백그라운드 프로세스 관리

```batch
# 실행 모드:
# 1. 전체 자동화 (터미널 + 자동응답)
# 2. 터미널 설정만
# 3. 자동 응답만
# 4. 테스트 모드
```

### ⚡ `quick_start.bat`
**원클릭 실행**
- 환경 복구 + 시스템 시작을 한번에
- 초보자 친화적 메뉴 제공

### 🔄 `alternative_install.bat`
**대안적 설치 방법**
- 가상환경 없이 시스템 Python 사용
- Python 3.13 호환성 문제 해결
- 안정적인 패키지 버전 사용

## 🎛️ 사용 시나리오

### 시나리오 1: 처음 사용자
```batch
# 1. 환경 설정
fix_environment.bat

# 2. 시스템 테스트
python test_terminal_setup.py

# 3. 자동화 시작
start_automation.bat
```

### 시나리오 2: 빠른 시작
```batch
# 모든 것을 한번에
quick_start.bat
```

### 시나리오 3: 문제 해결
```batch
# 패키지 설치 문제가 있을 때
alternative_install.bat

# 환경 재설정
fix_environment.bat
```

## 🖥️ 자동 생성되는 터미널들

`start_automation.bat` 실행 시 PyCharm에서 자동으로 7개 터미널이 생성됩니다:

1. **Orchestrator** - 메인 컨트롤러
2. **Lead-Opus4** - Claude Opus 4 (계획 수립)
3. **Worker1-Sonnet** - Claude Sonnet 4 (작업자 1)
4. **Worker2-Sonnet** - Claude Sonnet 4 (작업자 2)
5. **Worker3-Sonnet** - Claude Sonnet 4 (작업자 3)
6. **AutoResponder** - 자동 응답 시스템
7. **TmuxMonitor** - Tmux 세션 모니터

## 🔧 문제 해결

### Python 가상환경 문제
```
AttributeError: class must define a '_type_' attribute
```
**해결**: `fix_environment.bat` 실행

### PyCharm 터미널 생성 실패
```
PyCharm을 찾을 수 없습니다
```
**해결**: PyCharm에서 Routine_app 프로젝트 열기

### 패키지 설치 실패
```
pip install 오류
```
**해결**: `alternative_install.bat` 실행

### Claude Code 인증 문제
```
Claude Code 인증 필요
```
**해결**: 터미널에서 `claude` 실행하여 브라우저 로그인

## 📊 모니터링 & 로그

### 실행 중인 프로세스 확인
```batch
tasklist | findstr python
tasklist | findstr claude
```

### 로그 파일 위치
```
logs/
├── build-logs/        # 빌드 로그
├── test-logs/         # 테스트 로그
└── debug-logs/        # 디버그 로그
```

### 자동 응답 패턴
```
"1. Yes  2. Yes, and don't ask again" → "2"
"(Y/n)" → "Y"
"Continue?" → "Y"
"Are you sure" → "Y"
```

## 🔒 안전 기능

- **Failsafe**: 마우스를 화면 모서리로 이동하면 자동 중지
- **Git Worktree**: 독립적인 작업공간으로 충돌 방지
- **Process Monitoring**: 프로세스 상태 실시간 확인
- **Graceful Shutdown**: 안전한 종료 프로세스

## 📝 고급 사용법

### 커스텀 터미널 추가
`pycharm_terminal_controller.py`에서 `get_terminal_configs()` 수정

### 자동 응답 패턴 추가
`auto_responder.py`에서 `response_mappings` 수정

### 배치 파일 커스터마이징
각 .bat 파일을 열어서 경로나 설정 변경

## 🎉 성공적인 실행 확인

시스템이 정상적으로 실행되면:
- ✅ PyCharm에 7개 터미널 탭이 생성됨
- ✅ 각 터미널에 적절한 명령어가 실행됨
- ✅ 자동 응답 시스템이 백그라운드에서 작동
- ✅ Git worktree가 설정되어 병렬 작업 가능

---

💡 **팁**: 처음 사용 시 `quick_start.bat`으로 시작하세요!

🔧 **문제 발생 시**: `fix_environment.bat`을 먼저 실행하세요!