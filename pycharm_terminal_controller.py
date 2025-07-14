#!/usr/bin/env python3
"""
PyCharm Terminal Controller
PyCharm의 여러 터미널을 자동으로 제어하고 관리
"""

import subprocess
import time
import os
import json
from typing import List, Dict
import pyautogui
import psutil
import threading
import queue
from datetime import datetime

class PyCharmTerminalController:
    def __init__(self):
        self.project_root = r"C:\Git\Routine_app"
        self.squash_app_root = r"C:\Git\Routine_app\SquashTrainingApp"
        self.terminals = {}
        self.pycharm_process = None
        self.response_queue = queue.Queue()
        
        # 자동 응답 패턴
        self.response_patterns = {
            "Yes, and don't ask again": "2",
            "1. Yes  2. Yes, and don't ask again": "2",
            "(Y/n)": "Y",
            "Do you want to proceed": "Y",
            "Continue?": "yes",
            "Press Enter to continue": "",
            "Are you sure": "Y"
        }
        
    def find_pycharm_window(self):
        """PyCharm 창 찾기"""
        import win32gui
        import win32con
        
        def enum_windows_callback(hwnd, windows):
            if win32gui.IsWindowVisible(hwnd):
                window_title = win32gui.GetWindowText(hwnd)
                if "Routine_app" in window_title and "PyCharm" in window_title:
                    windows.append((hwnd, window_title))
        
        windows = []
        win32gui.EnumWindows(enum_windows_callback, windows)
        
        if windows:
            hwnd, title = windows[0]
            print(f"✅ PyCharm 창 발견: {title}")
            # 창을 전면으로
            win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
            win32gui.SetForegroundWindow(hwnd)
            return True
        return False

    def open_terminal_tab(self, name: str, wait_time: float = 1.0):
        """새 터미널 탭 열기"""
        print(f"📟 새 터미널 탭 생성: {name}")
        
        # Alt+F12로 터미널 열기
        pyautogui.hotkey('alt', 'f12')
        time.sleep(wait_time)
        
        # 새 탭 생성 (터미널이 이미 열려있다면)
        if len(self.terminals) > 0:
            pyautogui.hotkey('shift', 'alt', 't')
            time.sleep(wait_time)

    def rename_terminal_tab(self, name: str):
        """터미널 탭 이름 변경"""
        # 탭에서 우클릭
        pyautogui.rightClick()
        time.sleep(0.5)
        
        # 'Rename' 선택 (R 키)
        pyautogui.press('r')
        time.sleep(0.5)
        
        # 기존 이름 선택 및 삭제
        pyautogui.hotkey('ctrl', 'a')
        time.sleep(0.2)
        
        # 새 이름 입력
        pyautogui.typewrite(name)
        pyautogui.press('enter')
        time.sleep(0.5)

    def execute_command(self, command: str, auto_enter: bool = True):
        """터미널에 명령 실행"""
        pyautogui.typewrite(command)
        if auto_enter:
            pyautogui.press('enter')
        time.sleep(0.5)

    def setup_terminals(self, terminal_configs: List[Dict]):
        """여러 터미널 설정 및 명령 실행"""
        
        print("🖥️ PyCharm 터미널 자동 설정 시작...")
        
        # PyCharm 창 찾기
        if not self.find_pycharm_window():
            print("❌ PyCharm을 찾을 수 없습니다. Routine_app 프로젝트를 열어주세요.")
            return False
        
        time.sleep(1)
        
        # 각 터미널 설정
        for i, config in enumerate(terminal_configs):
            print(f"\n설정 중: {config['name']}")
            
            # 터미널 탭 열기
            self.open_terminal_tab(config['name'], wait_time=1.5 if i == 0 else 1.0)
            
            # 이름 변경 (선택사항)
            if config.get('rename', True):
                self.rename_terminal_tab(config['name'])
            
            # 초기 명령 실행
            if 'commands' in config:
                for cmd in config['commands']:
                    self.execute_command(cmd)
                    time.sleep(config.get('command_delay', 1.0))
            
            # 터미널 정보 저장
            self.terminals[config['name']] = {
                'index': i,
                'config': config,
                'status': 'running',
                'created_at': datetime.now()
            }
        
        print("\n✅ 모든 터미널 설정 완료!")
        return True

    def switch_to_terminal_by_index(self, index: int):
        """인덱스로 터미널 전환"""
        if index == 0:
            # 첫 번째 터미널
            pyautogui.hotkey('alt', 'f12')
        else:
            # Alt+숫자로 전환 (최대 9개)
            if index < 9:
                pyautogui.hotkey('alt', str(index + 1))
        time.sleep(0.3)

    def monitor_terminals(self):
        """터미널 모니터링 및 자동 응답"""
        print("\n🤖 자동 모니터링 시작...")
        
        monitor_thread = threading.Thread(target=self._monitor_loop, daemon=True)
        monitor_thread.start()

    def _monitor_loop(self):
        """모니터링 루프"""
        while True:
            try:
                # 각 터미널 순회
                for name, info in self.terminals.items():
                    if info['status'] == 'running':
                        # 터미널로 전환
                        self.switch_to_terminal_by_index(info['index'])
                        
                        # 화면 캡처 (간단한 방식)
                        # 실제로는 OCR이나 더 정교한 방법 필요
                        
                        # 프롬프트 감지 시뮬레이션
                        # 실제 구현시 pytesseract 등 사용
                        
                        time.sleep(0.5)
                
                time.sleep(3)  # 3초마다 확인
                
            except Exception as e:
                print(f"모니터링 오류: {e}")
                time.sleep(5)

class MultiAgentOrchestrator:
    """다중 에이전트 오케스트레이터 - PyCharm 통합"""
    
    def __init__(self):
        self.terminal_controller = PyCharmTerminalController()
        self.project_root = r"C:\Git\Routine_app"
        self.squash_app_root = r"C:\Git\Routine_app\SquashTrainingApp"
        
    def prepare_environment(self):
        """환경 준비"""
        print("🔧 환경 준비 중...")
        
        # 1. Git worktree 설정
        self.setup_worktrees()
        
        # 2. 필요한 디렉토리 생성
        os.makedirs(os.path.join(self.project_root, "logs"), exist_ok=True)
        os.makedirs(os.path.join(self.project_root, ".cache"), exist_ok=True)
        
        print("✅ 환경 준비 완료")
    
    def setup_worktrees(self):
        """Git worktree 설정"""
        print("\n📁 Git worktree 설정...")
        
        # 현재 변경사항 저장
        subprocess.run(["git", "add", "."], cwd=self.project_root, capture_output=True)
        subprocess.run(["git", "commit", "-m", "Save current state"], cwd=self.project_root, capture_output=True)
        
        for i in range(1, 4):
            branch_name = f"feature/worker-{i}"
            worktree_path = os.path.join(os.path.dirname(self.project_root), f"worker-{i}")
            
            if not os.path.exists(worktree_path):
                # 브랜치 생성
                subprocess.run(["git", "branch", branch_name], cwd=self.project_root, capture_output=True)
                
                # Worktree 추가
                result = subprocess.run(
                    ["git", "worktree", "add", worktree_path, branch_name],
                    cwd=self.project_root,
                    capture_output=True,
                    text=True
                )
                
                if result.returncode == 0:
                    print(f"  ✅ Worktree 생성: worker-{i}")
                else:
                    print(f"  ⚠️ Worktree 생성 실패: {result.stderr}")

    def get_terminal_configs(self):
        """터미널 구성 정의"""
        return [
            {
                'name': 'Orchestrator',
                'rename': True,
                'commands': [
                    'echo "🎯 Orchestrator Terminal Ready"',
                    'python orchestrator.py'
                ],
                'command_delay': 1.0
            },
            {
                'name': 'Lead-Opus4',
                'rename': True,
                'commands': [
                    'echo "🧠 Lead Agent (Opus 4) Ready"',
                    'cd C:\\Git\\Routine_app\\SquashTrainingApp',
                    # 'claude --model opus'  # 실제 실행시 주석 해제
                ],
                'command_delay': 1.0
            },
            {
                'name': 'Worker1-Sonnet',
                'rename': True,
                'commands': [
                    'echo "🔨 Worker 1 (Sonnet 4) Ready"',
                    'cd C:\\Git\\Routine_app\\SquashTrainingApp',
                    # 'claude --model sonnet'  # 실제 실행시 주석 해제
                ],
                'command_delay': 1.0
            },
            {
                'name': 'Worker2-Sonnet',
                'rename': True,
                'commands': [
                    'echo "🔧 Worker 2 (Sonnet 4) Ready"',
                    'cd C:\\Git\\Routine_app\\SquashTrainingApp',
                    # 'claude --model sonnet'  # 실제 실행시 주석 해제
                ],
                'command_delay': 1.0
            },
            {
                'name': 'Worker3-Sonnet',
                'rename': True,
                'commands': [
                    'echo "⚙️ Worker 3 (Sonnet 4) Ready"',
                    'cd C:\\Git\\Routine_app\\SquashTrainingApp',
                    # 'claude --model sonnet'  # 실제 실행시 주석 해제
                ],
                'command_delay': 1.0
            },
            {
                'name': 'AutoResponder',
                'rename': True,
                'commands': [
                    'echo "🤖 Auto Responder Ready"',
                    'cd C:\\Git\\Routine_app',
                    'python auto_responder.py monitor'
                ],
                'command_delay': 1.0
            },
            {
                'name': 'TmuxMonitor',
                'rename': True,
                'commands': [
                    'echo "📊 Tmux Monitor Ready"',
                    'wsl -d Ubuntu',
                    'cd /mnt/c/Git/Routine_app/SquashTrainingApp/scripts/production/tmux-automation',
                    'tmux attach -t squash-automation || ./TMUX-SETUP.sh --attach'
                ],
                'command_delay': 2.0
            }
        ]

    def run(self):
        """전체 시스템 실행"""
        print("🚀 PyCharm 다중 에이전트 시스템 시작\n")
        
        # 1. 환경 준비
        self.prepare_environment()
        
        # 2. 터미널 설정
        configs = self.get_terminal_configs()
        if self.terminal_controller.setup_terminals(configs):
            # 3. 모니터링 시작
            self.terminal_controller.monitor_terminals()
            
            print("\n✨ 시스템이 실행 중입니다.")
            print("종료하려면 Ctrl+C를 누르세요.\n")
            
            try:
                # 계속 실행
                while True:
                    time.sleep(1)
            except KeyboardInterrupt:
                print("\n\n⏹️ 시스템 종료")
        else:
            print("\n❌ 터미널 설정 실패")

def main():
    # PyCharm이 실행 중인지 확인
    pycharm_running = False
    for proc in psutil.process_iter(['name']):
        if 'pycharm' in proc.info['name'].lower():
            pycharm_running = True
            break
    
    if not pycharm_running:
        print("⚠️ PyCharm이 실행되지 않았습니다.")
        print("PyCharm에서 Routine_app 프로젝트를 열고 다시 실행하세요.")
        return
    
    # 의존성 확인
    try:
        import pyautogui
        import win32gui
    except ImportError:
        print("⚠️ 필요한 패키지가 설치되지 않았습니다.")
        print("다음 명령을 실행하세요:")
        print("pip install pyautogui pywin32 psutil")
        return
    
    # 안전 설정
    pyautogui.FAILSAFE = True
    pyautogui.PAUSE = 0.5
    
    # 오케스트레이터 실행
    orchestrator = MultiAgentOrchestrator()
    orchestrator.run()

if __name__ == "__main__":
    main()