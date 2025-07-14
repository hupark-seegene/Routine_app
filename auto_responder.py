#!/usr/bin/env python3
"""
Windows Auto Responder for Claude Code
Claude Code 인스턴스의 프롬프트를 모니터링하고 자동으로 응답
"""

import subprocess
import time
import sys
import os
import psutil
from typing import Optional

try:
    import pyautogui
    import pygetwindow as gw
except ImportError:
    print("필요한 패키지를 설치하세요: pip install pyautogui pygetwindow")
    sys.exit(1)

class WindowsAutoResponder:
    def __init__(self):
        self.project_root = r"C:\Git\Routine_app"
        self.response_mappings = {
            "Yes, and don't ask again": "2",
            "1. Yes  2. Yes, and don't ask again": "2",
            "(Y/n)": "Y",
            "(y/N)": "Y",
            "Continue?": "Y",
            "Proceed?": "Y",
            "Are you sure": "Y",
            "Do you want to": "Y"
        }
        
    def find_claude_windows(self) -> list:
        """Claude Code 관련 윈도우 찾기"""
        windows = []
        try:
            all_windows = gw.getAllTitles()
            for title in all_windows:
                if any(keyword in title.lower() for keyword in ['claude', 'terminal', 'powershell', 'cmd']):
                    windows.append(title)
        except Exception as e:
            print(f"윈도우 검색 오류: {e}")
        return windows
    
    def monitor_tmux_session(self, session_name: str = "squash-automation"):
        """Tmux 세션 모니터링 (WSL 환경)"""
        print(f"🤖 Tmux 세션 '{session_name}' 모니터링 시작...")
        
        while True:
            try:
                # Tmux pane의 내용 캡처
                capture_cmd = f"tmux capture-pane -t {session_name} -p"
                result = subprocess.run(
                    ["wsl", "bash", "-c", capture_cmd],
                    capture_output=True,
                    text=True
                )
                
                if result.returncode == 0:
                    content = result.stdout
                    
                    # 프롬프트 패턴 확인
                    if "1. Yes  2. Yes, and don't ask again" in content:
                        print("✅ 번호 선택 프롬프트 감지 - '2' 전송")
                        send_cmd = f"tmux send-keys -t {session_name} '2' Enter"
                        subprocess.run(["wsl", "bash", "-c", send_cmd])
                        time.sleep(1)
                        
                    elif "(Y/n)" in content or "(y/N)" in content:
                        print("✅ Y/n 프롬프트 감지 - 'Y' 전송")
                        send_cmd = f"tmux send-keys -t {session_name} 'Y' Enter"
                        subprocess.run(["wsl", "bash", "-c", send_cmd])
                        time.sleep(1)
                        
                    elif "rate limit" in content.lower():
                        print("⏸️ Rate limit 감지 - 대기 중...")
                        time.sleep(60)  # 1분 대기
                
            except Exception as e:
                print(f"모니터링 오류: {e}")
                
            time.sleep(2)  # 2초마다 확인
    
    def monitor_worker(self, worker_id: int = 1):
        """특정 워커 모니터링"""
        worker_path = os.path.join(os.path.dirname(self.project_root), f"worker-{worker_id}")
        
        print(f"🤖 Worker {worker_id} 자동 응답 시스템 시작...")
        print(f"   경로: {worker_path}")
        
        # PowerShell 스크립트로 자동 응답
        ps_script = f"""
        $WorkerPath = "{worker_path}"
        $LogFile = "$WorkerPath\\auto_responder.log"
        
        Write-Host "Starting auto responder for Worker {worker_id}..."
        
        while ($true) {{
            Start-Sleep -Seconds 2
            
            # 활성 프로세스 확인
            $claudeProcesses = Get-Process | Where-Object {{ $_.ProcessName -like "*claude*" }}
            
            if ($claudeProcesses) {{
                Add-Content -Path $LogFile -Value "$(Get-Date): Claude processes found"
                
                # 여기에 구체적인 윈도우 자동화 로직 추가
                # 예: Send-Keys, UI Automation 등
            }}
            
            Write-Host "." -NoNewline
        }}
        """
        
        # PowerShell 실행
        try:
            subprocess.run(["powershell", "-Command", ps_script], cwd=worker_path)
        except KeyboardInterrupt:
            print("\n자동 응답 시스템 종료")
    
    def monitor_all_terminals(self):
        """모든 터미널을 동시에 모니터링"""
        print("🤖 전체 터미널 모니터링 시작...")
        print("모니터링 중인 패턴:")
        for pattern, response in self.response_mappings.items():
            print(f"  - '{pattern}' → '{response}'")
        print("\n모니터링 중... (Ctrl+C로 중지)\n")
        
        while True:
            try:
                # Tmux 세션 확인
                tmux_result = subprocess.run(
                    ["wsl", "bash", "-c", "tmux list-sessions 2>/dev/null"],
                    capture_output=True,
                    text=True
                )
                
                if "squash-automation" in tmux_result.stdout:
                    # Tmux 세션의 모든 pane 확인
                    panes_cmd = "tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}'"
                    panes_result = subprocess.run(
                        ["wsl", "bash", "-c", panes_cmd],
                        capture_output=True,
                        text=True
                    )
                    
                    for pane in panes_result.stdout.strip().split('\n'):
                        if pane.startswith("squash-automation"):
                            self.check_and_respond_tmux_pane(pane)
                
                # Windows 터미널 프로세스 확인
                self.check_windows_terminals()
                
                time.sleep(1)  # 1초마다 확인
                
            except KeyboardInterrupt:
                print("\n\n✅ 모니터링 종료")
                break
            except Exception as e:
                print(f"모니터링 오류: {e}")
                time.sleep(5)
    
    def check_and_respond_tmux_pane(self, pane_id: str):
        """특정 tmux pane 확인 및 응답"""
        capture_cmd = f"tmux capture-pane -t {pane_id} -p -S -10"
        result = subprocess.run(
            ["wsl", "bash", "-c", capture_cmd],
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            content = result.stdout
            
            # 각 패턴 확인
            for pattern, response in self.response_mappings.items():
                if pattern in content:
                    print(f"✅ [{pane_id}] 프롬프트 감지: '{pattern}' → '{response}' 전송")
                    send_cmd = f"tmux send-keys -t {pane_id} '{response}' Enter"
                    subprocess.run(["wsl", "bash", "-c", send_cmd])
                    time.sleep(0.5)
                    break

    def check_windows_terminals(self):
        """Windows 터미널 확인 (Claude Code 프로세스)"""
        try:
            # Claude 관련 프로세스 찾기
            for proc in psutil.process_iter(['name', 'cmdline']):
                if 'claude' in str(proc.info['cmdline']).lower():
                    # 프로세스 발견 시 로그
                    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
                    print(f"[{timestamp}] Claude 프로세스 활성: PID {proc.pid}")
        except Exception as e:
            pass
    
    def create_monitoring_script(self):
        """모니터링 배치 스크립트 생성"""
        script_content = """@echo off
echo === Claude Code Auto Responder ===
echo.

:MENU
echo 1. Monitor Tmux Session (WSL)
echo 2. Monitor Worker 1
echo 3. Monitor Worker 2
echo 4. Monitor Worker 3
echo 5. Monitor All Terminals
echo 6. Exit
echo.
set /p choice=Select option: 

if %choice%==1 python "%~dp0auto_responder.py" tmux
if %choice%==2 python "%~dp0auto_responder.py" worker 1
if %choice%==3 python "%~dp0auto_responder.py" worker 2
if %choice%==4 python "%~dp0auto_responder.py" worker 3
if %choice%==5 python "%~dp0auto_responder.py" monitor
if %choice%==6 exit

goto MENU
"""
        
        script_path = os.path.join(self.project_root, "start_auto_responder.bat")
        with open(script_path, "w") as f:
            f.write(script_content)
        
        print(f"✅ 모니터링 스크립트 생성: {script_path}")

def main():
    responder = WindowsAutoResponder()
    
    if len(sys.argv) < 2:
        print("사용법:")
        print("  python auto_responder.py tmux           # Tmux 세션 모니터링")
        print("  python auto_responder.py worker [id]    # 특정 워커 모니터링")
        print("  python auto_responder.py monitor        # 모든 터미널 모니터링")
        print("")
        responder.create_monitoring_script()
        return
    
    mode = sys.argv[1]
    
    if mode == "tmux":
        responder.monitor_tmux_session()
    elif mode == "worker":
        worker_id = int(sys.argv[2]) if len(sys.argv) > 2 else 1
        responder.monitor_worker(worker_id)
    elif mode == "monitor":
        responder.monitor_all_terminals()
    else:
        print(f"알 수 없는 모드: {mode}")

if __name__ == "__main__":
    main()