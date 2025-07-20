# Wrapper script to run comprehensive debug with proper ADB path

# Set ADB path
$env:PATH = "C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools;$env:PATH"

# Change to project directory
Set-Location -Path "C:\Git\Routine_app"

# Check if emulator is running
Write-Host "[INFO] Checking emulator status..." -ForegroundColor Cyan
$devices = adb devices
if ($devices -notmatch "emulator") {
    Write-Host "[WARNING] No emulator detected. Please start an emulator first." -ForegroundColor Yellow
    
    # Try to start emulator
    Write-Host "[INFO] Attempting to start emulator..." -ForegroundColor Cyan
    $emulatorPath = "C:\Users\hwpar\AppData\Local\Android\Sdk\emulator"
    $env:PATH = "$emulatorPath;$env:PATH"
    
    # List available emulators
    $avds = emulator -list-avds
    if ($avds) {
        $firstAvd = ($avds -split "`n")[0].Trim()
        Write-Host "[INFO] Starting emulator: $firstAvd" -ForegroundColor Green
        Start-Process -FilePath "emulator" -ArgumentList "-avd", $firstAvd -WindowStyle Hidden
        
        # Wait for emulator to boot
        Write-Host "[INFO] Waiting for emulator to boot (this may take a few minutes)..." -ForegroundColor Yellow
        $timeout = 120
        $elapsed = 0
        while ($elapsed -lt $timeout) {
            Start-Sleep -Seconds 5
            $elapsed += 5
            $devices = adb devices
            if ($devices -match "emulator.*device") {
                Write-Host "[SUCCESS] Emulator is ready!" -ForegroundColor Green
                break
            }
            Write-Host "." -NoNewline
        }
        Write-Host ""
    } else {
        Write-Host "[ERROR] No AVDs found. Please create an AVD first." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[SUCCESS] Emulator is already running" -ForegroundColor Green
}

# Install APK if needed
Write-Host "[INFO] Installing APK..." -ForegroundColor Cyan
$apkPath = "C:\Git\Routine_app\SquashTrainingApp\android\app\build\outputs\apk\debug\app-debug.apk"
if (Test-Path $apkPath) {
    adb install -r $apkPath 2>&1 | Out-Null
    Write-Host "[SUCCESS] APK installed" -ForegroundColor Green
} else {
    Write-Host "[ERROR] APK not found at: $apkPath" -ForegroundColor Red
    Write-Host "[INFO] Please build the APK first" -ForegroundColor Yellow
    exit 1
}

# Run comprehensive debug
Write-Host "[INFO] Starting comprehensive functional debug..." -ForegroundColor Cyan
& ".\COMPREHENSIVE-FUNCTIONAL-DEBUG.ps1"