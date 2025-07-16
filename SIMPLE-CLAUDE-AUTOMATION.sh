#!/bin/bash

# 간단한 Claude Code 터미널 자동화 스크립트
# 5개 터미널을 /mnt/c/Git/Routine_app에서 생성

echo "🚀 간단한 Claude Code 터미널 자동화"
echo "=========================================="
echo ""

# 현재 디렉토리 확인
echo "📁 현재 디렉토리: $(pwd)"

# /mnt/c/Git/Routine_app 디렉토리로 이동
cd /mnt/c/Git/Routine_app

echo "📁 작업 디렉토리: $(pwd)"
echo ""

# Windows Terminal 확인
if ! command -v wt.exe &> /dev/null; then
    echo "❌ Windows Terminal이 설치되지 않았습니다."
    exit 1
fi

echo "✅ Windows Terminal 확인됨"
echo ""

# 5개 터미널 생성
echo "터미널 생성 중..."
echo ""

# Terminal 1: 플래너
echo "터미널 1: 🧠 Claude4-Opus-Planner"
cmd.exe /c "wt new-tab --title \"🧠Claude4-Opus-Planner\" wsl -d Ubuntu --cd /mnt/c/Git/Routine_app"
sleep 3

# Terminal 2: 코더1
echo "터미널 2: 🔨 Claude4-Sonnet-Coder1"
cmd.exe /c "wt new-tab --title \"🔨Claude4-Sonnet-Coder1\" wsl -d Ubuntu --cd /mnt/c/Git/Routine_app"
sleep 3

# Terminal 3: 코더2
echo "터미널 3: 🔧 Claude4-Sonnet-Coder2"
cmd.exe /c "wt new-tab --title \"🔧Claude4-Sonnet-Coder2\" wsl -d Ubuntu --cd /mnt/c/Git/Routine_app"
sleep 3

# Terminal 4: 코더3
echo "터미널 4: ⚙️ Claude4-Sonnet-Coder3"
cmd.exe /c "wt new-tab --title \"⚙️Claude4-Sonnet-Coder3\" wsl -d Ubuntu --cd /mnt/c/Git/Routine_app"
sleep 3

# Terminal 5: 모니터
echo "터미널 5: 📊 Claude4-Sonnet-Monitor"
cmd.exe /c "wt new-tab --title \"📊Claude4-Sonnet-Monitor\" wsl -d Ubuntu --cd /mnt/c/Git/Routine_app"
sleep 3

echo ""
echo "✅ 모든 터미널이 생성되었습니다!"
echo ""

# 사용 가이드
echo "=========================================="
echo "🎯 사용 가이드"
echo "=========================================="
echo ""
echo "각 터미널에서 다음 명령만 실행하세요:"
echo ""
echo "  claude"
echo ""
echo "💡 팁:"
echo "• 모든 터미널에서 동일한 명령어 'claude'만 입력"
echo "• 각 터미널은 /mnt/c/Git/Routine_app 디렉토리에 위치"
echo "• Enter를 두 번 눌러서 명령 전달"
echo ""

# 터미널 역할
echo "터미널 역할 분배:"
echo "🧠 Claude4-Opus-Planner: 계획 및 아키텍처 설계"
echo "🔨 Claude4-Sonnet-Coder1: 주요 코드 구현"
echo "🔧 Claude4-Sonnet-Coder2: 테스트 및 디버깅"
echo "⚙️ Claude4-Sonnet-Coder3: 빌드 및 배포"
echo "📊 Claude4-Sonnet-Monitor: 모니터링 및 조정"
echo ""

# 프로젝트 안내
echo "=========================================="
echo "🔄 프로젝트 진행 방법"
echo "=========================================="
echo ""
echo "1. 각 터미널에서 'claude' 명령 실행"
echo "2. 플래너가 전체 계획 수립"
echo "3. 코더들이 역할별로 작업 수행"
echo "4. 모니터가 전체 조정 및 관리"
echo ""
echo "🎯 목표: SquashTrainingApp 완성된 버전 개발"
echo "🔄 사이클: 설치 → 실행 → 디버그 → 삭제 → 수정 (50회+)"
echo ""
echo "=========================================="
echo "🚀 이제 각 터미널에서 'claude'를 입력하세요!"
echo "=========================================="