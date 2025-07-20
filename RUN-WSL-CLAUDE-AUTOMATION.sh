#!/bin/bash

# WSL Claude Code 자동화 실행 스크립트
# 5개 터미널을 자동으로 생성하고 Claude Code를 시작합니다

echo "🚀 WSL Claude Code 자동화 시스템 시작..."
echo "=================================================="

# 프로젝트 루트 디렉토리로 이동
cd /mnt/c/Git/Routine_app

echo "📁 현재 디렉토리: $(pwd)"
echo ""

# Windows Terminal이 설치되어 있는지 확인
if ! command -v wt.exe &> /dev/null; then
    echo "❌ Windows Terminal (wt.exe)이 설치되지 않았습니다."
    echo "Microsoft Store에서 Windows Terminal을 설치하세요."
    exit 1
fi

echo "✅ Windows Terminal 발견됨"
echo ""

# 5개 터미널 생성 (WSL 환경에서)
echo "터미널 생성 중..."

# Terminal 1: 🧠 Claude4-Opus-Planner
echo "터미널 1 생성: 🧠 Claude4-Opus-Planner"
cmd.exe /c "wt new-tab --title \"🧠Claude4-Opus-Planner\" wsl"
sleep 3

# Terminal 2: 🔨 Claude4-Sonnet-Coder1
echo "터미널 2 생성: 🔨 Claude4-Sonnet-Coder1"
cmd.exe /c "wt new-tab --title \"🔨Claude4-Sonnet-Coder1\" wsl"
sleep 3

# Terminal 3: 🔧 Claude4-Sonnet-Coder2
echo "터미널 3 생성: 🔧 Claude4-Sonnet-Coder2"
cmd.exe /c "wt new-tab --title \"🔧Claude4-Sonnet-Coder2\" wsl"
sleep 3

# Terminal 4: ⚙️ Claude4-Sonnet-Coder3
echo "터미널 4 생성: ⚙️ Claude4-Sonnet-Coder3"
cmd.exe /c "wt new-tab --title \"⚙️Claude4-Sonnet-Coder3\" wsl"
sleep 3

# Terminal 5: 📊 Claude4-Sonnet-Monitor
echo "터미널 5 생성: 📊 Claude4-Sonnet-Monitor"
cmd.exe /c "wt new-tab --title \"📊Claude4-Sonnet-Monitor\" wsl"
sleep 3

echo ""
echo "✅ 모든 터미널이 생성되었습니다!"
echo ""

# 사용 지침 출력
echo "=================================================="
echo "🎯 Claude Code 시작 가이드"
echo "=================================================="
echo ""
echo "각 터미널에서 다음 명령을 실행하세요:"
echo ""
echo "claude"
echo ""
echo "※ 모든 터미널에서 동일한 명령어 'claude'만 입력하면 됩니다."
echo "※ 각 터미널은 이미 /mnt/c/Git/Routine_app 디렉토리에 위치합니다."
echo ""
echo "⚠️ 중요: Claude Code에서는 Enter를 두 번 눌러야 명령이 전달됩니다!"
echo ""

# 터미널 역할 설명
echo "터미널 역할 분배:"
echo "🧠 Claude4-Opus-Planner: 계획 및 아키텍처 설계"
echo "🔨 Claude4-Sonnet-Coder1: 주요 코드 구현"
echo "🔧 Claude4-Sonnet-Coder2: 테스트 및 디버깅"
echo "⚙️ Claude4-Sonnet-Coder3: 빌드 및 배포"
echo "📊 Claude4-Sonnet-Monitor: 모니터링 및 조정"
echo ""

# 자동화 사이클 설명
echo "=================================================="
echo "🔄 50+ 사이클 자동화 프로세스"
echo "=================================================="
echo ""
echo "사이클: 설치 → 실행 → 모든 기능 디버그 → 앱 삭제 → 수정"
echo "목표: fail/issue가 없을 때까지 50회 이상 반복 수행"
echo ""
echo "각 터미널에서 역할에 맞는 작업을 수행하고"
echo "서로 협력하여 완성된 앱을 만들어가세요!"
echo ""
echo "🚀 성공적인 자동화를 위해 화이팅!"

# 터미널 상태 확인 (옵션)
echo ""
echo "터미널 탭 전환 방법:"
echo "  Ctrl+Tab: 다음 탭"
echo "  Ctrl+Shift+Tab: 이전 탭"
echo "  Ctrl+Shift+숫자: 특정 탭으로 이동"
echo ""
echo "=================================================="