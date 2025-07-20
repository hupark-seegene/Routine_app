#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Multi-Terminal Opener for Claude AI Automation
.DESCRIPTION
    Opens multiple Windows Terminal tabs for Claude AI automation
    User manually sets up WSL and Claude Code in each terminal
.NOTES
    Author: Claude AI Automation System
    Date: 2025-07-16
    Version: 1.0
#>

param(
    [int]$NumTerminals = 5,
    [switch]$OpenAll,
    [switch]$Status,
    [switch]$Close
)

# Configuration
$ProjectRoot = "C:\Git\Routine_app\SquashTrainingApp"
$TerminalConfigs = @(
    @{
        Name = "🧠Claude4-Opus-Planner"
        Role = "Planning and Architecture"
        Model = "claude-3-opus-20240229"
        Instructions = "계획 및 아키텍처 설계 담당"
        Color = "Blue"
    },
    @{
        Name = "🔨Claude4-Sonnet-Coder1"
        Role = "Primary Implementation"
        Model = "claude-3-5-sonnet-20241022"
        Instructions = "주요 코드 작성 및 구현 담당"
        Color = "Green"
    },
    @{
        Name = "🔧Claude4-Sonnet-Coder2"
        Role = "Testing and Debugging"
        Model = "claude-3-5-sonnet-20241022"
        Instructions = "테스트 및 디버깅 담당"
        Color = "Yellow"
    },
    @{
        Name = "⚙️Claude4-Sonnet-Coder3"
        Role = "Build and Deployment"
        Model = "claude-3-5-sonnet-20241022"
        Instructions = "빌드 및 배포 담당"
        Color = "Cyan"
    },
    @{
        Name = "📊Claude4-Sonnet-Monitor"
        Role = "Monitoring and Coordination"
        Model = "claude-3-5-sonnet-20241022"
        Instructions = "모니터링 및 전체 조정 담당"
        Color = "Magenta"
    }
)

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Open-TerminalTab {
    param(
        [hashtable]$Config,
        [int]$Index
    )
    
    Write-ColorOutput "터미널 생성 중: $($Config.Name)" $Config.Color
    
    try {
        # Open new Windows Terminal tab
        $command = "wt new-tab --title `"$($Config.Name)`" PowerShell"
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $command -WindowStyle Hidden
        Start-Sleep -Seconds 2
        
        Write-ColorOutput "✅ 터미널 생성됨: $($Config.Name)" "Green"
        
        # Display setup instructions
        Write-ColorOutput "  역할: $($Config.Role)" "Gray"
        Write-ColorOutput "  모델: $($Config.Model)" "Gray"
        Write-ColorOutput "  지시사항: $($Config.Instructions)" "Gray"
        Write-ColorOutput ""
        
        return $true
    } catch {
        Write-ColorOutput "❌ 터미널 생성 실패: $($Config.Name)" "Red"
        return $false
    }
}

function Show-SetupInstructions {
    Write-ColorOutput "=" * 80 "Cyan"
    Write-ColorOutput "Claude AI 자동화 터미널 설정 가이드" "Cyan"
    Write-ColorOutput "=" * 80 "Cyan"
    Write-ColorOutput ""
    
    Write-ColorOutput "각 터미널에서 다음 명령을 실행하세요:" "Yellow"
    Write-ColorOutput ""
    
    Write-ColorOutput "1. WSL 환경으로 전환:" "White"
    Write-ColorOutput "   wsl" "Gray"
    Write-ColorOutput ""
    
    Write-ColorOutput "2. 프로젝트 디렉토리로 이동:" "White"
    Write-ColorOutput "   cd /mnt/c/Git/Routine_app/SquashTrainingApp" "Gray"
    Write-ColorOutput ""
    
    Write-ColorOutput "3. Claude Code 시작:" "White"
    Write-ColorOutput "   claude" "Gray"
    Write-ColorOutput ""
    
    Write-ColorOutput "4. 모델 설정 (선택사항):" "White"
    Write-ColorOutput "   claude --model claude-3-opus-20240229       (플래너용)" "Gray"
    Write-ColorOutput "   claude --model claude-3-5-sonnet-20241022   (코더용)" "Gray"
    Write-ColorOutput ""
    
    Write-ColorOutput "⚠️ 중요: Claude Code에서는 Enter를 두 번 눌러야 명령이 전달됩니다!" "Red"
    Write-ColorOutput ""
    
    Write-ColorOutput "터미널 역할 분배:" "Yellow"
    foreach ($config in $TerminalConfigs) {
        Write-ColorOutput "  $($config.Name): $($config.Role)" $config.Color
    }
    Write-ColorOutput ""
    
    Write-ColorOutput "설정 완료 후 자동화 스크립트를 실행하세요:" "Green"
    Write-ColorOutput "  .\CLAUDE-AI-AUTOMATION.ps1 -Start" "Gray"
    Write-ColorOutput ""
    Write-ColorOutput "=" * 80 "Cyan"
}

function Show-TerminalStatus {
    Write-ColorOutput "=" * 60 "Cyan"
    Write-ColorOutput "터미널 상태 확인" "Cyan"
    Write-ColorOutput "=" * 60 "Cyan"
    
    Write-ColorOutput "Windows Terminal 프로세스:" "Yellow"
    $wtProcesses = Get-Process "WindowsTerminal" -ErrorAction SilentlyContinue
    if ($wtProcesses) {
        foreach ($process in $wtProcesses) {
            Write-ColorOutput "  ✅ PID: $($process.Id) - 시작: $($process.StartTime)" "Green"
        }
    } else {
        Write-ColorOutput "  ❌ Windows Terminal이 실행되지 않음" "Red"
    }
    
    Write-ColorOutput ""
    Write-ColorOutput "예상 터미널 탭:" "Yellow"
    foreach ($config in $TerminalConfigs) {
        Write-ColorOutput "  $($config.Name): $($config.Role)" $config.Color
    }
    
    Write-ColorOutput ""
    Write-ColorOutput "터미널 탭 전환:" "Yellow"
    Write-ColorOutput "  Ctrl+Shift+Tab: 이전 탭" "Gray"
    Write-ColorOutput "  Ctrl+Tab: 다음 탭" "Gray"
    Write-ColorOutput "  Ctrl+Shift+숫자: 특정 탭으로 이동" "Gray"
    Write-ColorOutput ""
}

function Close-AllTerminals {
    Write-ColorOutput "모든 터미널 종료 중..." "Yellow"
    
    $wtProcesses = Get-Process "WindowsTerminal" -ErrorAction SilentlyContinue
    if ($wtProcesses) {
        foreach ($process in $wtProcesses) {
            try {
                $process.Kill()
                Write-ColorOutput "✅ 터미널 종료됨: PID $($process.Id)" "Green"
            } catch {
                Write-ColorOutput "❌ 터미널 종료 실패: PID $($process.Id)" "Red"
            }
        }
    } else {
        Write-ColorOutput "종료할 터미널이 없습니다." "Gray"
    }
}

function Create-AutomationCoordinator {
    Write-ColorOutput "자동화 조정 스크립트 생성 중..." "Cyan"
    
    $coordinatorScript = @"
#!/usr/bin/env pwsh
# Claude AI 자동화 조정 스크립트
# 각 터미널에서 실행할 작업을 조정합니다

`$Tasks = @{
    "Planning" = @"
🧠 플래닝 작업:

현재 SquashTrainingApp 프로젝트 상태를 분석하고 다음 개발 사이클을 계획해주세요.

1. 현재 코드 상태 분석
2. 우선순위 기능 선정
3. 구현 계획 수립
4. 리스크 분석
5. 다른 코더들에게 작업 분배

계획 완료 시 'PLANNING_COMPLETE'를 두 번 Enter로 전송해주세요.
"@

    "Coding1" = @"
🔨 주요 코딩 작업:

플래너가 제공한 계획에 따라 핵심 기능을 구현해주세요.

1. React Native 컴포넌트 구현
2. 상태 관리 로직 작성
3. API 연동 코드 작성
4. 타입스크립트 적용
5. 에러 핸들링 구현

작업 완료 시 'CODING1_COMPLETE'를 두 번 Enter로 전송해주세요.
"@

    "Testing" = @"
🔧 테스트 및 디버깅:

작성된 코드를 테스트하고 버그를 수정해주세요.

1. 빌드 테스트 실행
2. 기능 테스트 수행
3. 버그 발견 및 수정
4. 성능 최적화
5. 에뮬레이터 테스트

테스트 완료 시 'TESTING_COMPLETE'를 두 번 Enter로 전송해주세요.
"@

    "Build" = @"
⚙️ 빌드 및 배포:

앱 빌드 및 배포 준비를 진행해주세요.

1. 빌드 설정 최적화
2. APK 생성 및 테스트
3. 배포 스크립트 작성
4. 에뮬레이터 설치 테스트
5. 문서 업데이트

빌드 완료 시 'BUILD_COMPLETE'를 두 번 Enter로 전송해주세요.
"@

    "Monitor" = @"
📊 모니터링 및 조정:

전체 프로젝트 상황을 모니터링하고 조정해주세요.

1. 각 팀원 작업 상태 확인
2. 진행 상황 리포트
3. 병목 지점 식별
4. 작업 재분배 제안
5. 품질 관리

모니터링 완료 시 'MONITORING_COMPLETE'를 두 번 Enter로 전송해주세요.
"@
}

Write-Host "🚀 Claude AI 자동화 조정 시작" -ForegroundColor Cyan
Write-Host "=" * 60

foreach (`$taskName in `$Tasks.Keys) {
    Write-Host ""
    Write-Host "[$taskName] 작업 내용:" -ForegroundColor Yellow
    Write-Host `$Tasks[`$taskName] -ForegroundColor White
    Write-Host ""
    Write-Host "이 작업을 해당 터미널에 복사하여 붙여넣으세요." -ForegroundColor Green
    Write-Host "Press Enter to continue to next task..."
    Read-Host
}

Write-Host ""
Write-Host "🎯 모든 작업이 완료되면 다음 사이클을 시작하세요!" -ForegroundColor Green
"@

    $coordinatorScript | Out-File -FilePath "$ProjectRoot\scripts\production\automation-coordinator.ps1" -Encoding UTF8
    Write-ColorOutput "✅ 자동화 조정 스크립트 생성됨: automation-coordinator.ps1" "Green"
}

# Main execution
function Main {
    Write-ColorOutput "🚀 Claude AI 터미널 자동화 시스템" "Cyan"
    Write-ColorOutput "=" * 60 "Cyan"
    
    switch ($true) {
        $OpenAll {
            Write-ColorOutput "모든 터미널 열기 시작..." "Green"
            Write-ColorOutput ""
            
            $successCount = 0
            foreach ($config in $TerminalConfigs) {
                if (Open-TerminalTab -Config $config -Index $successCount) {
                    $successCount++
                }
                Start-Sleep -Seconds 1
            }
            
            Write-ColorOutput ""
            Write-ColorOutput "✅ $successCount 개의 터미널이 생성되었습니다." "Green"
            Write-ColorOutput ""
            
            Show-SetupInstructions
            Create-AutomationCoordinator
        }
        
        $Status {
            Show-TerminalStatus
        }
        
        $Close {
            Close-AllTerminals
        }
        
        default {
            Write-ColorOutput "Claude AI 터미널 자동화 시스템" "Green"
            Write-ColorOutput ""
            Write-ColorOutput "사용법:" "Yellow"
            Write-ColorOutput "  -OpenAll    : 모든 터미널 열기" "White"
            Write-ColorOutput "  -Status     : 터미널 상태 확인" "White"
            Write-ColorOutput "  -Close      : 모든 터미널 종료" "White"
            Write-ColorOutput ""
            Write-ColorOutput "예제:" "Yellow"
            Write-ColorOutput "  .\TERMINAL-OPENER.ps1 -OpenAll" "Gray"
            Write-ColorOutput "  .\TERMINAL-OPENER.ps1 -Status" "Gray"
            Write-ColorOutput "  .\TERMINAL-OPENER.ps1 -Close" "Gray"
            Write-ColorOutput ""
            Write-ColorOutput "터미널 설정:" "Yellow"
            foreach ($config in $TerminalConfigs) {
                Write-ColorOutput "  $($config.Name): $($config.Role)" $config.Color
            }
        }
    }
}

Main