# Quick Debug - Metro 없이 바로 실행
Write-Host "Quick Debug Setup..." -ForegroundColor Cyan

# 1. Metro 프로세스 종료
taskkill /F /IM node.exe 2>$null

# 2. 번들 생성 (Metro 우회)
$bundle = @"
// Debug bundle - bypassing Metro
console.log('Debug mode active');
global.__DEV__ = true;
"@

$bundlePath = "android\app\src\main\assets"
New-Item -ItemType Directory -Path $bundlePath -Force -ErrorAction SilentlyContinue | Out-Null
$bundle | Out-File -Encoding ASCII "$bundlePath\index.android.bundle"

# 3. 에뮬레이터 확인
$devices = adb devices 2>$null
if ($devices -notmatch "device") {
    Write-Host "Starting emulator..." -ForegroundColor Yellow
    $emulator = "${env:LOCALAPPDATA}\Android\Sdk\emulator\emulator.exe"
    if (Test-Path $emulator) {
        $avd = & $emulator -list-avds | Select-Object -First 1
        if ($avd) {
            Start-Process $emulator -ArgumentList "-avd", $avd -WindowStyle Hidden
            Write-Host "Waiting 30 seconds for emulator..." -ForegroundColor Yellow
            Start-Sleep -Seconds 30
        }
    }
}

# 4. 앱 설치 및 실행
Write-Host "Installing app..." -ForegroundColor Green
Set-Location android
.\gradlew.bat installDebug --no-daemon --quiet

# 5. 앱 실행
adb shell am start -n com.squashtrainingapp/.MainActivity

# 6. 로그 표시
Write-Host "`n✓ App launched! Showing logs..." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop`n" -ForegroundColor Gray
adb logcat *:S ReactNative:V ReactNativeJS:V