#!/usr/bin/env pwsh
# BUILD-APK-2025.ps1
# Squash Training App APK Build Script
# Created: 2025-07-22
# Purpose: Build debug APK for SquashTrainingApp with proper environment setup

param(
    [switch]$Release,
    [switch]$Clean,
    [switch]$InstallToDevice,
    [string]$OutputPath = ".\apk-output"
)

# Constants
$SCRIPT_NAME = "BUILD-APK-2025"
$PROJECT_ROOT = (Get-Item (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))).FullName
$ANDROID_DIR = Join-Path $PROJECT_ROOT "android"
$GRADLE_WRAPPER = Join-Path $ANDROID_DIR "gradlew.bat"
$BUILD_DIR = Join-Path $ANDROID_DIR "app\build\outputs\apk"

# Colors for output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Header {
    Clear-Host
    Write-ColorOutput Green "========================================"
    Write-ColorOutput Green "   Squash Training App - APK Builder"
    Write-ColorOutput Green "   Version: 2025.07.22"
    Write-ColorOutput Green "========================================"
    Write-Host ""
}

function Test-Requirements {
    Write-ColorOutput Yellow "🔍 Checking build requirements..."
    
    $errors = @()
    
    # Check Node.js
    try {
        $nodeVersion = node --version 2>$null
        if ($nodeVersion) {
            Write-ColorOutput Green "✅ Node.js: $nodeVersion"
        } else {
            $errors += "Node.js is not installed"
        }
    } catch {
        $errors += "Node.js is not installed"
    }
    
    # Check Java
    $javaHome = $env:JAVA_HOME
    if ([string]::IsNullOrEmpty($javaHome)) {
        # Try to find Java automatically
        $possiblePaths = @(
            "C:\Program Files\Java\jdk-17*",
            "C:\Program Files\Java\jdk-11*",
            "C:\Program Files\Java\jdk1.8*",
            "C:\Program Files\AdoptOpenJDK\jdk-*",
            "C:\Program Files\Eclipse Adoptium\jdk-*"
        )
        
        foreach ($path in $possiblePaths) {
            $matches = Get-ChildItem -Path $path -ErrorAction SilentlyContinue
            if ($matches) {
                $javaHome = $matches[0].FullName
                $env:JAVA_HOME = $javaHome
                Write-ColorOutput Yellow "⚠️  JAVA_HOME not set, using: $javaHome"
                break
            }
        }
    }
    
    if ([string]::IsNullOrEmpty($javaHome)) {
        $errors += "JAVA_HOME is not set and Java installation not found"
    } else {
        Write-ColorOutput Green "✅ Java: $javaHome"
    }
    
    # Check Android SDK
    $androidHome = $env:ANDROID_HOME
    if ([string]::IsNullOrEmpty($androidHome)) {
        $androidHome = $env:ANDROID_SDK_ROOT
    }
    
    if ([string]::IsNullOrEmpty($androidHome)) {
        # Try default locations
        $possibleAndroidPaths = @(
            "$env:LOCALAPPDATA\Android\Sdk",
            "$env:USERPROFILE\AppData\Local\Android\Sdk",
            "C:\Android\Sdk"
        )
        
        foreach ($path in $possibleAndroidPaths) {
            if (Test-Path $path) {
                $androidHome = $path
                $env:ANDROID_HOME = $androidHome
                $env:ANDROID_SDK_ROOT = $androidHome
                Write-ColorOutput Yellow "⚠️  ANDROID_HOME not set, using: $androidHome"
                break
            }
        }
    }
    
    if ([string]::IsNullOrEmpty($androidHome)) {
        $errors += "ANDROID_HOME is not set and Android SDK not found"
    } else {
        Write-ColorOutput Green "✅ Android SDK: $androidHome"
    }
    
    # Check gradle wrapper
    if (-not (Test-Path $GRADLE_WRAPPER)) {
        $errors += "Gradle wrapper not found at: $GRADLE_WRAPPER"
    } else {
        Write-ColorOutput Green "✅ Gradle wrapper: Found"
    }
    
    if ($errors.Count -gt 0) {
        Write-Host ""
        Write-ColorOutput Red "❌ Build requirements not met:"
        foreach ($error in $errors) {
            Write-ColorOutput Red "   • $error"
        }
        return $false
    }
    
    Write-Host ""
    return $true
}

function Install-Dependencies {
    Write-ColorOutput Yellow "📦 Installing dependencies..."
    
    Push-Location $PROJECT_ROOT
    try {
        # Install npm dependencies
        Write-ColorOutput Cyan "   Installing npm packages..."
        npm install
        if ($LASTEXITCODE -ne 0) {
            throw "npm install failed"
        }
        
        # Install pods if on macOS (not needed for Windows)
        if ($IsMacOS) {
            Push-Location ios
            pod install
            Pop-Location
        }
        
        Write-ColorOutput Green "✅ Dependencies installed successfully"
    } catch {
        Write-ColorOutput Red "❌ Failed to install dependencies: $_"
        return $false
    } finally {
        Pop-Location
    }
    
    return $true
}

function Clean-Build {
    Write-ColorOutput Yellow "🧹 Cleaning build directories..."
    
    Push-Location $ANDROID_DIR
    try {
        # Clean gradle build
        & $GRADLE_WRAPPER clean
        if ($LASTEXITCODE -ne 0) {
            throw "Gradle clean failed"
        }
        
        # Clean React Native cache
        Push-Location $PROJECT_ROOT
        npx react-native clean
        Pop-Location
        
        # Remove build directories
        $dirsToRemove = @(
            "$ANDROID_DIR\app\build",
            "$ANDROID_DIR\.gradle",
            "$PROJECT_ROOT\node_modules\.cache"
        )
        
        foreach ($dir in $dirsToRemove) {
            if (Test-Path $dir) {
                Remove-Item -Path $dir -Recurse -Force -ErrorAction SilentlyContinue
                Write-ColorOutput Green "   Removed: $dir"
            }
        }
        
        Write-ColorOutput Green "✅ Build cleaned successfully"
    } catch {
        Write-ColorOutput Red "❌ Failed to clean build: $_"
        return $false
    } finally {
        Pop-Location
    }
    
    return $true
}

function Build-APK {
    param([bool]$IsRelease)
    
    $buildType = if ($IsRelease) { "Release" } else { "Debug" }
    Write-ColorOutput Yellow "🔨 Building $buildType APK..."
    
    Push-Location $ANDROID_DIR
    try {
        # Set build command
        $gradleTask = if ($IsRelease) { "assembleRelease" } else { "assembleDebug" }
        
        # Build APK
        Write-ColorOutput Cyan "   Running gradle $gradleTask..."
        & $GRADLE_WRAPPER $gradleTask --no-daemon
        
        if ($LASTEXITCODE -ne 0) {
            throw "Gradle build failed"
        }
        
        # Find built APK
        $apkSubDir = if ($IsRelease) { "release" } else { "debug" }
        $apkPath = Join-Path $BUILD_DIR "$apkSubDir\app-$apkSubDir.apk"
        
        if (-not (Test-Path $apkPath)) {
            throw "APK not found at expected location: $apkPath"
        }
        
        # Copy to output directory
        if (-not (Test-Path $OutputPath)) {
            New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
        }
        
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $outputFileName = "SquashTrainingApp-$buildType-$timestamp.apk"
        $outputFile = Join-Path $OutputPath $outputFileName
        
        Copy-Item -Path $apkPath -Destination $outputFile -Force
        
        # Get APK info
        $apkSize = (Get-Item $outputFile).Length / 1MB
        
        Write-Host ""
        Write-ColorOutput Green "✅ APK built successfully!"
        Write-ColorOutput Green "📱 APK Location: $outputFile"
        Write-ColorOutput Green "📊 APK Size: $([Math]::Round($apkSize, 2)) MB"
        
        return $outputFile
    } catch {
        Write-ColorOutput Red "❌ Failed to build APK: $_"
        return $null
    } finally {
        Pop-Location
    }
}

function Install-APK {
    param([string]$ApkPath)
    
    Write-ColorOutput Yellow "📲 Installing APK to device..."
    
    try {
        # Check if adb is available
        $adb = Get-Command adb -ErrorAction SilentlyContinue
        if (-not $adb) {
            throw "ADB not found in PATH"
        }
        
        # Check connected devices
        $devices = adb devices | Select-String -Pattern "device$"
        if ($devices.Count -eq 0) {
            throw "No Android devices connected"
        }
        
        # Install APK
        adb install -r $ApkPath
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to install APK"
        }
        
        Write-ColorOutput Green "✅ APK installed successfully!"
        
        # Try to launch the app
        Write-ColorOutput Yellow "🚀 Launching app..."
        adb shell monkey -p com.squashtrainingapp -c android.intent.category.LAUNCHER 1
        
    } catch {
        Write-ColorOutput Red "❌ Failed to install APK: $_"
        Write-ColorOutput Yellow "💡 Make sure your device is connected and USB debugging is enabled"
    }
}

# Main execution
Write-Header

# Check requirements
if (-not (Test-Requirements)) {
    Write-Host ""
    Write-ColorOutput Red "Please install missing requirements and try again."
    exit 1
}

# Install dependencies
if (-not (Install-Dependencies)) {
    exit 1
}

# Clean if requested
if ($Clean) {
    if (-not (Clean-Build)) {
        exit 1
    }
}

# Build APK
$builtApk = Build-APK -IsRelease:$Release

if ($builtApk) {
    # Install if requested
    if ($InstallToDevice) {
        Install-APK -ApkPath $builtApk
    }
    
    Write-Host ""
    Write-ColorOutput Cyan "🎉 Build completed successfully!"
    Write-ColorOutput Cyan "📁 APK saved to: $builtApk"
    
    # Show next steps
    Write-Host ""
    Write-ColorOutput Yellow "📝 Next steps:"
    Write-ColorOutput Yellow "   1. Transfer APK to your device"
    Write-ColorOutput Yellow "   2. Install using file manager"
    Write-ColorOutput Yellow "   3. Or use: .\INSTALL-TO-BLUESTACKS.ps1"
    
    exit 0
} else {
    exit 1
}