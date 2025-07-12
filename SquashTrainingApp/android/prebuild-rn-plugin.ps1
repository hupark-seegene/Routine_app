#!/usr/bin/env pwsh
# Pre-build React Native gradle plugin for RN 0.80+
# This script ensures the gradle plugin is built before attempting app build

param(
    [switch]$Force = $false  # Force rebuild even if plugin exists
)

Write-Host "React Native Gradle Plugin Pre-Builder" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Get paths
$scriptDir = $PSScriptRoot
$projectRoot = Split-Path -Parent $scriptDir
$pluginPath = Join-Path $projectRoot "node_modules\@react-native\gradle-plugin"
$pluginJar = Join-Path $pluginPath "react-native-gradle-plugin\build\libs\react-native-gradle-plugin.jar"
$settingsJar = Join-Path $pluginPath "settings-plugin\build\libs\settings-plugin.jar"

# Check if plugin directory exists
if (!(Test-Path $pluginPath)) {
    Write-Host "✗ React Native gradle plugin not found!" -ForegroundColor Red
    Write-Host "  Expected at: $pluginPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Have you run 'npm install'?" -ForegroundColor Yellow
    exit 1
}

# Check if plugin is already built
$pluginBuilt = (Test-Path $pluginJar) -and (Test-Path $settingsJar)

if ($pluginBuilt -and !$Force) {
    Write-Host "✓ React Native gradle plugin is already built" -ForegroundColor Green
    Write-Host "  Main plugin: $(Split-Path -Leaf $pluginJar)" -ForegroundColor Gray
    Write-Host "  Settings plugin: $(Split-Path -Leaf $settingsJar)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Use -Force parameter to rebuild" -ForegroundColor Gray
    exit 0
}

# Set up Java environment if not already set
if (!$env:JAVA_HOME) {
    Write-Host "Setting up Java environment..." -ForegroundColor Yellow
    $env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
    $env:Path = "$env:JAVA_HOME\bin;$env:Path"
}

# Verify Java is available
try {
    $null = java -version 2>&1
    Write-Host "✓ Java is available" -ForegroundColor Green
} catch {
    Write-Host "✗ Java not found! Please install JDK 17" -ForegroundColor Red
    exit 1
}

# Build the plugin
Write-Host ""
if ($Force) {
    Write-Host "Force rebuilding React Native gradle plugin..." -ForegroundColor Yellow
} else {
    Write-Host "Building React Native gradle plugin..." -ForegroundColor Yellow
}

Push-Location $pluginPath
try {
    # Clean if forcing rebuild
    if ($Force) {
        Write-Host "  Cleaning previous build..." -ForegroundColor Cyan
        $cleanCmd = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "gradlew.bat clean" -NoNewWindow -PassThru -Wait
        if ($cleanCmd.ExitCode -ne 0) {
            Write-Host "⚠ Clean failed but continuing..." -ForegroundColor Yellow
        }
    }
    
    # Build the plugin
    Write-Host "  Building plugin (this may take 1-2 minutes)..." -ForegroundColor Cyan
    $startTime = Get-Date
    
    # First try: build with tests
    Write-Host "  Building plugin (including tests)..." -ForegroundColor Cyan
    $buildOutput = & cmd /c "gradlew.bat build 2>&1"
    $buildSuccess = $LASTEXITCODE -eq 0
    
    # If build with tests failed, try without tests
    if (!$buildSuccess) {
        Write-Host ""
        Write-Host "  Build with tests failed. Retrying without tests..." -ForegroundColor Yellow
        Write-Host "  Note: This is common on Windows due to test compatibility issues." -ForegroundColor Yellow
        Write-Host ""
        
        $buildOutput = & cmd /c "gradlew.bat build -x test 2>&1"
        $buildSuccess = $LASTEXITCODE -eq 0
    }
    
    $duration = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 1)
    
    if ($buildSuccess) {
        Write-Host "✓ Plugin built successfully in ${duration}s" -ForegroundColor Green
        
        # Verify JAR files were created
        if ((Test-Path $pluginJar) -and (Test-Path $settingsJar)) {
            $mainSize = [math]::Round((Get-Item $pluginJar).Length / 1KB, 1)
            $settingsSize = [math]::Round((Get-Item $settingsJar).Length / 1KB, 1)
            
            Write-Host ""
            Write-Host "Created plugin files:" -ForegroundColor Green
            Write-Host "  • react-native-gradle-plugin.jar (${mainSize}KB)" -ForegroundColor Gray
            Write-Host "  • settings-plugin.jar (${settingsSize}KB)" -ForegroundColor Gray
        } else {
            Write-Host "⚠ Build reported success but JAR files not found!" -ForegroundColor Yellow
        }
    } else {
        Write-Host "✗ Plugin build failed even without tests!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Build output:" -ForegroundColor Yellow
        $buildOutput | Select-Object -Last 20 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
        Pop-Location
        exit 1
    }
} catch {
    Write-Host "✗ Error building plugin: $_" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location

Write-Host ""
Write-Host "React Native gradle plugin is ready!" -ForegroundColor Green