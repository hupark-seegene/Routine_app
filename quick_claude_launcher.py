#!/usr/bin/env python3
"""
Claude Code에서 즉시 실행하는 간단한 다중 에이전트 런처
"""

import subprocess
import os
import time

def main():
    print("🚀 Claude Code 다중 에이전트 시스템 시작!")
    print("="*50)
    
    # 1. 현재 디렉토리 확인
    current_dir = os.getcwd()
    print(f"📁 현재 디렉토리: {current_dir}")
    
    # 2. 프로젝트 구조 확인
    print("\n📋 프로젝트 파일 확인:")
    files = os.listdir('.')
    for f in files[:10]:  # 처음 10개만 표시
        print(f"  - {f}")
    
    # 3. Git 상태 확인
    print("\n📊 Git 상태:")
    try:
        result = subprocess.run(['git', 'status', '--porcelain'], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            print("✅ Git 저장소 정상")
        else:
            print("⚠️  Git 저장소 문제")
    except:
        print("❌ Git 명령 실행 실패")
    
    # 4. 워크트리 생성
    print("\n🔧 워크트리 설정:")
    for i in range(1, 4):
        worker_path = f"/mnt/c/Git/claude-worker-{i}"
        branch_name = f"feature/claude-worker-{i}"
        
        # 브랜치 생성
        subprocess.run(['git', 'checkout', '-b', branch_name, 'main'], 
                      capture_output=True)
        subprocess.run(['git', 'checkout', 'main'], capture_output=True)
        
        # 워크트리 생성
        if not os.path.exists(worker_path):
            result = subprocess.run(['git', 'worktree', 'add', worker_path, branch_name],
                                  capture_output=True, text=True)
            if result.returncode == 0:
                print(f"  ✅ Worker {i} 생성: {worker_path}")
            else:
                print(f"  ⚠️  Worker {i} 생성 실패")
    
    # 5. 작업 할당
    print("\n🎯 작업 할당:")
    tasks = [
        "SquashTrainingApp 백엔드 API 최적화",
        "SquashTrainingApp UI/UX 개선", 
        "SquashTrainingApp 테스트 자동화"
    ]
    
    for i, task in enumerate(tasks, 1):
        print(f"  Worker {i}: {task}")
    
    # 6. 실행 지침
    print("\n📖 다음 단계:")
    print("1. 새 터미널에서 각 Worker 디렉토리로 이동")
    print("2. claude 명령으로 각 작업 시작")
    print("3. 다음 명령어 사용:")
    
    for i in range(1, 4):
        print(f"\n   Worker {i} 시작:")
        print(f"   cd /mnt/c/Git/claude-worker-{i}")
        print(f"   claude -p '{tasks[i-1]}를 수행해주세요'")
    
    print("\n✨ 설정 완료! 각 터미널에서 위 명령어를 실행하세요.")

if __name__ == "__main__":
    main()