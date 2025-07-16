@echo off
:: WSL Claude Code 터미널 자동화 시스템
:: 5개 터미널을 열고 각각 WSL 모드로 전환 후 Claude Code 실행

echo ====================================
echo WSL Claude Code 터미널 자동화 시스템
echo ====================================
echo.

:: 관리자 권한 확인
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] 관리자 권한으로 실행하는 것을 권장합니다.
    echo 우클릭 - "관리자 권한으로 실행"
    echo.
    echo 일반 권한으로 계속 진행합니다... (5초 후)
    timeout /t 5 /nobreak >nul
    echo.
)

:: 환경 확인
echo [1/4] 환경 확인 중...
echo.

:: WSL 설치 확인
wsl --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] WSL이 설치되지 않았거나 사용할 수 없습니다.
    echo WSL 설치 방법:
    echo   1. 관리자 권한으로 PowerShell 실행
    echo   2. wsl --install 명령 실행
    echo   3. 재부팅 후 다시 시도
    echo.
    echo 자동 종료합니다.
    pause
    exit /b 1
)

:: Claude Code 설치 확인
echo Claude Code 설치 확인 중...
wsl -e bash -c "which claude" >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] Claude Code가 WSL에 설치되지 않았습니다.
    echo.
    echo Claude Code 설치 방법:
    echo   1. WSL에서 실행: curl -fsSL https://claude.ai/install.sh | bash
    echo   2. 또는 npm install -g @anthropic-ai/claude-cli
    echo.
    echo Claude Code 없이 계속 진행합니다...
    echo 각 터미널에서 수동으로 설치하세요.
    echo.
    timeout /t 3 /nobreak >nul
)

:: 프로젝트 디렉토리 확인
echo 프로젝트 디렉토리 확인 중...
if not exist "C:\Git\Routine_app\SquashTrainingApp" (
    echo [ERROR] 프로젝트 디렉토리를 찾을 수 없습니다.
    echo 경로: C:\Git\Routine_app\SquashTrainingApp
    echo.
    echo 프로젝트 디렉토리가 올바른지 확인하세요.
    pause
    exit /b 1
)

echo ✅ 환경 확인 완료
echo.

:: 터미널 생성
echo [2/4] 터미널 생성 중...
echo.

:: Terminal 1: 🧠 Claude4-Opus-Planner (계획 및 아키텍처)
echo 터미널 1 생성 중: 🧠 Claude4-Opus-Planner
wt new-tab --title "🧠Claude4-Opus-Planner" cmd /k "wsl -e bash -c 'cd /mnt/c/Git/Routine_app/SquashTrainingApp && echo \"🧠 Claude4-Opus-Planner - 계획 및 아키텍처 설계 담당\" && echo \"프로젝트 디렉토리: /mnt/c/Git/Routine_app/SquashTrainingApp\" && echo \"역할: 계획 및 아키텍처 설계\" && echo \"모델: claude-3-opus-20240229\" && echo \"\" && echo \"Claude Code 시작 방법:\" && echo \"  claude --model claude-3-opus-20240229\" && echo \"\" && echo \"Enter를 두 번 눌러야 명령이 전달됩니다!\" && echo \"\" && exec bash'"
timeout /t 2 /nobreak >nul

:: Terminal 2: 🔨 Claude4-Sonnet-Coder1 (주요 구현)
echo 터미널 2 생성 중: 🔨 Claude4-Sonnet-Coder1
wt new-tab --title "🔨Claude4-Sonnet-Coder1" cmd /k "wsl -e bash -c 'cd /mnt/c/Git/Routine_app/SquashTrainingApp && echo \"🔨 Claude4-Sonnet-Coder1 - 주요 코드 구현 담당\" && echo \"프로젝트 디렉토리: /mnt/c/Git/Routine_app/SquashTrainingApp\" && echo \"역할: 주요 코드 구현\" && echo \"모델: claude-3-5-sonnet-20241022\" && echo \"\" && echo \"Claude Code 시작 방법:\" && echo \"  claude --model claude-3-5-sonnet-20241022\" && echo \"\" && echo \"Enter를 두 번 눌러야 명령이 전달됩니다!\" && echo \"\" && exec bash'"
timeout /t 2 /nobreak >nul

:: Terminal 3: 🔧 Claude4-Sonnet-Coder2 (테스트 및 디버깅)
echo 터미널 3 생성 중: 🔧 Claude4-Sonnet-Coder2
wt new-tab --title "🔧Claude4-Sonnet-Coder2" cmd /k "wsl -e bash -c 'cd /mnt/c/Git/Routine_app/SquashTrainingApp && echo \"🔧 Claude4-Sonnet-Coder2 - 테스트 및 디버깅 담당\" && echo \"프로젝트 디렉토리: /mnt/c/Git/Routine_app/SquashTrainingApp\" && echo \"역할: 테스트 및 디버깅\" && echo \"모델: claude-3-5-sonnet-20241022\" && echo \"\" && echo \"Claude Code 시작 방법:\" && echo \"  claude --model claude-3-5-sonnet-20241022\" && echo \"\" && echo \"Enter를 두 번 눌러야 명령이 전달됩니다!\" && echo \"\" && exec bash'"
timeout /t 2 /nobreak >nul

:: Terminal 4: ⚙️ Claude4-Sonnet-Coder3 (빌드 및 배포)
echo 터미널 4 생성 중: ⚙️ Claude4-Sonnet-Coder3
wt new-tab --title "⚙️Claude4-Sonnet-Coder3" cmd /k "wsl -e bash -c 'cd /mnt/c/Git/Routine_app/SquashTrainingApp && echo \"⚙️ Claude4-Sonnet-Coder3 - 빌드 및 배포 담당\" && echo \"프로젝트 디렉토리: /mnt/c/Git/Routine_app/SquashTrainingApp\" && echo \"역할: 빌드 및 배포\" && echo \"모델: claude-3-5-sonnet-20241022\" && echo \"\" && echo \"Claude Code 시작 방법:\" && echo \"  claude --model claude-3-5-sonnet-20241022\" && echo \"\" && echo \"Enter를 두 번 눌러야 명령이 전달됩니다!\" && echo \"\" && exec bash'"
timeout /t 2 /nobreak >nul

:: Terminal 5: 📊 Claude4-Sonnet-Monitor (모니터링 및 조정)
echo 터미널 5 생성 중: 📊 Claude4-Sonnet-Monitor
wt new-tab --title "📊Claude4-Sonnet-Monitor" cmd /k "wsl -e bash -c 'cd /mnt/c/Git/Routine_app/SquashTrainingApp && echo \"📊 Claude4-Sonnet-Monitor - 모니터링 및 조정 담당\" && echo \"프로젝트 디렉토리: /mnt/c/Git/Routine_app/SquashTrainingApp\" && echo \"역할: 모니터링 및 조정\" && echo \"모델: claude-3-5-sonnet-20241022\" && echo \"\" && echo \"Claude Code 시작 방법:\" && echo \"  claude --model claude-3-5-sonnet-20241022\" && echo \"\" && echo \"Enter를 두 번 눌러야 명령이 전달됩니다!\" && echo \"\" && exec bash'"
timeout /t 2 /nobreak >nul

echo.
echo ✅ 모든 터미널이 생성되었습니다!
echo.

:: 설정 지침
echo [3/4] 설정 지침 표시 중...
echo.
echo ====================================
echo 터미널 설정 가이드
echo ====================================
echo.
echo 각 터미널에서 다음 명령을 실행하세요:
echo.
echo 1. 각 터미널은 이미 WSL 모드로 진입됩니다
echo 2. 프로젝트 디렉토리에 자동 이동됩니다
echo 3. 다음 명령으로 Claude Code를 시작하세요:
echo.
echo    플래너용 (Terminal 1):
echo    claude --model claude-3-opus-20240229
echo.
echo    코더용 (Terminal 2-5):
echo    claude --model claude-3-5-sonnet-20241022
echo.
echo    또는 간단히:
echo    claude
echo.
echo ⚠️ 중요: Claude Code에서는 Enter를 두 번 눌러야 명령이 전달됩니다!
echo.
echo 터미널 역할 분배:
echo   🧠 Claude4-Opus-Planner: 계획 및 아키텍처 설계
echo   🔨 Claude4-Sonnet-Coder1: 주요 코드 구현
echo   🔧 Claude4-Sonnet-Coder2: 테스트 및 디버깅
echo   ⚙️ Claude4-Sonnet-Coder3: 빌드 및 배포
echo   📊 Claude4-Sonnet-Monitor: 모니터링 및 조정
echo.
echo 터미널 탭 전환:
echo   Ctrl+Tab: 다음 탭
echo   Ctrl+Shift+Tab: 이전 탭
echo   Ctrl+Shift+숫자: 특정 탭으로 이동
echo.

:: 자동화 가이드
echo [4/4] 자동화 가이드...
echo.
echo ====================================
echo 50+ 사이클 자동화 가이드
echo ====================================
echo.
echo 각 터미널에서 다음 작업을 순환 수행하세요:
echo.
echo 🧠 플래너 (Terminal 1):
echo   - 전체 개발 사이클 계획 수립
echo   - 아키텍처 설계 및 개선
echo   - 다른 에이전트들에게 작업 분배
echo.
echo 🔨 주요 코더 (Terminal 2):
echo   - React Native 컴포넌트 구현
echo   - 핵심 비즈니스 로직 작성
echo   - 상태 관리 및 API 연동
echo.
echo 🔧 테스트 코더 (Terminal 3):
echo   - 빌드 테스트 및 디버깅
echo   - 기능 테스트 수행
echo   - 버그 수정 및 최적화
echo.
echo ⚙️ 빌드 코더 (Terminal 4):
echo   - APK 빌드 및 배포
echo   - 에뮬레이터 테스트
echo   - 설치/삭제 사이클 관리
echo.
echo 📊 모니터 (Terminal 5):
echo   - 전체 진행 상황 모니터링
echo   - 팀 간 조정 및 협업
echo   - 성과 측정 및 리포팅
echo.
echo 사이클 프로세스:
echo   1. 설치 → 2. 실행 → 3. 모든 기능 디버그 → 4. 앱 삭제 → 5. 수정
echo   이 과정을 fail/issue가 없을 때까지 50회+ 반복 수행
echo.
echo ====================================
echo 설정 완료!
echo ====================================
echo.
echo 모든 터미널이 준비되었습니다.
echo 각 터미널에서 Claude Code를 시작하고 작업을 시작하세요.
echo.
echo 성공적인 자동화를 위해 화이팅! 🚀
echo.
pause