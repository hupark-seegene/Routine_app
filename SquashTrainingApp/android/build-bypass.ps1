#!/usr/bin/env pwsh
# React Native 0.80+ Build Bypass Script
# This script bypasses the problematic plugin system entirely

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " React Native Build Bypass Script" -ForegroundColor Cyan
Write-Host " (Avoids RN 0.80+ plugin issues)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the android directory
if (-not (Test-Path "gradlew.bat")) {
    Write-Host "Error: Must be run from the android directory" -ForegroundColor Red
    exit 1
}

# Step 1: Backup current configuration
Write-Host "[1/6] Backing up current configuration..." -ForegroundColor Yellow

$filesToBackup = @("settings.gradle", "build.gradle", "app/build.gradle")
foreach ($file in $filesToBackup) {
    if ((Test-Path $file) -and !(Test-Path "$file.backup")) {
        Copy-Item $file "$file.backup"
        Write-Host "  Backed up $file" -ForegroundColor Gray
    }
}
Write-Host "✓ Configuration backed up" -ForegroundColor Green

# Step 2: Apply bypass configuration
Write-Host ""
Write-Host "[2/6] Applying bypass configuration..." -ForegroundColor Yellow

try {
    Copy-Item "settings.gradle.bypass" "settings.gradle" -Force
    Copy-Item "build.gradle.bypass" "build.gradle" -Force
    Copy-Item "app/build.gradle.bypass" "app/build.gradle" -Force
    Write-Host "✓ Bypass configuration applied" -ForegroundColor Green
} catch {
    Write-Host "Error applying bypass configuration: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Set up environment
Write-Host ""
Write-Host "[3/6] Setting up environment..." -ForegroundColor Yellow

$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

# Verify Java
$javaVersion = & java -version 2>&1 | Select-String "version"
if ($javaVersion) {
    Write-Host "✓ Java configured: $javaVersion" -ForegroundColor Green
} else {
    Write-Host "Error: Java not found" -ForegroundColor Red
    exit 1
}

# Step 4: Clean previous builds
Write-Host ""
Write-Host "[4/6] Cleaning previous builds..." -ForegroundColor Yellow

& cmd /c "gradlew.bat clean 2>&1" | Out-Null
Remove-Item -Path ".gradle" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "app/build" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "✓ Build directories cleaned" -ForegroundColor Green

# Step 5: Verify configuration
Write-Host ""
Write-Host "[5/6] Verifying bypass configuration..." -ForegroundColor Yellow

& cmd /c "gradlew.bat verifyBypassConfig 2>&1" | ForEach-Object {
    if ($_ -match "React Native Bypass Configuration Active") {
        Write-Host "✓ $_" -ForegroundColor Green
    } else {
        Write-Host "  $_" -ForegroundColor Gray
    }
}

# Step 6: Build the app
Write-Host ""
Write-Host "[6/6] Building Android app..." -ForegroundColor Yellow
Write-Host "  This may take several minutes..." -ForegroundColor Cyan

$buildStart = Get-Date

try {
    # Build with detailed output
    $buildProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "gradlew.bat assembleDebug --no-daemon --stacktrace" -NoNewWindow -PassThru -RedirectStandardOutput "build-output.log" -RedirectStandardError "build-error.log"
    
    # Show progress
    while (!$buildProcess.HasExited) {
        Write-Host "." -NoNewline
        Start-Sleep -Seconds 2
    }
    
    Write-Host ""
    
    if ($buildProcess.ExitCode -eq 0) {
        $buildTime = [math]::Round(((Get-Date) - $buildStart).TotalSeconds, 2)
        
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host " BUILD SUCCESSFUL!" -ForegroundColor Green
        Write-Host " Build time: $buildTime seconds" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        
        $apkPath = "app\build\outputs\apk\debug\app-debug.apk"
        if (Test-Path $apkPath) {
            $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
            Write-Host ""
            Write-Host "APK Details:" -ForegroundColor Cyan
            Write-Host "  Location: $((Get-Item $apkPath).FullName)" -ForegroundColor White
            Write-Host "  Size: ${apkSize} MB" -ForegroundColor White
            Write-Host ""
            Write-Host "Install command:" -ForegroundColor Yellow
            Write-Host "  adb install `"$((Get-Item $apkPath).FullName)`"" -ForegroundColor White
        }
    } else {
        Write-Host ""
        Write-Host "BUILD FAILED (Exit code: $($buildProcess.ExitCode))" -ForegroundColor Red
        Write-Host ""
        Write-Host "Check build-output.log and build-error.log for details" -ForegroundColor Yellow
        
        # Show last few lines of error log
        if (Test-Path "build-error.log") {
            Write-Host ""
            Write-Host "Last error messages:" -ForegroundColor Red
            Get-Content "build-error.log" -Tail 20 | ForEach-Object {
                Write-Host "  $_" -ForegroundColor Red
            }
        }
        
        exit 1
    }
} catch {
    Write-Host "Build error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Gray
Write-Host " Restore original configuration:" -ForegroundColor Gray
Write-Host "   .\restore-config.ps1" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Gray