<#
.SYNOPSIS
    Debug crash logs to find why navigation is crashing
#>

$ErrorActionPreference = "Continue"
$ADB = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$PACKAGE_NAME = "com.squashtrainingapp"
$LOGS_DIR = "C:\git\routine_app\build-artifacts\logs\crash-debug"

if (!(Test-Path $LOGS_DIR)) {
    New-Item -ItemType Directory -Path $LOGS_DIR -Force | Out-Null
}

Write-Host "=== CRASH DEBUG ANALYSIS ===" -ForegroundColor Cyan

# Clear previous logs
Write-Host "Clearing previous logs..." -ForegroundColor Yellow
& $ADB logcat -c

# Launch app
Write-Host "Launching app..." -ForegroundColor Yellow
& $ADB shell am start -n "$PACKAGE_NAME/.MainActivity" 2>&1 | Out-Null
Start-Sleep -Seconds 3

# Try to navigate and capture crash
Write-Host "Attempting navigation to trigger crash..." -ForegroundColor Yellow
& $ADB shell input tap 216 2337  # Checklist tab
Start-Sleep -Seconds 2

# Capture logs
Write-Host "Capturing crash logs..." -ForegroundColor Yellow
$logFile = "$LOGS_DIR\crash_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
& $ADB logcat -d > $logFile 2>&1

# Filter for crashes and errors
Write-Host "`n=== CRASH ANALYSIS ===" -ForegroundColor Red
$crashes = Get-Content $logFile | Select-String -Pattern "AndroidRuntime|FATAL|$PACKAGE_NAME.*Exception|$PACKAGE_NAME.*Error|ActivityNotFoundException"

if ($crashes) {
    Write-Host "`nCrashes found:" -ForegroundColor Red
    $crashes | ForEach-Object {
        Write-Host $_ -ForegroundColor Yellow
    }
    
    # Save filtered crash log
    $crashFile = "$LOGS_DIR\filtered_crashes.txt"
    $crashes | Out-File $crashFile -Encoding UTF8
    Write-Host "`nFiltered crash log saved to: $crashFile" -ForegroundColor Cyan
} else {
    Write-Host "No obvious crashes found in logs" -ForegroundColor Yellow
}

# Check for activity not found errors
Write-Host "`n=== CHECKING FOR ACTIVITY ERRORS ===" -ForegroundColor Cyan
$activityErrors = Get-Content $logFile | Select-String -Pattern "Unable to find explicit activity|ActivityNotFoundException|No Activity found"

if ($activityErrors) {
    Write-Host "`nActivity errors found:" -ForegroundColor Red
    $activityErrors | ForEach-Object {
        Write-Host $_ -ForegroundColor Yellow
    }
}

# Check AndroidManifest issues
Write-Host "`n=== CHECKING MANIFEST CONFIGURATION ===" -ForegroundColor Cyan
$manifestErrors = Get-Content $logFile | Select-String -Pattern "Permission Denial|SecurityException|not exported"

if ($manifestErrors) {
    Write-Host "`nManifest/Permission errors found:" -ForegroundColor Red
    $manifestErrors | ForEach-Object {
        Write-Host $_ -ForegroundColor Yellow
    }
}

Write-Host "`nFull log saved to: $logFile" -ForegroundColor Cyan
Write-Host "Opening logs directory..." -ForegroundColor Green
Start-Process explorer.exe $LOGS_DIR