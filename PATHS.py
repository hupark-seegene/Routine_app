#!/usr/bin/env python3
"""
Centralized Path Configuration for Multi-Agent Automation System
All path references should use this configuration file
"""

import os
import platform

class AutomationPaths:
    """
    Centralized path configuration for all automation components
    """
    
    def __init__(self):
        self.is_windows = platform.system().lower() == 'windows'
        self.is_wsl = 'wsl' in platform.uname().release.lower() if platform.system().lower() == 'linux' else False
        
        # Root paths
        if self.is_windows:
            self.project_root = r"C:\Git\Routine_app"
            self.squash_app_root = r"C:\Git\Routine_app\SquashTrainingApp"
        else:  # WSL/Linux
            self.project_root = "/mnt/c/Git/Routine_app"
            self.squash_app_root = "/mnt/c/Git/Routine_app/SquashTrainingApp"
        
        # Automation directories
        self.scripts_dir = os.path.join(self.squash_app_root, "scripts")
        self.production_scripts = os.path.join(self.scripts_dir, "production")
        self.tmux_automation = os.path.join(self.production_scripts, "tmux-automation")
        self.utility_scripts = os.path.join(self.scripts_dir, "utility")
        
        # Logs and output directories
        self.logs_dir = os.path.join(self.project_root, "logs")
        self.build_artifacts = os.path.join(self.project_root, "build-artifacts")
        self.screenshots_dir = os.path.join(self.build_artifacts, "screenshots")
        self.reports_dir = os.path.join(self.build_artifacts, "reports")
        
        # Source code directories
        self.src_dir = os.path.join(self.squash_app_root, "src")
        self.android_dir = os.path.join(self.squash_app_root, "android")
        self.ios_dir = os.path.join(self.squash_app_root, "ios")
        
        # Documentation
        self.docs_dir = os.path.join(self.project_root, "docs")
        self.guides_dir = os.path.join(self.docs_dir, "guides")
        
        # Archives
        self.archive_dir = os.path.join(self.project_root, "archive")
        
        # Create essential directories
        self._create_directories()
    
    def _create_directories(self):
        """Create essential directories if they don't exist"""
        essential_dirs = [
            self.logs_dir,
            self.build_artifacts,
            self.screenshots_dir,
            self.reports_dir,
            os.path.join(self.logs_dir, "build-logs"),
            os.path.join(self.logs_dir, "test-logs"),
            os.path.join(self.logs_dir, "debug-logs"),
        ]
        
        for directory in essential_dirs:
            os.makedirs(directory, exist_ok=True)
    
    def get_worker_path(self, worker_id=None):
        """
        Get the working directory for Claude Code workers
        All workers now work from SquashTrainingApp directory
        """
        return self.squash_app_root
    
    def get_tmux_session_paths(self):
        """Get paths for tmux session configuration"""
        return {
            'session_name': 'claude-multi-agent',
            'controller_path': self.tmux_automation,
            'worker_path': self.squash_app_root,
            'monitor_path': self.project_root
        }
    
    def get_log_paths(self):
        """Get log file paths for different automation components"""
        return {
            'auto_responder': os.path.join(self.logs_dir, "auto_responder.log"),
            'pycharm_controller': os.path.join(self.logs_dir, "pycharm_controller.log"),
            'orchestrator': os.path.join(self.logs_dir, "orchestrator.log"),
            'build_log': os.path.join(self.logs_dir, "build-logs", "latest.log"),
            'test_log': os.path.join(self.logs_dir, "test-logs", "latest.log"),
            'debug_log': os.path.join(self.logs_dir, "debug-logs", "latest.log")
        }
    
    def get_config_paths(self):
        """Get configuration file paths"""
        return {
            'project_plan': os.path.join(self.project_root, "project_plan.md"),
            'claude_md': os.path.join(self.project_root, "CLAUDE.md"),
            'package_json': os.path.join(self.squash_app_root, "package.json"),
            'android_gradle': os.path.join(self.android_dir, "build.gradle"),
            'app_gradle': os.path.join(self.android_dir, "app", "build.gradle")
        }
    
    def get_script_paths(self):
        """Get paths to important automation scripts"""
        if self.is_windows:
            return {
                'start_automation': os.path.join(self.project_root, "start_automation.bat"),
                'fix_environment': os.path.join(self.project_root, "fix_environment.bat"),
                'quick_start': os.path.join(self.project_root, "quick_start.bat")
            }
        else:
            return {
                'tmux_setup': os.path.join(self.tmux_automation, "TMUX-SETUP.sh"),
                'tmux_controller': os.path.join(self.tmux_automation, "TMUX-AUTOMATION-CONTROLLER.ps1")
            }
    
    def validate_paths(self):
        """Validate that critical paths exist"""
        critical_paths = [
            self.project_root,
            self.squash_app_root,
            self.src_dir,
            self.android_dir
        ]
        
        validation_results = {}
        for path in critical_paths:
            validation_results[path] = os.path.exists(path)
        
        return validation_results
    
    def get_relative_path(self, absolute_path, base_path=None):
        """Convert absolute path to relative path from base directory"""
        if base_path is None:
            base_path = self.project_root
        
        try:
            return os.path.relpath(absolute_path, base_path)
        except ValueError:
            return absolute_path
    
    def normalize_path(self, path):
        """Normalize path for current platform"""
        if self.is_windows:
            return path.replace('/', '\\')
        else:
            return path.replace('\\', '/')

# Global instance for easy importing
PATHS = AutomationPaths()

# Convenience functions for common paths
def get_project_root():
    """Get the main project root directory"""
    return PATHS.project_root

def get_squash_app_root():
    """Get the SquashTrainingApp directory"""
    return PATHS.squash_app_root

def get_worker_directory():
    """Get the directory where Claude Code workers should operate"""
    return PATHS.get_worker_path()

def get_logs_directory():
    """Get the logs directory"""
    return PATHS.logs_dir

def validate_environment():
    """Validate that the automation environment is set up correctly"""
    results = PATHS.validate_paths()
    all_valid = all(results.values())
    
    if not all_valid:
        print("❌ Path validation failed:")
        for path, valid in results.items():
            status = "✅" if valid else "❌"
            print(f"  {status} {path}")
    else:
        print("✅ All critical paths validated successfully")
    
    return all_valid

if __name__ == "__main__":
    # Test the path configuration
    print("🔧 Path Configuration Test")
    print("=" * 50)
    print(f"Platform: {platform.system()}")
    print(f"Is Windows: {PATHS.is_windows}")
    print(f"Is WSL: {PATHS.is_wsl}")
    print()
    
    print("📁 Key Paths:")
    print(f"Project Root: {PATHS.project_root}")
    print(f"SquashTrainingApp: {PATHS.squash_app_root}")
    print(f"Worker Directory: {get_worker_directory()}")
    print(f"Logs Directory: {get_logs_directory()}")
    print()
    
    print("🔍 Path Validation:")
    validate_environment()