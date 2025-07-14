#!/usr/bin/env python3
"""
Master Controller for Multi-Agent Automation System
Unified entry point that coordinates all automation subsystems
"""

import subprocess
import time
import os
import json
import threading
import queue
import signal
import sys
from datetime import datetime
from typing import Dict, List, Optional
import psutil

# Import our centralized paths
from PATHS import PATHS, validate_environment, get_worker_directory

class MasterController:
    """
    Unified controller that coordinates all automation subsystems:
    - Tmux automation
    - PyCharm terminal controller  
    - Auto responder
    - Orchestrator
    - Monitoring and logging
    """
    
    def __init__(self):
        self.paths = PATHS
        self.active_processes = {}
        self.subsystems_status = {}
        self.running = False
        self.checkpoint_data = {}
        
        # Validate environment first
        if not validate_environment():
            raise RuntimeError("Environment validation failed. Please check paths.")
        
        # Initialize logging
        self.setup_logging()
        
        # Signal handlers
        signal.signal(signal.SIGINT, self.graceful_shutdown)
        signal.signal(signal.SIGTERM, self.graceful_shutdown)
    
    def setup_logging(self):
        """Setup centralized logging for all subsystems"""
        log_paths = self.paths.get_log_paths()
        
        # Create log directories if they don't exist
        for log_path in log_paths.values():
            os.makedirs(os.path.dirname(log_path), exist_ok=True)
        
        self.master_log = log_paths.get('master_controller', 
                                      os.path.join(self.paths.logs_dir, "master_controller.log"))
        
        self.log(f"Master Controller initialized at {datetime.now()}")
        self.log(f"Working from: {self.paths.project_root}")
        self.log(f"SquashTrainingApp: {self.paths.squash_app_root}")
    
    def log(self, message, level="INFO"):
        """Centralized logging function"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] [{level}] {message}"
        
        print(log_entry)
        
        try:
            with open(self.master_log, "a", encoding='utf-8') as f:
                f.write(log_entry + "\n")
        except Exception as e:
            print(f"Logging error: {e}")
    
    def check_prerequisites(self):
        """Check all prerequisites before starting automation"""
        self.log("Checking prerequisites...")
        
        prerequisites = {
            'python': self.check_python(),
            'claude_code': self.check_claude_code(),
            'tmux': self.check_tmux(),
            'pycharm': self.check_pycharm(),
            'dependencies': self.check_python_dependencies()
        }
        
        all_good = all(prerequisites.values())
        
        for name, status in prerequisites.items():
            status_symbol = "✅" if status else "❌"
            self.log(f"  {status_symbol} {name}")
        
        return all_good, prerequisites
    
    def check_python(self):
        """Check Python installation"""
        try:
            result = subprocess.run(['python', '--version'], capture_output=True, text=True)
            return result.returncode == 0
        except:
            return False
    
    def check_claude_code(self):
        """Check Claude Code installation and authentication"""
        try:
            result = subprocess.run(['claude', '--version'], capture_output=True, text=True)
            return result.returncode == 0
        except:
            return False
    
    def check_tmux(self):
        """Check tmux availability (WSL/Linux)"""
        if self.paths.is_windows:
            return True  # Not required on Windows
        try:
            result = subprocess.run(['which', 'tmux'], capture_output=True, text=True)
            return result.returncode == 0
        except:
            return False
    
    def check_pycharm(self):
        """Check if PyCharm is running"""
        for proc in psutil.process_iter(['name']):
            try:
                if 'pycharm' in proc.info['name'].lower():
                    return True
            except:
                continue
        return False
    
    def check_python_dependencies(self):
        """Check required Python packages"""
        required_packages = ['pyautogui', 'psutil', 'pygetwindow']
        
        for package in required_packages:
            try:
                __import__(package)
            except ImportError:
                return False
        return True
    
    def start_subsystem(self, name, command, cwd=None, shell=True):
        """Start a subsystem and track its process"""
        self.log(f"Starting subsystem: {name}")
        
        try:
            if cwd is None:
                cwd = self.paths.project_root
            
            process = subprocess.Popen(
                command,
                cwd=cwd,
                shell=shell,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            self.active_processes[name] = {
                'process': process,
                'start_time': time.time(),
                'command': command,
                'cwd': cwd
            }
            
            self.subsystems_status[name] = 'starting'
            self.log(f"✅ {name} started (PID: {process.pid})")
            
            return True
            
        except Exception as e:
            self.log(f"❌ Failed to start {name}: {e}", "ERROR")
            self.subsystems_status[name] = 'failed'
            return False
    
    def monitor_subsystems(self):
        """Monitor all running subsystems"""
        while self.running:
            for name, proc_info in self.active_processes.items():
                process = proc_info['process']
                
                if process.poll() is not None:
                    # Process has terminated
                    exit_code = process.returncode
                    if exit_code == 0:
                        self.subsystems_status[name] = 'completed'
                        self.log(f"✅ {name} completed successfully")
                    else:
                        self.subsystems_status[name] = 'failed'
                        self.log(f"❌ {name} failed with exit code {exit_code}", "ERROR")
                        
                        # Try to restart critical subsystems
                        if name in ['auto_responder', 'monitor']:
                            self.log(f"🔄 Attempting to restart {name}")
                            self.restart_subsystem(name)
                else:
                    self.subsystems_status[name] = 'running'
            
            time.sleep(5)  # Check every 5 seconds
    
    def restart_subsystem(self, name):
        """Restart a failed subsystem"""
        if name in self.active_processes:
            old_info = self.active_processes[name]
            
            # Kill old process if still running
            try:
                old_info['process'].terminate()
                old_info['process'].wait(timeout=10)
            except:
                try:
                    old_info['process'].kill()
                except:
                    pass
            
            # Start new process
            self.start_subsystem(name, old_info['command'], old_info['cwd'])
    
    def create_checkpoint(self, cycle_number, data):
        """Create a checkpoint for recovery"""
        checkpoint = {
            'cycle': cycle_number,
            'timestamp': datetime.now().isoformat(),
            'data': data,
            'subsystems_status': self.subsystems_status.copy()
        }
        
        checkpoint_file = os.path.join(self.paths.logs_dir, f"checkpoint_{cycle_number}.json")
        
        try:
            with open(checkpoint_file, 'w') as f:
                json.dump(checkpoint, f, indent=2)
            
            self.log(f"📋 Checkpoint {cycle_number} created")
            return True
            
        except Exception as e:
            self.log(f"❌ Failed to create checkpoint: {e}", "ERROR")
            return False
    
    def load_latest_checkpoint(self):
        """Load the latest checkpoint for recovery"""
        checkpoint_files = []
        
        for file in os.listdir(self.paths.logs_dir):
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
        checkpoint_path = os.path.join(self.paths.logs_dir, latest_file)
        
        try:
            with open(checkpoint_path, 'r') as f:
                checkpoint = json.load(f)
            
            self.log(f"📋 Loaded checkpoint from cycle {latest_cycle}")
            return checkpoint
            
        except Exception as e:
            self.log(f"❌ Failed to load checkpoint: {e}", "ERROR")
            return None
    
    def run_automation_cycle(self, target_cycles=50, start_cycle=1):
        """Run the complete automation cycle"""
        self.log(f"🚀 Starting automation cycle: {start_cycle} to {target_cycles}")
        self.running = True
        
        # Start monitoring thread
        monitor_thread = threading.Thread(target=self.monitor_subsystems, daemon=True)
        monitor_thread.start()
        
        try:
            for cycle in range(start_cycle, target_cycles + 1):
                self.log(f"🔄 Starting cycle {cycle}/{target_cycles}")
                
                # Run build-test-debug cycle
                cycle_success = self.run_single_cycle(cycle)
                
                # Create checkpoint
                self.create_checkpoint(cycle, {
                    'success': cycle_success,
                    'completion_time': datetime.now().isoformat()
                })
                
                if not cycle_success:
                    self.log(f"❌ Cycle {cycle} failed", "ERROR")
                    # Could implement retry logic here
                else:
                    self.log(f"✅ Cycle {cycle} completed successfully")
                
                # Brief pause between cycles
                time.sleep(2)
            
            self.log(f"🎉 All {target_cycles} cycles completed!")
            
        except KeyboardInterrupt:
            self.log("⏹️ Automation interrupted by user")
        except Exception as e:
            self.log(f"❌ Automation failed: {e}", "ERROR")
        finally:
            self.running = False
    
    def run_single_cycle(self, cycle_number):
        """Run a single build-test-debug cycle"""
        self.log(f"  🔨 Cycle {cycle_number}: Building...")
        
        # Example build command - adjust based on your actual build process
        build_cmd = ["./scripts/production/BUILD-ITERATE-APP.ps1"]
        build_cwd = self.paths.squash_app_root
        
        try:
            # Run build
            result = subprocess.run(
                build_cmd,
                cwd=build_cwd,
                capture_output=True,
                text=True,
                timeout=300  # 5 minute timeout
            )
            
            if result.returncode == 0:
                self.log(f"  ✅ Cycle {cycle_number}: Build successful")
                return True
            else:
                self.log(f"  ❌ Cycle {cycle_number}: Build failed")
                self.log(f"    Error: {result.stderr}")
                return False
                
        except subprocess.TimeoutExpired:
            self.log(f"  ⏰ Cycle {cycle_number}: Build timeout")
            return False
        except Exception as e:
            self.log(f"  ❌ Cycle {cycle_number}: Build error: {e}")
            return False
    
    def start_all_subsystems(self):
        """Start all automation subsystems"""
        self.log("🚀 Starting all automation subsystems...")
        
        subsystems = [
            {
                'name': 'auto_responder',
                'command': ['python', 'auto_responder.py', 'monitor'],
                'cwd': self.paths.project_root
            },
            {
                'name': 'monitor',
                'command': ['python', 'monitor_workers.py'],
                'cwd': self.paths.project_root
            }
        ]
        
        # Add PyCharm controller if PyCharm is running
        if self.check_pycharm():
            subsystems.append({
                'name': 'pycharm_controller',
                'command': ['python', 'pycharm_terminal_controller.py'],
                'cwd': self.paths.project_root
            })
        
        # Start each subsystem
        for subsystem in subsystems:
            self.start_subsystem(
                subsystem['name'],
                subsystem['command'],
                subsystem['cwd']
            )
        
        # Wait for subsystems to initialize
        time.sleep(5)
        
        self.log("✅ All subsystems started")
    
    def graceful_shutdown(self, signum=None, frame=None):
        """Gracefully shutdown all subsystems"""
        self.log("⏹️ Initiating graceful shutdown...")
        self.running = False
        
        # Terminate all active processes
        for name, proc_info in self.active_processes.items():
            process = proc_info['process']
            self.log(f"  🛑 Stopping {name}...")
            
            try:
                process.terminate()
                process.wait(timeout=10)
                self.log(f"  ✅ {name} stopped")
            except subprocess.TimeoutExpired:
                self.log(f"  🔪 Force killing {name}")
                process.kill()
            except Exception as e:
                self.log(f"  ⚠️ Error stopping {name}: {e}")
        
        self.log("✅ Graceful shutdown completed")
        sys.exit(0)
    
    def run(self, cycles=50, resume=False):
        """Main entry point for the master controller"""
        self.log("=" * 60)
        self.log("🎯 MASTER CONTROLLER STARTING")
        self.log("=" * 60)
        
        # Check prerequisites
        all_good, prereqs = self.check_prerequisites()
        if not all_good:
            self.log("❌ Prerequisites check failed", "ERROR")
            return False
        
        start_cycle = 1
        
        # Handle resume from checkpoint
        if resume:
            checkpoint = self.load_latest_checkpoint()
            if checkpoint:
                start_cycle = checkpoint['cycle'] + 1
                self.log(f"📋 Resuming from cycle {start_cycle}")
        
        # Start all subsystems
        self.start_all_subsystems()
        
        # Run automation cycles
        self.run_automation_cycle(cycles, start_cycle)
        
        return True

def main():
    """Command line interface for the master controller"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Master Controller for Multi-Agent Automation")
    parser.add_argument('--cycles', type=int, default=50, help='Number of cycles to run')
    parser.add_argument('--resume', action='store_true', help='Resume from last checkpoint')
    parser.add_argument('--test', action='store_true', help='Run in test mode (fewer cycles)')
    
    args = parser.parse_args()
    
    if args.test:
        args.cycles = 5
    
    try:
        controller = MasterController()
        success = controller.run(cycles=args.cycles, resume=args.resume)
        
        if success:
            print("\n🎉 Master Controller completed successfully!")
        else:
            print("\n❌ Master Controller failed!")
            sys.exit(1)
            
    except KeyboardInterrupt:
        print("\n⏹️ Master Controller interrupted by user")
    except Exception as e:
        print(f"\n❌ Master Controller error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()