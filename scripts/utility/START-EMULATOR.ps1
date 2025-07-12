# Start Emulator Script
$ErrorActionPreference = "Continue"

Write-Host "`n=== STARTING EMULATOR ===" -ForegroundColor Cyan

$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$emulator = "$env:ANDROID_HOME\emulator\emulator.exe"
$adb = "$env:ANDROID_HOME\platform-tools\adb.exe"

# Check if emulator is already running
$devices = & $adb devices 2>$null
if ($devices -match "emulator.*device") {
    Write-Host "✓ Emulator already running!" -ForegroundColor Green
    exit 0
}

# List available AVDs
Write-Host "`nAvailable emulators:" -ForegroundColor Yellow
$avds = & $emulator -list-avds 2>$null
$avds | ForEach-Object { Write-Host "  - $_" }

# Find Pixel 6 or any available AVD
$targetAvd = $avds | Where-Object { $_ -match "Pixel.*6" } | Select-Object -First 1
if (-not $targetAvd) {
    $targetAvd = $avds | Select-Object -First 1
}

if ($targetAvd) {
    Write-Host "`nStarting emulator: $targetAvd" -ForegroundColor Yellow
    Start-Process $emulator -ArgumentList "-avd", $targetAvd, "-no-snapshot" -WindowStyle Normal
    
    Write-Host "Waiting for emulator to boot..." -ForegroundColor Yellow
    $timeout = 120
    $elapsed = 0
    
    while ($elapsed -lt $timeout) {
        Start-Sleep -Seconds 5
        $elapsed += 5
        
        $devices = & $adb devices 2>$null
        if ($devices -match "emulator.*device") {
            Write-Host "`n✓ Emulator ready!" -ForegroundColor Green
            
            # Wait for boot to complete
            Write-Host "Waiting for boot to complete..." -ForegroundColor Yellow
            & $adb wait-for-device
            Start-Sleep -Seconds 10
            
            # Unlock screen
            & $adb shell input keyevent 82
            
            Write-Host "`n✓ Emulator fully ready!" -ForegroundColor Green
            exit 0
        }
        Write-Host "  ... $elapsed/$timeout seconds" -ForegroundColor Gray
    }
    
    Write-Host "`n✗ Emulator failed to start!" -ForegroundColor Red
} else {
    Write-Host "`n✗ No AVDs found!" -ForegroundColor Red
    Write-Host "Create an AVD in Android Studio first." -ForegroundColor Yellow
}