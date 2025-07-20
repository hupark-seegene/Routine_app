#!/usr/bin/env pwsh
<#
.SYNOPSIS
    터미널 컨트롤러 - Windows Terminal 자동화
.DESCRIPTION
    열려진 Windows Terminal 탭들을 제어하여 명령 자동 실행
.NOTES
    Author: Claude AI Automation System
    Date: 2025-07-16
    Version: 1.0
#>

param(
    [string]$Action = "control",
    [string]$Terminal = "all",
    [string]$Command = "",
    [switch]$Setup,
    [switch]$Test,
    [switch]$Execute
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogDir = "$ScriptDir/logs/terminal-control"

# Terminal mapping based on your opened terminals
$TerminalTargets = @{
    "planner" = "🧠Claude4-Opus-Planner"
    "coder1" = "🔨Claude4-Sonnet-Coder1" 
    "coder2" = "🔧Claude4-Sonnet-Coder2"
    "coder3" = "⚙️Claude4-Sonnet-Coder3"
    "monitor" = "📊Claude4-Sonnet-Monitor"
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    
    if (!(Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    $logFile = "$LogDir/terminal-control-$(Get-Date -Format 'yyyyMMdd').log"
    
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

function Find-WindowsByTitle {
    param([string]$TitlePattern)
    
    # Use Windows API to find windows
    $signature = @"
[DllImport("user32.dll", SetLastError = true)]
public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

[DllImport("user32.dll", SetLastError = true)]
public static extern bool SetForegroundWindow(IntPtr hwnd);

[DllImport("user32.dll", SetLastError = true)]
public static extern bool ShowWindow(IntPtr hwnd, int nCmdShow);

[DllImport("user32.dll", CharSet = CharSet.Auto)]
public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
"@

    try {
        Add-Type -MemberDefinition $signature -Name WindowAPI -Namespace User32 -ErrorAction SilentlyContinue
    } catch {
        # Type already loaded
    }

    # Find Windows Terminal processes
    $wtProcesses = Get-Process "WindowsTerminal" -ErrorAction SilentlyContinue
    return $wtProcesses
}

function Focus-TerminalWindow {
    param([string]$TerminalTitle)
    
    Write-Log "터미널 포커스 시도: $TerminalTitle" "INFO"
    
    try {
        # Find Windows Terminal windows and try to focus the right one
        $wtProcesses = Get-Process "WindowsTerminal" -ErrorAction SilentlyContinue
        
        if ($wtProcesses) {
            # Focus the first Windows Terminal window
            $hwnd = $wtProcesses[0].MainWindowHandle
            if ($hwnd -ne [System.IntPtr]::Zero) {
                [User32.WindowAPI]::SetForegroundWindow($hwnd)
                [User32.WindowAPI]::ShowWindow($hwnd, 1) # SW_NORMAL
                Start-Sleep -Milliseconds 500
                
                Write-Log "Windows Terminal 포커스 성공" "INFO"
                return $true
            }
        }
        
        Write-Log "Windows Terminal 창을 찾을 수 없음" "WARN"
        return $false
        
    } catch {
        Write-Log "터미널 포커스 실패: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Send-KeysToActiveWindow {
    param([string]$Text)
    
    Write-Log "키 입력 전송: $Text" "INFO"
    
    try {
        # Send text character by character
        foreach ($char in $Text.ToCharArray()) {
            [System.Windows.Forms.SendKeys]::SendWait($char.ToString())
            Start-Sleep -Milliseconds 50
        }
        
        # Send Enter
        [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep -Milliseconds 100
        
        Write-Log "키 입력 전송 완료" "INFO"
        return $true
        
    } catch {
        Write-Log "키 입력 전송 실패: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Navigate-ToTerminalTab {
    param([string]$TerminalName)
    
    Write-Log "터미널 탭 네비게이션: $TerminalName" "INFO"
    
    # Get tab number based on terminal name
    $tabIndex = switch ($TerminalName) {
        "planner" { 1 }
        "coder1" { 2 }
        "coder2" { 3 }
        "coder3" { 4 }
        "monitor" { 5 }
        default { 1 }
    }
    
    try {
        # Use Ctrl+Tab to navigate or Ctrl+Shift+T for new tabs
        # For Windows Terminal, use Ctrl+Shift+[number] to switch to specific tab
        $keySequence = "^+$tabIndex"  # Ctrl+Shift+Number
        [System.Windows.Forms.SendKeys]::SendWait($keySequence)
        Start-Sleep -Milliseconds 500
        
        Write-Log "탭 $tabIndex 로 전환 완료" "INFO"
        return $true
        
    } catch {
        Write-Log "탭 전환 실패: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Send-CommandToTerminal {
    param(
        [string]$TerminalName,
        [string]$Command,
        [bool]$WaitForCompletion = $true
    )
    
    Write-Log "터미널 명령 전송 시작: $TerminalName -> $Command" "INFO"
    
    try {
        # Step 1: Focus Windows Terminal
        if (!(Focus-TerminalWindow -TerminalTitle $TerminalTargets[$TerminalName])) {
            Write-Log "터미널 포커스 실패" "ERROR"
            return $false
        }
        
        # Step 2: Navigate to correct tab
        if (!(Navigate-ToTerminalTab -TerminalName $TerminalName)) {
            Write-Log "탭 네비게이션 실패" "ERROR"
            return $false
        }
        
        # Step 3: Send command
        if (!(Send-KeysToActiveWindow -Text $Command)) {
            Write-Log "명령 전송 실패" "ERROR"
            return $false
        }
        
        # Step 4: Wait if requested
        if ($WaitForCompletion) {
            Start-Sleep -Seconds 2
        }
        
        Write-Log "터미널 명령 전송 완료: $TerminalName" "INFO"
        return $true
        
    } catch {
        Write-Log "터미널 명령 전송 중 오류: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Setup-TerminalEnvironment {
    param([string]$TerminalName)
    
    Write-Log "터미널 환경 설정: $TerminalName" "INFO"
    
    $commands = @(
        "wsl",
        "cd /mnt/c/Git/Routine_app/SquashTrainingApp",
        "pwd"
    )
    
    foreach ($cmd in $commands) {
        if (!(Send-CommandToTerminal -TerminalName $TerminalName -Command $cmd -WaitForCompletion $true)) {
            Write-Log "환경 설정 실패: $TerminalName at command: $cmd" "ERROR"
            return $false
        }
        Start-Sleep -Seconds 2
    }
    
    Write-Log "터미널 환경 설정 완료: $TerminalName" "INFO"
    return $true
}

function Start-ClaudeInTerminal {
    param([string]$TerminalName)
    
    $config = $TerminalTargets[$TerminalName]
    Write-Log "Claude Code 시작: $TerminalName" "INFO"
    
    # Determine Claude model based on terminal
    $claudeModel = if ($TerminalName -eq "planner") {
        "claude-3-opus-20240229"
    } else {
        "claude-3-5-sonnet-20241022"
    }
    
    $claudeCommand = "claude --model $claudeModel"
    
    if (Send-CommandToTerminal -TerminalName $TerminalName -Command $claudeCommand -WaitForCompletion $false) {
        Write-Log "Claude Code 시작 명령 전송 완료: $TerminalName" "INFO"
        return $true
    } else {
        Write-Log "Claude Code 시작 실패: $TerminalName" "ERROR"
        return $false
    }
}

function Test-TerminalConnections {
    Write-Log "터미널 연결 테스트 시작" "INFO"
    
    foreach ($terminalName in $TerminalTargets.Keys) {
        Write-Log "테스트 중: $terminalName" "INFO"
        
        if (Send-CommandToTerminal -TerminalName $terminalName -Command "echo 'Test from $terminalName'" -WaitForCompletion $true) {
            Write-Host "✅ $terminalName 연결 성공" -ForegroundColor Green
        } else {
            Write-Host "❌ $terminalName 연결 실패" -ForegroundColor Red
        }
        
        Start-Sleep -Seconds 1
    }
    
    Write-Log "터미널 연결 테스트 완료" "INFO"
}

function Initialize-AllTerminals {
    Write-Log "모든 터미널 초기화 시작" "INFO"
    
    foreach ($terminalName in $TerminalTargets.Keys) {
        Write-Host "🔧 초기화 중: $($TerminalTargets[$terminalName])" -ForegroundColor Yellow
        
        # Setup environment
        if (Setup-TerminalEnvironment -TerminalName $terminalName) {
            Write-Host "✅ 환경 설정 완료: $terminalName" -ForegroundColor Green
            
            # Start Claude Code
            Start-Sleep -Seconds 2
            if (Start-ClaudeInTerminal -TerminalName $terminalName) {
                Write-Host "✅ Claude Code 시작: $terminalName" -ForegroundColor Green
            } else {
                Write-Host "❌ Claude Code 시작 실패: $terminalName" -ForegroundColor Red
            }
        } else {
            Write-Host "❌ 환경 설정 실패: $terminalName" -ForegroundColor Red
        }
        
        Start-Sleep -Seconds 3
    }
    
    Write-Log "모든 터미널 초기화 완료" "INFO"
    Write-Host "`n🎉 모든 터미널이 준비되었습니다!" -ForegroundColor Green
}

# Main execution
switch ($Action) {
    "setup" {
        Initialize-AllTerminals
    }
    "test" {
        Test-TerminalConnections
    }
    "command" {
        if ($Terminal -and $Command) {
            Send-CommandToTerminal -TerminalName $Terminal -Command $Command
        } else {
            Write-Host "사용법: -Action command -Terminal <terminal> -Command <command>" -ForegroundColor Yellow
        }
    }
    "control" {
        Write-Host "터미널 컨트롤러 준비됨" -ForegroundColor Green
        Write-Host "사용 가능한 액션: setup, test, command" -ForegroundColor Cyan
        Write-Host "터미널 목록: $($TerminalTargets.Keys -join ', ')" -ForegroundColor Cyan
    }
    default {
        Write-Host "사용법: .\TERMINAL-CONTROLLER.ps1 -Action <setup|test|command> [-Terminal <name>] [-Command <cmd>]" -ForegroundColor Yellow
    }
}

# Auto-execute based on switches
if ($Setup) { Initialize-AllTerminals }
if ($Test) { Test-TerminalConnections }
if ($Execute -and $Terminal -and $Command) { 
    Send-CommandToTerminal -TerminalName $Terminal -Command $Command 
}