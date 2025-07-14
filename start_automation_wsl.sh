#!/bin/bash
# WSL 환경에서 자동화 시스템 시작 스크립트
# Windows 배치 파일의 WSL 버전

echo "===================================="
echo "Multi-Agent Automation System (WSL)"
echo "===================================="
echo

# 1. 환경 확인
echo "[1/4] 환경 확인 중..."
if ! python3 -c "import sys; print('Python OK')" 2>/dev/null; then
    echo "[ERROR] Python3가 설치되지 않았거나 경로에 없습니다."
    echo "sudo apt update && sudo apt install -y python3 python3-pip를 실행하세요."
    exit 1
fi

# 2. 프로젝트 경로 확인
echo "[2/4] 프로젝트 경로 확인 중..."
if [ ! -f "PATHS.py" ]; then
    echo "[ERROR] PATHS.py를 찾을 수 없습니다."
    echo "올바른 프로젝트 디렉토리에서 실행하세요."
    exit 1
fi

# 환경 검증
python3 PATHS.py
if [ $? -ne 0 ]; then
    echo "[ERROR] 환경 검증 실패"
    exit 1
fi

# 3. 자동 실행 모드 선택
echo "[3/4] 자동 실행 모드..."
echo
echo "사용 가능한 자동화 옵션:"
echo "1. 간단한 자동화 테스트 (5 사이클)"
echo "2. 전체 50 사이클 자동화"
echo "3. 실시간 모니터링 대시보드"
echo "4. 통합 테스트 실행"
echo
echo "자동으로 간단한 테스트를 시작합니다... (3초 후)"
sleep 3

# 4. 자동화 시스템 시작
echo "[4/4] 자동화 시스템 시작 중..."
echo

echo "✓ 간단한 자동화 테스트 (5 사이클) 실행 중..."
python3 simple_automation.py --test

echo
echo "✓ 시스템이 성공적으로 완료되었습니다!"
echo

# 5. 추가 옵션 제공
echo "===================================="
echo "추가 실행 옵션:"
echo "===================================="
echo "전체 50 사이클:     python3 simple_automation.py --cycles 50"
echo "모니터링 대시보드:   python3 monitoring_dashboard.py"
echo "통합 테스트:        python3 integration_test.py"
echo "체크포인트 재시작:   python3 simple_automation.py --resume"
echo

# 6. 백그라운드 프로세스 확인
echo "현재 실행 중인 자동화 프로세스:"
ps aux | grep -E "(python3.*automation|python3.*monitor)" | grep -v grep || echo "현재 백그라운드 프로세스 없음"

echo
echo "===================================="
echo "자동화 시스템 준비 완료!"
echo "===================================="
echo "감사합니다!"