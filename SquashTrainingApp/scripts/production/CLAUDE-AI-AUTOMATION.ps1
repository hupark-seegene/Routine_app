# CLAUDE-AI-AUTOMATION.ps1
# Claude AI 기반 WSL 멀티 터미널 자동화 시스템
# Opus는 계획, Sonnet은 코드 작성을 담당하는 분산 자동화 시스템

param(
    [int]$TargetIterations = 50,
    [string]$OpusModel = "claude-3-opus-20240229",
    [string]$SonnetModel = "claude-3-5-sonnet-20241022",
    [switch]$DebugMode = $false,
    [switch]$ContinueFromLastState = $false,
    [switch]$Setup,
    [switch]$Start,
    [switch]$Monitor,
    [switch]$Stop,
    [switch]$Status,
    [switch]$CleanStart,
    [string]$Task = "Complete SquashTrainingApp development and testing cycle"
)

$ErrorActionPreference = "Stop"

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item "$ScriptDir/../..").FullName
$SessionName = "claude-ai-automation"
$StateFile = "$ScriptDir/claude-ai-state.json"
$LogFile = "$ScriptDir/logs/claude_automation_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Claude AI 워커 구성 (WSL 터미널 기반)
$ClaudeWorkers = @{
    "opus-planner" = @{
        Model = $OpusModel
        Role = "계획 및 아키텍처 설계"
        Window = "opus"
        Terminal = "🧠Claude4-Opus-Planner"
        Prompt = "당신은 프로젝트 계획 전문가입니다. React Native 앱 개발의 각 단계를 계획하고 아키텍처를 설계하세요."
        Priority = "High"
    }
    "sonnet-coder1" = @{
        Model = $SonnetModel
        Role = "코드 작성 및 구현"
        Window = "sonnet1"
        Terminal = "🔨Claude4-Sonnet-Coder1"
        Prompt = "당신은 코드 작성 전문가입니다. 계획에 따라 실제 코드를 작성하고 구현하세요."
        Priority = "High"
    }
    "sonnet-coder2" = @{
        Model = $SonnetModel
        Role = "테스트 및 디버깅"
        Window = "sonnet2"
        Terminal = "🔧Claude4-Sonnet-Coder2"
        Prompt = "당신은 테스트 및 디버깅 전문가입니다. 코드를 테스트하고 버그를 수정하세요."
        Priority = "Medium"
    }
    "sonnet-coder3" = @{
        Model = $SonnetModel
        Role = "빌드 및 배포"
        Window = "sonnet3"
        Terminal = "⚙️Claude4-Sonnet-Coder3"
        Prompt = "당신은 빌드 및 배포 전문가입니다. 빌드 설정을 최적화하고 배포를 관리하세요."
        Priority = "Medium"
    }
    "sonnet-monitor" = @{
        Model = $SonnetModel
        Role = "모니터링 및 조정"
        Window = "monitor"
        Terminal = "📊Claude4-Sonnet-Monitor"
        Prompt = "당신은 모니터링 및 조정 전문가입니다. 전체 프로젝트 진행 상황을 모니터링하고 조정하세요."
        Priority = "Medium"
    }
}

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White",
        [switch]$NoNewline
    )
    
    $params = @{
        Object = $Message
        ForegroundColor = $Color
        NoNewline = $NoNewline.IsPresent
    }
    Write-Host @params
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-ColorOutput $logMessage
    
    # Ensure log directory exists
    $logDir = Split-Path -Parent $LogFile
    if (!(Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    
    Add-Content -Path $LogFile -Value $logMessage -Force
}

function Initialize-WSLEnvironment {
    Write-Log "WSL Claude AI 자동화 환경을 초기화합니다..." "INFO"
    
    # Create necessary directories
    $dirs = @("$ScriptDir/logs", "$ScriptDir/.cache")
    foreach ($dir in $dirs) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Log "Created directory: $dir" "INFO"
        }
    }
    
    # Check Python dependencies
    Write-Log "Python 의존성 확인 중..." "INFO"
    $requiredPackages = @("pyautogui", "pywin32", "psutil")
    foreach ($package in $requiredPackages) {
        try {
            pip show $package | Out-Null
            Write-Log "✅ $package 설치됨" "INFO"
        } catch {
            Write-Log "❌ $package 설치 필요" "ERROR"
            Write-Log "$package 설치 중..." "INFO"
            pip install $package
        }
    }
    
    # Check WSL availability
    Write-Log "WSL 가용성 확인 중..." "INFO"
    try {
        wsl --list --quiet | Out-Null
        Write-Log "✅ WSL 사용 가능" "INFO"
    } catch {
        Write-Log "❌ WSL 사용 불가능 또는 설정 필요" "ERROR"
        return $false
    }
    
    # Check Windows Terminal availability
    try {
        Get-Command wt -ErrorAction Stop | Out-Null
        Write-Log "✅ Windows Terminal 사용 가능" "INFO"
    } catch {
        Write-Log "❌ Windows Terminal 설치 필요" "ERROR"
        Write-Log "Microsoft Store에서 Windows Terminal을 설치하세요" "ERROR"
        return $false
    }
    
    # Check Claude Code availability
    Write-Log "Claude Code 가용성 확인 중..." "INFO"
    try {
        wsl which claude | Out-Null
        Write-Log "✅ Claude Code WSL에서 사용 가능" "INFO"
    } catch {
        Write-Log "❌ Claude Code WSL 설치 필요" "ERROR"
        Write-Log "WSL에서 Claude Code를 먼저 설치하세요" "ERROR"
        return $false
    }
    
    return $true
}

function Start-WSLTerminal {
    param(
        [string]$TerminalName,
        [string]$WorkingDirectory = "/mnt/c/Git/Routine_app/SquashTrainingApp"
    )
    
    Write-Log "WSL 터미널 시작: $TerminalName" "INFO"
    
    try {
        # Start new Windows Terminal tab with WSL
        $command = "wt new-tab --title `"$TerminalName`" wsl -d Ubuntu"
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $command -WindowStyle Hidden
        Start-Sleep -Seconds 3
        
        Write-Log "✅ WSL 터미널 시작됨: $TerminalName" "INFO"
        return $true
    } catch {
        Write-Log "❌ WSL 터미널 시작 실패: $TerminalName - $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Start-ClaudeInWSL {
    param(
        [string]$WorkerName,
        [hashtable]$Config
    )
    
    Write-Log "Claude Code 시작: $($Config.Terminal)" "INFO"
    
    try {
        # This would need to be implemented with automation tools
        # For now, just log the configuration
        Write-Log "Claude 설정 - 모델: $($Config.Model)" "INFO"
        Write-Log "Claude 설정 - 역할: $($Config.Role)" "INFO"
        Write-Log "Claude 설정 - 프롬프트: $($Config.Prompt)" "INFO"
        
        # In actual implementation, this would:
        # 1. Focus the terminal window
        # 2. Type "claude --model $($Config.Model)"
        # 3. Send initial prompt
        
        return $true
    } catch {
        Write-Log "❌ Claude 시작 실패: $WorkerName - $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Send-TaskToWSLWorker {
    param(
        [string]$WorkerName,
        [string]$Message,
        [int]$Iteration
    )
    
    $config = $ClaudeWorkers[$WorkerName]
    Write-Log "[$($config.Terminal)] 메시지 전송: $Message" "INFO"
    
    # This would need to be implemented with automation tools
    # For now, just log the task
    Write-Log "작업 전송 - 워커: $WorkerName" "INFO"
    Write-Log "작업 전송 - 반복: $Iteration" "INFO"
    Write-Log "작업 전송 - 메시지: $Message" "INFO"
    
    # Save task log
    $taskLogPath = "$ScriptDir/logs/claude-ai-logs/worker-$WorkerName-$Iteration.log"
    $taskLogDir = Split-Path -Parent $taskLogPath
    if (!(Test-Path $taskLogDir)) {
        New-Item -ItemType Directory -Path $taskLogDir -Force | Out-Null
    }
    
    @"
[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ITERATION $Iteration
WORKER: $WorkerName
TERMINAL: $($config.Terminal)
ROLE: $($config.Role)
MODEL: $($config.Model)
MESSAGE: $Message
"@ | Add-Content -Path $taskLogPath
}

function Initialize-ClaudeAISession {
    Write-ColorOutput "WSL Claude AI 자동화 세션을 초기화합니다..." "Cyan"
    
    # Initialize WSL environment
    if (!(Initialize-WSLEnvironment)) {
        Write-Log "WSL 환경 초기화 실패" "ERROR"
        return $false
    }
    
    # Start Windows Terminal if not running
    $wtProcess = Get-Process "WindowsTerminal" -ErrorAction SilentlyContinue
    if (!$wtProcess) {
        Write-Log "Windows Terminal 시작 중..." "INFO"
        Start-Process "wt" -WindowStyle Normal
        Start-Sleep -Seconds 3
    }
    
    # Start WSL terminals for each Claude worker
    foreach ($worker in $ClaudeWorkers.Keys) {
        $config = $ClaudeWorkers[$worker]
        if (Start-WSLTerminal -TerminalName $config.Terminal) {
            Write-ColorOutput "  생성됨: $($config.Terminal) - $($config.Role)" "Green"
            
            # Start Claude Code in the terminal
            if (Start-ClaudeInWSL -WorkerName $worker -Config $config) {
                Write-ColorOutput "  Claude 시작됨: $($config.Terminal)" "Green"
            }
        }
    }
    
    Write-ColorOutput "WSL Claude AI 세션이 준비되었습니다!" "Green"
    return $true
}

function Start-ClaudeWorker {
    param(
        [string]$WorkerName,
        [string]$Task,
        [int]$Iteration
    )
    
    $config = $ClaudeWorkers[$WorkerName]
    Write-ColorOutput "[AI-$($config.Window.ToUpper())] 작업 시작: $Task" "Blue"
    
    # Claude Code 시작 명령 생성
    $claudeCmd = @"
cd '$ProjectRoot'
echo '시작: Claude $($config.Model) - $($config.Role)'
echo '작업: $Task'
echo '반복: $Iteration'
echo '프롬프트: $($config.Prompt)'
echo ''
echo '사용자 입력을 기다립니다...'
echo 'Claude Code를 시작하려면 다음 명령을 실행하세요:'
echo 'claude'
"@
    
    # tmux 윈도우에 명령 전송
    & bash -c "tmux send-keys -t '${SessionName}:$($config.Window)' `"$claudeCmd`" C-m"
    
    # Claude 시작 대기
    Start-Sleep -Seconds 2
    
    # Claude Code 실행
    & bash -c "tmux send-keys -t '${SessionName}:$($config.Window)' 'claude' C-m"
    
    Write-ColorOutput "[AI-$($config.Window.ToUpper())] Claude Code 시작됨" "Green"
}

function Send-TaskToWorker {
    param(
        [string]$WorkerName,
        [string]$Message,
        [int]$Iteration
    )
    
    $config = $ClaudeWorkers[$WorkerName]
    Write-ColorOutput "[AI-$($config.Window.ToUpper())] 메시지 전송: $Message" "Yellow"
    
    # Claude에게 메시지 전송
    & bash -c "tmux send-keys -t '${SessionName}:$($config.Window)' `"$Message`" C-m"
    
    # 로그 저장
    $logPath = "$ScriptDir/logs/claude-ai-logs/worker-$WorkerName-$Iteration.log"
    $logDir = Split-Path -Parent $logPath
    if (!(Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    
    @"
[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ITERATION $Iteration
WORKER: $WorkerName
ROLE: $($config.Role)
MESSAGE: $Message
"@ | Add-Content -Path $logPath
}

function Get-State {
    if (Test-Path $StateFile) {
        return Get-Content $StateFile | ConvertFrom-Json
    }
    
    $defaultState = @{
        currentIteration = 0
        targetIterations = $TargetIterations
        startTime = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        lastUpdate = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        status = "initialized"
        workersStatus = @{}
        completedTasks = @()
        errors = @()
        planningHistory = @()
        codeHistory = @()
    }
    
    # 워커 상태 초기화
    foreach ($worker in $ClaudeWorkers.Keys) {
        $defaultState.workersStatus[$worker] = "idle"
    }
    
    $defaultState | ConvertTo-Json -Depth 10 | Set-Content $StateFile
    return $defaultState
}

function Update-State {
    param([hashtable]$Updates)
    
    $state = Get-State
    foreach ($key in $Updates.Keys) {
        $state.$key = $Updates[$key]
    }
    $state.lastUpdate = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile
}

function Start-AutomationCycle {
    param([int]$Iteration)
    
    Write-ColorOutput "`n$('='*80)" "Cyan"
    Write-ColorOutput "CLAUDE AI 자동화 사이클 $Iteration 시작" "Cyan"
    Write-ColorOutput "$('='*80)" "Cyan"
    
    # 1단계: Opus가 계획 수립
    Write-ColorOutput "`n[1단계] 계획 수립 (Claude Opus)" "Magenta"
    Start-ClaudeWorker -WorkerName "opus-planner" -Task "계획 수립" -Iteration $Iteration
    
    $planningTask = @"
반복 $Iteration 에 대한 개발 계획을 수립해주세요.

현재 상태: Squash Training App React Native 프로젝트
목표: 완성도 높은 앱 구현 및 테스트

다음 사항을 계획해주세요:
1. 이번 반복에서 구현할 기능들
2. 기능별 우선순위
3. 예상 소요 시간
4. 테스트 계획
5. 잠재적 위험 요소

계획을 완료하면 'PLANNING_COMPLETE'라고 입력해주세요.
"@
    
    Send-TaskToWorker -WorkerName "opus-planner" -Message $planningTask -Iteration $Iteration
    
    # 계획 완료 대기
    Write-ColorOutput "계획 수립 완료를 기다립니다..." "Yellow"
    Start-Sleep -Seconds 30
    
    # 2단계: Sonnet이 코드 작성
    Write-ColorOutput "`n[2단계] 코드 작성 (Claude Sonnet)" "Blue"
    Start-ClaudeWorker -WorkerName "sonnet-coder" -Task "코드 작성" -Iteration $Iteration
    
    $codingTask = @"
Opus가 수립한 계획에 따라 코드를 작성해주세요.

작업 내용:
1. 계획된 기능들을 실제 코드로 구현
2. React Native 베스트 프랙티스 적용
3. 타입스크립트 사용
4. 에러 핸들링 포함
5. 성능 최적화 고려

코드 작성을 완료하면 'CODING_COMPLETE'라고 입력해주세요.
"@
    
    Send-TaskToWorker -WorkerName "sonnet-coder" -Message $codingTask -Iteration $Iteration
    
    # 코드 작성 완료 대기
    Write-ColorOutput "코드 작성 완료를 기다립니다..." "Yellow"
    Start-Sleep -Seconds 45
    
    # 3단계: Sonnet이 테스트 및 디버깅
    Write-ColorOutput "`n[3단계] 테스트 및 디버깅 (Claude Sonnet)" "Green"
    Start-ClaudeWorker -WorkerName "sonnet-tester" -Task "테스트 및 디버깅" -Iteration $Iteration
    
    $testingTask = @"
작성된 코드를 테스트하고 디버깅해주세요.

작업 내용:
1. 코드 빌드 및 실행
2. 기능 테스트 수행
3. 오류 발견 시 수정
4. 성능 테스트
5. 에뮬레이터에서 실제 동작 확인

테스트를 완료하면 'TESTING_COMPLETE'라고 입력해주세요.
"@
    
    Send-TaskToWorker -WorkerName "sonnet-tester" -Message $testingTask -Iteration $Iteration
    
    # 테스트 완료 대기
    Write-ColorOutput "테스트 완료를 기다립니다..." "Yellow"
    Start-Sleep -Seconds 60
    
    # 4단계: Sonnet이 코드 리뷰
    Write-ColorOutput "`n[4단계] 코드 리뷰 (Claude Sonnet)" "Cyan"
    Start-ClaudeWorker -WorkerName "sonnet-reviewer" -Task "코드 리뷰" -Iteration $Iteration
    
    $reviewTask = @"
완성된 코드를 리뷰하고 최적화해주세요.

작업 내용:
1. 코드 품질 검토
2. 성능 최적화 방안 제시
3. 보안 취약점 검토
4. 코드 스타일 통일성 확인
5. 문서화 상태 점검

리뷰를 완료하면 'REVIEW_COMPLETE'라고 입력해주세요.
"@
    
    Send-TaskToWorker -WorkerName "sonnet-reviewer" -Message $reviewTask -Iteration $Iteration
    
    # 리뷰 완료 대기
    Write-ColorOutput "리뷰 완료를 기다립니다..." "Yellow"
    Start-Sleep -Seconds 30
    
    Write-ColorOutput "`n[반복 $Iteration 완료]" "Green"
    
    # 상태 업데이트
    Update-State @{
        currentIteration = $Iteration
        status = "completed-iteration"
    }
}

function Show-Dashboard {
    Write-ColorOutput "`n$('='*80)" "Cyan"
    Write-ColorOutput "CLAUDE AI 자동화 대시보드" "Cyan"
    Write-ColorOutput "$('='*80)" "Cyan"
    
    $state = Get-State
    
    Write-ColorOutput "현재 반복: $($state.currentIteration)/$($state.targetIterations)" "White"
    Write-ColorOutput "상태: $($state.status)" "Yellow"
    Write-ColorOutput "시작 시간: $($state.startTime)" "Gray"
    Write-ColorOutput ""
    
    Write-ColorOutput "워커 상태:" "Blue"
    foreach ($worker in $ClaudeWorkers.Keys) {
        $config = $ClaudeWorkers[$worker]
        $status = $state.workersStatus[$worker]
        Write-ColorOutput "  $($config.Window): $status - $($config.Role)" "White"
    }
    
    Write-ColorOutput "`n세션 접속 방법:" "Green"
    Write-ColorOutput "  tmux attach -t $SessionName" "Gray"
    Write-ColorOutput "  윈도우 전환: Ctrl+b + 윈도우번호" "Gray"
    
    Write-ColorOutput "$('='*80)" "Cyan"
}

function Start-MonitoringDashboard {
    Write-ColorOutput "모니터링 대시보드를 시작합니다..." "Cyan"
    
    $monitorScript = @"
#!/bin/bash
cd '$ProjectRoot'
while true; do
    clear
    echo "=== CLAUDE AI 자동화 모니터링 ==="
    echo "시간: \$(date)"
    echo ""
    echo "활성 세션:"
    tmux list-sessions | grep $SessionName || echo "세션 없음"
    echo ""
    echo "활성 윈도우:"
    tmux list-windows -t $SessionName 2>/dev/null || echo "윈도우 없음"
    echo ""
    echo "로그 디렉토리:"
    ls -la '$ScriptDir/logs/claude-ai-logs/' 2>/dev/null || echo "로그 없음"
    echo ""
    echo "Press Ctrl+C to exit"
    sleep 10
done
"@
    
    $monitorScript | Set-Content "$ScriptDir/monitor-dashboard.sh"
    & bash -c "chmod +x '$ScriptDir/monitor-dashboard.sh'"
    
    # 모니터 윈도우에서 실행
    & bash -c "tmux send-keys -t '${SessionName}:monitor' '$ScriptDir/monitor-dashboard.sh' C-m"
}

# 메인 실행
try {
    Write-ColorOutput "CLAUDE AI 자동화 시스템 시작" "Cyan"
    Write-ColorOutput "$('='*80)" "Cyan"
    
    # 로그 디렉토리 생성
    $logDir = "$ScriptDir/logs/claude-ai-logs"
    if (!(Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    
    # 세션 초기화
    Initialize-ClaudeAISession
    
    # 대시보드 시작
    Start-MonitoringDashboard
    
    # 상태 초기화
    $state = Get-State
    if ($ContinueFromLastState -and $state.currentIteration -gt 0) {
        Write-ColorOutput "이전 상태에서 계속합니다: 반복 $($state.currentIteration + 1)" "Yellow"
        $startIteration = $state.currentIteration + 1
    } else {
        Write-ColorOutput "새로운 자동화 사이클을 시작합니다" "Green"
        $startIteration = 1
    }
    
    # 메인 자동화 루프
    for ($i = $startIteration; $i -le $TargetIterations; $i++) {
        Start-AutomationCycle -Iteration $i
        
        # 진행 상황 표시
        if ($i % 5 -eq 0) {
            Show-Dashboard
        }
        
        # 사용자 입력 대기 (각 사이클 사이)
        if (!$DebugMode) {
            Write-ColorOutput "`n다음 사이클을 계속하려면 Enter를 누르세요 (q=종료)..." "Yellow"
            $input = Read-Host
            if ($input -eq 'q') {
                Write-ColorOutput "사용자가 종료를 요청했습니다." "Red"
                break
            }
        }
    }
    
    # 최종 대시보드 표시
    Show-Dashboard
    
    Write-ColorOutput "`nClaude AI 자동화가 완료되었습니다!" "Green"
    Write-ColorOutput "세션에 연결하려면: tmux attach -t $SessionName" "Cyan"
    
} catch {
    Write-ColorOutput "오류 발생: $_" "Red"
    Write-ColorOutput "세션 정리 중..." "Yellow"
    & bash -c "tmux kill-session -t $SessionName" 2>/dev/null
    exit 1
}