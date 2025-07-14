import subprocess
import time
import sys
import os


class WindowsAutoResponder:
    def __init__(self):
        self.project_root = r"C:\Git\Routine_app"

    def monitor_claude(self, worker_id=1):
        """Claude Code 모니터링 및 자동 응답"""
        worker_path = os.path.join(os.path.dirname(self.project_root), f"worker-{worker_id}")

        print(f"🤖 Worker {worker_id} 자동 응답 시스템 시작...")

        # PowerShell 스크립트로 자동 응답
        ps_script = """
        while ($true) {
            Start-Sleep -Seconds 2
            # 여기에 자동 응답 로직 추가
            Write-Host "Monitoring..."
        }
        """

        # 실행
        subprocess.run(["powershell", "-Command", ps_script], cwd=worker_path)


if __name__ == "__main__":
    responder = WindowsAutoResponder()
    if len(sys.argv) > 1:
        worker_id = int(sys.argv[1])
        responder.monitor_claude(worker_id)
    else:
        responder.monitor_claude()