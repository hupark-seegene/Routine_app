#!/usr/bin/env python3
"""
간단한 자동화 시스템 상태 체크 (의존성 없이 실행 가능)
"""

import os
import json
import subprocess
from datetime import datetime
from PATHS import PATHS

def main():
    """자동화 시스템 상태를 체크하고 출력"""
    
    print("🎯 자동화 시스템 상태 체크")
    print("=" * 50)
    
    # 1. 환경 상태
    print("\n📋 환경 상태:")
    print(f"✅ 프로젝트 루트: {PATHS.project_root}")
    print(f"✅ SquashTrainingApp: {PATHS.squash_app_root}")
    print(f"✅ 로그 디렉토리: {PATHS.logs_dir}")
    
    # 2. 체크포인트 파일 확인
    print("\n📊 체크포인트 현황:")
    checkpoint_count = 0
    latest_checkpoint = None
    
    if os.path.exists(PATHS.logs_dir):
        for file in os.listdir(PATHS.logs_dir):
            if file.startswith('checkpoint_') and file.endswith('.json'):
                checkpoint_count += 1
                try:
                    cycle_num = int(file.replace('checkpoint_', '').replace('.json', ''))
                    if latest_checkpoint is None or cycle_num > latest_checkpoint:
                        latest_checkpoint = cycle_num
                except ValueError:
                    continue
    
    print(f"📋 총 체크포인트: {checkpoint_count}개")
    if latest_checkpoint:
        print(f"🏁 최신 체크포인트: Cycle {latest_checkpoint}")
        
        # 최신 체크포인트 내용 확인
        latest_file = os.path.join(PATHS.logs_dir, f"checkpoint_{latest_checkpoint}.json")
        try:
            with open(latest_file, 'r') as f:
                checkpoint_data = json.load(f)
            print(f"⏰ 마지막 실행: {checkpoint_data.get('timestamp', 'Unknown')}")
            if 'data' in checkpoint_data:
                success = checkpoint_data['data'].get('success', False)
                status_symbol = "✅" if success else "❌"
                print(f"📈 마지막 상태: {status_symbol}")
        except Exception as e:
            print(f"⚠️ 체크포인트 읽기 오류: {e}")
    else:
        print("📋 체크포인트 없음 - 아직 실행되지 않음")
    
    # 3. 로그 파일 확인
    print("\n📝 로그 파일 현황:")
    log_files = [
        'simple_automation.log',
        'master_controller.log',
        'auto_responder.log',
        'error_recovery.log'
    ]
    
    for log_file in log_files:
        log_path = os.path.join(PATHS.logs_dir, log_file)
        if os.path.exists(log_path):
            try:
                # 파일 크기
                size = os.path.getsize(log_path)
                size_kb = size / 1024
                
                # 줄 수
                with open(log_path, 'r', encoding='utf-8') as f:
                    lines = len(f.readlines())
                
                print(f"📄 {log_file}: {lines}줄, {size_kb:.1f}KB")
            except Exception as e:
                print(f"📄 {log_file}: 읽기 오류")
        else:
            print(f"📄 {log_file}: 없음")
    
    # 4. 실행 중인 프로세스 확인 (기본 명령어만 사용)
    print("\n🔧 실행 중인 프로세스:")
    try:
        # pgrep 사용 (WSL에서 사용 가능)
        result = subprocess.run(['pgrep', '-f', 'python.*automation'], 
                              capture_output=True, text=True)
        if result.returncode == 0 and result.stdout.strip():
            pids = result.stdout.strip().split('\n')
            print(f"🟢 자동화 프로세스: {len(pids)}개 실행 중")
            for pid in pids:
                if pid:
                    print(f"   PID: {pid}")
        else:
            print("🔴 자동화 프로세스: 실행 중이지 않음")
    except Exception:
        print("❓ 프로세스 상태: 확인 불가")
    
    # 5. 시스템 권장사항
    print("\n💡 권장 실행 명령어:")
    print("🚀 간단한 테스트:        python3 simple_automation.py --test")
    print("🎯 전체 50 사이클:       python3 simple_automation.py --cycles 50")
    print("📊 통합 테스트:          python3 integration_test.py")
    print("🔄 체크포인트에서 재시작: python3 simple_automation.py --resume")
    
    # 6. 최근 로그 출력
    if os.path.exists(os.path.join(PATHS.logs_dir, 'simple_automation.log')):
        print("\n📋 최근 로그 (마지막 5줄):")
        try:
            with open(os.path.join(PATHS.logs_dir, 'simple_automation.log'), 'r', encoding='utf-8') as f:
                lines = f.readlines()
                for line in lines[-5:]:
                    print(f"   {line.strip()}")
        except Exception:
            print("   로그 읽기 오류")
    
    print("\n" + "=" * 50)
    print("상태 체크 완료!")
    
if __name__ == "__main__":
    main()