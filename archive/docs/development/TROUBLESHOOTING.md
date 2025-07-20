# 🔧 문제 해결 가이드

## 🚨 자주 발생하는 문제들

### 1. Python 가상환경 오류
```
AttributeError: class must define a '_type_' attribute
```

**원인**: Python 3.13의 ctypes 라이브러리 호환성 문제

**해결법**:
```batch
# 방법 1: 환경 재설정
fix_environment.bat

# 방법 2: 대안적 설치
alternative_install.bat

# 방법 3: Python 다운그레이드
# Python 3.11 또는 3.12 설치 권장
```

### 2. PyCharm을 찾을 수 없음
```
PyCharm이 실행되지 않았습니다
```

**해결법**:
1. PyCharm 실행
2. File → Open → `C:\Git\Routine_app` 열기
3. 프로젝트가 완전히 로드될 때까지 대기
4. 다시 실행

### 3. 터미널이 생성되지 않음
```
터미널 설정 실패
```

**해결법**:
```batch
# 1. 관리자 권한으로 실행
# 우클릭 → "관리자 권한으로 실행"

# 2. PyCharm 재시작
# PyCharm 완전 종료 후 재시작

# 3. 터미널 수동 정리
# PyCharm에서 기존 터미널 탭들 모두 닫기
```

### 4. 패키지 설치 실패
```
pip install 오류
```

**해결법**:
```batch
# 방법 1: 가상환경 없이 설치
alternative_install.bat

# 방법 2: 개별 패키지 설치
python -m pip install pyautogui==0.9.53
python -m pip install pygetwindow==0.0.9
python -m pip install pywin32==306
python -m pip install psutil==5.9.5
python -m pip install python-dotenv==1.0.0

# 방법 3: 캐시 초기화
python -m pip cache purge
python -m pip install --no-cache-dir -r requirements.txt
```

### 5. Claude Code 인증 오류
```
Claude Code 인증 필요
```

**해결법**:
1. 새 터미널 열기
2. `claude` 입력
3. 브라우저에서 Anthropic 계정 로그인
4. Max 요금제 구독 확인
5. 인증 완료 후 터미널로 돌아가기

### 6. 자동 응답이 작동하지 않음
```
프롬프트가 자동으로 응답되지 않음
```

**해결법**:
```batch
# 자동 응답 시스템 재시작
taskkill /F /FI "WINDOWTITLE eq Auto Responder"
python auto_responder.py monitor

# 또는 전체 시스템 재시작
start_automation.bat
```

### 7. Git worktree 오류
```
Git worktree 생성 실패
```

**해결법**:
```bash
# 기존 worktree 정리
git worktree prune

# 수동 worktree 생성
git worktree add ../worker-1 feature/worker-1
git worktree add ../worker-2 feature/worker-2
git worktree add ../worker-3 feature/worker-3
```

### 8. 메모리 부족 오류
```
Memory Error 또는 시스템 느려짐
```

**해결법**:
1. 불필요한 프로그램 종료
2. 터미널 개수 줄이기 (pycharm_terminal_controller.py 수정)
3. 시스템 재시작

## 🔍 디버깅 명령어

### 시스템 상태 확인
```batch
# Python 버전 확인
python --version

# 설치된 패키지 확인
pip list

# 실행 중인 프로세스 확인
tasklist | findstr python
tasklist | findstr claude
tasklist | findstr pycharm

# 메모리 사용량 확인
python -c "import psutil; print(f'메모리: {psutil.virtual_memory().percent}%')"
```

### 로그 확인
```batch
# 빌드 로그
type logs\build-logs\*.log

# 테스트 로그
type logs\test-logs\*.log

# 디버그 로그
type logs\debug-logs\*.log
```

### 프로세스 강제 종료
```batch
# Python 프로세스 모두 종료
taskkill /F /IM python.exe

# 특정 프로세스 종료
taskkill /F /FI "WINDOWTITLE eq PyCharm Controller"
taskkill /F /FI "WINDOWTITLE eq Auto Responder"
```

## 🛠️ 고급 해결 방법

### 완전 초기화
```batch
# 1. 모든 프로세스 종료
taskkill /F /IM python.exe

# 2. 가상환경 삭제
rmdir /s /q .venv

# 3. Git worktree 정리
git worktree prune

# 4. 캐시 정리
python -m pip cache purge
rd /s /q __pycache__
rd /s /q .cache

# 5. 재설정
fix_environment.bat
```

### 수동 환경 설정
```batch
# 1. 가상환경 생성
python -m venv .venv

# 2. 활성화 (cmd 방식)
.venv\Scripts\activate.bat

# 3. 패키지 설치
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

# 4. 테스트
python test_terminal_setup.py
```

### 네트워크 문제
```batch
# 프록시 설정 (필요시)
set HTTP_PROXY=http://proxy.company.com:8080
set HTTPS_PROXY=https://proxy.company.com:8080

# DNS 플러시
ipconfig /flushdns

# 패키지 소스 변경
python -m pip install -i https://pypi.org/simple/ pyautogui
```

## 📞 최종 해결 방법

### 1. 시스템 재시작
모든 것이 실패하면 Windows 재시작

### 2. Python 재설치
Python 3.11 또는 3.12 새로 설치

### 3. PyCharm 재설치
PyCharm 완전 삭제 후 재설치

### 4. 프로젝트 재복제
```bash
git clone https://github.com/hupark-seegene/Routine_app.git
cd Routine_app
quick_start.bat
```

## 🆘 여전히 문제가 있다면

1. **에러 메시지 전체 복사**
2. **시스템 환경 정보 수집**:
   ```batch
   systeminfo > system_info.txt
   python --version > python_info.txt
   pip list > package_info.txt
   ```
3. **GitHub Issues에 보고**

문제가 해결되지 않으면 위 정보와 함께 문의해주세요!