#!/usr/bin/env python3
"""
자동 응답 시스템 - Claude Code 세션에 자동으로 응답
"""
import subprocess
import time
import re
import signal
import sys
from datetime import datetime

class AutoResponder:
    def __init__(self):
        self.session_name = "claude-multi-agent"
        self.workers = ['worker1', 'worker2', 'worker3']
        self.response_patterns = {
            'continue': ['continue', 'proceed', '계속', '진행'],
            'confirm': ['yes', 'y', 'confirm', '확인', '네'],
            'next': ['next', 'next step', '다음'],
            'build': ['build', 'compile', '빌드'],
            'test': ['test', 'testing', '테스트'],
            'commit': ['commit', 'save', '저장', '커밋']
        }
        self.running = True
        
    def send_to_tmux(self, window, command):
        """tmux 세션에 명령어 전송"""
        try:
            cmd = ['tmux', 'send-keys', '-t', f'{self.session_name}:{window}', command, 'Enter']
            subprocess.run(cmd, check=True)
            return True
        except Exception as e:
            print(f"❌ {window} 명령 전송 실패: {e}")
            return False
    
    def get_tmux_output(self, window, lines=10):
        """tmux 세션의 출력 가져오기"""
        try:
            cmd = ['tmux', 'capture-pane', '-t', f'{self.session_name}:{window}', '-p', '-S', f'-{lines}']
            result = subprocess.run(cmd, capture_output=True, text=True)
            return result.stdout if result.returncode == 0 else ""
        except Exception as e:
            print(f"❌ {window} 출력 가져오기 실패: {e}")
            return ""
    
    def analyze_output(self, output):
        """출력 분석하여 응답 필요성 판단"""
        if not output.strip():
            return None
            
        # 대기 중인 프롬프트 패턴 (확장된 목록)
        waiting_patterns = [
            r'>\s*$',  # 기본 프롬프트
            r'\$\s*$',  # 쉘 프롬프트
            r'Continue\?',  # 계속 확인
            r'Proceed\?',  # 진행 확인
            r'\[y/n\]',  # 예/아니오
            r'\[Y/n\]',  # 예/아니오 (대문자)
            r'\(y/n\)',  # 예/아니오 (괄호)
            r'\(Y/n\)',  # 예/아니오 (괄호, 대문자)
            r'Press any key',  # 키 입력 대기
            r'Press Enter',  # Enter 키 대기
            r'계속하시겠습니까',  # 한국어 확인
            r'진행하시겠습니까',
            r'Do you want to',
            r'Would you like to',
            r'Are you sure',
            r'확인하시겠습니까',
            r'삭제하시겠습니까',
            r'저장하시겠습니까',
            r'claude>',  # Claude 프롬프트
            r'.*>$',  # 일반 프롬프트
            r'.*\?\s*$',  # 질문으로 끝나는 패턴
            r'1\.\s+Yes\s+2\.\s+Yes.*ask.*again',  # Claude Code 특정 프롬프트
            r'Please confirm',  # 확인 요청
            r'Type.*continue',  # 타이핑으로 계속
            r'Enter to continue',  # Enter로 계속
            r'Press.*to continue',  # 키 눌러서 계속
            r'Overwrite\?',  # 덮어쓰기 확인
            r'Replace\?',  # 교체 확인
            r'Delete\?',  # 삭제 확인
            r'Install\?',  # 설치 확인
            r'Update\?',  # 업데이트 확인
            r'Build\?',  # 빌드 확인
            r'Deploy\?',  # 배포 확인
            r'Commit\?',  # 커밋 확인
            r'Push\?',  # 푸시 확인
            r'Merge\?',  # 병합 확인
            r'Ready\?\s*$',  # 준비됨 확인
            r'OK\?\s*$',  # OK 확인
            r'Sure\?\s*$',  # 확실함 확인
            r'.*pause.*',  # pause 명령
            r'Hit.*key.*',  # 키 입력 요청
        ]
        
        for pattern in waiting_patterns:
            if re.search(pattern, output, re.IGNORECASE | re.MULTILINE):
                return 'waiting_for_input'
        
        # 오류 패턴
        error_patterns = [
            r'error:',
            r'Error:',
            r'ERROR:',
            r'failed',
            r'Failed',
            r'오류',
            r'실패'
        ]
        
        for pattern in error_patterns:
            if re.search(pattern, output, re.IGNORECASE):
                return 'error_detected'
        
        # 완료 패턴
        complete_patterns = [
            r'완료',
            r'finished',
            r'completed',
            r'done',
            r'success'
        ]
        
        for pattern in complete_patterns:
            if re.search(pattern, output, re.IGNORECASE):
                return 'task_completed'
        
        return None
    
    def detect_prompt_type(self, output):
        """프롬프트 유형을 세분화하여 감지"""
        output_lower = output.lower()
        
        # Claude Code 특정 프롬프트
        if re.search(r'1\.\s+Yes\s+2\.\s+Yes.*ask.*again', output, re.IGNORECASE):
            return 'claude_confirmation'
        
        # 예/아니오 질문
        if re.search(r'\[?[yY]/[nN]\]?|\([yY]/[nN]\)', output):
            return 'yes_no_question'
        
        # 확인 질문들
        if any(word in output_lower for word in ['continue', 'proceed', 'confirm', 'sure', 'ready']):
            return 'confirmation_question'
        
        # 키 입력 대기
        if any(phrase in output_lower for phrase in ['press', 'hit', 'enter', 'key']):
            return 'key_press_wait'
        
        # 설치/업데이트/빌드 관련
        if any(word in output_lower for word in ['install', 'update', 'build', 'deploy', 'commit', 'push']):
            return 'action_confirmation'
        
        # 파일 작업 관련
        if any(word in output_lower for word in ['overwrite', 'replace', 'delete', 'save']):
            return 'file_operation'
        
        # 일반 프롬프트
        if re.search(r'>\s*$|\$\s*$|.*\?\s*$', output):
            return 'general_prompt'
        
        return 'unknown'

    def get_appropriate_response(self, status, window, output=""):
        """상황에 맞는 응답 생성 (개선된 버전)"""
        if status == 'waiting_for_input':
            prompt_type = self.detect_prompt_type(output)
            
            if prompt_type == 'claude_confirmation':
                return "2"  # "Yes, and don't ask again"
            elif prompt_type == 'yes_no_question':
                return "Y"
            elif prompt_type == 'confirmation_question':
                return "네, 계속 진행해주세요."
            elif prompt_type == 'key_press_wait':
                return ""  # Just press Enter
            elif prompt_type == 'action_confirmation':
                return "Y"
            elif prompt_type == 'file_operation':
                return "Y"
            elif prompt_type == 'general_prompt':
                responses = [
                    "네, 계속 진행해주세요.",
                    "계속해서 다음 단계로 진행해주세요.",
                    "좋습니다. 계속 개발해주세요.",
                    "네, 진행하겠습니다.",
                    "계속해서 작업해주세요."
                ]
                return responses[hash(window) % len(responses)]
            else:
                return "Y"  # Default to yes for unknown prompts
        
        elif status == 'error_detected':
            return "오류를 분석하고 해결책을 제시해주세요. 그 후 계속 진행해주세요."
        
        elif status == 'task_completed':
            if 'worker1' in window:
                return "SquashTrainingApp 백엔드 최적화를 계속 진행해주세요. /mnt/c/Git/Routine_app/SquashTrainingApp 디렉토리에서 작업해주세요."
            elif 'worker2' in window:
                return "SquashTrainingApp UI/UX 개선을 계속 진행해주세요. /mnt/c/Git/Routine_app/SquashTrainingApp 디렉토리에서 작업해주세요."
            elif 'worker3' in window:
                return "SquashTrainingApp 테스트 자동화를 계속 진행해주세요. /mnt/c/Git/Routine_app/SquashTrainingApp 디렉토리에서 작업해주세요."
        
        return "SquashTrainingApp 개발을 계속 진행해주세요. 프로젝트 루트: /mnt/c/Git/Routine_app/SquashTrainingApp"
    
    def monitor_and_respond(self):
        """지속적으로 모니터링하고 자동 응답"""
        print(f"🤖 자동 응답 시스템 시작 - {datetime.now().strftime('%H:%M:%S')}")
        print("=" * 60)
        
        cycle_count = 0
        
        while self.running:
            cycle_count += 1
            print(f"\n🔄 Cycle {cycle_count} - {datetime.now().strftime('%H:%M:%S')}")
            
            for worker in self.workers:
                try:
                    # 최근 출력 가져오기
                    output = self.get_tmux_output(worker, 20)
                    
                    if output:
                        # 출력 분석
                        status = self.analyze_output(output)
                        
                        if status:
                            print(f"   📋 {worker}: {status}")
                            
                            # 적절한 응답 생성 (출력 내용도 전달)
                            response = self.get_appropriate_response(status, worker, output)
                            
                            # 응답 전송
                            if self.send_to_tmux(worker, response):
                                print(f"   ✅ {worker} 응답 전송: {response[:50]}...")
                            else:
                                print(f"   ❌ {worker} 응답 전송 실패")
                        else:
                            print(f"   ⏳ {worker}: 작업 진행 중...")
                    else:
                        print(f"   ❓ {worker}: 출력 없음")
                        
                except Exception as e:
                    print(f"   ⚠️ {worker} 처리 오류: {e}")
                
                time.sleep(2)  # Worker 간 딜레이
            
            # 주기적으로 작업 지시 전송
            if cycle_count % 10 == 0:  # 10 사이클마다
                print(f"\n🎯 주기적 작업 지시 전송 (Cycle {cycle_count})")
                for worker in self.workers:
                    if 'worker1' in worker:
                        cmd = "SquashTrainingApp 백엔드 API의 다음 최적화 작업을 계속 진행해주세요."
                    elif 'worker2' in worker:
                        cmd = "SquashTrainingApp UI/UX의 다음 개선 작업을 계속 진행해주세요."
                    elif 'worker3' in worker:
                        cmd = "SquashTrainingApp 테스트 자동화의 다음 작업을 계속 진행해주세요."
                    
                    self.send_to_tmux(worker, cmd)
                    print(f"   📤 {worker}: 작업 지시 전송")
            
            time.sleep(30)  # 30초마다 체크
    
    def signal_handler(self, signum, frame):
        """시그널 핸들러"""
        print(f"\n\n⏹️ 자동 응답 시스템 종료 중...")
        self.running = False
        sys.exit(0)

def main():
    responder = AutoResponder()
    
    # 시그널 핸들러 등록
    signal.signal(signal.SIGINT, responder.signal_handler)
    signal.signal(signal.SIGTERM, responder.signal_handler)
    
    try:
        responder.monitor_and_respond()
    except KeyboardInterrupt:
        print(f"\n\n⏹️ 자동 응답 시스템 종료")
    except Exception as e:
        print(f"\n❌ 시스템 오류: {e}")

if __name__ == "__main__":
    main()