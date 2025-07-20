#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Simple Multi-Terminal Opener for Claude AI
.DESCRIPTION
    Opens 5 Windows Terminal tabs for Claude AI automation
.NOTES
    Version: 1.0
#>

Write-Host "🚀 Claude AI 터미널 자동화 시스템" -ForegroundColor Cyan
Write-Host "=" * 60

# Terminal configurations
$terminals = @(
    "🧠Claude4-Opus-Planner",
    "🔨Claude4-Sonnet-Coder1", 
    "🔧Claude4-Sonnet-Coder2",
    "⚙️Claude4-Sonnet-Coder3",
    "📊Claude4-Sonnet-Monitor"
)

Write-Host "터미널 생성 중..." -ForegroundColor Yellow
Write-Host ""

# Check if Windows Terminal is available
try {
    Get-Command wt -ErrorAction Stop | Out-Null
    Write-Host "✅ Windows Terminal 사용 가능" -ForegroundColor Green
} catch {
    Write-Host "❌ Windows Terminal 설치 필요" -ForegroundColor Red
    Write-Host "Microsoft Store에서 Windows Terminal을 설치하세요" -ForegroundColor Gray
    exit 1
}

# Open terminals
foreach ($terminal in $terminals) {
    try {
        Write-Host "생성 중: $terminal" -ForegroundColor White
        
        # Create new terminal tab
        Start-Process -FilePath "wt.exe" -ArgumentList "new-tab", "--title", "`"$terminal`"", "PowerShell.exe" -WindowStyle Hidden
        Start-Sleep -Seconds 1
        
        Write-Host "✅ 생성됨: $terminal" -ForegroundColor Green
    } catch {
        Write-Host "❌ 생성 실패: $terminal" -ForegroundColor Red
        Write-Host "오류: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "✅ 모든 터미널이 생성되었습니다!" -ForegroundColor Green
Write-Host ""

Write-Host "다음 단계:" -ForegroundColor Yellow
Write-Host "1. 각 터미널에서 WSL 환경 진입: wsl" -ForegroundColor White
Write-Host "2. 프로젝트 디렉토리 이동: cd /mnt/c/Git/Routine_app/SquashTrainingApp" -ForegroundColor White
Write-Host "3. Claude Code 시작:" -ForegroundColor White
Write-Host "   - 플래너: claude --model claude-3-opus-20240229" -ForegroundColor Gray
Write-Host "   - 코더들: claude --model claude-3-5-sonnet-20241022" -ForegroundColor Gray
Write-Host ""
Write-Host "⚠️ 중요: Claude Code에서는 Enter를 두 번 눌러야 명령이 전달됩니다!" -ForegroundColor Red
Write-Host ""
Write-Host "터미널 역할:" -ForegroundColor Yellow
Write-Host "🧠 Claude4-Opus-Planner: 계획 및 아키텍처 설계" -ForegroundColor Blue
Write-Host "🔨 Claude4-Sonnet-Coder1: 주요 코드 구현" -ForegroundColor Green
Write-Host "🔧 Claude4-Sonnet-Coder2: 테스트 및 디버깅" -ForegroundColor Yellow
Write-Host "⚙️ Claude4-Sonnet-Coder3: 빌드 및 배포" -ForegroundColor Cyan
Write-Host "📊 Claude4-Sonnet-Monitor: 모니터링 및 조정" -ForegroundColor Magenta
Write-Host ""

Read-Host "Press Enter to continue..."