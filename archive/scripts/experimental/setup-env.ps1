#!/usr/bin/env pwsh
# Environment setup script for React Native Android builds
# Sets up Java, Android SDK, and other required environment variables

Write-Host "React Native Build Environment Setup" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

$issues = @()

# Java Environment Setup
Write-Host "Java Environment:" -ForegroundColor Yellow
$javaHome = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"

if (Test-Path $javaHome) {
    $env:JAVA_HOME = $javaHome
    $env:Path = "$env:JAVA_HOME\bin;$env:Path"
    Write-Host "  ✓ JAVA_HOME: $env:JAVA_HOME" -ForegroundColor Green
    
    # Test Java
    try {
        $javaVersion = & java -version 2>&1 | Select-String "version" | Out-String
        Write-Host "  ✓ Java Version: $($javaVersion.Trim())" -ForegroundColor Green
    } catch {
        $issues += "Java executable not working properly"
    }
} else {
    $issues += "Java JDK not found at: $javaHome"
    Write-Host "  ✗ Java JDK not found at: $javaHome" -ForegroundColor Red
}

# Android SDK Setup
Write-Host ""
Write-Host "Android SDK Environment:" -ForegroundColor Yellow
$androidHome = "C:\Users\hwpar\AppData\Local\Android\Sdk"

if (Test-Path $androidHome) {
    $env:ANDROID_HOME = $androidHome
    $env:Path = "$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\tools;$env:ANDROID_HOME\tools\bin;$env:Path"
    Write-Host "  ✓ ANDROID_HOME: $env:ANDROID_HOME" -ForegroundColor Green
    
    # Check for essential Android SDK components
    $platformTools = Join-Path $androidHome "platform-tools\adb.exe"
    if (Test-Path $platformTools) {
        Write-Host "  ✓ Platform Tools: Found" -ForegroundColor Green
        
        # Test ADB
        try {
            $adbVersion = & $platformTools version 2>&1 | Select-String "Version" | Out-String
            Write-Host "  ✓ ADB: $($adbVersion.Trim())" -ForegroundColor Green
        } catch {
            $issues += "ADB not working properly"
        }
    } else {
        $issues += "Android Platform Tools not installed"
        Write-Host "  ✗ Platform Tools: Not found" -ForegroundColor Red
    }
} else {
    $issues += "Android SDK not found at: $androidHome"
    Write-Host "  ✗ Android SDK not found at: $androidHome" -ForegroundColor Red
}

# Node.js Environment Check
Write-Host ""
Write-Host "Node.js Environment:" -ForegroundColor Yellow
try {
    $nodeVersion = & node --version 2>&1
    $npmVersion = & npm --version 2>&1
    Write-Host "  ✓ Node.js: $nodeVersion" -ForegroundColor Green
    Write-Host "  ✓ NPM: v$npmVersion" -ForegroundColor Green
} catch {
    $issues += "Node.js not found in PATH"
    Write-Host "  ✗ Node.js not found" -ForegroundColor Red
}

# React Native Project Check
Write-Host ""
Write-Host "React Native Project:" -ForegroundColor Yellow
$projectRoot = Split-Path -Parent $PSScriptRoot
$packageJson = Join-Path $projectRoot "package.json"
$nodeModules = Join-Path $projectRoot "node_modules"

if (Test-Path $packageJson) {
    Write-Host "  ✓ package.json found" -ForegroundColor Green
    
    # Check React Native version
    try {
        $packageContent = Get-Content $packageJson -Raw | ConvertFrom-Json
        $rnVersion = $packageContent.dependencies.'react-native'
        Write-Host "  ✓ React Native version: $rnVersion" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ Could not read React Native version" -ForegroundColor Yellow
    }
} else {
    $issues += "package.json not found"
    Write-Host "  ✗ package.json not found" -ForegroundColor Red
}

if (Test-Path $nodeModules) {
    $moduleCount = (Get-ChildItem $nodeModules).Count
    Write-Host "  ✓ node_modules: $moduleCount packages" -ForegroundColor Green
} else {
    $issues += "node_modules not found - run 'npm install'"
    Write-Host "  ✗ node_modules not found" -ForegroundColor Red
}

# Gradle Wrapper Check
Write-Host ""
Write-Host "Gradle Configuration:" -ForegroundColor Yellow
$gradlewPath = Join-Path $PSScriptRoot "gradlew.bat"

if (Test-Path $gradlewPath) {
    Write-Host "  ✓ gradlew.bat found" -ForegroundColor Green
    
    # Check gradle properties
    $gradleProps = Join-Path $PSScriptRoot "gradle.properties"
    if (Test-Path $gradleProps) {
        Write-Host "  ✓ gradle.properties found" -ForegroundColor Green
    } else {
        $issues += "gradle.properties not found"
        Write-Host "  ✗ gradle.properties not found" -ForegroundColor Red
    }
} else {
    $issues += "gradlew.bat not found"
    Write-Host "  ✗ gradlew.bat not found" -ForegroundColor Red
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
if ($issues.Count -eq 0) {
    Write-Host "✓ Environment is properly configured!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now run:" -ForegroundColor Yellow
    Write-Host "  .\build-android.ps1" -ForegroundColor White
    Write-Host ""
    exit 0
} else {
    Write-Host "✗ Environment has issues:" -ForegroundColor Red
    Write-Host ""
    foreach ($issue in $issues) {
        Write-Host "  • $issue" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "Please fix the issues above before building." -ForegroundColor Yellow
    exit 1
}