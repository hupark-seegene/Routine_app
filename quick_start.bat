@echo off
:: 빠른 시작 배치 파일
:: 환경 문제 해결 및 터미널 자동화 시스템 실행

echo ====================================
echo Quick Start - Multi-Agent System
echo ====================================
echo.

:: 1. 환경 복구 실행
echo [1/3] 환경 복구 중...
call fix_environment.bat
if %errorLevel% neq 0 (
    echo [ERROR] 환경 복구 실패
    pause
    exit /b 1
)

echo.
echo [2/3] Claude Code 확인 중...
claude --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] Claude Code가 설치되지 않았습니다.
    echo 설치: npm install -g @anthropic-ai/claude-code
    echo 또는 시스템 없이 계속 진행하시겠습니까?
    set /p choice="(Y/n): "
    if /i "%choice%"=="n" (
        echo 설치 후 다시 실행하세요.
        pause
        exit /b 1
    )
)

echo.
echo [3/3] 터미널 자동화 시스템 실행 중...
echo.
echo 실행 옵션을 선택하세요:
echo 1. PyCharm 터미널 자동 설정
echo 2. 자동 응답 시스템만 실행
echo 3. 시스템 테스트
echo 4. 취소
echo.
set /p option="선택 (1-4): "

if "%option%"=="1" (
    echo PyCharm 터미널 자동 설정 실행 중...
    python pycharm_terminal_controller.py
) else if "%option%"=="2" (
    echo 자동 응답 시스템 실행 중...
    python auto_responder.py monitor
) else if "%option%"=="3" (
    echo 시스템 테스트 실행 중...
    python test_terminal_setup.py
) else if "%option%"=="4" (
    echo 취소됨
    goto :end
) else (
    echo 잘못된 선택입니다.
    goto :end
)

:end
echo.
echo ====================================
echo 완료!
echo ====================================
pause