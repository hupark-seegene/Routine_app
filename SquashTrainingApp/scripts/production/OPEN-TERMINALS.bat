@echo off
echo 🚀 Claude AI 터미널 자동화 시스템 (WSL + Claude Code)
echo ========================================================
echo.

:: 환경 확인
echo 환경 확인 중...
wsl --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] WSL이 설치되지 않았거나 사용할 수 없습니다.
    echo 수동으로 각 터미널에서 WSL을 시작하세요.
    echo.
)

echo 터미널 생성 중 (WSL 자동 진입)...
echo.

:: Terminal 1: 🧠 Claude4-Opus-Planner (계획 및 아키텍처) - WSL 자동 진입
echo 터미널 1 생성: 🧠 Claude4-Opus-Planner
wt new-tab --title "🧠Claude4-Opus-Planner" cmd /k "wsl -e bash -c 'cd /mnt/c/Git/Routine_app/SquashTrainingApp && echo \"🧠 Claude4-Opus-Planner - 계획 및 아키텍처 설계 담당\" && echo \"프로젝트 디렉토리: $(pwd)\" && echo \"Claude Code 시작: claude --model claude-3-opus-20240229\" && echo \"\" && exec bash'"
timeout /t 2 /nobreak >nul

:: Terminal 2: 🔨 Claude4-Sonnet-Coder1 (주요 구현) - WSL 자동 진입
echo 터미널 2 생성: 🔨 Claude4-Sonnet-Coder1
wt new-tab --title "🔨Claude4-Sonnet-Coder1" cmd /k "wsl -e bash -c 'cd /mnt/c/Git/Routine_app/SquashTrainingApp && echo \"🔨 Claude4-Sonnet-Coder1 - 주요 코드 구현 담당\" && echo \"프로젝트 디렉토리: $(pwd)\" && echo \"Claude Code 시작: claude --model claude-3-5-sonnet-20241022\" && echo \"\" && exec bash'"
timeout /t 2 /nobreak >nul

:: Terminal 3: 🔧 Claude4-Sonnet-Coder2 (테스트 및 디버깅) - WSL 자동 진입
echo 터미널 3 생성: 🔧 Claude4-Sonnet-Coder2
wt new-tab --title "🔧Claude4-Sonnet-Coder2" cmd /k "wsl -e bash -c 'cd /mnt/c/Git/Routine_app/SquashTrainingApp && echo \"🔧 Claude4-Sonnet-Coder2 - 테스트 및 디버깅 담당\" && echo \"프로젝트 디렉토리: $(pwd)\" && echo \"Claude Code 시작: claude --model claude-3-5-sonnet-20241022\" && echo \"\" && exec bash'"
timeout /t 2 /nobreak >nul

:: Terminal 4: ⚙️ Claude4-Sonnet-Coder3 (빌드 및 배포) - WSL 자동 진입
echo 터미널 4 생성: ⚙️ Claude4-Sonnet-Coder3
wt new-tab --title "⚙️Claude4-Sonnet-Coder3" cmd /k "wsl -e bash -c 'cd /mnt/c/Git/Routine_app/SquashTrainingApp && echo \"⚙️ Claude4-Sonnet-Coder3 - 빌드 및 배포 담당\" && echo \"프로젝트 디렉토리: $(pwd)\" && echo \"Claude Code 시작: claude --model claude-3-5-sonnet-20241022\" && echo \"\" && exec bash'"
timeout /t 2 /nobreak >nul

:: Terminal 5: 📊 Claude4-Sonnet-Monitor (모니터링 및 조정) - WSL 자동 진입
echo 터미널 5 생성: 📊 Claude4-Sonnet-Monitor
wt new-tab --title "📊Claude4-Sonnet-Monitor" cmd /k "wsl -e bash -c 'cd /mnt/c/Git/Routine_app/SquashTrainingApp && echo \"📊 Claude4-Sonnet-Monitor - 모니터링 및 조정 담당\" && echo \"프로젝트 디렉토리: $(pwd)\" && echo \"Claude Code 시작: claude --model claude-3-5-sonnet-20241022\" && echo \"\" && exec bash'"
timeout /t 2 /nobreak >nul

echo.
echo ✅ 모든 터미널이 생성되었습니다!
echo.
echo ========================================================
echo Claude Code 시작 가이드
echo ========================================================
echo.
echo 각 터미널에서 다음 명령을 실행하세요:
echo.
echo 🧠 플래너 (Terminal 1):
echo   claude --model claude-3-opus-20240229
echo.
echo 🔨🔧⚙️📊 코더들 (Terminal 2-5):
echo   claude --model claude-3-5-sonnet-20241022
echo.
echo 또는 간단히:
echo   claude
echo.
echo ⚠️ 중요: Claude Code에서는 Enter를 두 번 눌러야 명령이 전달됩니다!
echo.
echo 터미널 역할 분배:
echo 🧠 Claude4-Opus-Planner: 계획 및 아키텍처 설계
echo 🔨 Claude4-Sonnet-Coder1: 주요 코드 구현
echo 🔧 Claude4-Sonnet-Coder2: 테스트 및 디버깅
echo ⚙️ Claude4-Sonnet-Coder3: 빌드 및 배포
echo 📊 Claude4-Sonnet-Monitor: 모니터링 및 조정
echo.
echo 50+ 사이클 자동화:
echo   설치 → 실행 → 모든 기능 디버그 → 앱 삭제 → 수정
echo   이 과정을 fail/issue가 없을 때까지 반복 수행
echo.
echo ========================================================
echo.

pause