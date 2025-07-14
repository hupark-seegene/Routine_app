# PyCharm 터미널 자동화 가이드

PyCharm에서 여러 터미널을 자동으로 설정하고 Claude Code 인스턴스를 관리하는 시스템입니다.

## 🚀 빠른 시작

### 1. 필수 준비사항

```bash
# Python 패키지 설치
pip install -r requirements.txt
pip install pyautogui pygetwindow pywin32

# Claude Code 설치 확인
claude --version

# 인증 확인 (브라우저 로그인 필요)
claude
```

### 2. PyCharm에서 실행

#### 방법 1: Run Configuration 사용
1. PyCharm 상단 툴바에서 Run 드롭다운 클릭
2. "PyCharm Terminal Controller" 선택
3. Run 버튼 클릭 (Shift+F10)

#### 방법 2: 배치 파일 사용
1. PyCharm Terminal에서:
```bash
./launch_pycharm_terminals.bat
```

#### 방법 3: Python 직접 실행
```bash
python pycharm_terminal_controller.py
```

## 📟 자동 생성되는 터미널들

시스템이 자동으로 7개의 터미널을 생성하고 설정합니다:

1. **Orchestrator** - 메인 오케스트레이터
2. **Lead-Opus4** - Claude Opus 4 (계획 담당)
3. **Worker1-Sonnet** - Claude Sonnet 4 (작업자 1)
4. **Worker2-Sonnet** - Claude Sonnet 4 (작업자 2)
5. **Worker3-Sonnet** - Claude Sonnet 4 (작업자 3)
6. **AutoResponder** - 자동 응답 시스템
7. **TmuxMonitor** - Tmux 세션 모니터

## 🔧 작동 방식

### 1. Git Worktree 자동 설정
```
C:\Git\
├── Routine_app\       (메인)
├── worker-1\          (Worker 1 작업공간)
├── worker-2\          (Worker 2 작업공간)
└── worker-3\          (Worker 3 작업공간)
```

### 2. 터미널 자동화
- PyCharm 창을 찾아 전면으로 가져옴
- `Alt+F12`로 터미널 열기
- `Shift+Alt+T`로 새 탭 생성
- 각 터미널 이름 변경 및 명령 실행

### 3. 자동 응답
AutoResponder가 모니터링하는 프롬프트:
- "1. Yes  2. Yes, and don't ask again" → "2"
- "(Y/n)" → "Y"
- "Continue?" → "Y"
- Rate limit 감지 시 자동 대기

## 🎯 사용 시나리오

### 시나리오 1: 완전 자동 개발
```python
# 1. PyCharm Terminal Controller 실행
# 2. 모든 터미널이 자동 설정됨
# 3. Lead-Opus4 터미널에서:
claude -p "SquashTrainingApp의 테스트 커버리지를 90%로 높이는 작업을 3개로 분할해주세요"

# 4. 각 Worker에게 자동으로 작업 할당
# 5. AutoResponder가 모든 프롬프트 자동 응답
```

### 시나리오 2: Tmux 통합
```bash
# TmuxMonitor 터미널이 자동으로:
# 1. WSL 접속
# 2. tmux 세션 연결/생성
# 3. 50+ 빌드 사이클 모니터링
```

## ⚙️ 고급 설정

### 터미널 구성 커스터마이징

`pycharm_terminal_controller.py`에서 `get_terminal_configs()` 수정:

```python
{
    'name': 'CustomTerminal',
    'rename': True,
    'commands': [
        'echo "Custom Terminal Ready"',
        'cd C:\\MyProject',
        'npm start'
    ],
    'command_delay': 1.0
}
```

### 자동 응답 패턴 추가

`auto_responder.py`에서 `response_mappings` 수정:

```python
self.response_mappings = {
    "Your custom prompt": "your response",
    # ... 더 추가
}
```

## 🐛 문제 해결

### PyCharm을 찾을 수 없음
- PyCharm에서 Routine_app 프로젝트가 열려있는지 확인
- 관리자 권한으로 실행 필요할 수 있음

### 터미널이 생성되지 않음
- PyCharm 터미널이 이미 많이 열려있다면 일부 닫기
- `pyautogui.PAUSE = 1.0`으로 속도 조절

### Claude Code 인증 오류
```bash
# 터미널에서 직접 인증
claude

# 브라우저에서 로그인 후 재시도
```

## 📊 모니터링

### 프로세스 상태 확인
```powershell
# PowerShell에서
Get-Process | Where-Object {$_.ProcessName -like "*claude*"}
```

### 로그 확인
- 각 worker 디렉토리의 `auto_responder.log`
- `C:\Git\Routine_app\logs\` 디렉토리

## 🔐 안전 기능

- `pyautogui.FAILSAFE = True`: 마우스를 화면 모서리로 이동하면 중지
- 모든 작업은 Git worktree에서 독립적으로 진행
- 자동 커밋 전 사용자 확인 필요

## 📝 추가 명령어

### 수동으로 워커 전환
```python
# Python 콘솔에서
from pycharm_terminal_controller import PyCharmTerminalController
controller = PyCharmTerminalController()
controller.switch_to_terminal_by_index(2)  # Worker1로 전환
```

### 특정 터미널에 명령 전송
```python
controller.execute_command("git status")
```

## 🎉 완료!

이제 PyCharm에서 완전 자동화된 다중 Claude Code 인스턴스를 사용할 수 있습니다!