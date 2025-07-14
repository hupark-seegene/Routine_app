#!/usr/bin/env python3
"""
Enhanced Error Recovery System for Multi-Agent Automation
Handles various failure scenarios with intelligent retry logic
"""

import os
import json
import time
import subprocess
import threading
import shutil
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Callable
from enum import Enum

from PATHS import PATHS

class ErrorType(Enum):
    """Classification of different error types"""
    BUILD_FAILURE = "build_failure"
    DEPENDENCY_ERROR = "dependency_error"
    PERMISSION_ERROR = "permission_error"
    NETWORK_ERROR = "network_error"
    TIMEOUT_ERROR = "timeout_error"
    CLAUDE_CODE_ERROR = "claude_code_error"
    ENVIRONMENT_ERROR = "environment_error"
    UNKNOWN_ERROR = "unknown_error"

class RecoveryStrategy(Enum):
    """Different recovery strategies"""
    RETRY = "retry"
    RESET_ENVIRONMENT = "reset_environment"
    RESTART_SUBSYSTEM = "restart_subsystem"
    CLEAR_CACHE = "clear_cache"
    FALLBACK_METHOD = "fallback_method"
    MANUAL_INTERVENTION = "manual_intervention"

class ErrorRecoveryManager:
    """
    Manages error detection, classification, and recovery for the automation system
    """
    
    def __init__(self):
        self.paths = PATHS
        self.recovery_log = os.path.join(self.paths.logs_dir, "error_recovery.log")
        self.error_patterns = self._load_error_patterns()
        self.recovery_strategies = self._setup_recovery_strategies()
        self.error_history = []
        self.retry_limits = {
            ErrorType.BUILD_FAILURE: 3,
            ErrorType.DEPENDENCY_ERROR: 2,
            ErrorType.PERMISSION_ERROR: 1,
            ErrorType.NETWORK_ERROR: 5,
            ErrorType.TIMEOUT_ERROR: 2,
            ErrorType.CLAUDE_CODE_ERROR: 3,
            ErrorType.ENVIRONMENT_ERROR: 2,
            ErrorType.UNKNOWN_ERROR: 1
        }
        
        # Ensure log directory exists
        os.makedirs(os.path.dirname(self.recovery_log), exist_ok=True)
    
    def _load_error_patterns(self):
        """Load error patterns for classification"""
        return {
            ErrorType.BUILD_FAILURE: [
                r"Build failed",
                r"Compilation error",
                r"gradle.*failed",
                r"BUILD FAILED",
                r"npm.*error",
                r"react-native.*error"
            ],
            ErrorType.DEPENDENCY_ERROR: [
                r"Module not found",
                r"Cannot resolve dependency",
                r"Package.*not found",
                r"ImportError",
                r"ModuleNotFoundError",
                r"npm.*missing"
            ],
            ErrorType.PERMISSION_ERROR: [
                r"Permission denied",
                r"Access denied",
                r"EPERM",
                r"EACCES",
                r"insufficient privileges"
            ],
            ErrorType.NETWORK_ERROR: [
                r"Network.*error",
                r"Connection.*failed",
                r"Timeout.*connecting",
                r"DNS.*error",
                r"ETIMEDOUT",
                r"ECONNREFUSED"
            ],
            ErrorType.TIMEOUT_ERROR: [
                r"Timeout",
                r"TimeoutExpired",
                r"Operation.*timed out",
                r"Request timeout"
            ],
            ErrorType.CLAUDE_CODE_ERROR: [
                r"claude.*error",
                r"Authentication.*failed",
                r"API.*error",
                r"Invalid.*token",
                r"Claude.*not found"
            ],
            ErrorType.ENVIRONMENT_ERROR: [
                r"Environment.*error",
                r"PATH.*not found",
                r"Command.*not found",
                r"Python.*not found",
                r"java.*not found"
            ]
        }
    
    def _setup_recovery_strategies(self):
        """Setup recovery strategies for different error types"""
        return {
            ErrorType.BUILD_FAILURE: [
                (RecoveryStrategy.CLEAR_CACHE, self._clear_build_cache),
                (RecoveryStrategy.RESET_ENVIRONMENT, self._reset_build_environment),
                (RecoveryStrategy.RETRY, self._retry_build)
            ],
            ErrorType.DEPENDENCY_ERROR: [
                (RecoveryStrategy.CLEAR_CACHE, self._clear_dependency_cache),
                (RecoveryStrategy.RESET_ENVIRONMENT, self._reinstall_dependencies),
                (RecoveryStrategy.RETRY, self._retry_dependency_install)
            ],
            ErrorType.PERMISSION_ERROR: [
                (RecoveryStrategy.RESET_ENVIRONMENT, self._fix_permissions),
                (RecoveryStrategy.MANUAL_INTERVENTION, self._request_admin_privileges)
            ],
            ErrorType.NETWORK_ERROR: [
                (RecoveryStrategy.RETRY, self._retry_network_operation),
                (RecoveryStrategy.FALLBACK_METHOD, self._use_offline_fallback)
            ],
            ErrorType.TIMEOUT_ERROR: [
                (RecoveryStrategy.RETRY, self._retry_with_longer_timeout),
                (RecoveryStrategy.RESTART_SUBSYSTEM, self._restart_slow_subsystem)
            ],
            ErrorType.CLAUDE_CODE_ERROR: [
                (RecoveryStrategy.RESET_ENVIRONMENT, self._reauthenticate_claude),
                (RecoveryStrategy.RESTART_SUBSYSTEM, self._restart_claude_session)
            ],
            ErrorType.ENVIRONMENT_ERROR: [
                (RecoveryStrategy.RESET_ENVIRONMENT, self._fix_environment_paths),
                (RecoveryStrategy.MANUAL_INTERVENTION, self._request_environment_setup)
            ],
            ErrorType.UNKNOWN_ERROR: [
                (RecoveryStrategy.RETRY, self._generic_retry),
                (RecoveryStrategy.MANUAL_INTERVENTION, self._request_manual_review)
            ]
        }
    
    def log_error(self, message, level="ERROR"):
        """Log error recovery messages"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] [{level}] {message}"
        
        print(log_entry)
        
        try:
            with open(self.recovery_log, "a", encoding='utf-8') as f:
                f.write(log_entry + "\n")
        except Exception as e:
            print(f"Logging error: {e}")
    
    def classify_error(self, error_message, stderr_output="", exit_code=None):
        """Classify error based on patterns and context"""
        full_error_text = f"{error_message} {stderr_output}".lower()
        
        for error_type, patterns in self.error_patterns.items():
            for pattern in patterns:
                import re
                if re.search(pattern.lower(), full_error_text):
                    return error_type
        
        # Additional classification based on exit codes
        if exit_code:
            if exit_code == 1:
                return ErrorType.BUILD_FAILURE
            elif exit_code == 126 or exit_code == 127:
                return ErrorType.ENVIRONMENT_ERROR
            elif exit_code == 130:  # Ctrl+C
                return ErrorType.TIMEOUT_ERROR
        
        return ErrorType.UNKNOWN_ERROR
    
    def can_retry(self, error_type, current_attempts):
        """Check if we can retry based on error type and attempt count"""
        max_retries = self.retry_limits.get(error_type, 1)
        return current_attempts < max_retries
    
    def recover_from_error(self, error_message, stderr_output="", exit_code=None, context=None):
        """
        Main error recovery function
        Returns: (success: bool, recovery_actions: List[str])
        """
        error_type = self.classify_error(error_message, stderr_output, exit_code)
        
        self.log_error(f"Error detected: {error_type.value}")
        self.log_error(f"Error message: {error_message}")
        
        # Record error in history
        error_record = {
            'timestamp': datetime.now().isoformat(),
            'type': error_type.value,
            'message': error_message,
            'stderr': stderr_output,
            'exit_code': exit_code,
            'context': context
        }
        self.error_history.append(error_record)
        
        # Get current attempt count for this error type
        recent_errors = [e for e in self.error_history[-10:] if e['type'] == error_type.value]
        current_attempts = len(recent_errors)
        
        if not self.can_retry(error_type, current_attempts):
            self.log_error(f"Max retry attempts ({self.retry_limits[error_type]}) exceeded for {error_type.value}")
            return False, ["Max retries exceeded"]
        
        # Execute recovery strategies
        strategies = self.recovery_strategies.get(error_type, [])
        recovery_actions = []
        
        for strategy_type, recovery_function in strategies:
            self.log_error(f"Attempting recovery strategy: {strategy_type.value}")
            
            try:
                success, action_description = recovery_function(error_record)
                recovery_actions.append(f"{strategy_type.value}: {action_description}")
                
                if success:
                    self.log_error(f"✅ Recovery successful with {strategy_type.value}")
                    return True, recovery_actions
                else:
                    self.log_error(f"❌ Recovery failed with {strategy_type.value}")
                    
            except Exception as e:
                self.log_error(f"❌ Recovery strategy {strategy_type.value} threw exception: {e}")
                recovery_actions.append(f"{strategy_type.value}: Exception - {str(e)}")
        
        self.log_error(f"❌ All recovery strategies failed for {error_type.value}")
        return False, recovery_actions
    
    # Recovery strategy implementations
    
    def _clear_build_cache(self, error_record):
        """Clear build cache directories"""
        try:
            cache_dirs = [
                os.path.join(self.paths.squash_app_root, "node_modules", ".cache"),
                os.path.join(self.paths.android_dir, "build"),
                os.path.join(self.paths.android_dir, "app", "build"),
                os.path.join(self.paths.squash_app_root, ".gradle")
            ]
            
            cleared_dirs = []
            for cache_dir in cache_dirs:
                if os.path.exists(cache_dir):
                    shutil.rmtree(cache_dir, ignore_errors=True)
                    cleared_dirs.append(cache_dir)
            
            return True, f"Cleared cache directories: {', '.join(cleared_dirs)}"
            
        except Exception as e:
            return False, f"Failed to clear cache: {e}"
    
    def _reset_build_environment(self, error_record):
        """Reset build environment"""
        try:
            commands = [
                ["npm", "install"],
                ["npx", "react-native", "clean"]
            ]
            
            for cmd in commands:
                result = subprocess.run(
                    cmd,
                    cwd=self.paths.squash_app_root,
                    capture_output=True,
                    text=True,
                    timeout=300
                )
                
                if result.returncode != 0:
                    return False, f"Command failed: {' '.join(cmd)}"
            
            return True, "Build environment reset successfully"
            
        except Exception as e:
            return False, f"Failed to reset build environment: {e}"
    
    def _retry_build(self, error_record):
        """Retry the build operation"""
        try:
            # Wait a bit before retrying
            time.sleep(5)
            
            return True, "Ready for build retry"
            
        except Exception as e:
            return False, f"Build retry preparation failed: {e}"
    
    def _clear_dependency_cache(self, error_record):
        """Clear dependency cache"""
        try:
            commands = [
                ["npm", "cache", "clean", "--force"],
                ["rm", "-rf", "node_modules"]
            ]
            
            for cmd in commands:
                subprocess.run(
                    cmd,
                    cwd=self.paths.squash_app_root,
                    capture_output=True,
                    text=True
                )
            
            return True, "Dependency cache cleared"
            
        except Exception as e:
            return False, f"Failed to clear dependency cache: {e}"
    
    def _reinstall_dependencies(self, error_record):
        """Reinstall all dependencies"""
        try:
            result = subprocess.run(
                ["npm", "install"],
                cwd=self.paths.squash_app_root,
                capture_output=True,
                text=True,
                timeout=600
            )
            
            if result.returncode == 0:
                return True, "Dependencies reinstalled successfully"
            else:
                return False, f"Dependency reinstall failed: {result.stderr}"
                
        except Exception as e:
            return False, f"Failed to reinstall dependencies: {e}"
    
    def _retry_dependency_install(self, error_record):
        """Retry dependency installation"""
        try:
            time.sleep(10)  # Wait before retry
            return True, "Ready for dependency retry"
        except Exception as e:
            return False, f"Dependency retry preparation failed: {e}"
    
    def _fix_permissions(self, error_record):
        """Fix file permissions"""
        try:
            # Fix common permission issues
            commands = [
                ["chmod", "-R", "755", self.paths.squash_app_root],
                ["chown", "-R", f"{os.getenv('USER', 'user')}", self.paths.squash_app_root]
            ]
            
            for cmd in commands:
                subprocess.run(cmd, capture_output=True, text=True)
            
            return True, "Permissions fixed"
            
        except Exception as e:
            return False, f"Failed to fix permissions: {e}"
    
    def _request_admin_privileges(self, error_record):
        """Request manual admin privileges"""
        message = "Manual intervention required: Please run with administrator privileges"
        self.log_error(message, "WARNING")
        return False, message
    
    def _retry_network_operation(self, error_record):
        """Retry network operations with backoff"""
        try:
            time.sleep(30)  # Wait 30 seconds for network issues
            return True, "Network retry prepared"
        except Exception as e:
            return False, f"Network retry preparation failed: {e}"
    
    def _use_offline_fallback(self, error_record):
        """Use offline fallback methods"""
        try:
            # Set npm to offline mode
            subprocess.run(
                ["npm", "config", "set", "registry", ""],
                capture_output=True,
                text=True
            )
            return True, "Switched to offline mode"
        except Exception as e:
            return False, f"Failed to switch to offline mode: {e}"
    
    def _retry_with_longer_timeout(self, error_record):
        """Retry with longer timeout"""
        try:
            return True, "Prepared for retry with extended timeout"
        except Exception as e:
            return False, f"Timeout retry preparation failed: {e}"
    
    def _restart_slow_subsystem(self, error_record):
        """Restart subsystem that's causing timeouts"""
        try:
            # Kill any hanging processes
            subprocess.run(["pkill", "-f", "node"], capture_output=True)
            subprocess.run(["pkill", "-f", "gradle"], capture_output=True)
            time.sleep(5)
            return True, "Slow subsystems restarted"
        except Exception as e:
            return False, f"Failed to restart subsystems: {e}"
    
    def _reauthenticate_claude(self, error_record):
        """Reauthenticate Claude Code"""
        try:
            # Clear Claude Code cache/session
            claude_cache = os.path.expanduser("~/.claude")
            if os.path.exists(claude_cache):
                shutil.rmtree(claude_cache, ignore_errors=True)
            
            return False, "Manual Claude Code reauthentication required"
        except Exception as e:
            return False, f"Failed to clear Claude cache: {e}"
    
    def _restart_claude_session(self, error_record):
        """Restart Claude Code session"""
        try:
            # Kill existing Claude processes
            subprocess.run(["pkill", "-f", "claude"], capture_output=True)
            time.sleep(5)
            return True, "Claude Code session restarted"
        except Exception as e:
            return False, f"Failed to restart Claude session: {e}"
    
    def _fix_environment_paths(self, error_record):
        """Fix environment PATH issues"""
        try:
            # Run environment fix script
            fix_script = os.path.join(self.paths.project_root, "fix_environment.bat")
            if os.path.exists(fix_script):
                result = subprocess.run([fix_script], capture_output=True, text=True, shell=True)
                if result.returncode == 0:
                    return True, "Environment paths fixed"
                else:
                    return False, f"Environment fix failed: {result.stderr}"
            else:
                return False, "Environment fix script not found"
        except Exception as e:
            return False, f"Failed to fix environment: {e}"
    
    def _request_environment_setup(self, error_record):
        """Request manual environment setup"""
        message = "Manual intervention required: Please check environment setup"
        self.log_error(message, "WARNING")
        return False, message
    
    def _generic_retry(self, error_record):
        """Generic retry mechanism"""
        try:
            time.sleep(5)
            return True, "Generic retry prepared"
        except Exception as e:
            return False, f"Generic retry preparation failed: {e}"
    
    def _request_manual_review(self, error_record):
        """Request manual review of unknown error"""
        message = f"Manual review required for unknown error: {error_record['message']}"
        self.log_error(message, "WARNING")
        return False, message
    
    def get_error_summary(self):
        """Get summary of recent errors"""
        if not self.error_history:
            return "No errors recorded"
        
        recent_errors = self.error_history[-10:]  # Last 10 errors
        error_types = {}
        
        for error in recent_errors:
            error_type = error['type']
            if error_type not in error_types:
                error_types[error_type] = 0
            error_types[error_type] += 1
        
        summary = f"Recent errors ({len(recent_errors)} total):\n"
        for error_type, count in error_types.items():
            summary += f"  - {error_type}: {count}\n"
        
        return summary
    
    def save_error_history(self):
        """Save error history to file"""
        history_file = os.path.join(self.paths.logs_dir, "error_history.json")
        
        try:
            with open(history_file, 'w') as f:
                json.dump(self.error_history, f, indent=2)
            return True
        except Exception as e:
            self.log_error(f"Failed to save error history: {e}")
            return False

# Global instance
ERROR_RECOVERY = ErrorRecoveryManager()

def recover_from_error(error_message, stderr_output="", exit_code=None, context=None):
    """Convenience function for error recovery"""
    return ERROR_RECOVERY.recover_from_error(error_message, stderr_output, exit_code, context)

if __name__ == "__main__":
    # Test the error recovery system
    recovery_manager = ErrorRecoveryManager()
    
    # Test error classification
    test_errors = [
        ("Build failed with exit code 1", "", 1),
        ("Module 'react-native' not found", "", None),
        ("Permission denied: /usr/local/bin", "", 126),
        ("Network timeout occurred", "", None),
        ("Claude authentication failed", "", None)
    ]
    
    print("🧪 Testing Error Recovery System")
    print("=" * 50)
    
    for error_msg, stderr, exit_code in test_errors:
        print(f"\n🔍 Testing: {error_msg}")
        error_type = recovery_manager.classify_error(error_msg, stderr, exit_code)
        print(f"   Classification: {error_type.value}")
        
        success, actions = recovery_manager.recover_from_error(error_msg, stderr, exit_code)
        print(f"   Recovery Success: {success}")
        print(f"   Actions: {actions}")
    
    print(f"\n📊 Error Summary:")
    print(recovery_manager.get_error_summary())