# Check App Status Script
Write-Host "`n=== CHECKING APP STATUS ===" -ForegroundColor Cyan

$adb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"

# Check if app is installed
Write-Host "`nChecking installation..." -ForegroundColor Yellow
$packages = & $adb shell pm list packages 2>$null
if ($packages -match "com.squashtrainingapp") {
    Write-Host "✓ App is installed" -ForegroundColor Green
} else {
    Write-Host "✗ App is NOT installed" -ForegroundColor Red
    exit 1
}

# Check if app is running
Write-Host "`nChecking if app is running..." -ForegroundColor Yellow
$processes = & $adb shell ps 2>$null
if ($processes -match "com.squashtrainingapp") {
    Write-Host "✓ App is running" -ForegroundColor Green
} else {
    Write-Host "✗ App is NOT running" -ForegroundColor Red
    
    # Try to launch it
    Write-Host "`nAttempting to launch app..." -ForegroundColor Yellow
    & $adb shell am start -n com.squashtrainingapp/.MainActivity 2>$null
    Start-Sleep -Seconds 2
}

# Get recent logs
Write-Host "`nRecent app logs:" -ForegroundColor Yellow
Write-Host "=================" -ForegroundColor Gray

# Clear logcat first
& $adb logcat -c

# Launch app again to capture fresh logs
& $adb shell am start -n com.squashtrainingapp/.MainActivity 2>$null
Start-Sleep -Seconds 3

# Get logs
$tempLog = Join-Path $env:TEMP "squash_app_status.log"
& $adb logcat -d -t 500 > $tempLog

# Look for crashes
$logContent = Get-Content $tempLog -Raw
if ($logContent -match "FATAL EXCEPTION|AndroidRuntime.*FATAL|Process.*died") {
    Write-Host "`n✗ APP IS CRASHING!" -ForegroundColor Red
    
    # Extract crash details
    $crashLines = $logContent -split "`n" | Where-Object { 
        $_ -match "AndroidRuntime|FATAL|Exception|Error|at com\.squashtrainingapp|at com\.facebook\.react"
    }
    
    Write-Host "`nCrash details:" -ForegroundColor Yellow
    $crashLines | Select-Object -First 20 | ForEach-Object { Write-Host $_ }
    
    # Common crash patterns
    if ($logContent -match "ClassNotFoundException.*MainActivity") {
        Write-Host "`n[ISSUE] MainActivity not found - Check if Java files are compiled" -ForegroundColor Yellow
    }
    if ($logContent -match "couldn't find DSO to load") {
        Write-Host "`n[ISSUE] Native library missing - Check native module configuration" -ForegroundColor Yellow
    }
    if ($logContent -match "Unable to load script.*index.android.bundle") {
        Write-Host "`n[ISSUE] JavaScript bundle missing or invalid" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n✓ No crashes detected" -ForegroundColor Green
    
    # Check for React Native initialization
    if ($logContent -match "ReactNativeJS.*Running") {
        Write-Host "✓ React Native is running" -ForegroundColor Green
    } else {
        Write-Host "! React Native may not be initialized yet" -ForegroundColor Yellow
    }
}

# Check Metro connection
Write-Host "`nChecking Metro bundler connection..." -ForegroundColor Yellow
$metroTest = & $adb shell curl -s http://localhost:8081/status 2>$null
if ($metroTest -match "packager-status:running") {
    Write-Host "✓ Metro bundler is connected" -ForegroundColor Green
} else {
    Write-Host "! Metro bundler may not be connected" -ForegroundColor Yellow
    Write-Host "  Run: adb reverse tcp:8081 tcp:8081" -ForegroundColor Gray
}

Write-Host "`nDone!" -ForegroundColor Green