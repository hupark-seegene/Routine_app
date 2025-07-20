# SquashTrainingApp 한글화 완료 빌드 스크립트
# 목적: 한글화가 완료된 앱을 빌드하고 설치/테스트

$ErrorActionPreference = "Stop"

# 색상 설정
$colors = @{
    GREEN = [ConsoleColor]::Green
    YELLOW = [ConsoleColor]::Yellow
    RED = [ConsoleColor]::Red
    CYAN = [ConsoleColor]::Cyan
    BLUE = [ConsoleColor]::Blue
}

function Write-ColorOutput($message, $color = "GREEN") {
    Write-Host $message -ForegroundColor $colors[$color]
}

# DDD 버전 관리
$currentDDD = 5
$dddPath = "$PSScriptRoot/../../ddd/ddd$('{0:D3}' -f $currentDDD)"

# 현재 날짜/시간
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-ColorOutput "`n========================================" "CYAN"
Write-ColorOutput "🌏 한글화 완료 앱 빌드 시작" "CYAN"
Write-ColorOutput "DDD: $currentDDD | Time: $timestamp" "YELLOW"
Write-ColorOutput "========================================`n" "CYAN"

# 1. 프로젝트 디렉토리로 이동
Write-ColorOutput "📂 프로젝트 디렉토리로 이동..." "BLUE"
Set-Location "$PSScriptRoot/../.."

# 2. DDD 디렉토리 생성
Write-ColorOutput "`n📁 DDD$currentDDD 디렉토리 생성..." "BLUE"
if (!(Test-Path $dddPath)) {
    New-Item -ItemType Directory -Path $dddPath | Out-Null
}

# 3. 캐시 정리
Write-ColorOutput "`n🧹 캐시 및 이전 빌드 정리..." "YELLOW"
if (Test-Path "android/app/build") {
    Remove-Item -Recurse -Force "android/app/build"
}
if (Test-Path "android/.gradle") {
    Remove-Item -Recurse -Force "android/.gradle"
}

# 4. 종속성 설치 확인
Write-ColorOutput "`n📦 종속성 확인..." "BLUE"
if (!(Test-Path "node_modules")) {
    Write-ColorOutput "종속성 설치 중..." "YELLOW"
    npm install
}

# 5. 빌드 실행
Write-ColorOutput "`n🔨 앱 빌드 중..." "GREEN"
cd android
./gradlew assembleDebug

if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "`n❌ 빌드 실패!" "RED"
    exit 1
}

# 6. APK 복사
Write-ColorOutput "`n📋 APK 파일 복사..." "BLUE"
$apkSource = "app/build/outputs/apk/debug/app-debug.apk"
$apkDest = "$dddPath/SquashTrainingApp-Localized-v$currentDDD.apk"

if (Test-Path $apkSource) {
    Copy-Item $apkSource $apkDest
    Write-ColorOutput "✅ APK 복사 완료: $apkDest" "GREEN"
} else {
    Write-ColorOutput "❌ APK 파일을 찾을 수 없습니다!" "RED"
    exit 1
}

# 7. 에뮬레이터 확인
Write-ColorOutput "`n📱 에뮬레이터 확인..." "BLUE"
$devices = adb devices | Select-String -Pattern "emulator|device" | Where-Object { $_ -notmatch "List of devices" }

if ($devices.Count -eq 0) {
    Write-ColorOutput "❌ 연결된 디바이스가 없습니다!" "RED"
    Write-ColorOutput "에뮬레이터를 시작하거나 디바이스를 연결하세요." "YELLOW"
    exit 1
}

# 8. 이전 앱 제거
Write-ColorOutput "`n🗑️ 이전 버전 제거..." "YELLOW"
adb uninstall com.squashtrainingapp 2>$null

# 9. 새 버전 설치
Write-ColorOutput "`n📲 새 버전 설치..." "GREEN"
adb install -r $apkDest

if ($LASTEXITCODE -eq 0) {
    Write-ColorOutput "✅ 설치 완료!" "GREEN"
} else {
    Write-ColorOutput "❌ 설치 실패!" "RED"
    exit 1
}

# 10. 앱 실행
Write-ColorOutput "`n🚀 앱 실행..." "CYAN"
adb shell am start -n com.squashtrainingapp/.MainActivity

# 11. 한글화 테스트 가이드
Write-ColorOutput "`n========================================" "CYAN"
Write-ColorOutput "🌏 한글화 테스트 가이드" "CYAN"
Write-ColorOutput "========================================" "CYAN"
Write-ColorOutput "`n1️⃣ 설정(Settings)으로 이동" "YELLOW"
Write-ColorOutput "2️⃣ 언어(Language)를 '한국어'로 변경" "YELLOW"
Write-ColorOutput "3️⃣ 앱을 재시작하여 한글화 확인" "YELLOW"
Write-ColorOutput "`n테스트 항목:" "GREEN"
Write-ColorOutput "✔️ 메인 화면 마스코트 안내 메시지" "WHITE"
Write-ColorOutput "✔️ 각 화면 제목 및 텍스트" "WHITE"
Write-ColorOutput "✔️ 음성 명령 응답 메시지" "WHITE"
Write-ColorOutput "✔️ 토스트 메시지 및 다이얼로그" "WHITE"
Write-ColorOutput "✔️ 설정 화면 모든 옵션" "WHITE"

# 12. 로그 모니터링
Write-ColorOutput "`n📊 로그 모니터링 시작 (Ctrl+C로 종료)..." "BLUE"
Write-ColorOutput "========================================`n" "CYAN"

adb logcat -c
adb logcat | Select-String -Pattern "squashtrainingapp|MainActivity|Voice|한글|Korean"