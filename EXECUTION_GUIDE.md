# 🚀 실행 방법 완벽 가이드

## 📋 사전 준비사항

### 1. 필수 소프트웨어 설치
- **Python 3.8-3.12** (3.13은 호환성 문제로 권장하지 않음)
- **PyCharm** (Community/Professional 무관)
- **Git** (Windows용)
- **Node.js** (Claude Code 설치용)

### 2. Claude Code 설치 및 인증
```bash
# Node.js 설치 후
npm install -g @anthropic-ai/claude-code

# 인증 (브라우저 로그인)
claude

# Max 요금제 구독 확인 필요
```

## 🎯 실행 방법 (3가지 방법)

### 방법 1: 원클릭 실행 ⭐ **추천**

```batch
# 1. Windows 탐색기에서 C:\Git\Routine_app 폴더 열기
# 2. quick_start.bat 더블클릭
# 3. 화면 지시에 따라 Enter 키 누르기
```

**과정**:
1. 환경 자동 복구
2. 패키지 자동 설치
3. 실행 옵션 선택
4. 자동화 시스템 시작

### 방법 2: 단계별 실행 (안전한 방법)

```batch
# 1단계: 환경 복구
fix_environment.bat

# 2단계: 시스템 시작
start_automation.bat
```

### 방법 3: 수동 실행 (고급 사용자)

```batch
# 1. 환경 설정
python test_terminal_setup.py

# 2. PyCharm 터미널 설정
python pycharm_terminal_controller.py

# 3. 자동 응답 시스템 (별도 터미널)
python auto_responder.py monitor
```

## 📱 실행 화면별 대응법

### 1. 환경 복구 화면
```
====================================
Python Environment Fix & Setup
====================================

[1/7] 기존 가상환경 정리 중...
[2/7] Python 버전 확인 중...
```
**대응**: 그냥 기다리기 (자동 진행)

### 2. 패키지 설치 화면
```
Installing pyautogui...
Installing pygetwindow...
Installing pywin32...
```
**대응**: 설치 완료까지 기다리기

### 3. 실행 모드 선택
```
실행 모드를 선택하세요:
1. 전체 자동화 (PyCharm 터미널 + 자동 응답)
2. PyCharm 터미널 설정만
3. 자동 응답 시스템만
4. 테스트 모드
5. 취소

선택 (1-5):
```
**대응**: **1번** 입력 후 Enter (전체 자동화)

### 4. PyCharm 준비 화면
```
준비되셨으면 Enter를 누르세요...
```
**대응**: 
1. PyCharm에서 Routine_app 프로젝트 열기
2. Enter 키 누르기

### 5. 자동화 진행 화면
```
[1/4] 환경 확인 중...
[2/4] PyCharm 실행 확인 중...
[3/4] 실행 모드 선택...
[4/4] 전체 자동화 시스템 시작 중...

✓ 두 시스템이 모두 시작되었습니다!
```
**대응**: 성공! PyCharm 확인하기

## 🖥️ PyCharm에서 확인할 것들

### 1. 터미널 탭 확인
PyCharm 하단에 7개 터미널이 생성되어야 합니다:
```
[Orchestrator] [Lead-Opus4] [Worker1-Sonnet] [Worker2-Sonnet] [Worker3-Sonnet] [AutoResponder] [TmuxMonitor]
```

### 2. 각 터미널 상태 확인
```
# Orchestrator 터미널
🎯 Orchestrator Terminal Ready

# Lead-Opus4 터미널
🧠 Lead Agent (Opus 4) Ready

# Worker 터미널들
🔨 Worker 1 (Sonnet 4) Ready
🔧 Worker 2 (Sonnet 4) Ready
⚙️ Worker 3 (Sonnet 4) Ready

# AutoResponder 터미널
🤖 Auto Responder Ready
```

## 💻 실제 작업 시작하기

### 1. Lead-Opus4 터미널에서 계획 수립
```bash
# Lead-Opus4 터미널에서 실행
claude -p "SquashTrainingApp의 성능을 개선할 3가지 작업을 병렬로 분할해주세요"
```

### 2. 자동 작업 할당 확인
- AutoResponder가 "1. Yes 2. Yes, and don't ask again" → "2" 자동 응답
- 각 Worker에게 작업 자동 할당

### 3. 진행 상황 모니터링
- TmuxMonitor 터미널에서 빌드 상태 확인
- 각 Worker 터미널에서 진행 상황 확인

## 🔧 문제 해결 가이드

### Python 가상환경 오류
```
AttributeError: class must define a '_type_' attribute
```
**해결법**:
```batch
fix_environment.bat
```

### PyCharm을 찾을 수 없음
```
PyCharm이 실행되지 않았습니다
```
**해결법**:
1. PyCharm 실행
2. File → Open → C:\Git\Routine_app 열기
3. 다시 실행

### 패키지 설치 실패
```
pip install 오류
```
**해결법**:
```batch
alternative_install.bat
```

### Claude Code 인증 오류
```
Claude Code 인증 필요
```
**해결법**:
1. 새 터미널 열기
2. `claude` 입력
3. 브라우저에서 로그인
4. Max 요금제 확인

## 📊 성공 확인 체크리스트

### ✅ 환경 설정 성공
- [ ] Python 설치 확인
- [ ] 가상환경 생성 성공
- [ ] 필수 패키지 설치 완료
- [ ] PyCharm 프로젝트 열림

### ✅ 시스템 시작 성공
- [ ] 7개 터미널 탭 생성
- [ ] 각 터미널 이름 정상 표시
- [ ] 초기 명령어 실행 완료
- [ ] 자동 응답 시스템 작동

### ✅ 작업 진행 성공
- [ ] Lead-Opus4에서 계획 수립
- [ ] Worker들에게 작업 할당
- [ ] 자동 응답 정상 작동
- [ ] 병렬 작업 진행 확인

## 🎉 완료!

모든 단계가 성공하면:
- **7개 터미널**이 PyCharm에서 자동으로 작동
- **자동 응답 시스템**이 백그라운드에서 프롬프트 처리
- **병렬 작업**이 독립적인 Git worktree에서 진행
- **실시간 모니터링**으로 진행 상황 확인

이제 완전 자동화된 다중 Claude Code 개발 환경을 사용할 수 있습니다! 🚀

## 🆘 추가 도움이 필요하면

1. **테스트 실행**: `python test_terminal_setup.py`
2. **로그 확인**: `logs/` 디렉토리
3. **프로세스 확인**: `tasklist | findstr python`
4. **재시작**: `start_automation.bat`