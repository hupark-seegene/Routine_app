#!/usr/bin/env pwsh
# Quick build script - One command to build everything
# This is a convenience wrapper around the main build script

Write-Host "Quick Build - React Native Android" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = $PSScriptRoot

# Check if main build script exists
$buildScript = Join-Path $scriptDir "build-android.ps1"
if (!(Test-Path $buildScript)) {
    Write-Host "✗ Main build script not found at: $buildScript" -ForegroundColor Red
    exit 1
}

# Run the main build script
Write-Host "Starting build process..." -ForegroundColor Yellow
Write-Host ""

& $buildScript

# Exit with the same code as the build script
exit $LASTEXITCODE