#!/usr/bin/env python3
"""
Real-time Monitoring Dashboard for Multi-Agent Automation System
Provides visual feedback and status updates for 50+ cycle automation
"""

import os
import json
import time
import threading
import subprocess
from datetime import datetime, timedelta
from collections import deque
import psutil

from PATHS import PATHS

class MonitoringDashboard:
    """
    Real-time dashboard for monitoring automation cycles and system health
    """
    
    def __init__(self):
        self.paths = PATHS
        self.running = False
        self.cycle_history = deque(maxlen=100)  # Keep last 100 cycles
        self.system_metrics = {}
        self.subsystem_status = {}
        self.error_count = 0
        self.success_count = 0
        self.start_time = None
        
        # Dashboard configuration
        self.refresh_interval = 2  # seconds
        self.metrics_interval = 5  # seconds
        
        # Initialize status tracking
        self.init_status_tracking()
    
    def init_status_tracking(self):
        """Initialize status tracking for all subsystems"""
        self.subsystem_status = {
            'master_controller': {'status': 'unknown', 'last_update': None, 'pid': None},
            'auto_responder': {'status': 'unknown', 'last_update': None, 'pid': None},
            'monitor_workers': {'status': 'unknown', 'last_update': None, 'pid': None},
            'pycharm_controller': {'status': 'unknown', 'last_update': None, 'pid': None},
            'tmux_automation': {'status': 'unknown', 'last_update': None, 'pid': None}
        }
    
    def clear_screen(self):
        """Clear the terminal screen"""
        os.system('cls' if os.name == 'nt' else 'clear')
    
    def get_system_metrics(self):
        """Collect system performance metrics"""
        try:
            # CPU and Memory usage
            cpu_percent = psutil.cpu_percent(interval=1)
            memory = psutil.virtual_memory()
            disk = psutil.disk_usage(self.paths.project_root)
            
            # Process information
            python_processes = []
            claude_processes = []
            
            for proc in psutil.process_iter(['pid', 'name', 'cmdline', 'cpu_percent', 'memory_percent']):
                try:
                    if 'python' in proc.info['name'].lower():
                        cmdline = ' '.join(proc.info['cmdline']) if proc.info['cmdline'] else ''
                        if any(script in cmdline for script in ['auto_responder', 'monitor_workers', 'master_controller', 'pycharm_terminal']):
                            python_processes.append({
                                'pid': proc.info['pid'],
                                'name': proc.info['name'],
                                'cmdline': cmdline[:50] + '...' if len(cmdline) > 50 else cmdline,
                                'cpu': proc.info['cpu_percent'],
                                'memory': proc.info['memory_percent']
                            })
                    
                    if 'claude' in proc.info['name'].lower():
                        claude_processes.append({
                            'pid': proc.info['pid'],
                            'name': proc.info['name'],
                            'cpu': proc.info['cpu_percent'],
                            'memory': proc.info['memory_percent']
                        })
                        
                except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                    continue
            
            return {
                'cpu_percent': cpu_percent,
                'memory_percent': memory.percent,
                'memory_available_gb': memory.available / (1024**3),
                'disk_free_gb': disk.free / (1024**3),
                'python_processes': python_processes,
                'claude_processes': claude_processes,
                'timestamp': datetime.now()
            }
            
        except Exception as e:
            return {
                'error': str(e),
                'timestamp': datetime.now()
            }
    
    def load_checkpoint_data(self):
        """Load latest checkpoint data"""
        try:
            checkpoint_files = []
            logs_dir = self.paths.logs_dir
            
            if not os.path.exists(logs_dir):
                return None
            
            for file in os.listdir(logs_dir):
                if file.startswith('checkpoint_') and file.endswith('.json'):
                    try:
                        cycle_num = int(file.replace('checkpoint_', '').replace('.json', ''))
                        checkpoint_files.append((cycle_num, file))
                    except ValueError:
                        continue
            
            if not checkpoint_files:
                return None
            
            # Get latest checkpoint
            latest_cycle, latest_file = max(checkpoint_files)
            checkpoint_path = os.path.join(logs_dir, latest_file)
            
            with open(checkpoint_path, 'r') as f:
                checkpoint = json.load(f)
            
            return checkpoint
            
        except Exception as e:
            return {'error': str(e)}
    
    def update_subsystem_status(self):
        """Update status of all subsystems"""
        current_time = datetime.now()
        
        # Check for running Python automation processes
        for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
            try:
                if 'python' in proc.info['name'].lower() and proc.info['cmdline']:
                    cmdline = ' '.join(proc.info['cmdline'])
                    
                    if 'master_controller' in cmdline:
                        self.subsystem_status['master_controller'].update({
                            'status': 'running',
                            'last_update': current_time,
                            'pid': proc.info['pid']
                        })
                    elif 'auto_responder' in cmdline:
                        self.subsystem_status['auto_responder'].update({
                            'status': 'running',
                            'last_update': current_time,
                            'pid': proc.info['pid']
                        })
                    elif 'monitor_workers' in cmdline:
                        self.subsystem_status['monitor_workers'].update({
                            'status': 'running',
                            'last_update': current_time,
                            'pid': proc.info['pid']
                        })
                    elif 'pycharm_terminal' in cmdline:
                        self.subsystem_status['pycharm_controller'].update({
                            'status': 'running',
                            'last_update': current_time,
                            'pid': proc.info['pid']
                        })
                        
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                continue
        
        # Check tmux sessions (if on WSL/Linux)
        if not self.paths.is_windows:
            try:
                result = subprocess.run(['tmux', 'list-sessions'], capture_output=True, text=True)
                if result.returncode == 0 and 'claude-multi-agent' in result.stdout:
                    self.subsystem_status['tmux_automation'].update({
                        'status': 'running',
                        'last_update': current_time,
                        'pid': 'tmux-session'
                    })
                else:
                    self.subsystem_status['tmux_automation']['status'] = 'stopped'
            except:
                self.subsystem_status['tmux_automation']['status'] = 'unknown'
        
        # Mark processes as stopped if not updated recently
        for subsystem, status in self.subsystem_status.items():
            if status['last_update'] and current_time - status['last_update'] > timedelta(seconds=30):
                status['status'] = 'stopped'
                status['pid'] = None
    
    def render_header(self):
        """Render dashboard header"""
        current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        uptime = ""
        if self.start_time:
            uptime_delta = datetime.now() - self.start_time
            uptime = str(uptime_delta).split('.')[0]  # Remove microseconds
        
        print("🎯 MULTI-AGENT AUTOMATION DASHBOARD")
        print("=" * 80)
        print(f"📅 Current Time: {current_time}")
        if uptime:
            print(f"⏱️  Dashboard Uptime: {uptime}")
        print(f"🏠 Project Root: {self.paths.squash_app_root}")
        print()
    
    def render_cycle_progress(self):
        """Render cycle progress information"""
        checkpoint = self.load_checkpoint_data()
        
        print("🔄 AUTOMATION CYCLE PROGRESS")
        print("-" * 40)
        
        if checkpoint and 'cycle' in checkpoint:
            current_cycle = checkpoint['cycle']
            target_cycles = 50  # Default target
            progress_percent = (current_cycle / target_cycles) * 100
            
            # Progress bar
            bar_length = 30
            filled_length = int(bar_length * current_cycle // target_cycles)
            bar = '█' * filled_length + '-' * (bar_length - filled_length)
            
            print(f"📊 Progress: [{bar}] {progress_percent:.1f}%")
            print(f"🎯 Cycle: {current_cycle}/{target_cycles}")
            
            if 'timestamp' in checkpoint:
                last_update = checkpoint['timestamp']
                print(f"⏰ Last Update: {last_update}")
            
            if 'data' in checkpoint and 'success' in checkpoint['data']:
                status_symbol = "✅" if checkpoint['data']['success'] else "❌"
                print(f"📋 Last Cycle: {status_symbol}")
            
        else:
            print("⏳ No cycle data available yet")
            print("🚀 Waiting for automation to start...")
        
        print(f"✅ Successful Cycles: {self.success_count}")
        print(f"❌ Failed Cycles: {self.error_count}")
        print()
    
    def render_subsystem_status(self):
        """Render subsystem status"""
        print("🔧 SUBSYSTEM STATUS")
        print("-" * 40)
        
        status_symbols = {
            'running': '🟢',
            'stopped': '🔴',
            'unknown': '🟡'
        }
        
        for subsystem, status in self.subsystem_status.items():
            symbol = status_symbols.get(status['status'], '❓')
            name = subsystem.replace('_', ' ').title()
            pid_info = f"(PID: {status['pid']})" if status['pid'] else ""
            
            print(f"{symbol} {name:<20} {status['status']:<10} {pid_info}")
        
        print()
    
    def render_system_metrics(self):
        """Render system performance metrics"""
        print("📊 SYSTEM METRICS")
        print("-" * 40)
        
        if self.system_metrics and 'error' not in self.system_metrics:
            cpu = self.system_metrics['cpu_percent']
            memory = self.system_metrics['memory_percent']
            memory_avail = self.system_metrics['memory_available_gb']
            disk_free = self.system_metrics['disk_free_gb']
            
            # CPU and Memory bars
            cpu_bar = self.create_progress_bar(cpu, 100, 20)
            memory_bar = self.create_progress_bar(memory, 100, 20)
            
            print(f"🖥️  CPU Usage:    [{cpu_bar}] {cpu:.1f}%")
            print(f"🧠 Memory Usage: [{memory_bar}] {memory:.1f}%")
            print(f"💾 Memory Free:  {memory_avail:.1f} GB")
            print(f"💿 Disk Free:    {disk_free:.1f} GB")
            
            # Python processes
            python_procs = self.system_metrics.get('python_processes', [])
            if python_procs:
                print(f"\n🐍 Python Processes ({len(python_procs)}):")
                for proc in python_procs[:5]:  # Show top 5
                    print(f"   PID {proc['pid']}: {proc['cmdline'][:40]}...")
            
            # Claude processes
            claude_procs = self.system_metrics.get('claude_processes', [])
            if claude_procs:
                print(f"\n🤖 Claude Processes ({len(claude_procs)}):")
                for proc in claude_procs:
                    print(f"   PID {proc['pid']}: CPU {proc['cpu']:.1f}% MEM {proc['memory']:.1f}%")
        
        else:
            print("⚠️ System metrics unavailable")
        
        print()
    
    def create_progress_bar(self, value, max_value, length):
        """Create a simple progress bar"""
        filled_length = int(length * value / max_value)
        bar = '█' * filled_length + '░' * (length - filled_length)
        return bar
    
    def render_recent_activity(self):
        """Render recent activity and logs"""
        print("📝 RECENT ACTIVITY")
        print("-" * 40)
        
        # Check for recent log files
        log_files = [
            ('Auto Responder', os.path.join(self.paths.logs_dir, 'auto_responder.log')),
            ('Error Recovery', os.path.join(self.paths.logs_dir, 'error_recovery.log')),
            ('Master Controller', os.path.join(self.paths.logs_dir, 'master_controller.log'))
        ]
        
        for log_name, log_path in log_files:
            if os.path.exists(log_path):
                try:
                    # Get file modification time
                    mod_time = datetime.fromtimestamp(os.path.getmtime(log_path))
                    time_diff = datetime.now() - mod_time
                    
                    if time_diff.total_seconds() < 300:  # Last 5 minutes
                        # Read last few lines
                        with open(log_path, 'r', encoding='utf-8') as f:
                            lines = f.readlines()
                            if lines:
                                last_line = lines[-1].strip()
                                print(f"📄 {log_name}: {last_line[:60]}...")
                except Exception:
                    continue
        
        print()
    
    def render_controls(self):
        """Render control information"""
        print("⌨️  CONTROLS")
        print("-" * 40)
        print("Ctrl+C: Stop dashboard")
        print("📁 Logs: " + self.paths.logs_dir)
        print("🏠 Root: " + self.paths.project_root)
        print()
    
    def metrics_updater(self):
        """Background thread to update system metrics"""
        while self.running:
            self.system_metrics = self.get_system_metrics()
            time.sleep(self.metrics_interval)
    
    def status_updater(self):
        """Background thread to update subsystem status"""
        while self.running:
            self.update_subsystem_status()
            time.sleep(self.refresh_interval)
    
    def render_dashboard(self):
        """Render the complete dashboard"""
        self.clear_screen()
        
        self.render_header()
        self.render_cycle_progress()
        self.render_subsystem_status()
        self.render_system_metrics()
        self.render_recent_activity()
        self.render_controls()
    
    def run(self):
        """Main dashboard loop"""
        self.running = True
        self.start_time = datetime.now()
        
        # Start background threads
        metrics_thread = threading.Thread(target=self.metrics_updater, daemon=True)
        status_thread = threading.Thread(target=self.status_updater, daemon=True)
        
        metrics_thread.start()
        status_thread.start()
        
        try:
            while self.running:
                self.render_dashboard()
                time.sleep(self.refresh_interval)
                
        except KeyboardInterrupt:
            print("\n\n⏹️ Dashboard stopped by user")
            self.running = False
        except Exception as e:
            print(f"\n\n❌ Dashboard error: {e}")
            self.running = False

class SimpleDashboard:
    """
    Simplified dashboard for systems without advanced terminal features
    """
    
    def __init__(self):
        self.paths = PATHS
    
    def print_status(self):
        """Print a simple status update"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        print(f"\n[{timestamp}] 🎯 Automation Status Check")
        
        # Check for checkpoints
        checkpoint_count = 0
        if os.path.exists(self.paths.logs_dir):
            for file in os.listdir(self.paths.logs_dir):
                if file.startswith('checkpoint_') and file.endswith('.json'):
                    checkpoint_count += 1
        
        print(f"📋 Checkpoints found: {checkpoint_count}")
        
        # Check for running processes
        automation_processes = 0
        for proc in psutil.process_iter(['name', 'cmdline']):
            try:
                if proc.info['cmdline']:
                    cmdline = ' '.join(proc.info['cmdline'])
                    if any(script in cmdline for script in ['auto_responder', 'monitor_workers', 'master_controller']):
                        automation_processes += 1
            except:
                continue
        
        print(f"🔧 Automation processes: {automation_processes}")
        
        # System metrics
        cpu = psutil.cpu_percent()
        memory = psutil.virtual_memory().percent
        print(f"💻 System: CPU {cpu:.1f}% | Memory {memory:.1f}%")
    
    def run_simple(self, duration_minutes=60):
        """Run simple monitoring for specified duration"""
        print(f"🚀 Starting simple monitoring for {duration_minutes} minutes...")
        
        start_time = time.time()
        end_time = start_time + (duration_minutes * 60)
        
        try:
            while time.time() < end_time:
                self.print_status()
                time.sleep(30)  # Update every 30 seconds
                
        except KeyboardInterrupt:
            print("\n⏹️ Simple monitoring stopped by user")

def main():
    """Command line interface for the monitoring dashboard"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Multi-Agent Automation Monitoring Dashboard")
    parser.add_argument('--simple', action='store_true', help='Use simple text-based monitoring')
    parser.add_argument('--duration', type=int, default=60, help='Duration for simple monitoring (minutes)')
    
    args = parser.parse_args()
    
    try:
        if args.simple:
            dashboard = SimpleDashboard()
            dashboard.run_simple(args.duration)
        else:
            dashboard = MonitoringDashboard()
            dashboard.run()
            
    except KeyboardInterrupt:
        print("\n⏹️ Monitoring stopped by user")
    except Exception as e:
        print(f"\n❌ Monitoring error: {e}")

if __name__ == "__main__":
    main()