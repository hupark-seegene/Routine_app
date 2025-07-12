#!/usr/bin/env pwsh
# Automated Build, Install & Run Script for React Native Android
# This script automates the entire process from building to running on device

param(
    [switch]$SkipBuild,     # Skip build and only install existing APK
    [switch]$NoMetro,       # Don't start Metro bundler
    [switch]$LaunchApp,     # Launch app after installation
    [switch]$Debug          # Show detailed debug information
)

$ErrorActionPreference = "Continue"

# Configuration
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:ANDROID_HOME = "C:\Users\hwpar\AppData\Local\Android\Sdk"
$env:Path = "$env:JAVA_HOME\bin;$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\tools;$env:Path"

$ADB = "$env:ANDROID_HOME\platform-tools\adb.exe"
$APK_PATH = "app\build\outputs\apk\debug\app-debug.apk"
$PACKAGE_NAME = "com.squashtrainingapp"

# Colors for output
function Write-ColorOutput($message, $color = "White") {
    Write-Host $message -ForegroundColor $color
}

function Write-Success($message) { Write-ColorOutput "✓ $message" "Green" }
function Write-Error($message) { Write-ColorOutput "✗ $message" "Red" }
function Write-Warning($message) { Write-ColorOutput "⚠ $message" "Yellow" }
function Write-Info($message) { Write-ColorOutput "→ $message" "Cyan" }
function Write-Debug($message) { 
    if ($Debug) { Write-ColorOutput "[DEBUG] $message" "Gray" }
}

# Header
Write-ColorOutput "`n============================================" "Cyan"
Write-ColorOutput " 🚀 React Native Build & Run Automation" "Cyan"
Write-ColorOutput "============================================" "Cyan"
Write-ColorOutput ""

# Ensure we're in android directory
if (-not (Test-Path "gradlew.bat")) {
    Write-Error "Must run from android directory"
    exit 1
}

# Check ADB availability
if (-not (Test-Path $ADB)) {
    Write-Error "ADB not found at: $ADB"
    Write-Warning "Please install Android SDK or update the path in this script"
    exit 1
}

# Function to get connected devices
function Get-ConnectedDevices {
    Write-Info "Checking for connected devices..."
    
    $devices = & $ADB devices 2>&1
    $deviceList = @()
    
    foreach ($line in $devices) {
        if ($line -match "^(\S+)\s+(device|emulator)$") {
            $deviceInfo = @{
                Id = $matches[1]
                Type = if ($matches[1] -match "emulator") { "Emulator" } else { "Device" }
            }
            
            # Get device name/model
            $model = & $ADB -s $deviceInfo.Id shell getprop ro.product.model 2>&1
            $manufacturer = & $ADB -s $deviceInfo.Id shell getprop ro.product.manufacturer 2>&1
            
            if ($model -and $manufacturer) {
                $deviceInfo.Name = "$manufacturer $model".Trim()
            } else {
                $deviceInfo.Name = $deviceInfo.Id
            }
            
            $deviceList += $deviceInfo
        }
    }
    
    return $deviceList
}

# Function to select device when multiple are connected
function Select-Device($devices) {
    if ($devices.Count -eq 1) {
        return $devices[0]
    }
    
    Write-ColorOutput "`nMultiple devices detected:" "Yellow"
    for ($i = 0; $i -lt $devices.Count; $i++) {
        $device = $devices[$i]
        Write-ColorOutput "  [$($i+1)] $($device.Name) ($($device.Type)) - $($device.Id)"
    }
    
    # Auto-select first device
    Write-Info "Auto-selecting first device..."
    return $devices[0]
}

# Function to build the app
function Build-App {
    Write-ColorOutput "`n[BUILD PHASE]" "Magenta"
    Write-Info "Starting build process..."
    
    # Check if React Native plugin is built
    $pluginJar = "..\node_modules\@react-native\gradle-plugin\react-native-gradle-plugin\build\libs\react-native-gradle-plugin.jar"
    if (-not (Test-Path $pluginJar)) {
        Write-Warning "React Native plugin not built, building now..."
        
        Push-Location "..\node_modules\@react-native\gradle-plugin"
        $buildOutput = & cmd /c "gradlew.bat build -x test 2>&1"
        Pop-Location
        
        if (Test-Path $pluginJar) {
            Write-Success "React Native plugin built"
        } else {
            Write-Error "Failed to build React Native plugin"
            return $false
        }
    }
    
    # Clean build
    Write-Info "Cleaning previous build..."
    & cmd /c "gradlew.bat clean 2>&1" | Out-Null
    
    # Build APK
    Write-Info "Building APK (this may take a few minutes)..."
    $buildStartTime = Get-Date
    
    $buildProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "gradlew.bat assembleDebug" -NoNewWindow -PassThru -Wait
    
    $buildDuration = [math]::Round(((Get-Date) - $buildStartTime).TotalSeconds, 1)
    
    if ($buildProcess.ExitCode -eq 0 -and (Test-Path $APK_PATH)) {
        $apkSize = [math]::Round((Get-Item $APK_PATH).Length / 1MB, 2)
        Write-Success "Build completed in ${buildDuration}s"
        Write-Info "APK Size: ${apkSize}MB"
        return $true
    } else {
        Write-Error "Build failed (Exit code: $($buildProcess.ExitCode))"
        Write-Warning "Run with -Debug flag for more details"
        return $false
    }
}

# Function to install APK
function Install-APK($device) {
    Write-ColorOutput "`n[INSTALLATION PHASE]" "Magenta"
    Write-Info "Installing on: $($device.Name)"
    
    # Uninstall previous version to ensure clean installation
    Write-Info "Removing previous installation..."
    & $ADB -s $device.Id uninstall $PACKAGE_NAME 2>&1 | Out-Null
    
    # Install new APK
    Write-Info "Installing APK..."
    $installOutput = & $ADB -s $device.Id install -r $APK_PATH 2>&1
    
    if ($installOutput -match "Success") {
        Write-Success "APK installed successfully"
        return $true
    } else {
        Write-Error "Installation failed"
        Write-Debug "Install output: $installOutput"
        return $false
    }
}

# Function to setup Metro bundler
function Setup-Metro($device) {
    if ($NoMetro) {
        return
    }
    
    Write-ColorOutput "`n[METRO BUNDLER]" "Magenta"
    
    # Setup port forwarding
    Write-Info "Setting up port forwarding..."
    & $ADB -s $device.Id reverse tcp:8081 tcp:8081 2>&1 | Out-Null
    
    # Check if Metro is already running
    $metroRunning = $false
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8081/status" -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $metroRunning = $true
        }
    } catch {
        # Metro not running
    }
    
    if ($metroRunning) {
        Write-Success "Metro bundler already running"
    } else {
        Write-Info "Starting Metro bundler in new window..."
        Push-Location ..
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "npm start" -WorkingDirectory $PWD
        Pop-Location
        Write-Success "Metro bundler started"
        Write-Warning "Wait a few seconds for Metro to initialize before launching the app"
    }
}

# Function to launch app
function Launch-App($device) {
    if (-not $LaunchApp) {
        return
    }
    
    Write-ColorOutput "`n[LAUNCHING APP]" "Magenta"
    Write-Info "Starting application..."
    
    # Launch the app
    $launchOutput = & $ADB -s $device.Id shell monkey -p $PACKAGE_NAME -c android.intent.category.LAUNCHER 1 2>&1
    
    if ($launchOutput -match "Events injected: 1") {
        Write-Success "App launched successfully"
    } else {
        Write-Warning "Could not auto-launch app, please launch manually"
    }
}

# Main execution
try {
    # Get connected devices
    $devices = Get-ConnectedDevices
    
    if ($devices.Count -eq 0) {
        Write-Error "No Android devices found!"
        Write-Warning "Please ensure:"
        Write-Warning "  1. Device is connected via USB"
        Write-Warning "  2. USB debugging is enabled"
        Write-Warning "  3. You've authorized this computer on the device"
        Write-ColorOutput "`nTo check device connection:" "Yellow"
        Write-ColorOutput "  $ADB devices" "White"
        exit 1
    }
    
    # Select device
    $selectedDevice = Select-Device $devices
    Write-Success "Using device: $($selectedDevice.Name)"
    
    # Build phase (unless skipped)
    if (-not $SkipBuild) {
        if (-not (Build-App)) {
            Write-Error "Build failed, aborting installation"
            exit 1
        }
    } else {
        if (Test-Path $APK_PATH) {
            Write-Info "Skipping build, using existing APK"
            $apkDate = (Get-Item $APK_PATH).LastWriteTime
            Write-Info "APK built: $($apkDate.ToString('yyyy-MM-dd HH:mm:ss'))"
        } else {
            Write-Error "No APK found at: $APK_PATH"
            Write-Warning "Run without -SkipBuild to build the app first"
            exit 1
        }
    }
    
    # Install phase
    if (-not (Install-APK $selectedDevice)) {
        exit 1
    }
    
    # Setup Metro
    Setup-Metro $selectedDevice
    
    # Launch app
    Launch-App $selectedDevice
    
    # Success summary
    Write-ColorOutput "`n============================================" "Green"
    Write-ColorOutput " ✅ PROCESS COMPLETED SUCCESSFULLY" "Green"
    Write-ColorOutput "============================================" "Green"
    Write-ColorOutput ""
    Write-Info "Device: $($selectedDevice.Name)"
    Write-Info "Package: $PACKAGE_NAME"
    
    if (-not $NoMetro) {
        Write-ColorOutput "`nMetro bundler commands:" "Yellow"
        Write-ColorOutput "  r - Reload app"
        Write-ColorOutput "  d - Open developer menu"
    }
    
    Write-ColorOutput "`nUseful ADB commands:" "Yellow"
    Write-ColorOutput "  adb logcat *:E                    # Show errors only"
    Write-ColorOutput "  adb logcat -s ReactNative:V      # React Native logs"
    Write-ColorOutput "  adb shell am force-stop $PACKAGE_NAME  # Force stop app"
    
} catch {
    Write-Error "Unexpected error: $_"
    exit 1
}

Write-ColorOutput "`nCompleted at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" "Gray"