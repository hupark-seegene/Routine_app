# Simple Build and Run
Write-Host "BUILD AND RUN - SQUASH TRAINING APP" -ForegroundColor Cyan

# Setup
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$androidHome = Join-Path $env:LOCALAPPDATA "Android\Sdk"
$env:ANDROID_HOME = $androidHome
$adb = Join-Path $androidHome "platform-tools\adb.exe"

# Add to PATH
$javaBin = Join-Path $env:JAVA_HOME "bin"
$adbPath = Join-Path $androidHome "platform-tools"
$env:Path = $javaBin + ";" + $adbPath + ";" + $env:Path

# Clean
Write-Host "Cleaning..." -ForegroundColor Yellow
$androidDir = Join-Path $PSScriptRoot "android"
Push-Location $androidDir
if (Test-Path "app\build") { Remove-Item -Recurse -Force "app\build" }
if (Test-Path ".gradle") { Remove-Item -Recurse -Force ".gradle" }
Pop-Location

# Build
Write-Host "Building APK..." -ForegroundColor Yellow
Push-Location $androidDir
cmd /c "gradlew.bat assembleDebug --no-daemon -x test"
$buildOk = $LASTEXITCODE -eq 0
Pop-Location

if (-not $buildOk) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# Check APK
$apk = Join-Path $androidDir "app\build\outputs\apk\debug\app-debug.apk"
if (-not (Test-Path $apk)) {
    Write-Host "APK not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Build successful!" -ForegroundColor Green

# Install
Write-Host "Installing..." -ForegroundColor Yellow
& $adb uninstall com.squashtrainingapp 2>$null
& $adb install -r $apk

# Launch
Write-Host "Launching..." -ForegroundColor Yellow
& $adb reverse tcp:8081 tcp:8081
& $adb shell am start -n com.squashtrainingapp/.MainActivity

Write-Host "App launched!" -ForegroundColor Green
Write-Host "Starting Metro..." -ForegroundColor Yellow

# Metro
cd $PSScriptRoot
npx react-native start