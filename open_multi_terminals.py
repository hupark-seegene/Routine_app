#!/usr/bin/env python3
"""
다중 터미널 오픈 스크립트 - 실시간 모니터링
"""
import subprocess
import time
import os
import signal
import sys

def open_terminal_with_command(title, command):
    """새 터미널 창을 열고 명령어 실행"""
    try:
        # Windows Terminal 사용 (WSL 환경에서)
        wt_command = f'wt.exe -w 0 nt --title "{title}" wsl -e bash -c "{command}"'
        subprocess.Popen(wt_command, shell=True)
        return True
    except Exception as e:
        print(f"Windows Terminal 실행 실패: {e}")
        try:
            # 대안: gnome-terminal 사용
            gnome_command = f'gnome-terminal --title="{title}" -- bash -c "{command}"'
            subprocess.Popen(gnome_command, shell=True)
            return True
        except Exception as e2:
            print(f"gnome-terminal 실행 실패: {e2}")
            return False

def main():
    print("🚀 다중 터미널 Claude Code 에이전트 시스템 시작!")
    print("=" * 60)
    
    # 터미널 설정
    terminals = [
        {
            'title': 'Worker 1 - Backend API',
            'command': 'cd /mnt/c/Git/claude-worker-1 && tmux attach -t claude-multi-agent:worker1 || echo "Worker 1 세션 대기 중..."; exec bash'
        },
        {
            'title': 'Worker 2 - UI/UX',
            'command': 'cd /mnt/c/Git/claude-worker-2 && tmux attach -t claude-multi-agent:worker2 || echo "Worker 2 세션 대기 중..."; exec bash'
        },
        {
            'title': 'Worker 3 - Testing',
            'command': 'cd /mnt/c/Git/claude-worker-3 && tmux attach -t claude-multi-agent:worker3 || echo "Worker 3 세션 대기 중..."; exec bash'
        },
        {
            'title': 'Main Monitor',
            'command': 'cd /mnt/c/Git/Routine_app && python3 monitor_workers.py; exec bash'
        }
    ]
    
    print("🔄 터미널 창 열기 중...")
    
    for i, terminal in enumerate(terminals):
        print(f"   {i+1}. {terminal['title']} 터미널 열기...")
        success = open_terminal_with_command(terminal['title'], terminal['command'])
        if success:
            print(f"   ✅ {terminal['title']} 터미널 열림")
        else:
            print(f"   ❌ {terminal['title']} 터미널 열기 실패")
        time.sleep(1)  # 터미널 간 딜레이
    
    print("\n" + "=" * 60)
    print("🎯 터미널 열기 완료!")
    print("📋 열린 터미널들:")
    for i, terminal in enumerate(terminals):
        print(f"   {i+1}. {terminal['title']}")
    
    print("\n💡 사용 팁:")
    print("   - 각 터미널에서 독립적으로 작업 진행")
    print("   - Main Monitor에서 전체 진행 상황 확인")
    print("   - tmux 세션 간 전환: Ctrl+b + 1,2,3")
    
    print("\n🔧 수동 터미널 명령어:")
    print("   터미널 1: cd /mnt/c/Git/claude-worker-1 && tmux attach -t claude-multi-agent:worker1")
    print("   터미널 2: cd /mnt/c/Git/claude-worker-2 && tmux attach -t claude-multi-agent:worker2")
    print("   터미널 3: cd /mnt/c/Git/claude-worker-3 && tmux attach -t claude-multi-agent:worker3")
    print("   모니터링: python3 monitor_workers.py")

if __name__ == "__main__":
    main()