#!/usr/bin/env pwsh
# Build using Gradle init script to fix plugin loading

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " React Native Build with Init Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the android directory
if (-not (Test-Path "gradlew.bat")) {
    Write-Host "Error: Must be run from the android directory" -ForegroundColor Red
    exit 1
}

# Step 1: Ensure plugins are built
Write-Host "[1/4] Checking React Native plugins..." -ForegroundColor Yellow

$pluginDir = "..\node_modules\@react-native\gradle-plugin"
$pluginJar = "$pluginDir\react-native-gradle-plugin\build\libs\react-native-gradle-plugin.jar"

if (-not (Test-Path $pluginJar)) {
    Write-Host "  Building React Native plugins..." -ForegroundColor Yellow
    
    Push-Location $pluginDir
    try {
        & cmd /c "gradlew.bat build -x test 2>&1" | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to build React Native gradle plugin" -ForegroundColor Red
            Pop-Location
            exit 1
        }
    } finally {
        Pop-Location
    }
}

Write-Host "✓ Plugins ready" -ForegroundColor Green

# Step 2: Set up environment
Write-Host ""
Write-Host "[2/4] Setting up environment..." -ForegroundColor Yellow

$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

Write-Host "✓ Environment configured" -ForegroundColor Green

# Step 3: Clean build
Write-Host ""
Write-Host "[3/4] Cleaning build directories..." -ForegroundColor Yellow

& cmd /c "gradlew.bat clean --init-script init.gradle 2>&1" | Out-Null
Write-Host "✓ Build cleaned" -ForegroundColor Green

# Step 4: Build with init script
Write-Host ""
Write-Host "[4/4] Building Android app with init script..." -ForegroundColor Yellow

try {
    & cmd /c "gradlew.bat assembleDebug --init-script init.gradle --no-daemon 2>&1" | ForEach-Object {
        Write-Host $_
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host " BUILD SUCCESSFUL!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        
        $apkPath = "app\build\outputs\apk\debug\app-debug.apk"
        if (Test-Path $apkPath) {
            $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
            Write-Host ""
            Write-Host "APK: $((Get-Item $apkPath).FullName)" -ForegroundColor Cyan
            Write-Host "Size: ${apkSize} MB" -ForegroundColor Cyan
        }
    } else {
        Write-Host ""
        Write-Host "BUILD FAILED" -ForegroundColor Red
    }
} catch {
    Write-Host "Build error: $_" -ForegroundColor Red
    exit 1
}