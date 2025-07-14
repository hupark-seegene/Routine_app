#!/usr/bin/env python3
"""
Claude Code 초기 설정 스크립트
Claude Code 설치 및 인증 상태를 확인하고 환경을 준비합니다.
"""

import subprocess
import os
import sys
import platform
import json
from pathlib import Path

class ClaudeSetup:
    def __init__(self):
        self.is_windows = platform.system() == "Windows"
        self.project_root = os.getcwd()
        
    def check_node_npm(self):
        """Node.js와 npm 설치 확인"""
        print("📦 Node.js 및 npm 확인 중...")
        
        try:
            # Node.js 버전 확인
            node_result = subprocess.run(
                ["node", "--version"],
                capture_output=True,
                text=True,
                shell=self.is_windows
            )
            
            if node_result.returncode == 0:
                print(f"✅ Node.js 설치됨: {node_result.stdout.strip()}")
            else:
                raise Exception("Node.js not found")
                
            # npm 버전 확인
            npm_result = subprocess.run(
                ["npm", "--version"],
                capture_output=True,
                text=True,
                shell=self.is_windows
            )
            
            if npm_result.returncode == 0:
                print(f"✅ npm 설치됨: v{npm_result.stdout.strip()}")
                return True
            else:
                raise Exception("npm not found")
                
        except Exception as e:
            print("❌ Node.js 또는 npm이 설치되지 않았습니다.")
            print("다음 링크에서 Node.js를 설치하세요: https://nodejs.org/")
            return False
    
    def check_claude_installation(self):
        """Claude Code 설치 확인"""
        print("\n🔍 Claude Code 설치 확인 중...")
        
        try:
            result = subprocess.run(
                ["claude", "--version"],
                capture_output=True,
                text=True,
                shell=self.is_windows
            )
            
            if result.returncode == 0:
                print(f"✅ Claude Code 이미 설치됨")
                return True
            else:
                return False
                
        except Exception:
            return False
    
    def install_claude_code(self):
        """Claude Code 설치"""
        print("\n📥 Claude Code 설치 중...")
        
        try:
            # npm을 통한 Claude Code 설치
            install_cmd = ["npm", "install", "-g", "@anthropic-ai/claude-code"]
            
            process = subprocess.Popen(
                install_cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                shell=self.is_windows
            )
            
            # 실시간 출력
            while True:
                output = process.stdout.readline()
                if output == '' and process.poll() is not None:
                    break
                if output:
                    print(output.strip())
            
            if process.returncode == 0:
                print("✅ Claude Code 설치 완료!")
                return True
            else:
                print("❌ Claude Code 설치 실패")
                return False
                
        except Exception as e:
            print(f"❌ 설치 중 오류 발생: {e}")
            return False
    
    def check_authentication(self):
        """Claude Code 인증 상태 확인"""
        print("\n🔐 Claude Code 인증 확인 중...")
        
        try:
            # 간단한 명령으로 인증 확인
            auth_check = subprocess.run(
                ["claude", "-p", "echo test", "--output-format", "json"],
                capture_output=True,
                text=True,
                shell=self.is_windows,
                timeout=10
            )
            
            if auth_check.returncode == 0:
                print("✅ Claude Code 인증 완료!")
                return True
            else:
                return False
                
        except subprocess.TimeoutExpired:
            print("⏱️ 인증 확인 시간 초과")
            return False
        except Exception as e:
            print(f"❌ 인증 확인 실패: {e}")
            return False
    
    def guide_authentication(self):
        """인증 가이드 제공"""
        print("\n📋 Claude Code 인증이 필요합니다!")
        print("\n다음 단계를 따라주세요:")
        print("1. 새 터미널/PowerShell을 열어주세요")
        print("2. 다음 명령을 실행하세요: claude")
        print("3. 브라우저가 열리면 Anthropic 계정으로 로그인")
        print("4. Claude Code Max 요금제 구독 확인")
        print("5. 인증 완료 후 이 스크립트를 다시 실행")
        print("\n⚠️  주의: Max 요금제가 필요합니다!")
    
    def test_models(self):
        """사용 가능한 모델 테스트"""
        print("\n🤖 사용 가능한 모델 확인 중...")
        
        models = {
            "opus": "Claude Opus 4",
            "sonnet": "Claude Sonnet 4",
            "haiku": "Claude Haiku"
        }
        
        available_models = []
        
        for model_id, model_name in models.items():
            print(f"\n테스트: {model_name} ({model_id})")
            
            try:
                test_cmd = [
                    "claude", "-p", "Say 'OK' if you can read this",
                    "--model", model_id,
                    "--output-format", "text"
                ]
                
                result = subprocess.run(
                    test_cmd,
                    capture_output=True,
                    text=True,
                    shell=self.is_windows,
                    timeout=30
                )
                
                if result.returncode == 0 and "OK" in result.stdout:
                    print(f"  ✅ {model_name} 사용 가능")
                    available_models.append(model_id)
                else:
                    print(f"  ❌ {model_name} 사용 불가")
                    
            except subprocess.TimeoutExpired:
                print(f"  ⏱️ {model_name} 시간 초과")
            except Exception as e:
                print(f"  ❌ {model_name} 테스트 실패: {e}")
        
        return available_models
    
    def create_env_file(self):
        """환경 설정 파일 생성"""
        print("\n📝 환경 설정 파일 생성 중...")
        
        env_content = """# Claude Code 설정 (API 키 불필요)
CLAUDE_DEFAULT_MODEL=opus
CLAUDE_WORKER_MODEL=sonnet

# 프로젝트 설정
PROJECT_ROOT=C:\\Git\\Routine_app
MAX_WORKERS=3

# 자동화 설정
AUTO_APPROVE=true
SKIP_CONFIRMATIONS=true

# Tmux 자동화 설정
TMUX_SESSION_NAME=squash-automation
TMUX_AUTO_RESPOND=true
"""
        
        env_path = os.path.join(self.project_root, ".env")
        
        if os.path.exists(env_path):
            print("⚠️  .env 파일이 이미 존재합니다.")
            response = input("덮어쓰시겠습니까? (y/N): ")
            if response.lower() != 'y':
                print("기존 파일 유지")
                return
        
        with open(env_path, "w", encoding="utf-8") as f:
            f.write(env_content)
        
        print(f"✅ .env 파일 생성 완료: {env_path}")
    
    def create_requirements_file(self):
        """Python 의존성 파일 생성"""
        print("\n📋 requirements.txt 생성 중...")
        
        requirements = """# Python dependencies for orchestrator
pyautogui>=0.9.54
pygetwindow>=0.0.9
python-dotenv>=1.0.0
"""
        
        req_path = os.path.join(self.project_root, "requirements.txt")
        
        with open(req_path, "w") as f:
            f.write(requirements)
        
        print(f"✅ requirements.txt 생성 완료")
        
        # 의존성 설치 안내
        print("\nPython 의존성 설치:")
        print("  pip install -r requirements.txt")
    
    def setup_summary(self, available_models):
        """설정 요약"""
        print("\n" + "="*60)
        print("🎉 Claude Code 설정 완료!")
        print("="*60)
        
        print("\n✅ 완료된 항목:")
        print("  - Node.js 및 npm 확인")
        print("  - Claude Code 설치")
        print("  - 인증 상태 확인")
        print("  - 환경 설정 파일 생성")
        print("  - Python 의존성 파일 생성")
        
        if available_models:
            print(f"\n🤖 사용 가능한 모델: {', '.join(available_models)}")
        
        print("\n📌 다음 단계:")
        print("1. Python 의존성 설치: pip install -r requirements.txt")
        print("2. orchestrator.py 실행: python orchestrator.py")
        print("3. Tmux 자동화 시스템 사용: cd SquashTrainingApp/scripts/production/tmux-automation")
        
        print("\n💡 팁:")
        print("- 여러 터미널을 열어 동시에 여러 작업 실행 가능")
        print("- auto_responder.py로 자동 응답 시스템 활성화")
        print("- tmux 세션으로 백그라운드 실행 가능")

def main():
    print("🚀 Claude Code 설정 시작\n")
    
    setup = ClaudeSetup()
    
    # 1. Node.js/npm 확인
    if not setup.check_node_npm():
        print("\n❌ Node.js를 먼저 설치해주세요.")
        return
    
    # 2. Claude Code 설치 확인
    if not setup.check_claude_installation():
        if not setup.install_claude_code():
            print("\n❌ Claude Code 설치에 실패했습니다.")
            return
    
    # 3. 인증 확인
    if not setup.check_authentication():
        setup.guide_authentication()
        return
    
    # 4. 모델 테스트
    available_models = setup.test_models()
    
    # 5. 환경 파일 생성
    setup.create_env_file()
    setup.create_requirements_file()
    
    # 6. 설정 요약
    setup.setup_summary(available_models)

if __name__ == "__main__":
    main()