#!/usr/bin/env pwsh
# DEBUG-BLUESTACKS.ps1
# BlueStacks APK Debug Script
# Created: 2025-07-22
# Purpose: Debug APK issues on BlueStacks using ADB

param(
    [string]$BlueStacksPort = "5556",
    [switch]$InstallAPK,
    [string]$APKPath,
    [switch]$ShowLogs,
    [switch]$ClearLogs
)

# Constants
$SCRIPT_NAME = "DEBUG-BLUESTACKS"
$BLUESTACKS_HOST = "127.0.0.1:$BlueStacksPort"
$PACKAGE_NAME = "com.squashtrainingapp"

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
    Write-ColorOutput Green "   BlueStacks Debug Tool"
    Write-ColorOutput Green "   Port: $BlueStacksPort"
    Write-ColorOutput Green "========================================"
    Write-Host ""
}

function Connect-BlueStacks {
    Write-ColorOutput Yellow "🔗 Connecting to BlueStacks..."
    
    # Disconnect any existing connections
    adb disconnect | Out-Null
    
    # Connect to BlueStacks
    $result = adb connect $BLUESTACKS_HOST 2>&1
    
    if ($result -like "*connected*") {
        Write-ColorOutput Green "✅ Connected to BlueStacks"
        
        # List devices to confirm
        Write-ColorOutput Cyan "📱 Connected devices:"
        adb devices
        return $true
    } else {
        Write-ColorOutput Red "❌ Failed to connect to BlueStacks"
        Write-ColorOutput Red "   Error: $result"
        Write-ColorOutput Yellow "💡 Make sure BlueStacks is running"
        return $false
    }
}

function Get-CrashLogs {
    Write-ColorOutput Yellow "📋 Getting crash logs..."
    
    # Check if app is installed
    $installed = adb shell pm list packages | Select-String $PACKAGE_NAME
    if (-not $installed) {
        Write-ColorOutput Red "❌ App not installed: $PACKAGE_NAME"
        return
    }
    
    Write-ColorOutput Cyan "🔍 Recent crashes for ${PACKAGE_NAME}:"
    
    # Get logcat for crashes
    adb logcat -d | Select-String -Pattern "$PACKAGE_NAME.*FATAL|$PACKAGE_NAME.*crash|AndroidRuntime.*$PACKAGE_NAME" -Context 5,5
    
    # Get specific app logs
    Write-ColorOutput Cyan "`n📝 App specific logs:"
    adb logcat -d -s "${PACKAGE_NAME}:*"
    
    # Check for React Native errors
    Write-ColorOutput Cyan "`n⚛️ React Native errors:"
    adb logcat -d | Select-String -Pattern "ReactNative|bundle.*error|Could not connect to development server" -Context 2,2
}

function Install-APKToBlueStacks {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        Write-ColorOutput Red "❌ APK not found: $Path"
        return $false
    }
    
    Write-ColorOutput Yellow "📦 Installing APK to BlueStacks..."
    Write-ColorOutput Cyan "   APK: $Path"
    
    # Uninstall existing version
    Write-ColorOutput Yellow "🗑️ Removing existing installation..."
    adb uninstall $PACKAGE_NAME 2>&1 | Out-Null
    
    # Install new APK
    $result = adb install -r $Path 2>&1
    
    if ($result -like "*Success*") {
        Write-ColorOutput Green "✅ APK installed successfully!"
        return $true
    } else {
        Write-ColorOutput Red "❌ Installation failed:"
        Write-ColorOutput Red "   $result"
        return $false
    }
}

function Start-App {
    Write-ColorOutput Yellow "🚀 Starting app..."
    
    # Try to start the app
    $result = adb shell monkey -p $PACKAGE_NAME -c android.intent.category.LAUNCHER 1 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput Green "✅ App started"
        
        # Wait a moment then check if it's still running
        Start-Sleep -Seconds 3
        
        $running = adb shell ps | Select-String $PACKAGE_NAME
        if ($running) {
            Write-ColorOutput Green "✅ App is running"
        } else {
            Write-ColorOutput Red "❌ App crashed immediately"
            Get-CrashLogs
        }
    } else {
        Write-ColorOutput Red "❌ Failed to start app"
        Write-ColorOutput Red "   $result"
    }
}

function Clear-AppData {
    Write-ColorOutput Yellow "🧹 Clearing app data..."
    adb shell pm clear $PACKAGE_NAME
    Write-ColorOutput Green "✅ App data cleared"
}

function Show-LiveLogs {
    Write-ColorOutput Yellow "📡 Showing live logs (Ctrl+C to stop)..."
    Write-ColorOutput Cyan "   Filtering for: $PACKAGE_NAME, ReactNative, AndroidRuntime"
    Write-Host ""
    
    # Show live filtered logs
    adb logcat -c  # Clear existing logs
    adb logcat "*:E" | Select-String -Pattern "$PACKAGE_NAME|ReactNative|AndroidRuntime|FATAL|crash"
}

function Check-ReactNativeSetup {
    Write-ColorOutput Yellow "🔍 Checking React Native setup..."
    
    # Check if JS bundle exists in APK
    Write-ColorOutput Cyan "📦 Checking for JS bundle in APK..."
    $tempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
    
    if ($APKPath -and (Test-Path $APKPath)) {
        # Extract APK to check contents
        Copy-Item $APKPath "$tempDir\app.zip"
        Expand-Archive "$tempDir\app.zip" -DestinationPath "$tempDir\extracted" -Force
        
        # Check for bundle
        $bundleExists = Test-Path "$tempDir\extracted\assets\index.android.bundle"
        if ($bundleExists) {
            Write-ColorOutput Green "✅ JS bundle found in APK"
            $bundleSize = (Get-Item "$tempDir\extracted\assets\index.android.bundle").Length / 1KB
            Write-ColorOutput Green "   Bundle size: $([Math]::Round($bundleSize, 2)) KB"
        } else {
            Write-ColorOutput Red "❌ JS bundle NOT found in APK!"
            Write-ColorOutput Red "   This is likely why the app won't start"
        }
        
        # Clean up
        Remove-Item -Path $tempDir -Recurse -Force
    }
    
    # Check if React Native is properly initialized
    Write-ColorOutput Cyan "🔍 Checking React Native initialization..."
    adb logcat -d | Select-String "ReactNative.*started|ReactNative.*initialized" | Select-Object -Last 5
}

# Main execution
Write-Header

# Connect to BlueStacks
if (-not (Connect-BlueStacks)) {
    exit 1
}

Write-Host ""

# Install APK if requested
if ($InstallAPK -and $APKPath) {
    if (Install-APKToBlueStacks -Path $APKPath) {
        Write-Host ""
        Start-App
    }
} elseif ($InstallAPK) {
    # Find latest APK
    $latestAPK = Get-ChildItem ".\apk-output\*.apk" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latestAPK) {
        Write-ColorOutput Cyan "📱 Found latest APK: $($latestAPK.Name)"
        if (Install-APKToBlueStacks -Path $latestAPK.FullName) {
            Write-Host ""
            Start-App
        }
    } else {
        Write-ColorOutput Red "❌ No APK found in .\apk-output\"
    }
}

# Clear logs if requested
if ($ClearLogs) {
    adb logcat -c
    Write-ColorOutput Green "✅ Logs cleared"
}

# Check React Native setup
Write-Host ""
Check-ReactNativeSetup

# Show logs if requested
if ($ShowLogs) {
    Write-Host ""
    Show-LiveLogs
} else {
    # Show recent crashes
    Write-Host ""
    Get-CrashLogs
    
    Write-Host ""
    Write-ColorOutput Yellow "💡 Options:"
    Write-ColorOutput Yellow "   -ShowLogs     : Show live logs"
    Write-ColorOutput Yellow "   -InstallAPK   : Install and run APK"
    Write-ColorOutput Yellow "   -ClearLogs    : Clear logcat"
    Write-ColorOutput Yellow ""
    Write-ColorOutput Cyan "📝 Example commands:"
    Write-ColorOutput Cyan "   .\DEBUG-BLUESTACKS.ps1 -ShowLogs"
    Write-ColorOutput Cyan "   .\DEBUG-BLUESTACKS.ps1 -InstallAPK"
    Write-ColorOutput Cyan "   .\DEBUG-BLUESTACKS.ps1 -InstallAPK -APKPath 'path\to\app.apk'"
}