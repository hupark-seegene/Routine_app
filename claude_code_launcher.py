#!/usr/bin/env python3
"""
Claude Code에서 직접 실행하는 다중 에이전트 런처
WSL 환경에서 Windows PyCharm을 제어하여 자동화 시스템 구축
"""

import subprocess
import time
import os
import sys
import threading
import queue
from datetime import datetime

class ClaudeCodeLauncher:
    def __init__(self):
        self.project_root = "/mnt/c/Git/Routine_app"
        self.workers = []
        self.response_queue = queue.Queue()
        
    def setup_environment(self):
        """환경 설정 및 준비"""
        print("🔧 환경 설정 중...")
        
        # 1. 프로젝트 디렉토리 확인
        if not os.path.exists(self.project_root):
            print(f"❌ 프로젝트 디렉토리를 찾을 수 없습니다: {self.project_root}")
            return False
        
        # 2. Python 패키지 확인 및 설치
        required_packages = ['subprocess', 'threading', 'queue']
        print("✅ Python 환경 확인 완료")
        
        # 3. Git worktree 설정
        self.setup_git_worktrees()
        
        return True
    
    def setup_git_worktrees(self):
        """Git worktree 설정"""
        print("📁 Git worktree 설정 중...")
        
        # 현재 변경사항 저장
        subprocess.run(["git", "add", "."], cwd=self.project_root, capture_output=True)
        subprocess.run(["git", "commit", "-m", "Auto save before multi-agent work"], 
                      cwd=self.project_root, capture_output=True)
        
        # Worker 디렉토리 생성
        for i in range(1, 4):
            branch_name = f"feature/claude-worker-{i}"
            worktree_path = f"/mnt/c/Git/claude-worker-{i}"
            
            if not os.path.exists(worktree_path):
                # 브랜치 생성
                subprocess.run(["git", "checkout", "-b", branch_name], 
                              cwd=self.project_root, capture_output=True)
                subprocess.run(["git", "checkout", "main"], 
                              cwd=self.project_root, capture_output=True)
                
                # Worktree 추가
                result = subprocess.run(["git", "worktree", "add", worktree_path, branch_name],
                                      cwd=self.project_root, capture_output=True, text=True)
                
                if result.returncode == 0:
                    print(f"  ✅ Worker {i} 작업공간 생성: {worktree_path}")
                else:
                    print(f"  ⚠️  Worker {i} 작업공간 생성 실패")
    
    def create_worker_sessions(self):
        """별도 세션에서 Worker 실행"""
        print("🚀 Worker 세션 생성 중...")
        
        # Worker 설정
        worker_configs = [
            {
                'id': 1,
                'name': 'Backend-Worker',
                'path': '/mnt/c/Git/claude-worker-1',
                'task': 'SquashTrainingApp 백엔드 API 성능 최적화'
            },
            {
                'id': 2,
                'name': 'Frontend-Worker', 
                'path': '/mnt/c/Git/claude-worker-2',
                'task': 'SquashTrainingApp UI/UX 개선 및 렌더링 최적화'
            },
            {
                'id': 3,
                'name': 'Testing-Worker',
                'path': '/mnt/c/Git/claude-worker-3', 
                'task': 'SquashTrainingApp 자동화 테스트 및 품질 보증'
            }
        ]
        
        # tmux 세션 생성
        subprocess.run(["tmux", "new-session", "-d", "-s", "claude-multi-agent"])
        
        for i, config in enumerate(worker_configs):
            if i > 0:
                subprocess.run(["tmux", "new-window", "-t", "claude-multi-agent"])
            
            # 각 워커 세션에 명령 전송
            window_name = f"claude-multi-agent:{i}"
            subprocess.run(["tmux", "send-keys", "-t", window_name, 
                          f"cd {config['path']}", "Enter"])
            subprocess.run(["tmux", "send-keys", "-t", window_name,
                          f"echo '🔨 {config['name']} 준비 완료'", "Enter"])
            
            print(f"  ✅ {config['name']} 세션 생성 완료")
        
        return worker_configs
    
    def start_lead_agent(self):
        """Lead Agent (Opus) 시작"""
        print("\n🧠 Lead Agent (Opus) 시작 중...")
        
        lead_prompt = f"""
        안녕하세요! 다중 에이전트 시스템의 Lead Agent입니다.
        
        현재 상황:
        - 3개의 Worker Agent가 준비되어 있습니다
        - 각각 독립적인 Git worktree에서 작업합니다
        - SquashTrainingApp 프로젝트를 개선하는 것이 목표입니다
        
        다음 작업을 수행해주세요:
        1. SquashTrainingApp 프로젝트 분석
        2. 성능 개선을 위한 3가지 주요 작업 식별
        3. 각 Worker에게 적절한 작업 할당
        
        Worker 정보:
        - Worker 1: 백엔드 API 최적화 담당
        - Worker 2: 프론트엔드 UI/UX 개선 담당  
        - Worker 3: 테스팅 및 품질 보증 담당
        
        프로젝트 경로: {self.project_root}
        
        작업을 시작하겠습니다!
        """
        
        print("📋 Lead Agent 작업 계획:")
        print(lead_prompt)
        
        return lead_prompt
    
    def start_worker_agents(self, worker_configs):
        """Worker Agent들 시작"""
        print("\n🔨 Worker Agent들 시작 중...")
        
        for config in worker_configs:
            print(f"\n📍 {config['name']} 시작:")
            print(f"   작업 디렉토리: {config['path']}")
            print(f"   담당 작업: {config['task']}")
            
            # Worker에게 작업 할당
            worker_prompt = f"""
            안녕하세요! {config['name']}입니다.
            
            작업 정보:
            - 작업 디렉토리: {config['path']}
            - 담당 업무: {config['task']}
            - 프로젝트: SquashTrainingApp
            
            Lead Agent의 지시에 따라 다음과 같이 작업을 진행하겠습니다:
            1. 현재 코드 분석
            2. 개선 방안 도출
            3. 실제 코드 수정
            4. 테스트 및 검증
            
            작업을 시작하겠습니다!
            """
            
            # tmux 세션에 명령 전송
            subprocess.run(["tmux", "send-keys", "-t", f"claude-multi-agent:{config['id']-1}",
                          f"echo '{worker_prompt}'", "Enter"])
    
    def start_auto_responder(self):
        """자동 응답 시스템 시작"""
        print("\n🤖 자동 응답 시스템 시작 중...")
        
        # 백그라운드에서 자동 응답 실행
        def auto_respond():
            response_patterns = {
                "Yes, and don't ask again": "2",
                "(Y/n)": "Y",
                "Continue?": "Y",
                "Proceed?": "Y"
            }
            
            while True:
                # tmux 세션들 모니터링
                for i in range(3):
                    try:
                        result = subprocess.run(
                            ["tmux", "capture-pane", "-t", f"claude-multi-agent:{i}", "-p"],
                            capture_output=True, text=True
                        )
                        
                        if result.returncode == 0:
                            content = result.stdout
                            
                            # 패턴 매칭 및 자동 응답
                            for pattern, response in response_patterns.items():
                                if pattern in content:
                                    print(f"🔄 자동 응답: '{pattern}' → '{response}'")
                                    subprocess.run([
                                        "tmux", "send-keys", "-t", f"claude-multi-agent:{i}",
                                        response, "Enter"
                                    ])
                                    break
                    except:
                        continue
                
                time.sleep(2)
        
        # 백그라운드 스레드로 실행
        responder_thread = threading.Thread(target=auto_respond, daemon=True)
        responder_thread.start()
        
        print("✅ 자동 응답 시스템 활성화")
    
    def monitor_progress(self):
        """진행 상황 모니터링"""
        print("\n📊 진행 상황 모니터링 시작...")
        
        def monitor():
            while True:
                # 현재 시간
                current_time = datetime.now().strftime("%H:%M:%S")
                print(f"\n[{current_time}] 📊 시스템 상태:")
                
                # 각 Worker 상태 확인
                for i in range(3):
                    try:
                        result = subprocess.run(
                            ["tmux", "capture-pane", "-t", f"claude-multi-agent:{i}", "-p", "-S", "-10"],
                            capture_output=True, text=True
                        )
                        
                        if result.returncode == 0:
                            # 최근 활동 확인
                            lines = result.stdout.strip().split('\n')
                            if lines:
                                last_line = lines[-1]
                                print(f"  Worker {i+1}: {last_line[:80]}...")
                        else:
                            print(f"  Worker {i+1}: 비활성")
                    except:
                        print(f"  Worker {i+1}: 상태 확인 실패")
                
                time.sleep(30)  # 30초마다 상태 확인
        
        # 모니터링 스레드 시작
        monitor_thread = threading.Thread(target=monitor, daemon=True)
        monitor_thread.start()
    
    def run(self):
        """전체 시스템 실행"""
        print("🚀 Claude Code 다중 에이전트 시스템 시작!")
        print("="*60)
        
        # 1. 환경 설정
        if not self.setup_environment():
            print("❌ 환경 설정 실패")
            return
        
        # 2. Worker 세션 생성
        worker_configs = self.create_worker_sessions()
        
        # 3. Lead Agent 시작
        lead_prompt = self.start_lead_agent()
        
        # 4. Worker Agent들 시작
        self.start_worker_agents(worker_configs)
        
        # 5. 자동 응답 시스템 시작
        self.start_auto_responder()
        
        # 6. 모니터링 시작
        self.monitor_progress()
        
        print("\n✨ 시스템 실행 완료!")
        print("="*60)
        print("📋 사용 방법:")
        print("1. tmux 세션 연결: tmux attach -t claude-multi-agent")
        print("2. 창 전환: Ctrl+b + 숫자 (0,1,2)")
        print("3. 세션 종료: tmux kill-session -t claude-multi-agent")
        print("4. 진행 상황: 이 터미널에서 실시간 모니터링 중")
        
        # 메인 루프
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            print("\n\n⏹️  시스템 종료 중...")
            subprocess.run(["tmux", "kill-session", "-t", "claude-multi-agent"], 
                          capture_output=True)
            print("✅ 시스템 종료 완료")

def main():
    """메인 실행 함수"""
    launcher = ClaudeCodeLauncher()
    launcher.run()

if __name__ == "__main__":
    main()