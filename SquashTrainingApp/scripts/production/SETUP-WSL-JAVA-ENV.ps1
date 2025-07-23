#!/usr/bin/env pwsh
# SETUP-WSL-JAVA-ENV.ps1
# Java and Android SDK environment setup for WSL
# Created: 2025-07-23
# Purpose: Automated Java/Android environment configuration

param(
    [switch]$InstallJava = $false,
    [switch]$SetupAndroidSDK = $false,
    [switch]$ShowOnly = $false
)

function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }
function Write-Warning { param($Message) Write-Host "⚠️ $Message" -ForegroundColor Yellow }
function Write-Info { param($Message) Write-Host "ℹ️ $Message" -ForegroundColor Cyan }
function Write-Step { param($Message) Write-Host "🔄 $Message" -ForegroundColor Blue }

Write-Host "☕ WSL Java Environment Setup" -ForegroundColor Magenta
Write-Host "================================" -ForegroundColor Magenta
Write-Host ""

# Check if running in WSL
$isWSL = $env:WSL_DISTRO_NAME -ne $null
if (-not $isWSL) {
    Write-Error "This script is designed for WSL environment only"
    Write-Info "For Windows, please install Android Studio manually"
    exit 1
}

Write-Info "WSL Distribution: $env:WSL_DISTRO_NAME"
Write-Host ""

# Check current Java installation
Write-Step "Checking current Java installation..."
try {
    $javaVersion = java -version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Java is already installed:"
        Write-Host $javaVersion[0] -ForegroundColor Green
        $javaInstalled = $true
    } else {
        $javaInstalled = $false
    }
} catch {
    $javaInstalled = $false
}

if (-not $javaInstalled) {
    Write-Warning "Java not found"
    if ($InstallJava -or (-not $ShowOnly)) {
        Write-Step "Installing OpenJDK 11..."
        try {
            # Update package list
            sudo apt update -qq
            
            # Install OpenJDK 11
            sudo apt install -y openjdk-11-jdk
            
            # Set JAVA_HOME
            $javaHome = "/usr/lib/jvm/java-11-openjdk-amd64"
            if (Test-Path $javaHome) {
                Write-Success "Java installed successfully"
                Write-Info "JAVA_HOME should be: $javaHome"
                
                # Add to bashrc if not already there
                $bashrc = "$env:HOME/.bashrc"
                $javaHomeExport = "export JAVA_HOME=$javaHome"
                $pathExport = "export PATH=`$JAVA_HOME/bin:`$PATH"
                
                $bashrcContent = Get-Content $bashrc -ErrorAction SilentlyContinue
                if ($bashrcContent -notcontains $javaHomeExport) {
                    Add-Content -Path $bashrc -Value ""
                    Add-Content -Path $bashrc -Value "# Java Environment"
                    Add-Content -Path $bashrc -Value $javaHomeExport
                    Add-Content -Path $bashrc -Value $pathExport
                    Write-Success "Added Java environment to ~/.bashrc"
                }
            }
        } catch {
            Write-Error "Failed to install Java: $($_.Exception.Message)"
        }
    } else {
        Write-Info "Use -InstallJava to install OpenJDK 11 automatically"
        Write-Info "Or run manually: sudo apt install openjdk-11-jdk"
    }
}

# Check JAVA_HOME environment variable
Write-Step "Checking JAVA_HOME..."
if ($env:JAVA_HOME) {
    Write-Success "JAVA_HOME is set: $env:JAVA_HOME"
} else {
    Write-Warning "JAVA_HOME not set"
    $possibleJavaHomes = @(
        "/usr/lib/jvm/java-11-openjdk-amd64",
        "/usr/lib/jvm/java-8-openjdk-amd64",
        "/usr/lib/jvm/default-java"
    )
    
    foreach ($path in $possibleJavaHomes) {
        if (Test-Path $path) {
            $env:JAVA_HOME = $path
            Write-Info "Setting JAVA_HOME to: $path"
            break
        }
    }
    
    if (-not $env:JAVA_HOME) {
        Write-Error "Could not determine JAVA_HOME"
        Write-Info "Please set JAVA_HOME manually in your shell profile"
    }
}

# Check Android SDK
Write-Step "Checking Android SDK..."
$androidHome = $env:ANDROID_HOME
if ($androidHome -and (Test-Path $androidHome)) {
    Write-Success "Android SDK found: $androidHome"
} else {
    Write-Warning "Android SDK not found"
    
    # Check common Windows locations (since WSL can access Windows files)
    $windowsPaths = @(
        "/mnt/c/Users/$env:USER/AppData/Local/Android/Sdk",
        "/mnt/c/Android/Sdk"
    )
    
    foreach ($path in $windowsPaths) {
        if (Test-Path $path) {
            $env:ANDROID_HOME = $path
            Write-Success "Found Android SDK at: $path"
            
            # Add to bashrc
            $bashrc = "$env:HOME/.bashrc"
            $androidHomeExport = "export ANDROID_HOME=$path"
            $androidPathExport = "export PATH=`$ANDROID_HOME/platform-tools:`$ANDROID_HOME/tools:`$PATH"
            
            $bashrcContent = Get-Content $bashrc -ErrorAction SilentlyContinue
            if ($bashrcContent -notcontains $androidHomeExport) {
                Add-Content -Path $bashrc -Value ""
                Add-Content -Path $bashrc -Value "# Android SDK Environment"
                Add-Content -Path $bashrc -Value $androidHomeExport
                Add-Content -Path $bashrc -Value $androidPathExport
                Write-Success "Added Android SDK environment to ~/.bashrc"
            }
            break
        }
    }
    
    if (-not $env:ANDROID_HOME) {
        Write-Info "Android SDK not found. Please install Android Studio on Windows"
        Write-Info "or install command-line tools for Linux"
    }
}

# Check ADB
Write-Step "Checking ADB..."
try {
    $adbVersion = adb version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "ADB is available"
    } else {
        Write-Warning "ADB not found in PATH"
    }
} catch {
    Write-Warning "ADB not found"
    if ($env:ANDROID_HOME) {
        $adbPath = Join-Path $env:ANDROID_HOME "platform-tools/adb"
        if (Test-Path $adbPath) {
            Write-Info "ADB found at: $adbPath"
            Write-Info "Make sure $env:ANDROID_HOME/platform-tools is in your PATH"
        }
    }
}

# Environment Summary
Write-Host ""
Write-Host "📋 Environment Summary" -ForegroundColor Blue
Write-Host "=====================" -ForegroundColor Blue

$envStatus = @{
    "Java Installed" = if ($javaInstalled) { "✅ Yes" } else { "❌ No" }
    "JAVA_HOME" = if ($env:JAVA_HOME) { "✅ $env:JAVA_HOME" } else { "❌ Not set" }
    "Android SDK" = if ($env:ANDROID_HOME) { "✅ $env:ANDROID_HOME" } else { "❌ Not set" }
    "WSL Distribution" = $env:WSL_DISTRO_NAME
}

foreach ($key in $envStatus.Keys) {
    Write-Host "$key`: $($envStatus[$key])"
}

Write-Host ""

if ($ShowOnly) {
    Write-Info "Environment check completed (ShowOnly mode)"
} else {
    Write-Host "🎯 Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Restart your terminal or run: source ~/.bashrc"
    Write-Host "2. Verify with: java -version && echo `$JAVA_HOME"
    Write-Host "3. Run the build script: BUILD-COMPLETE-STABLE-2025.ps1"
    Write-Host ""
}

Write-Success "Environment setup completed!"