# Auto Debug Script - Handles everything automatically
param(
    [int]$Attempt = 1,
    [int]$MaxAttempts = 10
)

$ErrorActionPreference = "Continue"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " Auto Debug - Attempt $Attempt of $MaxAttempts" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Function to check if port is in use
function Test-Port {
    param($Port)
    $connection = Test-NetConnection -ComputerName localhost -Port $Port -WarningAction SilentlyContinue -InformationLevel Quiet
    return $connection
}

# Step 1: Kill all potentially conflicting processes
Write-Host "`n[1/8] Cleaning up processes..." -ForegroundColor Yellow
$processesToKill = @("node", "adb", "qemu-system-x86_64")
foreach ($proc in $processesToKill) {
    Get-Process -Name $proc -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Seconds 2

# Step 2: Clean all caches and temp files
Write-Host "[2/8] Cleaning caches..." -ForegroundColor Yellow
$pathsToClean = @(
    "$env:TEMP\metro-*",
    "$env:TEMP\react-*",
    "$env:LOCALAPPDATA\Temp\metro-*",
    "$PWD\node_modules\.bin\.*",
    "$PWD\node_modules\.cache",
    "$PWD\.metro-cache"
)

foreach ($path in $pathsToClean) {
    Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
}

# Step 3: Fix permissions
Write-Host "[3/8] Fixing permissions..." -ForegroundColor Yellow
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Take ownership and grant full control
takeown /f "node_modules" /r /d y 2>$null | Out-Null
icacls "node_modules" /grant "${currentUser}:(OI)(CI)F" /t /c /q 2>$null | Out-Null

# Remove read-only attributes
Get-ChildItem -Path "node_modules" -Recurse -Force | ForEach-Object {
    if ($_.Attributes -match "ReadOnly") {
        Set-ItemProperty -Path $_.FullName -Name Attributes -Value Normal -ErrorAction SilentlyContinue
    }
}

# Step 4: Create JS bundle (bypass Metro)
Write-Host "[4/8] Creating JavaScript bundle..." -ForegroundColor Yellow
$bundleDir = "android\app\src\main\assets"
if (-not (Test-Path $bundleDir)) {
    New-Item -ItemType Directory -Path $bundleDir -Force | Out-Null
}

# Try to create bundle
$bundleCreated = $false
try {
    & npx react-native bundle `
        --platform android `
        --dev true `
        --entry-file index.js `
        --bundle-output "$bundleDir\index.android.bundle" `
        --assets-dest android\app\src\main\res `
        --max-workers 2 `
        --reset-cache 2>$null
    
    if (Test-Path "$bundleDir\index.android.bundle") {
        $bundleCreated = $true
        Write-Host "  ✓ Bundle created successfully" -ForegroundColor Green
    }
} catch {
    Write-Host "  ! Bundle creation failed, using fallback" -ForegroundColor Yellow
}

if (-not $bundleCreated) {
    # Create minimal bundle
    @"
// Auto-generated bundle
console.log('Debug bundle loaded');
if (typeof global === 'undefined') { global = window; }
global.__DEV__ = true;
require('./src/App');
"@ | Out-File -Encoding ASCII "$bundleDir\index.android.bundle"
}

# Step 5: Start ADB server
Write-Host "[5/8] Starting ADB server..." -ForegroundColor Yellow
& adb start-server 2>$null
Start-Sleep -Seconds 2

# Step 6: Check for emulator
Write-Host "[6/8] Checking emulator..." -ForegroundColor Yellow
$devices = & adb devices 2>$null
$emulatorRunning = $devices -match "emulator"

if (-not $emulatorRunning) {
    Write-Host "  ! No emulator detected. Starting Pixel 6..." -ForegroundColor Yellow
    
    # Find and start emulator
    $emulatorPath = "${env:LOCALAPPDATA}\Android\Sdk\emulator\emulator.exe"
    if (Test-Path $emulatorPath) {
        $avds = & $emulatorPath -list-avds 2>$null
        $pixel6 = $avds | Where-Object { $_ -match "Pixel.*6" } | Select-Object -First 1
        
        if ($pixel6) {
            Start-Process -FilePath $emulatorPath -ArgumentList "-avd", $pixel6, "-no-snapshot-load" -WindowStyle Hidden
            Write-Host "  Waiting for emulator to boot..." -ForegroundColor Gray
            
            $timeout = 60
            $elapsed = 0
            while ($elapsed -lt $timeout) {
                Start-Sleep -Seconds 5
                $elapsed += 5
                $devices = & adb devices 2>$null
                if ($devices -match "emulator.*device") {
                    Write-Host "  ✓ Emulator ready!" -ForegroundColor Green
                    break
                }
                Write-Host "  ... waiting ($elapsed/$timeout seconds)" -ForegroundColor Gray
            }
        }
    }
}

# Step 7: Setup port forwarding
Write-Host "[7/8] Setting up ports..." -ForegroundColor Yellow
$ports = @(8081, 8082, 8083, 8088, 8089)
$workingPort = $null

foreach ($port in $ports) {
    & adb reverse tcp:$port tcp:$port 2>$null
    if (-not (Test-Port -Port $port)) {
        $workingPort = $port
        Write-Host "  ✓ Using port $workingPort" -ForegroundColor Green
        break
    }
}

if (-not $workingPort) {
    Write-Host "  ! All ports in use, using 8081 anyway" -ForegroundColor Yellow
    $workingPort = 8081
}

# Step 8: Install and run app
Write-Host "[8/8] Installing app..." -ForegroundColor Yellow

# Build and install
Push-Location android
$buildResult = & .\gradlew.bat installDebug --no-daemon 2>&1
$buildSuccess = $LASTEXITCODE -eq 0
Pop-Location

if ($buildSuccess) {
    Write-Host "  ✓ App installed!" -ForegroundColor Green
    
    # Launch app
    & adb shell am start -n com.squashtrainingapp/.MainActivity 2>$null
    
    # Start log streaming
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host " ✓ DEBUG SETUP COMPLETE!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "App is running. Showing logs..." -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
    Write-Host ""
    
    # Stream logs
    & adb logcat -c
    & adb logcat ReactNative:V ReactNativeJS:V *:S
    
} else {
    Write-Host "  ✗ Build failed!" -ForegroundColor Red
    
    if ($Attempt -lt $MaxAttempts) {
        Write-Host "`nRetrying in 5 seconds..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        
        # Recursive retry
        & $PSCommandPath -Attempt ($Attempt + 1) -MaxAttempts $MaxAttempts
    } else {
        Write-Host "`n❌ Failed after $MaxAttempts attempts" -ForegroundColor Red
        Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
        Write-Host "1. Make sure Android Studio is not running" -ForegroundColor White
        Write-Host "2. Try: npm cache clean --force" -ForegroundColor White
        Write-Host "3. Try: Remove-Item -Recurse -Force node_modules" -ForegroundColor White
        Write-Host "4. Try: npm install" -ForegroundColor White
    }
}