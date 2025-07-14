@echo off
:: PyCharm 터미널 자동 설정 및 실행 스크립트
:: 이 스크립트는 PyCharm에서 실행하세요

echo ====================================
echo PyCharm Multi-Agent Terminal Setup
echo ====================================
echo.

:: Python 환경 확인
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python이 설치되지 않았습니다.
    echo Python을 설치하고 PATH에 추가하세요.
    pause
    exit /b 1
)

:: 의존성 확인
echo [1/4] 의존성 확인 중...
pip show pyautogui >nul 2>&1
if errorlevel 1 (
    echo 필요한 패키지 설치 중...
    pip install pyautogui pygetwindow pywin32 psutil
)

:: Claude Code 확인
echo [2/4] Claude Code 확인 중...
claude --version >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Claude Code가 설치되지 않았습니다.
    echo 다음 명령으로 설치하세요: npm install -g @anthropic-ai/claude-code
    echo.
)

:: 터미널 컨트롤러 실행
echo [3/4] PyCharm 터미널 자동 설정 시작...
echo.
echo 주의사항:
echo - PyCharm이 전면에 나타납니다
echo - 자동으로 터미널이 생성됩니다
echo - 마우스를 움직이지 마세요
echo.
echo 준비되면 Enter를 누르세요...
pause >nul

:: 메인 스크립트 실행
echo [4/4] 터미널 설정 중...
python pycharm_terminal_controller.py

echo.
echo ====================================
echo 설정 완료!
echo ====================================
pause