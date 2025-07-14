@echo off
:: 대안적 설치 방법 (가상환경 없이)
:: Python 3.13의 ctypes 문제 해결

echo ====================================
echo Alternative Package Installation
echo ====================================
echo.

:: Python 버전 확인
echo Python 버전 확인 중...
python --version
for /f "tokens=2 delims= " %%a in ('python --version 2^>^&1') do set pyver=%%a
echo 감지된 Python 버전: %pyver%

:: Python 3.13 경고
echo %pyver% | findstr "3.13" >nul
if %errorLevel% equ 0 (
    echo.
    echo [WARNING] Python 3.13은 일부 패키지와 호환성 문제가 있습니다.
    echo Python 3.11 또는 3.12 사용을 권장합니다.
    echo.
    echo 계속 진행하시겠습니까?
    set /p choice="(Y/n): "
    if /i "%choice%"=="n" exit /b 1
)

echo.
echo [1/6] 기존 패키지 정리 중...
python -m pip uninstall -y pyautogui pygetwindow pywin32 psutil python-dotenv 2>nul

echo.
echo [2/6] pip 업그레이드 중...
python -m pip install --upgrade pip

echo.
echo [3/6] 호환성 좋은 버전으로 개별 설치 중...

:: 안정적인 버전들로 설치
echo Installing pyautogui (older stable version)...
python -m pip install pyautogui==0.9.53 --no-cache-dir
if %errorLevel% neq 0 (
    echo Trying alternative version...
    python -m pip install pyautogui==0.9.52 --no-cache-dir
)

echo Installing pygetwindow...
python -m pip install pygetwindow==0.0.9 --no-cache-dir

echo Installing psutil...
python -m pip install psutil==5.9.5 --no-cache-dir

echo Installing python-dotenv...
python -m pip install python-dotenv==1.0.0 --no-cache-dir

echo Installing pywin32...
python -m pip install pywin32==306 --no-cache-dir
if %errorLevel% neq 0 (
    echo Trying alternative pywin32 installation...
    python -m pip install pywin32==305 --no-cache-dir
)

echo.
echo [4/6] pywin32 post-install 설정...
python -m pip install --upgrade pywin32
python Scripts\pywin32_postinstall.py -install 2>nul

echo.
echo [5/6] 패키지 검증 중...
python -c "import sys; print(f'Python: {sys.version}')"
python -c "import pyautogui; print('✓ pyautogui')" 2>nul || echo "✗ pyautogui"
python -c "import pygetwindow; print('✓ pygetwindow')" 2>nul || echo "✗ pygetwindow"
python -c "import psutil; print('✓ psutil')" 2>nul || echo "✗ psutil"
python -c "import dotenv; print('✓ python-dotenv')" 2>nul || echo "✗ python-dotenv"
python -c "import win32api; print('✓ pywin32')" 2>nul || echo "✗ pywin32"

echo.
echo [6/6] 최종 검증 테스트...
python -c "
import pyautogui
import psutil
print('화면 크기:', pyautogui.size())
print('CPU 개수:', psutil.cpu_count())
print('메모리:', round(psutil.virtual_memory().total / 1024**3, 1), 'GB')
print('✓ 모든 핵심 기능 작동 확인')
" 2>nul || echo "일부 기능에서 오류 발생"

echo.
echo ====================================
echo 설치 완료!
echo ====================================
echo.

:: 간단한 기능 테스트
echo 간단한 기능 테스트를 실행하시겠습니까?
set /p choice="(Y/n): "
if /i "%choice%"=="n" goto :end
if /i "%choice%"=="no" goto :end

echo.
echo 기능 테스트 실행 중...
python test_terminal_setup.py

:end
echo.
echo 다음 단계:
echo 1. python pycharm_terminal_controller.py
echo 2. python auto_responder.py monitor
echo.
pause