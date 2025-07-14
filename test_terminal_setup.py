#!/usr/bin/env python3
"""
PyCharm 터미널 자동화 테스트 스크립트
시스템이 제대로 설정되었는지 확인
"""

import sys
import subprocess
import os
import time

def check_requirements():
    """필수 패키지 확인"""
    print("🔍 필수 패키지 확인 중...")
    
    required_packages = {
        'pyautogui': 'GUI 자동화',
        'pygetwindow': '윈도우 관리',
        'pywin32': 'Windows API',
        'psutil': '프로세스 관리',
        'python-dotenv': '환경 변수'
    }
    
    missing = []
    
    for package, description in required_packages.items():
        try:
            __import__(package.replace('-', '_'))
            print(f"  ✅ {package} ({description})")
        except ImportError:
            print(f"  ❌ {package} ({description})")
            missing.append(package)
    
    if missing:
        print(f"\n⚠️  누락된 패키지: {', '.join(missing)}")
        print("설치 명령: pip install " + " ".join(missing))
        return False
    
    return True

def check_claude_code():
    """Claude Code 설치 확인"""
    print("\n🔍 Claude Code 확인 중...")
    
    try:
        result = subprocess.run(
            ["claude", "--version"],
            capture_output=True,
            text=True,
            shell=True
        )
        
        if result.returncode == 0:
            print("  ✅ Claude Code 설치됨")
            
            # 인증 확인
            auth_check = subprocess.run(
                ["claude", "-p", "echo OK", "--output-format", "text"],
                capture_output=True,
                text=True,
                shell=True,
                timeout=5
            )
            
            if auth_check.returncode == 0 and "OK" in auth_check.stdout:
                print("  ✅ Claude Code 인증 완료")
                return True
            else:
                print("  ❌ Claude Code 인증 필요")
                print("     터미널에서 'claude' 실행하여 로그인하세요")
                return False
        else:
            print("  ❌ Claude Code 미설치")
            print("     설치: npm install -g @anthropic-ai/claude-code")
            return False
            
    except Exception as e:
        print(f"  ❌ 오류: {e}")
        return False

def check_git_worktrees():
    """Git worktree 상태 확인"""
    print("\n🔍 Git worktree 확인 중...")
    
    project_root = r"C:\Git\Routine_app"
    
    # Git 저장소 확인
    if not os.path.exists(os.path.join(project_root, ".git")):
        print("  ❌ Git 저장소가 아닙니다")
        return False
    
    # Worktree 목록 확인
    result = subprocess.run(
        ["git", "worktree", "list"],
        cwd=project_root,
        capture_output=True,
        text=True
    )
    
    if result.returncode == 0:
        print("  현재 worktree:")
        for line in result.stdout.strip().split('\n'):
            print(f"    {line}")
        
        # 필요한 worktree 확인
        required_worktrees = ['worker-1', 'worker-2', 'worker-3']
        missing = []
        
        for wt in required_worktrees:
            if wt not in result.stdout:
                missing.append(wt)
        
        if missing:
            print(f"\n  ⚠️  누락된 worktree: {', '.join(missing)}")
            print("     pycharm_terminal_controller.py 실행 시 자동 생성됩니다")
        else:
            print("\n  ✅ 모든 worktree 준비됨")
        
        return True
    else:
        print("  ❌ Git worktree 확인 실패")
        return False

def check_pycharm_running():
    """PyCharm 실행 확인"""
    print("\n🔍 PyCharm 실행 상태 확인 중...")
    
    try:
        import psutil
        
        for proc in psutil.process_iter(['name', 'cmdline']):
            if 'pycharm' in proc.info['name'].lower():
                print("  ✅ PyCharm 실행 중")
                
                # Routine_app 프로젝트 확인
                cmdline = proc.info.get('cmdline', [])
                if any('Routine_app' in str(cmd) for cmd in cmdline):
                    print("  ✅ Routine_app 프로젝트 열림")
                else:
                    print("  ⚠️  Routine_app 프로젝트를 열어주세요")
                
                return True
        
        print("  ❌ PyCharm이 실행되지 않았습니다")
        print("     PyCharm에서 Routine_app 프로젝트를 열어주세요")
        return False
        
    except Exception as e:
        print(f"  ⚠️  확인 실패: {e}")
        return False

def test_pyautogui():
    """PyAutoGUI 작동 테스트"""
    print("\n🔍 PyAutoGUI 테스트...")
    
    try:
        import pyautogui
        
        # 안전 모드 설정
        pyautogui.FAILSAFE = True
        
        # 화면 크기 확인
        width, height = pyautogui.size()
        print(f"  ✅ 화면 크기: {width}x{height}")
        
        # 현재 마우스 위치
        x, y = pyautogui.position()
        print(f"  ✅ 마우스 위치: ({x}, {y})")
        
        print("  ✅ PyAutoGUI 정상 작동")
        return True
        
    except Exception as e:
        print(f"  ❌ PyAutoGUI 오류: {e}")
        return False

def main():
    print("="*60)
    print("PyCharm 터미널 자동화 시스템 테스트")
    print("="*60)
    
    all_good = True
    
    # 1. 필수 패키지 확인
    if not check_requirements():
        all_good = False
    
    # 2. Claude Code 확인
    if not check_claude_code():
        all_good = False
    
    # 3. Git worktree 확인
    if not check_git_worktrees():
        all_good = False
    
    # 4. PyCharm 실행 확인
    if not check_pycharm_running():
        all_good = False
    
    # 5. PyAutoGUI 테스트
    if not test_pyautogui():
        all_good = False
    
    print("\n" + "="*60)
    
    if all_good:
        print("✅ 모든 테스트 통과! 시스템을 사용할 준비가 되었습니다.")
        print("\n다음 명령으로 실행하세요:")
        print("  python pycharm_terminal_controller.py")
    else:
        print("❌ 일부 테스트 실패. 위의 문제를 해결하고 다시 시도하세요.")
    
    print("="*60)

if __name__ == "__main__":
    main()