#!/usr/bin/env pwsh
# Definitive React Native 0.80+ Build Solution
# This script provides multiple approaches to work around the plugin issues

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("bypass", "init", "cli", "direct")]
    [string]$Method = "bypass"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Definitive RN 0.80+ Build Solution" -ForegroundColor Cyan
Write-Host " Method: $Method" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set up environment first
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

function Build-Bypass {
    Write-Host "Using BYPASS method (most reliable)..." -ForegroundColor Yellow
    
    if (Test-Path "build-bypass.ps1") {
        & .\build-bypass.ps1
    } else {
        Write-Host "Error: build-bypass.ps1 not found" -ForegroundColor Red
        exit 1
    }
}

function Build-Init {
    Write-Host "Using INIT SCRIPT method..." -ForegroundColor Yellow
    
    if (Test-Path "build-with-init.ps1") {
        & .\build-with-init.ps1
    } else {
        Write-Host "Error: build-with-init.ps1 not found" -ForegroundColor Red
        exit 1
    }
}

function Build-CLI {
    Write-Host "Using React Native CLI method..." -ForegroundColor Yellow
    
    Push-Location ..
    try {
        Write-Host "Cleaning..." -ForegroundColor Gray
        & npx react-native clean
        
        Write-Host "Building..." -ForegroundColor Gray
        & npx react-native build-android --mode=debug
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "BUILD SUCCESSFUL!" -ForegroundColor Green
            
            $apkPath = "android\app\build\outputs\apk\debug\app-debug.apk"
            if (Test-Path $apkPath) {
                Write-Host "APK: $((Get-Item $apkPath).FullName)" -ForegroundColor Cyan
            }
        } else {
            Write-Host "BUILD FAILED" -ForegroundColor Red
        }
    } finally {
        Pop-Location
    }
}

function Build-Direct {
    Write-Host "Using DIRECT gradlew method (may fail)..." -ForegroundColor Yellow
    
    # Ensure plugins are built first
    $pluginDir = "..\node_modules\@react-native\gradle-plugin"
    if (Test-Path $pluginDir) {
        Write-Host "Pre-building React Native plugins..." -ForegroundColor Gray
        Push-Location $pluginDir
        & cmd /c "gradlew.bat build -x test 2>&1" | Out-Null
        Pop-Location
    }
    
    Write-Host "Cleaning..." -ForegroundColor Gray
    & cmd /c "gradlew.bat clean 2>&1" | Out-Null
    
    Write-Host "Building..." -ForegroundColor Gray
    & cmd /c "gradlew.bat assembleDebug --no-daemon 2>&1" | ForEach-Object {
        Write-Host $_
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "BUILD SUCCESSFUL!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "BUILD FAILED" -ForegroundColor Red
        Write-Host ""
        Write-Host "This is expected with React Native 0.80+. Try:" -ForegroundColor Yellow
        Write-Host "  .\definitive-build.ps1 -Method bypass" -ForegroundColor White
        Write-Host "  .\definitive-build.ps1 -Method cli" -ForegroundColor White
    }
}

# Execute the selected method
switch ($Method) {
    "bypass" { Build-Bypass }
    "init" { Build-Init }
    "cli" { Build-CLI }
    "direct" { Build-Direct }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Gray
Write-Host " Other methods you can try:" -ForegroundColor Gray
Write-Host "   .\definitive-build.ps1 -Method bypass" -ForegroundColor Gray
Write-Host "   .\definitive-build.ps1 -Method init" -ForegroundColor Gray
Write-Host "   .\definitive-build.ps1 -Method cli" -ForegroundColor Gray
Write-Host "   .\definitive-build.ps1 -Method direct" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Gray