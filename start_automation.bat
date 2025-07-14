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
    set /p choice="지금 환경을 복구하시겠습니까? (Y/n): "
    if /i "%choice%"=="n" goto :end
    call fix_environment.bat
)

:: 2. PyCharm 실행 확인
echo [2/4] PyCharm 실행 확인 중...
tasklist /FI "IMAGENAME eq pycharm*" 2>nul | find /i "pycharm" >nul
if %errorLevel% neq 0 (
    echo [WARNING] PyCharm이 실행되지 않았습니다.
    echo Routine_app 프로젝트를 PyCharm에서 열어주세요.
    echo.
    echo 계속 진행하시겠습니까?
    set /p choice="(Y/n): "
    if /i "%choice%"=="n" goto :end
)

:: 3. 실행 모드 선택
echo [3/4] 실행 모드 선택...
echo.
echo 실행 모드를 선택하세요:
echo 1. 전체 자동화 (PyCharm 터미널 + 자동 응답)
echo 2. PyCharm 터미널 설정만
echo 3. 자동 응답 시스템만
echo 4. 테스트 모드
echo 5. 취소
echo.
set /p mode="선택 (1-5): "

if "%mode%"=="1" goto :full_automation
if "%mode%"=="2" goto :terminal_only
if "%mode%"=="3" goto :responder_only
if "%mode%"=="4" goto :test_mode
if "%mode%"=="5" goto :end

echo 잘못된 선택입니다.
goto :end

:full_automation
echo [4/4] 전체 자동화 시스템 시작 중...
echo.
echo 1. PyCharm 터미널 자동 설정을 시작합니다...
echo 2. 5초 후 자동 응답 시스템이 시작됩니다...
echo 3. 두 시스템이 동시에 실행됩니다...
echo.
echo 준비되셨으면 Enter를 누르세요...
pause >nul

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
echo 준비되셨으면 Enter를 누르세요...
pause >nul

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
echo 백그라운드 프로세스를 종료하시겠습니까?
set /p choice="(Y/n): "
if /i "%choice%"=="y" (
    taskkill /F /FI "WINDOWTITLE eq PyCharm Controller" 2>nul
    taskkill /F /FI "WINDOWTITLE eq Auto Responder" 2>nul
    echo ✓ 백그라운드 프로세스 종료됨
)
echo.
echo 사용해 주셔서 감사합니다!
pause