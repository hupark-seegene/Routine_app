#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Claude AI 완전 자동화 런처
.DESCRIPTION
    모든 Claude AI 자동화 시스템을 통합하여 시작하는 마스터 스크립트
.NOTES
    Author: Claude AI Automation System
    Date: 2025-07-16
    Version: 1.0
#>

param(
    [switch]$Quick,
    [switch]$Setup,
    [switch]$Status,
    [switch]$Stop,
    [int]$Cycles = 50
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item "$ScriptDir/../..").FullName

function Show-WelcomeMessage {
    Clear-Host
    Write-Host @"
  
 ██████╗██╗      █████╗ ██╗   ██╗██████╗ ███████╗     █████╗ ██╗
██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝    ██╔══██╗██║
██║     ██║     ███████║██║   ██║██║  ██║█████╗      ███████║██║
██║     ██║     ██╔══██║██║   ██║██║  ██║██╔══╝      ██╔══██║██║
╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝███████╗    ██║  ██║██║
 ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝    ╚═╝  ╚═╝╚═╝
                                                                  
         SquashTrainingApp 자동화 개발 시스템
"@ -ForegroundColor Cyan

    Write-Host ""
    Write-Host "🎯 목표: 완성된 React Native 앱 개발 및 $Cycles 회 반복 테스트" -ForegroundColor Yellow
    Write-Host "🤖 AI 모델: Claude 4 Opus (계획) + Claude 4 Sonnet (코딩)" -ForegroundColor Green
    Write-Host "🔄 사이클: 설치 → 실행 → 테스트 → 디버그 → 수정 → 반복" -ForegroundColor Cyan
    Write-Host ""
}

function Show-AutomationMenu {
    Write-Host "자동화 옵션을 선택하세요:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. 🚀 빠른 시작 (터미널 열기 + 가이드)" -ForegroundColor Green
    Write-Host "2. 🛠️ 환경 설정 (의존성 확인 + 설정)" -ForegroundColor Blue
    Write-Host "3. 📊 상태 확인 (현재 프로세스 상태)" -ForegroundColor Cyan
    Write-Host "4. ⏹️ 자동화 중단 (모든 프로세스 종료)" -ForegroundColor Red
    Write-Host "5. 📖 도움말 (상세 가이드)" -ForegroundColor Magenta
    Write-Host ""
    
    $choice = Read-Host "선택 (1-5)"
    return $choice
}

function Quick-Start {
    Write-Host "🚀 빠른 시작 모드" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "1️⃣ 터미널 열기..." -ForegroundColor Yellow
    & "$ScriptDir\TERMINAL-OPENER.ps1" -OpenAll
    
    Write-Host ""
    Write-Host "2️⃣ 자동화 설정 완료!" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "다음 단계:" -ForegroundColor Yellow
    Write-Host "• 각 터미널에서 WSL 환경 설정 (wsl 명령)" -ForegroundColor White
    Write-Host "• Claude Code 시작 (claude 명령)" -ForegroundColor White
    Write-Host "• 자동화 조정 스크립트 실행 (automation-coordinator.ps1)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "⚠️ 주의사항:" -ForegroundColor Red
    Write-Host "• Claude Code에서는 Enter를 두 번 눌러야 명령이 전달됩니다" -ForegroundColor Red
    Write-Host "• 각 터미널은 고유한 역할을 담당합니다" -ForegroundColor Red
    Write-Host ""
}

function Setup-Environment {
    Write-Host "🛠️ 환경 설정 시작" -ForegroundColor Blue
    Write-Host ""
    
    Write-Host "의존성 확인 중..." -ForegroundColor Yellow
    
    # Check Windows Terminal
    try {
        Get-Command wt -ErrorAction Stop | Out-Null
        Write-Host "✅ Windows Terminal 설치됨" -ForegroundColor Green
    } catch {
        Write-Host "❌ Windows Terminal 설치 필요" -ForegroundColor Red
        Write-Host "   Microsoft Store에서 설치하세요" -ForegroundColor Gray
    }
    
    # Check WSL
    try {
        wsl --list --quiet | Out-Null
        Write-Host "✅ WSL 사용 가능" -ForegroundColor Green
    } catch {
        Write-Host "❌ WSL 설치 또는 설정 필요" -ForegroundColor Red
        Write-Host "   wsl --install 명령을 실행하세요" -ForegroundColor Gray
    }
    
    # Check Claude Code
    try {
        wsl which claude | Out-Null
        Write-Host "✅ Claude Code WSL에 설치됨" -ForegroundColor Green
    } catch {
        Write-Host "❌ Claude Code WSL 설치 필요" -ForegroundColor Red
        Write-Host "   WSL에서 Claude Code를 설치하세요" -ForegroundColor Gray
    }
    
    # Check Python dependencies
    Write-Host ""
    Write-Host "Python 의존성 확인 중..." -ForegroundColor Yellow
    $packages = @("pyautogui", "pywin32", "psutil")
    foreach ($package in $packages) {
        try {
            pip show $package | Out-Null
            Write-Host "✅ $package 설치됨" -ForegroundColor Green
        } catch {
            Write-Host "❌ $package 설치 필요" -ForegroundColor Red
            Write-Host "   pip install $package" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Write-Host "✅ 환경 설정 확인 완료!" -ForegroundColor Green
}

function Show-Status {
    Write-Host "📊 시스템 상태 확인" -ForegroundColor Cyan
    Write-Host ""
    
    & "$ScriptDir\TERMINAL-OPENER.ps1" -Status
    
    Write-Host ""
    Write-Host "자동화 프로세스:" -ForegroundColor Yellow
    
    # Check for automation processes
    $wtProcesses = Get-Process "WindowsTerminal" -ErrorAction SilentlyContinue
    $pythonProcesses = Get-Process "python" -ErrorAction SilentlyContinue
    $claudeProcesses = Get-Process -Name "*claude*" -ErrorAction SilentlyContinue
    
    if ($wtProcesses) {
        Write-Host "✅ Windows Terminal 실행 중 ($($wtProcesses.Count) 개)" -ForegroundColor Green
    } else {
        Write-Host "❌ Windows Terminal 실행되지 않음" -ForegroundColor Red
    }
    
    if ($pythonProcesses) {
        Write-Host "✅ Python 프로세스 실행 중 ($($pythonProcesses.Count) 개)" -ForegroundColor Green
    } else {
        Write-Host "❌ Python 프로세스 없음" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "프로젝트 상태:" -ForegroundColor Yellow
    Write-Host "  경로: $ProjectRoot" -ForegroundColor Gray
    Write-Host "  스크립트: $ScriptDir" -ForegroundColor Gray
    
    if (Test-Path "$ScriptDir\logs") {
        $logFiles = Get-ChildItem "$ScriptDir\logs" -Recurse -File
        Write-Host "  로그 파일: $($logFiles.Count) 개" -ForegroundColor Gray
    } else {
        Write-Host "  로그 파일: 없음" -ForegroundColor Gray
    }
}

function Stop-Automation {
    Write-Host "⏹️ 자동화 시스템 중단" -ForegroundColor Red
    Write-Host ""
    
    & "$ScriptDir\TERMINAL-OPENER.ps1" -Close
    
    Write-Host "추가 프로세스 종료 중..." -ForegroundColor Yellow
    
    # Stop Python processes
    $pythonProcesses = Get-Process "python" -ErrorAction SilentlyContinue
    foreach ($process in $pythonProcesses) {
        try {
            $process.Kill()
            Write-Host "✅ Python 프로세스 종료: PID $($process.Id)" -ForegroundColor Green
        } catch {
            Write-Host "❌ Python 프로세스 종료 실패: PID $($process.Id)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "✅ 자동화 시스템 중단 완료!" -ForegroundColor Green
}

function Show-Help {
    Write-Host "📖 Claude AI 자동화 시스템 도움말" -ForegroundColor Magenta
    Write-Host ""
    
    Write-Host "시스템 구성:" -ForegroundColor Yellow
    Write-Host "• 🧠 Claude 4 Opus: 계획 및 아키텍처 설계" -ForegroundColor Blue
    Write-Host "• 🔨 Claude 4 Sonnet: 주요 코드 구현" -ForegroundColor Green
    Write-Host "• 🔧 Claude 4 Sonnet: 테스트 및 디버깅" -ForegroundColor Yellow
    Write-Host "• ⚙️ Claude 4 Sonnet: 빌드 및 배포" -ForegroundColor Cyan
    Write-Host "• 📊 Claude 4 Sonnet: 모니터링 및 조정" -ForegroundColor Magenta
    Write-Host ""
    
    Write-Host "사용 방법:" -ForegroundColor Yellow
    Write-Host "1. 빠른 시작으로 터미널 열기" -ForegroundColor White
    Write-Host "2. 각 터미널에서 WSL 환경 설정" -ForegroundColor White
    Write-Host "3. Claude Code 시작" -ForegroundColor White
    Write-Host "4. 자동화 조정 스크립트 실행" -ForegroundColor White
    Write-Host "5. 50회 반복 개발 사이클 실행" -ForegroundColor White
    Write-Host ""
    
    Write-Host "주요 명령어:" -ForegroundColor Yellow
    Write-Host "• wsl                           : WSL 환경 진입" -ForegroundColor Gray
    Write-Host "• cd /mnt/c/Git/Routine_app/SquashTrainingApp : 프로젝트 디렉토리 이동" -ForegroundColor Gray
    Write-Host "• claude --model MODEL_NAME     : Claude Code 시작" -ForegroundColor Gray
    Write-Host "• automation-coordinator.ps1    : 자동화 조정 스크립트" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "문제 해결:" -ForegroundColor Yellow
    Write-Host "• Claude Code에서 Enter 두 번 눌러야 명령 전달" -ForegroundColor Red
    Write-Host "• WSL 설치 필요 시: wsl --install" -ForegroundColor Gray
    Write-Host "• Windows Terminal 설치 필요 시: Microsoft Store에서 설치" -ForegroundColor Gray
    Write-Host ""
}

# Main execution
function Main {
    Show-WelcomeMessage
    
    if ($Quick) {
        Quick-Start
        return
    }
    
    if ($Setup) {
        Setup-Environment
        return
    }
    
    if ($Status) {
        Show-Status
        return
    }
    
    if ($Stop) {
        Stop-Automation
        return
    }
    
    # Interactive mode
    while ($true) {
        $choice = Show-AutomationMenu
        
        switch ($choice) {
            "1" { Quick-Start; break }
            "2" { Setup-Environment; break }
            "3" { Show-Status; break }
            "4" { Stop-Automation; break }
            "5" { Show-Help; break }
            "q" { Write-Host "종료합니다..." -ForegroundColor Yellow; break }
            "quit" { Write-Host "종료합니다..." -ForegroundColor Yellow; break }
            default { Write-Host "잘못된 선택입니다. 1-5 또는 q를 입력하세요." -ForegroundColor Red }
        }
        
        if ($choice -in @("1", "2", "3", "4", "5")) {
            Write-Host ""
            Read-Host "Press Enter to continue..."
            Clear-Host
            Show-WelcomeMessage
        }
        
        if ($choice -in @("q", "quit")) {
            break
        }
    }
}

Main