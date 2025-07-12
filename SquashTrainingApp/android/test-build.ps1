#!/usr/bin/env pwsh
# Test build script to capture autolinking errors
# Updated to include proper environment setup for React Native 0.80+

Write-Host "Starting Android build test..." -ForegroundColor Green

# Set up Java environment FIRST
Write-Host "`nSetting up build environment..." -ForegroundColor Yellow
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

# Set up Android SDK
$env:ANDROID_HOME = "C:\Users\hwpar\AppData\Local\Android\Sdk"
$env:Path = "$env:ANDROID_HOME\platform-tools;$env:Path"

# Change to android directory
Set-Location "C:\Git\Routine_app\SquashTrainingApp\android"

Write-Host "Current directory: $(Get-Location)" -ForegroundColor Blue

# Check Java version (should work now)
Write-Host "`nJava version:" -ForegroundColor Blue
try {
    java -version
} catch {
    Write-Host "ERROR: Java not found even after setting JAVA_HOME!" -ForegroundColor Red
    Write-Host "Please ensure Java JDK 17 is installed at: $env:JAVA_HOME" -ForegroundColor Yellow
    exit 1
}

# Check Gradle wrapper
Write-Host "`nGradle wrapper info:" -ForegroundColor Blue
Get-Item gradlew.bat

# Pre-build React Native gradle plugin (Required for RN 0.80+)
Write-Host "`nPre-building React Native gradle plugin..." -ForegroundColor Yellow
$pluginScript = Join-Path $PSScriptRoot "prebuild-rn-plugin.ps1"
if (Test-Path $pluginScript) {
    & $pluginScript
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to pre-build React Native plugin!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Warning: Plugin pre-build script not found, build may fail!" -ForegroundColor Yellow
}

Write-Host "`nRunning assembleDebug..." -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow

# Run build and capture ALL output
try {
    .\gradlew.bat assembleDebug 2>&1 | Tee-Object -FilePath "build-output.log"
    Write-Host "`nBuild completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "`nBuild failed with error:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n=================================" -ForegroundColor Yellow
Write-Host "Full build output saved to build-output.log" -ForegroundColor Blue