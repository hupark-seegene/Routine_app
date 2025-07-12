#!/usr/bin/env pwsh
# Main Android build script for React Native 0.80+
# This script handles environment setup and React Native gradle plugin pre-building

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " React Native Android Build Script" -ForegroundColor Cyan
Write-Host " Version: 1.0 for RN 0.80+" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Set up Java environment
Write-Host "[1/5] Setting up Java environment..." -ForegroundColor Yellow
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

# Verify Java installation
try {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "✓ Java configured: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Java not found! Please install JDK 17 from Eclipse Adoptium" -ForegroundColor Red
    Write-Host "  Download from: https://adoptium.net/temurin/releases/?version=17" -ForegroundColor Yellow
    exit 1
}

# Step 2: Set up Android SDK environment
Write-Host ""
Write-Host "[2/5] Setting up Android SDK environment..." -ForegroundColor Yellow
$env:ANDROID_HOME = "C:\Users\hwpar\AppData\Local\Android\Sdk"
$env:Path = "$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\tools;$env:Path"

if (Test-Path $env:ANDROID_HOME) {
    Write-Host "✓ Android SDK found at: $env:ANDROID_HOME" -ForegroundColor Green
} else {
    Write-Host "✗ Android SDK not found at: $env:ANDROID_HOME" -ForegroundColor Red
    Write-Host "  Please install Android Studio or update the path in this script" -ForegroundColor Yellow
    exit 1
}

# Step 3: Pre-build React Native gradle plugin
Write-Host ""
Write-Host "[3/5] Pre-building React Native gradle plugin..." -ForegroundColor Yellow

$scriptDir = $PSScriptRoot
$projectRoot = Split-Path -Parent $scriptDir
$pluginPath = Join-Path $projectRoot "node_modules\@react-native\gradle-plugin"
$pluginJar = Join-Path $pluginPath "react-native-gradle-plugin\build\libs\react-native-gradle-plugin.jar"

# Check if plugin needs to be built
if (Test-Path $pluginJar) {
    Write-Host "✓ React Native gradle plugin already built" -ForegroundColor Green
} else {
    Write-Host "  Building React Native gradle plugin (this may take a minute)..." -ForegroundColor Cyan
    
    Push-Location $pluginPath
    try {
        # First try: build with tests
        Write-Host "  Attempting build with tests..." -ForegroundColor Cyan
        $buildProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "gradlew.bat build" -NoNewWindow -PassThru -Wait
        
        if ($buildProcess.ExitCode -ne 0) {
            # If failed, try without tests
            Write-Host "  Build with tests failed. Retrying without tests..." -ForegroundColor Yellow
            Write-Host "  Note: This is common on Windows due to test compatibility issues." -ForegroundColor Yellow
            $buildProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "gradlew.bat build -x test" -NoNewWindow -PassThru -Wait
        }
        
        if ($buildProcess.ExitCode -eq 0) {
            Write-Host "✓ React Native gradle plugin built successfully" -ForegroundColor Green
        } else {
            Write-Host "✗ Failed to build React Native gradle plugin even without tests" -ForegroundColor Red
            Pop-Location
            exit 1
        }
    } catch {
        Write-Host "✗ Error building React Native gradle plugin: $_" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    Pop-Location
}

# Step 4: Clean previous builds
Write-Host ""
Write-Host "[4/5] Cleaning previous builds..." -ForegroundColor Yellow

Push-Location $scriptDir
try {
    $cleanProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "gradlew.bat clean" -NoNewWindow -PassThru -Wait
    
    if ($cleanProcess.ExitCode -eq 0) {
        Write-Host "✓ Clean completed successfully" -ForegroundColor Green
    } else {
        Write-Host "⚠ Clean had issues but continuing..." -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠ Could not clean, continuing anyway..." -ForegroundColor Yellow
}

# Step 5: Build the app
Write-Host ""
Write-Host "[5/5] Building Android app (Debug)..." -ForegroundColor Yellow
Write-Host "  This may take several minutes on first build..." -ForegroundColor Cyan

try {
    # Run the build with real-time output
    & cmd /c "gradlew.bat assembleDebug 2>&1" | ForEach-Object {
        if ($_ -match "BUILD SUCCESSFUL") {
            Write-Host $_ -ForegroundColor Green
        } elseif ($_ -match "BUILD FAILED|ERROR|Exception") {
            Write-Host $_ -ForegroundColor Red
        } elseif ($_ -match "Warning|warning|WARN") {
            Write-Host $_ -ForegroundColor Yellow
        } else {
            Write-Host $_
        }
    }
    
    # Check if APK was created
    $apkPath = Join-Path $scriptDir "app\build\outputs\apk\debug\app-debug.apk"
    if (Test-Path $apkPath) {
        $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "✓ BUILD SUCCESSFUL!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "APK Location: $apkPath" -ForegroundColor Cyan
        Write-Host "APK Size: ${apkSize}MB" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "To install on connected device:" -ForegroundColor Yellow
        Write-Host "  adb install `"$apkPath`"" -ForegroundColor White
    } else {
        Write-Host ""
        Write-Host "✗ Build appeared to complete but APK not found!" -ForegroundColor Red
        Write-Host "  Check the build output above for errors" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host ""
    Write-Host "✗ Build failed with error: $_" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "Build completed at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray