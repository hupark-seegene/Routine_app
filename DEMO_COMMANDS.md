# 🎬 데모 명령어 모음

## 🚀 시스템 실행 후 바로 사용할 수 있는 명령어들

### 1. 프로젝트 분석 및 작업 분할

#### Lead-Opus4 터미널에서:
```bash
claude -p "SquashTrainingApp 프로젝트를 분석하고 성능 개선을 위한 3가지 작업으로 분할해주세요. 각 작업은 병렬로 수행 가능해야 합니다."
```

#### 예상 결과:
- 작업 1: API 응답 시간 최적화
- 작업 2: UI 컴포넌트 렌더링 개선
- 작업 3: 데이터베이스 쿼리 최적화

### 2. 자동화 시스템 테스트

#### Lead-Opus4 터미널에서:
```bash
claude -p "tmux 자동화 시스템을 50회 실행하여 빌드-테스트-디버그 사이클을 완전 자동화해주세요"
```

#### 예상 결과:
- 자동으로 Worker들이 tmux 세션 관리
- 빌드 실패 시 자동 수정 시도
- 테스트 결과 자동 분석

### 3. 코드 리팩토링

#### Worker1 터미널에서:
```bash
claude -p "SquashTrainingApp의 MainActivity.java를 분석하고 코드 품질을 개선해주세요. 특히 메모리 누수와 성능 문제를 해결해주세요."
```

#### Worker2 터미널에서:
```bash
claude -p "데이터베이스 관련 코드를 분석하고 SQL 쿼리 최적화를 수행해주세요. 인덱스 추가 및 N+1 문제 해결을 포함해주세요."
```

#### Worker3 터미널에서:
```bash
claude -p "UI 컴포넌트들의 렌더링 성능을 개선하고 사용자 경험을 향상시키는 작업을 수행해주세요."
```

### 4. 테스트 자동화

#### Lead-Opus4 터미널에서:
```bash
claude -p "현재 앱의 모든 기능에 대한 자동화된 테스트 스위트를 작성해주세요. 단위 테스트, 통합 테스트, UI 테스트를 포함해주세요."
```

### 5. 문서 자동 생성

#### Worker1 터미널에서:
```bash
claude -p "프로젝트의 모든 Java 클래스와 메소드에 대한 API 문서를 자동 생성해주세요. Javadoc 형식으로 작성해주세요."
```

## 🔄 자동 응답 시스템 테스트

### 프롬프트 응답 확인
시스템이 다음과 같은 프롬프트를 자동으로 처리하는지 확인:

1. **권한 확인**
```
1. Yes  2. Yes, and don't ask again  3. No, and tell Claude what to do differently
```
→ 자동으로 "2" 응답

2. **계속 진행**
```
Do you want to continue? (Y/n)
```
→ 자동으로 "Y" 응답

3. **파일 수정**
```
Are you sure you want to modify this file? (Y/n)
```
→ 자동으로 "Y" 응답

## 🎯 실제 사용 시나리오

### 시나리오 1: 버그 수정 병렬 작업
```bash
# Lead-Opus4에서 버그 분석
claude -p "현재 앱에서 발견된 버그 리스트를 분석하고 우선순위에 따라 3개 그룹으로 분류해주세요"

# 각 Worker에서 병렬 수정
# Worker1: 크리티컬 버그 수정
# Worker2: 중간 우선순위 버그 수정  
# Worker3: 마이너 버그 수정
```

### 시나리오 2: 기능 개발 파이프라인
```bash
# Lead-Opus4에서 기능 설계
claude -p "사용자 인증 시스템을 설계하고 구현 단계를 3개로 나누어 주세요"

# Worker1: 백엔드 API 개발
# Worker2: 프론트엔드 UI 개발
# Worker3: 테스트 및 검증
```

### 시나리오 3: 성능 최적화
```bash
# Lead-Opus4에서 성능 분석
claude -p "앱의 성능 병목 지점을 분석하고 최적화 방안을 제시해주세요"

# Worker1: 메모리 사용량 최적화
# Worker2: CPU 사용량 최적화
# Worker3: 네트워크 요청 최적화
```

## 📊 모니터링 명령어

### TmuxMonitor 터미널에서:
```bash
# 빌드 상태 확인
tmux capture-pane -t squash-automation:build -p

# 테스트 결과 확인
tmux capture-pane -t squash-automation:test -p

# 전체 세션 상태
tmux list-sessions
```

### AutoResponder 터미널에서:
```bash
# 응답 통계 확인
python auto_responder.py monitor --stats

# 특정 패턴 모니터링
python auto_responder.py monitor --pattern "rate limit"
```

## 🔧 디버깅 명령어

### 시스템 상태 확인:
```bash
# 모든 터미널 상태 확인
python -c "
import psutil
for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
    if 'claude' in str(proc.info.get('cmdline', [])).lower():
        print(f'PID: {proc.info[\"pid\"]}, Name: {proc.info[\"name\"]}')
"
```

### 로그 실시간 확인:
```bash
# 빌드 로그 실시간 확인
Get-Content -Path "logs\build-logs\*.log" -Wait

# 테스트 로그 확인
Get-Content -Path "logs\test-logs\*.log" -Wait
```

## 🎉 성공 확인 체크리스트

### ✅ 시스템 정상 작동 확인
1. 7개 터미널 모두 생성됨
2. 각 터미널에서 Claude Code 실행됨
3. 자동 응답 시스템 작동 중
4. Git worktree 설정됨

### ✅ 작업 진행 확인
1. Lead가 작업을 성공적으로 분할함
2. Worker들이 각각 다른 작업을 수행함
3. 자동 응답이 정상적으로 작동함
4. 결과가 각 worktree에 저장됨

### ✅ 자동화 확인
1. 프롬프트가 자동으로 응답됨
2. 빌드 실패 시 자동 재시도
3. 테스트 결과가 자동으로 분석됨
4. 모든 과정이 백그라운드에서 진행됨

이제 이 명령어들을 사용하여 완전 자동화된 개발 환경을 체험해보세요! 🚀