#!/usr/bin/env python3
"""
실시간 Worker 모니터링 스크립트
"""
import subprocess
import time
import os
from datetime import datetime

def monitor_workers():
    """Worker들의 진행 상황을 실시간으로 모니터링"""
    print("🔍 Claude Code 다중 에이전트 모니터링 시작")
    print("=" * 60)
    
    workers = [
        {'name': 'Worker 1 - Backend API', 'window': 'worker1', 'path': '/mnt/c/Git/Routine_app/SquashTrainingApp'},
        {'name': 'Worker 2 - UI/UX', 'window': 'worker2', 'path': '/mnt/c/Git/Routine_app/SquashTrainingApp'},
        {'name': 'Worker 3 - Testing', 'window': 'worker3', 'path': '/mnt/c/Git/Routine_app/SquashTrainingApp'}
    ]
    
    try:
        while True:
            os.system('clear')
            print(f"🕐 {datetime.now().strftime('%H:%M:%S')} - Claude Code 다중 에이전트 상태")
            print("=" * 60)
            
            for i, worker in enumerate(workers):
                print(f"\n📋 {worker['name']}:")
                print(f"   📁 경로: {worker['path']}")
                
                # tmux 세션에서 최근 활동 확인
                try:
                    result = subprocess.run([
                        'tmux', 'capture-pane', '-t', f"claude-multi-agent:{worker['window']}", 
                        '-p', '-S', '-10'
                    ], capture_output=True, text=True)
                    
                    if result.returncode == 0:
                        lines = result.stdout.strip().split('\n')
                        recent_lines = [line for line in lines[-5:] if line.strip()]
                        
                        if recent_lines:
                            print("   📝 최근 활동:")
                            for line in recent_lines:
                                print(f"      {line[:70]}...")
                        else:
                            print("   ⏳ 대기 중...")
                    else:
                        print("   ❌ 세션 연결 실패")
                        
                except Exception as e:
                    print(f"   ⚠️  모니터링 오류: {e}")
                
                # Git 상태 확인
                try:
                    git_result = subprocess.run([
                        'git', 'status', '--porcelain'
                    ], cwd=worker['path'], capture_output=True, text=True)
                    
                    if git_result.returncode == 0:
                        changes = git_result.stdout.strip().split('\n')
                        modified_files = [f for f in changes if f.strip()]
                        print(f"   📊 변경된 파일: {len(modified_files)}개")
                    else:
                        print("   📊 Git 상태 확인 실패")
                        
                except Exception as e:
                    print(f"   📊 Git 상태 오류: {e}")
            
            print("\n" + "=" * 60)
            print("🎯 제어 명령어:")
            print("   tmux attach -t claude-multi-agent  # 세션 접속")
            print("   Ctrl+b + 1,2,3                     # 창 전환")
            print("   Ctrl+C                             # 모니터링 종료")
            print("=" * 60)
            
            time.sleep(10)  # 10초마다 업데이트
            
    except KeyboardInterrupt:
        print("\n\n⏹️  모니터링 종료")
        print("💡 Worker들은 백그라운드에서 계속 실행됩니다.")
        print("   세션 접속: tmux attach -t claude-multi-agent")

if __name__ == "__main__":
    monitor_workers()