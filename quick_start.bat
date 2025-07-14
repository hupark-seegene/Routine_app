@echo off
:: 빠른 시작 배치 파일
:: 환경 문제 해결 및 터미널 자동화 시스템 실행

echo ====================================
echo Quick Start - Multi-Agent System
echo ====================================
echo.
echo 이 스크립트는 다음을 자동으로 수행합니다:
echo 1. Python 환경 문제 해결
echo 2. 필수 패키지 설치
echo 3. PyCharm 터미널 자동 설정
echo 4. 자동 응답 시스템 시작
echo.
echo 자동으로 시작합니다... (3초 후)
timeout /t 3 /nobreak >nul
echo.

:: 1. 환경 복구 실행
echo [1/3] 환경 복구 중...
call fix_environment.bat
if %errorLevel% neq 0 (
    echo [ERROR] 환경 복구 실패
    echo 자동 종료합니다.
    exit /b 1
)

echo.
echo [2/3] Claude Code 확인 중...
claude --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] Claude Code가 설치되지 않았습니다.
    echo 설치: npm install -g @anthropic-ai/claude-code
    echo Claude Code 없이 계속 진행합니다...
)

echo.
echo [3/3] 터미널 자동화 시스템 실행 중...
echo.
echo 자동으로 PyCharm 터미널 자동 설정을 실행합니다...
echo.
echo PyCharm 터미널 자동 설정 실행 중...
python pycharm_terminal_controller.py

:end
echo.
echo ====================================
echo 완료!
echo ====================================
echo 시스템이 자동으로 실행 중입니다.