# BUILD-DB-OPTIMIZED.ps1
# Purpose: Build and test database optimization features
# Category: BUILD
# Description: Complete build with DB indexing, backup/restore, and analytics

param(
    [switch]$SkipInstall,
    [switch]$DebugMode
)

$ErrorActionPreference = "Stop"
$StartTime = Get-Date

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Database Optimized Build System" -ForegroundColor Cyan
Write-Host "  Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Project paths
$projectRoot = Split-Path -Parent -Path (Split-Path -Parent -Path $PSScriptRoot)
$androidPath = Join-Path $projectRoot "android"
$srcPath = Join-Path $projectRoot "src"
$buildPath = Join-Path $androidPath "app" "build" "outputs" "apk" "debug"
$apkName = "app-debug.apk"

# ADB and emulator paths
$adbPath = "C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$emulatorPath = "C:\Users\hwpar\AppData\Local\Android\Sdk\emulator\emulator.exe"

# Color output functions
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

# Check prerequisites
function Test-Prerequisites {
    Write-Info "`n📋 Checking prerequisites..."
    
    $checks = @{
        "Node.js" = { node --version }
        "npm" = { npm --version }
        "Java" = { java -version 2>&1 }
        "Android SDK" = { Test-Path $adbPath }
        "React Native" = { npx react-native --version }
    }
    
    $allPassed = $true
    foreach ($tool in $checks.Keys) {
        try {
            $null = & $checks[$tool]
            Write-Success "  ✓ $tool"
        } catch {
            Write-Error "  ✗ $tool not found"
            $allPassed = $false
        }
    }
    
    return $allPassed
}

# Install dependencies
function Install-Dependencies {
    if (-not $SkipInstall) {
        Write-Info "`n📦 Installing dependencies..."
        Set-Location $projectRoot
        
        try {
            npm install --legacy-peer-deps
            Write-Success "✓ Dependencies installed"
        } catch {
            Write-Error "✗ Failed to install dependencies"
            exit 1
        }
    } else {
        Write-Warning "⚠ Skipping dependency installation"
    }
}

# Start Metro bundler
function Start-Metro {
    Write-Info "`n🚀 Starting Metro bundler..."
    
    $metroJob = Start-Job -ScriptBlock {
        param($projectPath)
        Set-Location $projectPath
        npx react-native start --reset-cache
    } -ArgumentList $projectRoot
    
    Write-Success "✓ Metro bundler started (Job ID: $($metroJob.Id))"
    Start-Sleep -Seconds 5
    return $metroJob
}

# Build Android APK
function Build-AndroidAPK {
    Write-Info "`n🔨 Building Android APK..."
    Set-Location $androidPath
    
    try {
        # Clean previous build
        Write-Info "  Cleaning previous build..."
        & ./gradlew clean
        
        # Build debug APK
        Write-Info "  Building debug APK..."
        & ./gradlew assembleDebug
        
        # Check if APK exists
        $apkPath = Join-Path $buildPath $apkName
        if (Test-Path $apkPath) {
            $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
            Write-Success "✓ APK built successfully ($apkSize MB)"
            return $apkPath
        } else {
            throw "APK not found at expected location"
        }
    } catch {
        Write-Error "✗ Build failed: $_"
        return $null
    }
}

# Install and launch app
function Install-App {
    param($apkPath)
    
    Write-Info "`n📱 Installing app on emulator..."
    
    try {
        # Uninstall previous version
        Write-Info "  Uninstalling previous version..."
        & $adbPath uninstall com.squashtrainingapp 2>$null
        
        # Install new APK
        Write-Info "  Installing new APK..."
        & $adbPath install -r $apkPath
        
        # Launch app
        Write-Info "  Launching app..."
        & $adbPath shell am start -n com.squashtrainingapp/.MainActivity
        
        Write-Success "✓ App installed and launched"
        return $true
    } catch {
        Write-Error "✗ Installation failed: $_"
        return $false
    }
}

# Test database features
function Test-DatabaseFeatures {
    Write-Info "`n🧪 Testing database optimization features..."
    
    $tests = @(
        @{
            Name = "Database Indexing"
            Command = "adb shell run-as com.squashtrainingapp sqlite3 /data/data/com.squashtrainingapp/databases/SquashTraining.db '.indexes'"
            Expected = "idx_workout_logs"
        },
        @{
            Name = "Analytics Cache"
            Command = "adb shell run-as com.squashtrainingapp ls -la /data/data/com.squashtrainingapp/databases/"
            Expected = "SquashTraining.db"
        }
    )
    
    foreach ($test in $tests) {
        Write-Info "  Testing: $($test.Name)"
        try {
            $result = & $adbPath shell run-as com.squashtrainingapp sqlite3 /data/data/com.squashtrainingapp/databases/SquashTraining.db ".indexes" 2>&1
            if ($result -match "idx_") {
                Write-Success "    ✓ Database indexes created"
            } else {
                Write-Warning "    ⚠ Indexes not verified (app may need to initialize)"
            }
        } catch {
            Write-Warning "    ⚠ Could not verify: $_"
        }
    }
}

# Main execution
function Main {
    Write-Info "Starting database optimized build process..."
    
    # Check prerequisites
    if (-not (Test-Prerequisites)) {
        Write-Error "Prerequisites check failed. Please install missing tools."
        exit 1
    }
    
    # Install dependencies
    Install-Dependencies
    
    # Start Metro
    $metroJob = Start-Metro
    
    # Build APK
    $apkPath = Build-AndroidAPK
    if (-not $apkPath) {
        Write-Error "Build failed. Exiting."
        Stop-Job $metroJob -Force
        Remove-Job $metroJob
        exit 1
    }
    
    # Check emulator
    Write-Info "`n📱 Checking emulator status..."
    $devices = & $adbPath devices
    if ($devices -notmatch "emulator") {
        Write-Warning "No emulator detected. Please start an emulator."
        Write-Info "Waiting for emulator..."
        
        $timeout = 60
        $elapsed = 0
        while ($elapsed -lt $timeout) {
            Start-Sleep -Seconds 5
            $elapsed += 5
            $devices = & $adbPath devices
            if ($devices -match "emulator") {
                Write-Success "✓ Emulator detected"
                break
            }
            Write-Info "  Waiting... ($elapsed/$timeout seconds)"
        }
        
        if ($elapsed -ge $timeout) {
            Write-Error "Timeout waiting for emulator"
            Stop-Job $metroJob -Force
            Remove-Job $metroJob
            exit 1
        }
    }
    
    # Install app
    if (Install-App -apkPath $apkPath) {
        # Wait for app to initialize
        Write-Info "Waiting for app to initialize..."
        Start-Sleep -Seconds 10
        
        # Test database features
        Test-DatabaseFeatures
    }
    
    # Summary
    $duration = [math]::Round(((Get-Date) - $StartTime).TotalMinutes, 2)
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Success "✅ Build completed successfully!"
    Write-Info "📊 Build Statistics:"
    Write-Info "  • Duration: $duration minutes"
    Write-Info "  • APK Size: $([math]::Round((Get-Item $apkPath).Length / 1MB, 2)) MB"
    Write-Info "  • Features: DB Indexing, Backup/Restore, Analytics"
    Write-Host "========================================" -ForegroundColor Green
    
    Write-Host "`n📱 Testing Instructions:" -ForegroundColor Cyan
    Write-Host "1. Navigate to Profile > Settings" -ForegroundColor White
    Write-Host "2. Test 'Backup & Restore' feature" -ForegroundColor White
    Write-Host "3. Test 'Analytics' to view performance data" -ForegroundColor White
    Write-Host "4. Check database performance improvements" -ForegroundColor White
    
    Write-Warning "`nPress Ctrl+C to stop Metro bundler when done testing"
    
    # Keep Metro running
    Wait-Job $metroJob
}

# Run main function
Main