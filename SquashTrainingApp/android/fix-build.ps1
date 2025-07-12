#!/usr/bin/env pwsh
# Quick fix for React Native 0.80+ build issues

Write-Host "React Native 0.80+ Build Fix" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Ensure we're in android directory
if (-not (Test-Path "gradlew.bat")) {
    Write-Host "Error: Run this from the android directory" -ForegroundColor Red
    exit 1
}

# Step 2: Set Java environment
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
Write-Host "✓ Java environment set" -ForegroundColor Green

# Step 3: Build React Native gradle plugin if needed
$pluginPath = "..\node_modules\@react-native\gradle-plugin"
$pluginJar = "$pluginPath\react-native-gradle-plugin\build\libs\react-native-gradle-plugin.jar"
$settingsJar = "$pluginPath\settings-plugin\build\libs\settings-plugin.jar"
$sharedJar = "$pluginPath\shared\build\libs\shared.jar"

if (-not (Test-Path $pluginJar) -or -not (Test-Path $settingsJar) -or -not (Test-Path $sharedJar)) {
    Write-Host "Building React Native gradle plugin..." -ForegroundColor Yellow
    Push-Location $pluginPath
    try {
        & cmd /c "gradlew.bat build -x test 2>&1"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Warning: Plugin build had issues, but continuing..." -ForegroundColor Yellow
        }
    } finally {
        Pop-Location
    }
}

Write-Host "✓ React Native plugin ready" -ForegroundColor Green
Write-Host ""

# Step 4: Try using npx first (simplest approach)
Write-Host "Attempting build with npx react-native..." -ForegroundColor Yellow
Push-Location ..
try {
    & npx react-native build-android --mode=debug
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "BUILD SUCCESSFUL!" -ForegroundColor Green
        Write-Host "APK location: android\app\build\outputs\apk\debug\app-debug.apk" -ForegroundColor Cyan
        exit 0
    }
} catch {
    Write-Host "npx approach failed, trying direct gradle..." -ForegroundColor Yellow
} finally {
    Pop-Location
}

# Step 5: If npx fails, try direct gradle with clean
Write-Host ""
Write-Host "Trying direct gradle build..." -ForegroundColor Yellow
& cmd /c "gradlew.bat clean 2>&1"
& cmd /c "gradlew.bat assembleDebug 2>&1"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "APK location: app\build\outputs\apk\debug\app-debug.apk" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "Build failed. Common solutions:" -ForegroundColor Red
    Write-Host "1. Close and reopen PowerShell" -ForegroundColor Yellow
    Write-Host "2. Delete node_modules and run npm install again" -ForegroundColor Yellow
    Write-Host "3. Use Android Studio (most reliable)" -ForegroundColor Yellow
    Write-Host "4. Check gradle.properties has correct Java path" -ForegroundColor Yellow
}