# Instant Debug - Metro 없이 즉시 디버깅
$ErrorActionPreference = "Continue"

Write-Host "`n=== Instant Debug Mode ===" -ForegroundColor Green

# 1. 번들 직접 생성
Write-Host "Creating bundle..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "app\src\main\assets" -Force | Out-Null

# React Native 앱을 위한 최소 번들
@'
// Instant debug bundle
if (typeof global === 'undefined') { global = window; }
global.__DEV__ = true;
global.__BUNDLE_START_TIME__ = Date.now();
console.log('Debug bundle loaded at', new Date().toISOString());

// React Native 초기화
try {
    require('react-native');
    console.log('React Native loaded successfully');
} catch (e) {
    console.error('Failed to load React Native:', e);
}

// 앱 엔트리포인트
try {
    require('../../index.js');
} catch (e) {
    console.error('Failed to load app:', e);
}
'@ | Out-File -Encoding ASCII "app\src\main\assets\index.android.bundle"

# 2. 빠른 빌드 (Metro 없이)
Write-Host "Building APK..." -ForegroundColor Yellow
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"

$buildStart = Get-Date
.\gradlew.bat assembleDebug --no-daemon --offline 2>$null
$buildTime = ((Get-Date) - $buildStart).TotalSeconds

if (Test-Path "app\build\outputs\apk\debug\app-debug.apk") {
    Write-Host "✓ Build successful ($([math]::Round($buildTime, 1))s)" -ForegroundColor Green
    
    # 3. 설치 및 실행
    Write-Host "Installing..." -ForegroundColor Yellow
    adb install -r app\build\outputs\apk\debug\app-debug.apk 2>$null
    
    # 4. 앱 시작
    adb shell am start -n com.squashtrainingapp/.MainActivity
    
    # 5. 로그 스트리밍
    Write-Host "`n=== App Running - Logs ===" -ForegroundColor Cyan
    adb logcat -c
    adb logcat *:S ReactNative:D ReactNativeJS:D AndroidRuntime:E
} else {
    Write-Host "✗ Build failed!" -ForegroundColor Red
    Write-Host "Running with existing APK..." -ForegroundColor Yellow
    
    # 기존 APK로 시도
    adb shell am start -n com.squashtrainingapp/.MainActivity 2>$null
    adb logcat *:S ReactNative:D ReactNativeJS:D
}