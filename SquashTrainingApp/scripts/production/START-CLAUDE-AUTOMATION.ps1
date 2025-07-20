#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Claude AI 자동화 시스템 시작 스크립트
.DESCRIPTION
    터미널을 열고 Claude AI 자동화 시스템을 시작합니다
.NOTES
    Author: Claude AI Automation System
    Date: 2025-07-16
    Version: 1.0
#>

Write-Host "🚀 Claude AI 자동화 시스템 시작" -ForegroundColor Cyan
Write-Host "=" * 60

Write-Host ""
Write-Host "1️⃣ 터미널 열기..." -ForegroundColor Yellow
& "$PSScriptRoot\TERMINAL-OPENER.ps1" -OpenAll

Write-Host ""
Write-Host "2️⃣ 각 터미널에서 다음 명령을 실행하세요:" -ForegroundColor Yellow
Write-Host ""

Write-Host "🧠 플래너 터미널:" -ForegroundColor Blue
Write-Host "   wsl" -ForegroundColor Gray
Write-Host "   cd /mnt/c/Git/Routine_app/SquashTrainingApp" -ForegroundColor Gray
Write-Host "   claude --model claude-3-opus-20240229" -ForegroundColor Gray
Write-Host ""

Write-Host "🔨 코더 터미널들:" -ForegroundColor Green
Write-Host "   wsl" -ForegroundColor Gray
Write-Host "   cd /mnt/c/Git/Routine_app/SquashTrainingApp" -ForegroundColor Gray
Write-Host "   claude --model claude-3-5-sonnet-20241022" -ForegroundColor Gray
Write-Host ""

Write-Host "⚠️ 중요: Claude Code에서는 Enter를 두 번 눌러야 명령이 전달됩니다!" -ForegroundColor Red
Write-Host ""

Write-Host "3️⃣ 모든 터미널 설정 완료 후 자동화 조정 스크립트 실행:" -ForegroundColor Yellow
Write-Host "   .\automation-coordinator.ps1" -ForegroundColor Gray
Write-Host ""

Write-Host "✅ 준비 완료! 각 터미널에서 설정을 진행하세요." -ForegroundColor Green

Read-Host "Press Enter to continue..."