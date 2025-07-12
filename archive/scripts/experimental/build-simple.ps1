#!/usr/bin/env pwsh
# Simple Android Build Script - Works around React Native 0.80+ plugin issues
# This script uses a refactored approach that avoids the complex plugin system

param(
    [switch]$AutoInstall    # Automatically install APK after successful build
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Simple Android Build Script" -ForegroundColor Cyan
Write-Host " (Bypasses RN 0.80+ plugin issues)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the android directory
if (-not (Test-Path "gradlew.bat")) {
    Write-Host "Error: Must be run from the android directory" -ForegroundColor Red
    exit 1
}

# Step 1: Ensure plugin JARs exist
Write-Host "[1/5] Checking React Native plugin JARs..." -ForegroundColor Yellow

$pluginJar = "..\node_modules\@react-native\gradle-plugin\react-native-gradle-plugin\build\libs\react-native-gradle-plugin.jar"
$settingsJar = "..\node_modules\@react-native\gradle-plugin\settings-plugin\build\libs\settings-plugin.jar"

if (-not (Test-Path $pluginJar) -or -not (Test-Path $settingsJar)) {
    Write-Host "  Plugin JARs not found. Building them first..." -ForegroundColor Yellow
    
    Push-Location "..\node_modules\@react-native\gradle-plugin"
    try {
        & cmd /c "gradlew.bat build -x test 2>&1"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to build React Native gradle plugin" -ForegroundColor Red
            Pop-Location
            exit 1
        }
    } finally {
        Pop-Location
    }
    
    Write-Host "✓ Plugin JARs built successfully" -ForegroundColor Green
} else {
    Write-Host "✓ Plugin JARs already exist" -ForegroundColor Green
}

# Step 2: Backup original files
Write-Host ""
Write-Host "[2/5] Backing up original configuration..." -ForegroundColor Yellow

if (-not (Test-Path "build.gradle.original")) {
    Copy-Item "build.gradle" "build.gradle.original"
    Write-Host "✓ Backed up build.gradle" -ForegroundColor Green
}

if (-not (Test-Path "settings.gradle.original")) {
    Copy-Item "settings.gradle" "settings.gradle.original"
    Write-Host "✓ Backed up settings.gradle" -ForegroundColor Green
}

# Step 3: Apply refactored configuration
Write-Host ""
Write-Host "[3/5] Applying simplified configuration..." -ForegroundColor Yellow

if (Test-Path "build.gradle.refactored") {
    Copy-Item "build.gradle.refactored" "build.gradle" -Force
    Write-Host "✓ Applied refactored build.gradle" -ForegroundColor Green
}

if (Test-Path "settings.gradle.refactored") {
    Copy-Item "settings.gradle.refactored" "settings.gradle" -Force
    Write-Host "✓ Applied refactored settings.gradle" -ForegroundColor Green
}

# Step 4: Set up environment
Write-Host ""
Write-Host "[4/5] Setting up environment..." -ForegroundColor Yellow

$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

Write-Host "✓ Java environment configured" -ForegroundColor Green

# Step 5: Build the app
Write-Host ""
Write-Host "[5/5] Building Android app..." -ForegroundColor Yellow
Write-Host "  This may take several minutes on first build..." -ForegroundColor Cyan

try {
    # Clean build with no daemon and no cache for maximum reliability
    & cmd /c "gradlew.bat clean assembleDebug --no-daemon --no-build-cache 2>&1" | ForEach-Object {
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
            Write-Host "APK created successfully:" -ForegroundColor Green
            Write-Host "  Location: $((Get-Item $apkPath).FullName)" -ForegroundColor Cyan
            Write-Host "  Size: ${apkSize} MB" -ForegroundColor Cyan
            Write-Host ""
            
            if ($AutoInstall) {
                # Auto-install functionality
                Write-Host "Auto-installing APK..." -ForegroundColor Yellow
                
                $adbPath = "C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools\adb.exe"
                
                if (Test-Path $adbPath) {
                    # Check for connected devices
                    $devices = & $adbPath devices 2>&1 | Select-String -Pattern "device$|emulator$"
                    
                    if ($devices.Count -gt 0) {
                        Write-Host "  Installing to connected device..." -ForegroundColor Cyan
                        $installResult = & $adbPath install $apkPath 2>&1
                        
                        if ($installResult -match "Success") {
                            Write-Host "✓ APK installed successfully!" -ForegroundColor Green
                            
                            # Set up port forwarding
                            & $adbPath reverse tcp:8081 tcp:8081 2>&1 | Out-Null
                            Write-Host "✓ Port forwarding set up for Metro bundler" -ForegroundColor Green
                            
                            Write-Host ""
                            Write-Host "To run the full build & launch script with device selection:" -ForegroundColor Yellow
                            Write-Host "  .\build-and-run.ps1" -ForegroundColor White
                        } else {
                            Write-Host "Installation failed. Output:" -ForegroundColor Red
                            Write-Host $installResult
                        }
                    } else {
                        Write-Host "No connected devices found!" -ForegroundColor Red
                        Write-Host "Connect a device or start an emulator and try again" -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "ADB not found at expected location" -ForegroundColor Red
                    Write-Host "Manual installation required:" -ForegroundColor Yellow
                    Write-Host "  adb install $apkPath" -ForegroundColor White
                }
            } else {
                Write-Host "To install on device/emulator:" -ForegroundColor Yellow
                Write-Host "  adb install $apkPath" -ForegroundColor White
                Write-Host ""
                Write-Host "Or use auto-install:" -ForegroundColor Gray
                Write-Host "  .\build-simple.ps1 -AutoInstall" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host ""
        Write-Host "BUILD FAILED" -ForegroundColor Red
        Write-Host "Check the error messages above for details" -ForegroundColor Yellow
        
        # Restore original files on failure
        Write-Host ""
        Write-Host "Restoring original configuration..." -ForegroundColor Yellow
        Copy-Item "build.gradle.original" "build.gradle" -Force
        Copy-Item "settings.gradle.original" "settings.gradle" -Force
        
        exit 1
    }
} catch {
    Write-Host "Build error: $_" -ForegroundColor Red
    
    # Restore original files on error
    Copy-Item "build.gradle.original" "build.gradle" -Force
    Copy-Item "settings.gradle.original" "settings.gradle" -Force
    
    exit 1
}

Write-Host ""
Write-Host "Note: If you want to restore original configuration, run:" -ForegroundColor Gray
Write-Host "  Copy-Item build.gradle.original build.gradle -Force" -ForegroundColor Gray
Write-Host "  Copy-Item settings.gradle.original settings.gradle -Force" -ForegroundColor Gray