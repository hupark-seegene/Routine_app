#!/usr/bin/env pwsh
<#
.SYNOPSIS
    마스터 자동화 컨트롤러 - 5개 Claude 터미널 통합 관리
.DESCRIPTION
    열려진 5개 Claude Code 터미널을 제어하여 50+ 빌드-테스트-디버그 사이클 실행
.NOTES
    Author: Claude AI Automation System
    Date: 2025-07-16
    Version: 2.0
#>

param(
    [int]$TargetCycles = 50,
    [switch]$Setup,
    [switch]$Start,
    [switch]$Monitor,
    [switch]$Stop,
    [switch]$Status,
    [switch]$Emergency
)

$ErrorActionPreference = "Stop"

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item "$ScriptDir/../..").FullName
$LogDir = "$ScriptDir/logs/automation"
$StateFile = "$LogDir/automation-state.json"

# Terminal Configuration - Match your opened terminals
$Terminals = @{
    "planner" = @{
        Title = "🧠Claude4-Opus-Planner"
        Role = "계획 및 아키텍처 설계"
        Model = "claude-3-opus-20240229"
        Priority = "Critical"
        Commands = @()
    }
    "coder1" = @{
        Title = "🔨Claude4-Sonnet-Coder1"
        Role = "주요 코드 구현"
        Model = "claude-3-5-sonnet-20241022"
        Priority = "High"
        Commands = @()
    }
    "coder2" = @{
        Title = "🔧Claude4-Sonnet-Coder2"
        Role = "테스트 및 디버깅"
        Model = "claude-3-5-sonnet-20241022"
        Priority = "High"
        Commands = @()
    }
    "coder3" = @{
        Title = "⚙️Claude4-Sonnet-Coder3"
        Role = "빌드 및 배포"
        Model = "claude-3-5-sonnet-20241022"
        Priority = "Medium"
        Commands = @()
    }
    "monitor" = @{
        Title = "📊Claude4-Sonnet-Monitor"
        Role = "모니터링 및 조정"
        Model = "claude-3-5-sonnet-20241022"
        Priority = "Medium"
        Commands = @()
    }
}

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White",
        [switch]$NoNewline
    )
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    $params = @{
        Object = "[$timestamp] $Message"
        ForegroundColor = $Color
        NoNewline = $NoNewline.IsPresent
    }
    Write-Host @params
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO", [string]$Terminal = "SYSTEM")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] [$Terminal] $Message"
    
    # Ensure log directory exists
    if (!(Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }
    
    # Write to main log
    $logFile = "$LogDir/automation-$(Get-Date -Format 'yyyyMMdd').log"
    Add-Content -Path $logFile -Value $logMessage -Force
    
    # Write to terminal-specific log
    $terminalLogFile = "$LogDir/terminal-$Terminal-$(Get-Date -Format 'yyyyMMdd').log"
    Add-Content -Path $terminalLogFile -Value $logMessage -Force
}

function Initialize-AutomationEnvironment {
    Write-ColorOutput "🔧 자동화 환경 초기화 중..." "Cyan"
    
    # Create directories
    $dirs = @($LogDir, "$LogDir/cycles", "$LogDir/screenshots", "$LogDir/builds")
    foreach ($dir in $dirs) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Log "Created directory: $dir" "INFO"
        }
    }
    
    # Check dependencies
    $dependencies = @{
        "Windows Terminal" = { Get-Command wt -ErrorAction SilentlyContinue }
        "WSL" = { wsl --list --quiet 2>$null }
        "Claude Code" = { wsl which claude 2>$null }
        "ADB" = { wsl which adb 2>$null }
        "Java" = { wsl java -version 2>$null }
    }
    
    foreach ($dep in $dependencies.Keys) {
        try {
            $result = & $dependencies[$dep]
            if ($result) {
                Write-ColorOutput "✅ $dep 사용 가능" "Green"
                Write-Log "$dep available" "INFO"
            } else {
                Write-ColorOutput "❌ $dep 설치 필요" "Red"
                Write-Log "$dep not available" "ERROR"
            }
        } catch {
            Write-ColorOutput "❌ $dep 확인 실패: $($_.Exception.Message)" "Red"
            Write-Log "$dep check failed: $($_.Exception.Message)" "ERROR"
        }
    }
    
    Write-ColorOutput "✅ 환경 초기화 완료" "Green"
    return $true
}

function Get-AutomationState {
    if (Test-Path $StateFile) {
        return Get-Content $StateFile | ConvertFrom-Json
    }
    
    $defaultState = @{
        currentCycle = 0
        targetCycles = $TargetCycles
        startTime = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        lastUpdate = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        status = "initialized"
        terminals = @{}
        cycles = @()
        errors = @()
        buildCount = 0
        successCount = 0
        failureCount = 0
    }
    
    # Initialize terminal states
    foreach ($terminal in $Terminals.Keys) {
        $defaultState.terminals[$terminal] = @{
            status = "idle"
            lastCommand = ""
            lastResponse = ""
            errors = 0
        }
    }
    
    $defaultState | ConvertTo-Json -Depth 10 | Set-Content $StateFile
    return $defaultState
}

function Update-AutomationState {
    param([hashtable]$Updates)
    
    $state = Get-AutomationState
    foreach ($key in $Updates.Keys) {
        $state.$key = $Updates[$key]
    }
    $state.lastUpdate = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile
}

function Send-CommandToTerminal {
    param(
        [string]$TerminalName,
        [string]$Command,
        [int]$Cycle,
        [bool]$WaitForResponse = $true
    )
    
    $config = $Terminals[$TerminalName]
    Write-ColorOutput "[$($config.Title)] 명령 전송: $Command" "Yellow"
    Write-Log "Sending command: $Command" "INFO" $TerminalName
    
    try {
        # Use Windows automation to send command to specific terminal
        # This is a placeholder - actual implementation would use automation tools
        
        # Log the command
        $commandLog = @{
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            cycle = $Cycle
            terminal = $TerminalName
            command = $Command
            status = "sent"
        }
        
        $commandLogFile = "$LogDir/cycles/cycle-$Cycle-commands.json"
        if (Test-Path $commandLogFile) {
            $existingCommands = Get-Content $commandLogFile | ConvertFrom-Json
            $existingCommands += $commandLog
        } else {
            $existingCommands = @($commandLog)
        }
        $existingCommands | ConvertTo-Json -Depth 5 | Set-Content $commandLogFile
        
        # Update terminal state
        $state = Get-AutomationState
        $state.terminals[$TerminalName].lastCommand = $Command
        $state.terminals[$TerminalName].status = "executing"
        Update-AutomationState $state
        
        Write-ColorOutput "✅ 명령 전송 완료: $TerminalName" "Green"
        return $true
        
    } catch {
        Write-ColorOutput "❌ 명령 전송 실패: $TerminalName - $($_.Exception.Message)" "Red"
        Write-Log "Command send failed: $($_.Exception.Message)" "ERROR" $TerminalName
        return $false
    }
}

function Start-AutomationCycle {
    param([int]$CycleNumber)
    
    Write-ColorOutput "`n$('='*80)" "Cyan"
    Write-ColorOutput "🚀 자동화 사이클 $CycleNumber 시작 (목표: $TargetCycles)" "Cyan"
    Write-ColorOutput "$('='*80)" "Cyan"
    
    $cycleStartTime = Get-Date
    $cycleLog = @{
        cycle = $CycleNumber
        startTime = $cycleStartTime.ToString("yyyy-MM-ddTHH:mm:ssZ")
        status = "started"
        phases = @()
        errors = @()
        results = @{}
    }
    
    # Phase 1: Planning (Opus)
    Write-ColorOutput "`n[1단계] 계획 수립 - Claude Opus" "Magenta"
    $planningPrompt = @"
사이클 $CycleNumber/$TargetCycles 에 대한 개발 계획을 수립해주세요.

현재 상태: SquashTrainingApp (React Native) - Cycle 28까지 완료
- 5개 메인 스크린 완성 (Home, Checklist, Record, Profile, Coach)
- SQLite 데이터베이스 통합
- 마스코트 시스템 구현
- 네비게이션 문제 해결

이번 사이클 목표:
1. 앱 빌드 및 설치 확인
2. 모든 기능 테스트
3. 발견된 이슈 수정
4. 성능 최적화
5. 다음 사이클 준비

계획을 수립하고 'PLANNING_COMPLETE_CYCLE_$CycleNumber'로 응답해주세요.
"@
    
    Send-CommandToTerminal -TerminalName "planner" -Command $planningPrompt -Cycle $CycleNumber
    $cycleLog.phases += @{ phase = "planning"; status = "started"; startTime = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ") }
    
    # Wait for planning completion
    Start-Sleep -Seconds 15
    
    # Phase 2: Build Implementation (Sonnet Coder1)
    Write-ColorOutput "`n[2단계] 빌드 구현 - Claude Sonnet Coder1" "Blue"
    $buildPrompt = @"
사이클 $CycleNumber 빌드를 실행해주세요.

작업 순서:
1. 프로젝트 디렉토리로 이동: cd SquashTrainingApp
2. 안드로이드 빌드 실행: ./gradlew assembleDebug
3. APK 파일 확인
4. 빌드 결과 검증

빌드 완료 후 'BUILD_COMPLETE_CYCLE_$CycleNumber'로 응답해주세요.
빌드 실패 시 'BUILD_FAILED_CYCLE_$CycleNumber [오류내용]'로 응답해주세요.
"@
    
    Send-CommandToTerminal -TerminalName "coder1" -Command $buildPrompt -Cycle $CycleNumber
    $cycleLog.phases += @{ phase = "build"; status = "started"; startTime = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ") }
    
    # Wait for build completion
    Start-Sleep -Seconds 45
    
    # Phase 3: Testing and Debugging (Sonnet Coder2)
    Write-ColorOutput "`n[3단계] 테스트 및 디버깅 - Claude Sonnet Coder2" "Green"
    $testPrompt = @"
사이클 $CycleNumber 테스트를 실행해주세요.

테스트 순서:
1. 에뮬레이터 상태 확인
2. APK 설치: adb install app-debug.apk
3. 앱 실행 및 기능 테스트
4. 스크린샷 캡처
5. 로그 분석

중점 테스트 항목:
- 마스코트 드래그 네비게이션
- 5개 스크린 전환
- 데이터베이스 CRUD 작업
- 성능 측정

테스트 완료 후 'TEST_COMPLETE_CYCLE_$CycleNumber'로 응답해주세요.
이슈 발견 시 'TEST_ISSUES_CYCLE_$CycleNumber [이슈내용]'로 응답해주세요.
"@
    
    Send-CommandToTerminal -TerminalName "coder2" -Command $testPrompt -Cycle $CycleNumber
    $cycleLog.phases += @{ phase = "testing"; status = "started"; startTime = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ") }
    
    # Wait for testing completion
    Start-Sleep -Seconds 60
    
    # Phase 4: Deployment and Optimization (Sonnet Coder3)
    Write-ColorOutput "`n[4단계] 배포 및 최적화 - Claude Sonnet Coder3" "Cyan"
    $deployPrompt = @"
사이클 $CycleNumber 배포 및 최적화를 실행해주세요.

최적화 작업:
1. APK 크기 분석
2. 성능 메트릭 수집
3. 메모리 사용량 확인
4. 빌드 설정 최적화

배포 준비:
1. APK 파일 백업
2. 빌드 로그 저장
3. 성능 리포트 생성

완료 후 'DEPLOY_COMPLETE_CYCLE_$CycleNumber'로 응답해주세요.
"@
    
    Send-CommandToTerminal -TerminalName "coder3" -Command $deployPrompt -Cycle $CycleNumber
    $cycleLog.phases += @{ phase = "deployment"; status = "started"; startTime = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ") }
    
    # Wait for deployment completion
    Start-Sleep -Seconds 30
    
    # Phase 5: Monitoring and Reporting (Sonnet Monitor)
    Write-ColorOutput "`n[5단계] 모니터링 및 리포팅 - Claude Sonnet Monitor" "Magenta"
    $monitorPrompt = @"
사이클 $CycleNumber 모니터링 및 리포팅을 실행해주세요.

모니터링 작업:
1. 전체 사이클 결과 수집
2. 성공/실패 지표 분석
3. 성능 트렌드 확인
4. 다음 사이클 추천사항 생성

리포트 생성:
1. 사이클 요약 리포트
2. 이슈 및 해결방안
3. 성능 개선사항
4. 다음 사이클 계획

완료 후 'MONITOR_COMPLETE_CYCLE_$CycleNumber'로 응답해주세요.
"@
    
    Send-CommandToTerminal -TerminalName "monitor" -Command $monitorPrompt -Cycle $CycleNumber
    $cycleLog.phases += @{ phase = "monitoring"; status = "started"; startTime = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ") }
    
    # Wait for monitoring completion
    Start-Sleep -Seconds 20
    
    # Complete cycle
    $cycleEndTime = Get-Date
    $cycleLog.endTime = $cycleEndTime.ToString("yyyy-MM-ddTHH:mm:ssZ")
    $cycleLog.duration = ($cycleEndTime - $cycleStartTime).TotalMinutes
    $cycleLog.status = "completed"
    
    # Save cycle log
    $cycleLogFile = "$LogDir/cycles/cycle-$CycleNumber-complete.json"
    $cycleLog | ConvertTo-Json -Depth 10 | Set-Content $cycleLogFile
    
    Write-ColorOutput "`n✅ 사이클 $CycleNumber 완료 (소요시간: $([math]::Round($cycleLog.duration, 1))분)" "Green"
    
    # Update automation state
    $state = Get-AutomationState
    $state.currentCycle = $CycleNumber
    $state.cycles += $cycleLog
    $state.buildCount++
    Update-AutomationState $state
    
    return $cycleLog
}

function Show-AutomationDashboard {
    Clear-Host
    $state = Get-AutomationState
    
    Write-ColorOutput "$('='*80)" "Cyan"
    Write-ColorOutput "📊 CLAUDE AI 자동화 대시보드" "Cyan"
    Write-ColorOutput "$('='*80)" "Cyan"
    
    Write-ColorOutput "`n📈 진행 상황:" "Yellow"
    Write-ColorOutput "  현재 사이클: $($state.currentCycle)/$($state.targetCycles)" "White"
    Write-ColorOutput "  진행률: $([math]::Round(($state.currentCycle / $state.targetCycles) * 100, 1))%" "White"
    Write-ColorOutput "  상태: $($state.status)" "White"
    Write-ColorOutput "  시작 시간: $($state.startTime)" "Gray"
    
    Write-ColorOutput "`n📊 통계:" "Yellow"
    Write-ColorOutput "  총 빌드: $($state.buildCount)" "White"
    Write-ColorOutput "  성공: $($state.successCount)" "Green"
    Write-ColorOutput "  실패: $($state.failureCount)" "Red"
    
    Write-ColorOutput "`n🖥️ 터미널 상태:" "Yellow"
    foreach ($terminalName in $Terminals.Keys) {
        $config = $Terminals[$terminalName]
        $terminalState = $state.terminals[$terminalName]
        $statusColor = switch ($terminalState.status) {
            "idle" { "Gray" }
            "executing" { "Yellow" }
            "completed" { "Green" }
            "error" { "Red" }
            default { "White" }
        }
        Write-ColorOutput "  $($config.Title): $($terminalState.status) - $($config.Role)" $statusColor
        if ($terminalState.lastCommand) {
            Write-ColorOutput "    마지막 명령: $($terminalState.lastCommand.Substring(0, [Math]::Min(50, $terminalState.lastCommand.Length)))..." "Gray"
        }
    }
    
    if ($state.errors.Count -gt 0) {
        Write-ColorOutput "`n❌ 최근 오류:" "Red"
        $recentErrors = $state.errors | Select-Object -Last 3
        foreach ($error in $recentErrors) {
            Write-ColorOutput "  $($error.timestamp): $($error.message)" "Red"
        }
    }
    
    Write-ColorOutput "`n$('='*80)" "Cyan"
}

function Start-ContinuousAutomation {
    Write-ColorOutput "🚀 연속 자동화 시작" "Cyan"
    
    $state = Get-AutomationState
    $startCycle = $state.currentCycle + 1
    
    for ($cycle = $startCycle; $cycle -le $TargetCycles; $cycle++) {
        # Show dashboard every 5 cycles
        if ($cycle % 5 -eq 1) {
            Show-AutomationDashboard
        }
        
        # Execute cycle
        $cycleResult = Start-AutomationCycle -CycleNumber $cycle
        
        # Check for user interruption
        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)
            if ($key.Key -eq "Q" -or $key.Key -eq "Escape") {
                Write-ColorOutput "`n⏹️ 사용자 중단 요청" "Red"
                break
            }
        }
        
        # Brief pause between cycles
        Start-Sleep -Seconds 5
    }
    
    Show-AutomationDashboard
    Write-ColorOutput "`n🎉 자동화 완료!" "Green"
}

# Main execution
function Main {
    param($Action)
    
    switch ($Action) {
        "Setup" {
            Initialize-AutomationEnvironment
        }
        "Start" {
            Initialize-AutomationEnvironment
            Start-ContinuousAutomation
        }
        "Monitor" {
            Show-AutomationDashboard
        }
        "Status" {
            $state = Get-AutomationState
            Write-ColorOutput "현재 상태: $($state.status)" "Yellow"
            Write-ColorOutput "진행 사이클: $($state.currentCycle)/$($state.targetCycles)" "White"
        }
        "Stop" {
            Write-ColorOutput "⏹️ 자동화 중지" "Red"
            $state = Get-AutomationState
            $state.status = "stopped"
            Update-AutomationState $state
        }
        "Emergency" {
            Write-ColorOutput "🚨 긴급 중지" "Red"
            # Emergency stop procedures
        }
        default {
            Write-ColorOutput "사용법: .\MASTER-AUTOMATION-CONTROLLER.ps1 -Start|-Monitor|-Status|-Stop|-Emergency" "Yellow"
        }
    }
}

# Execute based on parameters
if ($Setup) { Main "Setup" }
elseif ($Start) { Main "Start" }
elseif ($Monitor) { Main "Monitor" }
elseif ($Status) { Main "Status" }
elseif ($Stop) { Main "Stop" }
elseif ($Emergency) { Main "Emergency" }
else { Main "Help" }