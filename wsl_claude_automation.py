#!/usr/bin/env python3
"""
WSL Claude Code Automation System
Multiple terminals with different Claude models for automated coding
"""

import subprocess
import time
import os
import json
import threading
import psutil
from typing import List, Dict, Optional
from datetime import datetime
import pyautogui
import win32gui
import win32con

class WSLClaudeAutomation:
    def __init__(self):
        self.project_root = r"C:\Git\Routine_app"
        self.squash_app_root = r"C:\Git\Routine_app\SquashTrainingApp"
        self.terminals = {}
        self.automation_log = []
        
        # Claude model configurations
        self.claude_configs = {
            'planner': {
                'model': 'claude-3-opus-20240229',
                'role': 'Planning and Architecture',
                'name': 'Claude4-Opus-Planner',
                'color': '🧠'
            },
            'coder1': {
                'model': 'claude-3-5-sonnet-20241022', 
                'role': 'Primary Coding',
                'name': 'Claude4-Sonnet-Coder1',
                'color': '🔨'
            },
            'coder2': {
                'model': 'claude-3-5-sonnet-20241022',
                'role': 'Testing and Debugging', 
                'name': 'Claude4-Sonnet-Coder2',
                'color': '🔧'
            },
            'coder3': {
                'model': 'claude-3-5-sonnet-20241022',
                'role': 'Build and Deployment',
                'name': 'Claude4-Sonnet-Coder3',
                'color': '⚙️'
            },
            'monitor': {
                'model': 'claude-3-5-sonnet-20241022',
                'role': 'Monitoring and Coordination',
                'name': 'Claude4-Sonnet-Monitor',
                'color': '📊'
            }
        }
        
        # Safety settings
        pyautogui.FAILSAFE = True
        pyautogui.PAUSE = 0.3
        
    def log_action(self, action: str, details: str = ""):
        """액션 로깅"""
        log_entry = {
            'timestamp': datetime.now().isoformat(),
            'action': action,
            'details': details
        }
        self.automation_log.append(log_entry)
        print(f"[{datetime.now().strftime('%H:%M:%S')}] {action}: {details}")
        
    def find_windows_terminal(self) -> bool:
        """Windows Terminal 찾기"""
        def enum_windows_callback(hwnd, windows):
            if win32gui.IsWindowVisible(hwnd):
                window_title = win32gui.GetWindowText(hwnd)
                if "Windows Terminal" in window_title or "wt" in window_title:
                    windows.append((hwnd, window_title))
        
        windows = []
        win32gui.EnumWindows(enum_windows_callback, windows)
        
        if windows:
            hwnd, title = windows[0]
            self.log_action("Windows Terminal Found", title)
            win32gui.ShowWindow(hwnd, win32con.SW_MAXIMIZE)
            win32gui.SetForegroundWindow(hwnd)
            return True
        return False
    
    def open_wsl_terminal(self, name: str, wsl_distro: str = "Ubuntu") -> bool:
        """새 WSL 터미널 탭 열기"""
        try:
            # Windows Terminal에서 새 WSL 탭 열기
            command = f'wt new-tab --profile "{wsl_distro}" --title "{name}"'
            
            # 또는 직접 wsl 명령으로
            # command = f'wt new-tab wsl -d {wsl_distro}'
            
            subprocess.Popen(command, shell=True)
            time.sleep(2)
            
            self.log_action("WSL Terminal Opened", f"Name: {name}, Distro: {wsl_distro}")
            return True
            
        except Exception as e:
            self.log_action("WSL Terminal Error", str(e))
            return False
    
    def start_claude_in_terminal(self, terminal_name: str, model_config: Dict) -> bool:
        """터미널에서 Claude Code 시작"""
        try:
            # 터미널로 전환
            self.focus_terminal_by_name(terminal_name)
            time.sleep(1)
            
            # 프로젝트 디렉토리로 이동
            self.type_command("cd /mnt/c/Git/Routine_app/SquashTrainingApp")
            time.sleep(1)
            
            # Claude Code 시작
            claude_command = f"claude --model {model_config['model']}"
            self.type_command(claude_command)
            time.sleep(3)
            
            # 초기 설정 메시지 전송
            setup_message = f"""
Hello! I'm {model_config['name']} - {model_config['role']}.
I'm ready to work on the SquashTrainingApp project.

Current working directory: /mnt/c/Git/Routine_app/SquashTrainingApp
Role: {model_config['role']}
Model: {model_config['model']}

Please provide tasks related to my role.
"""
            
            self.type_command(setup_message)
            
            self.log_action("Claude Started", f"{terminal_name} - {model_config['name']}")
            return True
            
        except Exception as e:
            self.log_action("Claude Start Error", f"{terminal_name}: {str(e)}")
            return False
    
    def type_command(self, command: str, press_enter: bool = True):
        """터미널에 명령 입력"""
        pyautogui.typewrite(command, interval=0.01)
        if press_enter:
            pyautogui.press('enter')
        time.sleep(0.5)
    
    def focus_terminal_by_name(self, name: str) -> bool:
        """이름으로 터미널 탭 포커스"""
        try:
            # Ctrl+Shift+P로 명령 팔레트 열기
            pyautogui.hotkey('ctrl', 'shift', 'p')
            time.sleep(0.5)
            
            # 탭 이름으로 검색
            pyautogui.typewrite(name)
            time.sleep(0.5)
            pyautogui.press('enter')
            time.sleep(0.5)
            
            return True
        except Exception as e:
            self.log_action("Terminal Focus Error", f"{name}: {str(e)}")
            return False
    
    def setup_automation_terminals(self) -> bool:
        """모든 자동화 터미널 설정"""
        self.log_action("Automation Setup Started", "Setting up all terminals")
        
        # Windows Terminal 찾기 또는 시작
        if not self.find_windows_terminal():
            self.log_action("Starting Windows Terminal", "")
            subprocess.Popen("wt", shell=True)
            time.sleep(3)
            
            if not self.find_windows_terminal():
                self.log_action("Windows Terminal Error", "Could not start Windows Terminal")
                return False
        
        # 각 Claude 터미널 설정
        for role, config in self.claude_configs.items():
            terminal_name = f"{config['color']}{config['name']}"
            
            # 새 WSL 터미널 열기
            if self.open_wsl_terminal(terminal_name):
                time.sleep(2)
                
                # Claude Code 시작
                if self.start_claude_in_terminal(terminal_name, config):
                    self.terminals[role] = {
                        'name': terminal_name,
                        'config': config,
                        'status': 'running',
                        'created_at': datetime.now()
                    }
                    time.sleep(1)
                else:
                    self.log_action("Claude Setup Failed", terminal_name)
            else:
                self.log_action("Terminal Setup Failed", terminal_name)
        
        self.log_action("Automation Setup Complete", f"Terminals created: {len(self.terminals)}")
        return len(self.terminals) > 0
    
    def send_task_to_planner(self, task: str) -> bool:
        """플래너에게 작업 전송"""
        if 'planner' not in self.terminals:
            self.log_action("Planner Not Found", "")
            return False
        
        try:
            # 플래너 터미널로 전환
            planner_name = self.terminals['planner']['name']
            self.focus_terminal_by_name(planner_name)
            time.sleep(1)
            
            # 작업 전송
            planning_prompt = f"""
🧠 PLANNING TASK:
{task}

Please analyze this task and create a detailed plan with:
1. High-level architecture decisions
2. Step-by-step implementation plan
3. Task distribution for coding agents
4. Testing strategy
5. Risk assessment

Format your response as a structured plan that can be distributed to coding agents.
"""
            
            self.type_command(planning_prompt)
            self.log_action("Task Sent to Planner", task[:50] + "...")
            return True
            
        except Exception as e:
            self.log_action("Planner Task Error", str(e))
            return False
    
    def distribute_coding_tasks(self, plan_response: str) -> bool:
        """코딩 작업을 각 코더에게 분배"""
        try:
            # 코딩 작업 분배
            coding_roles = ['coder1', 'coder2', 'coder3']
            
            for i, role in enumerate(coding_roles):
                if role not in self.terminals:
                    continue
                
                # 코더 터미널로 전환
                coder_name = self.terminals[role]['name']
                self.focus_terminal_by_name(coder_name)
                time.sleep(1)
                
                # 역할별 작업 할당
                role_tasks = {
                    'coder1': "Primary implementation and core features",
                    'coder2': "Testing, debugging, and validation",
                    'coder3': "Build configuration and deployment"
                }
                
                coding_prompt = f"""
🔨 CODING TASK - {role_tasks[role]}:

Based on this plan:
{plan_response}

Your specific responsibilities:
{role_tasks[role]}

Please implement your assigned parts and coordinate with other agents.
Use the project structure in /mnt/c/Git/Routine_app/SquashTrainingApp
"""
                
                self.type_command(coding_prompt)
                self.log_action("Task Distributed", f"{role} - {role_tasks[role]}")
                time.sleep(2)
            
            return True
            
        except Exception as e:
            self.log_action("Task Distribution Error", str(e))
            return False
    
    def monitor_progress(self) -> None:
        """진행 상황 모니터링"""
        if 'monitor' not in self.terminals:
            self.log_action("Monitor Not Found", "")
            return
        
        try:
            # 모니터 터미널로 전환
            monitor_name = self.terminals['monitor']['name']
            self.focus_terminal_by_name(monitor_name)
            time.sleep(1)
            
            # 모니터링 요청
            monitor_prompt = f"""
📊 MONITORING TASK:

Please monitor the progress of all coding agents and:
1. Check the current status of the SquashTrainingApp project
2. Identify any issues or blockers
3. Coordinate between different agents
4. Provide regular status updates
5. Suggest optimizations

Current terminals active: {list(self.terminals.keys())}
Project location: /mnt/c/Git/Routine_app/SquashTrainingApp
"""
            
            self.type_command(monitor_prompt)
            self.log_action("Monitoring Started", "")
            
        except Exception as e:
            self.log_action("Monitor Error", str(e))
    
    def execute_automation_cycle(self, main_task: str) -> bool:
        """전체 자동화 사이클 실행"""
        self.log_action("Automation Cycle Started", main_task)
        
        # 1. 플래너에게 작업 전송
        if not self.send_task_to_planner(main_task):
            return False
        
        # 플래너 응답 대기 (실제로는 더 정교한 응답 감지 필요)
        self.log_action("Waiting for Planner", "30 seconds")
        time.sleep(30)
        
        # 2. 계획을 코더들에게 분배 (실제로는 플래너 응답을 파싱해야 함)
        plan_response = "Detailed implementation plan from planner..."
        if not self.distribute_coding_tasks(plan_response):
            return False
        
        # 3. 모니터링 시작
        self.monitor_progress()
        
        self.log_action("Automation Cycle Complete", "")
        return True
    
    def run_automation_system(self):
        """전체 자동화 시스템 실행"""
        print("🚀 WSL Claude Code Automation System Starting...\n")
        
        # 1. 터미널 설정
        if not self.setup_automation_terminals():
            print("❌ Failed to setup terminals")
            return
        
        print(f"\n✅ {len(self.terminals)} terminals ready!")
        print("Available terminals:")
        for role, info in self.terminals.items():
            config = info['config']
            print(f"  {config['color']} {config['name']} - {config['role']}")
        
        # 2. 메인 작업 실행
        main_task = """
완성된 SquashTrainingApp을 생성하여 구동하는 것이 목표입니다.
Emulator에서 (설치 → 실행 → 모든 기능 디버그 → 앱 삭제 → 수정) 사이클을 
fail/issue가 없을 때까지 계속 반복(50회 이상) 수행해야 합니다.

주요 요구사항:
1. React Native 앱 완전 동작
2. 모든 컴포넌트 정상 작동
3. Android 빌드 성공
4. Emulator 테스트 통과
5. 지속적인 개선 사이클
"""
        
        if self.execute_automation_cycle(main_task):
            print("\n🎯 Automation cycle initiated successfully!")
            print("Monitor the terminals for progress...")
            
            # 시스템 계속 실행
            try:
                while True:
                    time.sleep(60)  # 1분마다 체크
                    self.log_action("System Running", f"Active terminals: {len(self.terminals)}")
            except KeyboardInterrupt:
                print("\n\n⏹️ Automation system stopped")
        else:
            print("\n❌ Automation cycle failed")

def main():
    """메인 실행 함수"""
    print("WSL Claude Code Automation System")
    print("=" * 50)
    
    # 의존성 확인
    try:
        import pyautogui
        import win32gui
        import win32con
    except ImportError:
        print("❌ Required packages not installed")
        print("Run: pip install pyautogui pywin32 psutil")
        return
    
    # 자동화 시스템 실행
    automation = WSLClaudeAutomation()
    automation.run_automation_system()

if __name__ == "__main__":
    main()