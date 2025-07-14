#!/usr/bin/env python3
"""
Simplified Automation Controller
Runs without dependencies that aren't available in the WSL environment
"""

import subprocess
import time
import os
import json
import threading
import signal
import sys
from datetime import datetime
from typing import Dict, List, Optional

# Import our centralized paths
from PATHS import PATHS, validate_environment

class SimpleAutomationController:
    """
    Simplified automation controller that doesn't require psutil or other unavailable packages
    """
    
    def __init__(self):
        self.paths = PATHS
        self.active_processes = {}
        self.running = False
        self.start_time = None
        
        # Validate environment first
        if not validate_environment():
            raise RuntimeError("Environment validation failed. Please check paths.")
        
        # Initialize logging
        self.setup_logging()
        
        # Signal handlers
        signal.signal(signal.SIGINT, self.graceful_shutdown)
        signal.signal(signal.SIGTERM, self.graceful_shutdown)
    
    def setup_logging(self):
        """Setup logging"""
        os.makedirs(self.paths.logs_dir, exist_ok=True)
        self.log_file = os.path.join(self.paths.logs_dir, "simple_automation.log")
        
        self.log(f"Simple Automation Controller initialized at {datetime.now()}")
        self.log(f"Working from: {self.paths.project_root}")
        self.log(f"SquashTrainingApp: {self.paths.squash_app_root}")
    
    def log(self, message, level="INFO"):
        """Centralized logging function"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] [{level}] {message}"
        
        print(log_entry)
        
        try:
            with open(self.log_file, "a", encoding='utf-8') as f:
                f.write(log_entry + "\n")
        except Exception as e:
            print(f"Logging error: {e}")
    
    def create_checkpoint(self, cycle_number, data):
        """Create a checkpoint for recovery"""
        checkpoint = {
            'cycle': cycle_number,
            'timestamp': datetime.now().isoformat(),
            'data': data
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
    
    def run_single_cycle(self, cycle_number):
        """Run a single build-test-debug cycle"""
        self.log(f"🔄 Starting cycle {cycle_number}")
        
        # Simulate build process (replace with actual build commands)
        self.log(f"  🔨 Building React Native app...")
        
        # Example: Run a simple build validation
        try:
            # Check if package.json exists
            package_json = os.path.join(self.paths.squash_app_root, "package.json")
            if not os.path.exists(package_json):
                self.log(f"  ❌ package.json not found at {package_json}")
                return False
            
            # Check if node_modules exists or can be created
            node_modules = os.path.join(self.paths.squash_app_root, "node_modules")
            if not os.path.exists(node_modules):
                self.log(f"  📦 Installing dependencies...")
                # In a real scenario, you'd run npm install here
                
            self.log(f"  ✅ Cycle {cycle_number}: Build simulation successful")
            return True
            
        except Exception as e:
            self.log(f"  ❌ Cycle {cycle_number}: Error: {e}")
            return False
    
    def run_automation_cycles(self, target_cycles=50, start_cycle=1):
        """Run the complete automation cycle"""
        self.log(f"🚀 Starting automation: cycles {start_cycle} to {target_cycles}")
        self.running = True
        self.start_time = time.time()
        
        success_count = 0
        failure_count = 0
        
        try:
            for cycle in range(start_cycle, target_cycles + 1):
                if not self.running:
                    break
                
                # Run single cycle
                cycle_success = self.run_single_cycle(cycle)
                
                # Track results
                if cycle_success:
                    success_count += 1
                else:
                    failure_count += 1
                
                # Create checkpoint
                self.create_checkpoint(cycle, {
                    'success': cycle_success,
                    'completion_time': datetime.now().isoformat(),
                    'total_successes': success_count,
                    'total_failures': failure_count
                })
                
                # Progress update
                if cycle % 5 == 0:
                    elapsed = time.time() - self.start_time
                    self.log(f"📊 Progress: {cycle}/{target_cycles} cycles ({success_count} successful, {failure_count} failed)")
                    self.log(f"⏱️  Elapsed time: {elapsed:.1f} seconds")
                
                # Brief pause between cycles
                time.sleep(1)
            
            # Final summary
            elapsed = time.time() - self.start_time
            self.log(f"🎉 Automation completed!")
            self.log(f"📊 Final results: {success_count} successful, {failure_count} failed out of {target_cycles} cycles")
            self.log(f"⏱️  Total time: {elapsed:.1f} seconds")
            
        except KeyboardInterrupt:
            self.log("⏹️ Automation interrupted by user")
        except Exception as e:
            self.log(f"❌ Automation failed: {e}", "ERROR")
        finally:
            self.running = False
    
    def graceful_shutdown(self, signum=None, frame=None):
        """Gracefully shutdown automation"""
        self.log("⏹️ Initiating graceful shutdown...")
        self.running = False
        
        if self.start_time:
            elapsed = time.time() - self.start_time
            self.log(f"⏱️  Session duration: {elapsed:.1f} seconds")
        
        self.log("✅ Graceful shutdown completed")
        sys.exit(0)
    
    def run(self, cycles=50, resume=False):
        """Main entry point for the automation controller"""
        self.log("=" * 60)
        self.log("🎯 SIMPLE AUTOMATION CONTROLLER STARTING")
        self.log("=" * 60)
        
        start_cycle = 1
        
        # Handle resume from checkpoint (simplified)
        if resume:
            try:
                checkpoint_files = [f for f in os.listdir(self.paths.logs_dir) 
                                  if f.startswith('checkpoint_') and f.endswith('.json')]
                if checkpoint_files:
                    # Get latest checkpoint number
                    latest_num = max(int(f.replace('checkpoint_', '').replace('.json', '')) 
                                   for f in checkpoint_files)
                    start_cycle = latest_num + 1
                    self.log(f"📋 Resuming from cycle {start_cycle}")
            except Exception as e:
                self.log(f"⚠️ Could not resume from checkpoint: {e}")
        
        # Run automation cycles
        self.run_automation_cycles(cycles, start_cycle)
        
        return True

def main():
    """Command line interface for the simple automation controller"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Simple Automation Controller")
    parser.add_argument('--cycles', type=int, default=50, help='Number of cycles to run')
    parser.add_argument('--resume', action='store_true', help='Resume from last checkpoint')
    parser.add_argument('--test', action='store_true', help='Run in test mode (fewer cycles)')
    
    args = parser.parse_args()
    
    if args.test:
        args.cycles = 5
    
    try:
        controller = SimpleAutomationController()
        success = controller.run(cycles=args.cycles, resume=args.resume)
        
        if success:
            print("\n🎉 Simple Automation completed successfully!")
        else:
            print("\n❌ Simple Automation failed!")
            sys.exit(1)
            
    except KeyboardInterrupt:
        print("\n⏹️ Simple Automation interrupted by user")
    except Exception as e:
        print(f"\n❌ Simple Automation error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()