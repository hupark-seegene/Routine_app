# Fix Metro Permission Issues Once and For All
Write-Host "Fixing Metro permission issues..." -ForegroundColor Yellow

# 1. 관리자 권한 확인
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "Restarting with admin rights..." -ForegroundColor Cyan
    Start-Process powershell -Verb RunAs -ArgumentList "-File", $PSCommandPath
    exit
}

Write-Host "Running with administrator privileges" -ForegroundColor Green

# 2. 모든 Node 프로세스 종료
Write-Host "Stopping all Node processes..." -ForegroundColor Yellow
Get-Process -Name node -ErrorAction SilentlyContinue | Stop-Process -Force

# 3. 임시 파일 삭제
Write-Host "Cleaning temporary files..." -ForegroundColor Yellow
$tempPaths = @(
    "$env:TEMP\metro-*",
    "$env:TEMP\react-*",
    "$env:LOCALAPPDATA\Temp\metro-*",
    "$env:APPDATA\npm-cache\_cacache",
    "$PWD\node_modules\.cache",
    "$PWD\node_modules\.bin\.*"
)

foreach ($path in $tempPaths) {
    Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
}

# 4. node_modules 권한 재설정
Write-Host "Resetting node_modules permissions..." -ForegroundColor Yellow
if (Test-Path "node_modules") {
    # 소유권 가져오기
    takeown /f node_modules /r /d y | Out-Null
    
    # 전체 권한 부여
    icacls node_modules /reset /t /c | Out-Null
    icacls node_modules /grant:r "$env:USERNAME:(OI)(CI)F" /t /c | Out-Null
    
    # 읽기 전용 속성 제거
    Get-ChildItem -Path node_modules -Recurse -Force | ForEach-Object {
        $_.Attributes = 'Normal'
    }
}

# 5. Metro 설정 초기화
Write-Host "Resetting Metro configuration..." -ForegroundColor Yellow
Remove-Item -Path "$env:USERPROFILE\.metro-cache" -Recurse -Force -ErrorAction SilentlyContinue

# 6. 대체 Metro 실행 스크립트 생성
Write-Host "Creating Metro wrapper..." -ForegroundColor Yellow
$metroWrapper = @'
const { spawn } = require('child_process');
const path = require('path');

console.log('Starting Metro with fixed permissions...');

// Metro 실행 (권한 문제 우회)
const metro = spawn('node', [
    path.join(__dirname, 'node_modules', 'react-native', 'cli.js'),
    'start',
    '--reset-cache',
    '--no-watchman',
    '--max-workers=2'
], {
    stdio: 'inherit',
    env: { ...process.env, WATCHMAN_CRAWL_DEFER: 0 }
});

metro.on('error', (err) => {
    console.error('Metro error:', err);
    process.exit(1);
});
'@

$metroWrapper | Out-File -Encoding UTF8 "metro-wrapper.js"

Write-Host "`n✓ Permissions fixed!" -ForegroundColor Green
Write-Host "`nNow run:" -ForegroundColor Cyan
Write-Host "  node metro-wrapper.js" -ForegroundColor White
Write-Host "`nOr for debugging:" -ForegroundColor Cyan  
Write-Host "  .\quick-debug.ps1" -ForegroundColor White