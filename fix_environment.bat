@echo off
:: 환경 복구 및 의존성 설치 배치 파일
:: Python 가상환경 문제 해결 및 패키지 설치

echo ====================================
echo Python Environment Fix & Setup
echo ====================================
echo.

:: 관리자 권한 확인
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] 관리자 권한으로 실행하는 것이 좋습니다.
    echo 우클릭 - "관리자 권한으로 실행"
    echo 계속 진행합니다...
    echo.
)

:: 1. 기존 가상환경 정리
echo [1/7] 기존 가상환경 정리 중...
if exist .venv (
    echo 기존 .venv 디렉토리 삭제 중...
    rmdir /s /q .venv 2>nul
    timeout /t 2 /nobreak >nul
)

:: 2. Python 버전 확인
echo [2/7] Python 버전 확인 중...
python --version
if %errorLevel% neq 0 (
    echo [ERROR] Python이 설치되지 않았거나 PATH에 없습니다.
    echo Python 3.8 이상을 설치하고 PATH에 추가하세요.
    echo https://python.org/downloads/
    echo 자동 종료합니다.
    exit /b 1
)

:: 3. 가상환경 생성
echo [3/7] 새 가상환경 생성 중...
python -m venv .venv
if %errorLevel% neq 0 (
    echo [ERROR] 가상환경 생성 실패
    echo 시스템 Python을 사용하여 계속 진행합니다...
    goto :skip_venv
)

:: 4. 가상환경 활성화 (PowerShell 실행 정책 문제 해결)
echo [4/7] 가상환경 활성화 중...
call .venv\Scripts\activate.bat
if %errorLevel% neq 0 (
    echo [WARNING] 가상환경 활성화 실패, 시스템 Python 사용
    goto :skip_venv
)

:: 5. pip 업그레이드
echo [5/7] pip 업그레이드 중...
python -m pip install --upgrade pip
goto :install_packages

:skip_venv
echo [INFO] 시스템 Python 사용으로 전환

:install_packages
:: 6. 필수 패키지 설치
echo [6/7] 필수 패키지 설치 중...
echo.

:: 하나씩 설치하여 오류 방지
echo Installing pyautogui...
python -m pip install pyautogui==0.9.54
if %errorLevel% neq 0 (
    echo [WARNING] pyautogui 설치 실패
)

echo Installing pygetwindow...
python -m pip install pygetwindow==0.0.9
if %errorLevel% neq 0 (
    echo [WARNING] pygetwindow 설치 실패
)

echo Installing pywin32...
python -m pip install pywin32==306
if %errorLevel% neq 0 (
    echo [WARNING] pywin32 설치 실패
)

echo Installing psutil...
python -m pip install psutil==5.9.8
if %errorLevel% neq 0 (
    echo [WARNING] psutil 설치 실패
)

echo Installing python-dotenv...
python -m pip install python-dotenv==1.0.0
if %errorLevel% neq 0 (
    echo [WARNING] python-dotenv 설치 실패
)

:: 7. 설치 확인
echo [7/7] 설치 확인 중...
echo.

python -c "import pyautogui; print('pyautogui: OK')" 2>nul || echo "pyautogui: FAIL"
python -c "import pygetwindow; print('pygetwindow: OK')" 2>nul || echo "pygetwindow: FAIL"
python -c "import win32api; print('pywin32: OK')" 2>nul || echo "pywin32: FAIL"
python -c "import psutil; print('psutil: OK')" 2>nul || echo "psutil: FAIL"
python -c "import dotenv; print('python-dotenv: OK')" 2>nul || echo "python-dotenv: FAIL"

echo.
echo ====================================
echo 환경 설정 완료!
echo ====================================
echo.

:: 자동 테스트 실행
echo 자동으로 시스템 테스트를 실행합니다...
echo.
echo 시스템 테스트 실행 중...
python test_terminal_setup.py

:end
echo.
echo ====================================
echo 다음 단계:
echo ====================================
echo 1. PyCharm에서 터미널 자동 설정:
echo    python pycharm_terminal_controller.py
echo.
echo 2. 또는 배치 파일 실행:
echo    launch_pycharm_terminals.bat
echo.
echo 3. 자동 응답 시스템:
echo    python auto_responder.py monitor
echo ====================================
echo.
echo 환경 설정이 완료되었습니다.