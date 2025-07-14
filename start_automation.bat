@echo off
:: 자동화 시스템 시작 배치 파일
:: 모든 필요한 프로세스를 백그라운드에서 실행

echo ====================================
echo Multi-Agent Automation System
echo ====================================
echo.

:: 1. 환경 확인
echo [1/4] 환경 확인 중...
python -c "import pyautogui, psutil, pygetwindow" 2>nul
if %errorLevel% neq 0 (
    echo [ERROR] 필요한 패키지가 설치되지 않았습니다.
    echo fix_environment.bat을 먼저 실행하세요.
    echo.
    echo 자동으로 환경을 복구합니다...
    call fix_environment.bat
)

:: 2. PyCharm 실행 확인
echo [2/4] PyCharm 실행 확인 중...
tasklist /FI "IMAGENAME eq pycharm*" 2>nul | find /i "pycharm" >nul
if %errorLevel% neq 0 (
    echo [WARNING] PyCharm이 실행되지 않았습니다.
    echo Routine_app 프로젝트를 PyCharm에서 열어주세요.
    echo.
    echo PyCharm 미실행 상태에서 계속 진행합니다...
)

:: 3. 자동 실행 모드
echo [3/4] 자동 실행 모드...
echo.
echo 자동으로 전체 자동화 모드를 시작합니다:
echo - PyCharm 터미널 자동 설정
echo - 자동 응답 시스템 활성화
echo.
goto :full_automation

:full_automation
echo [4/4] 전체 자동화 시스템 시작 중...
echo.
echo 1. PyCharm 터미널 자동 설정을 시작합니다...
echo 2. 5초 후 자동 응답 시스템이 시작됩니다...
echo 3. 두 시스템이 동시에 실행됩니다...
echo.
echo 자동으로 시작합니다... (3초 후)
timeout /t 3 /nobreak >nul

:: 터미널 설정 시작
start "PyCharm Controller" python pycharm_terminal_controller.py

:: 5초 대기
timeout /t 5 /nobreak >nul

:: 자동 응답 시스템 시작
start "Auto Responder" python auto_responder.py monitor

echo.
echo ✓ 두 시스템이 모두 시작되었습니다!
echo ✓ 백그라운드에서 실행 중입니다.
echo.
goto :end

:terminal_only
echo [4/4] PyCharm 터미널 설정 시작 중...
echo.
echo 자동으로 시작합니다... (3초 후)
timeout /t 3 /nobreak >nul

python pycharm_terminal_controller.py
goto :end

:responder_only
echo [4/4] 자동 응답 시스템 시작 중...
echo.
echo 모니터링 중인 패턴:
echo - "1. Yes  2. Yes, and don't ask again" → "2"
echo - "(Y/n)" → "Y"
echo - "Continue?" → "Y"
echo.
python auto_responder.py monitor
goto :end

:test_mode
echo [4/4] 테스트 모드 실행 중...
echo.
python test_terminal_setup.py
goto :end

:end
echo.
echo ====================================
echo 시스템 종료
echo ====================================
echo.
echo 백그라운드 프로세스를 유지합니다 (자동화 계속 실행)
echo 수동 종료가 필요한 경우:
echo   taskkill /F /FI "WINDOWTITLE eq PyCharm Controller"
echo   taskkill /F /FI "WINDOWTITLE eq Auto Responder"
echo.
echo 사용해 주셔서 감사합니다!
echo 자동화 시스템이 백그라운드에서 실행 중입니다.