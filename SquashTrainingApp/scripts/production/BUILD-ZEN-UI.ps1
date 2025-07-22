# BUILD-ZEN-UI.ps1
# Build APK with new Zen Minimal UI

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Building Zen Minimal UI APK" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Navigate to android directory
$androidPath = "$PSScriptRoot\..\..\android"
if (-not (Test-Path $androidPath)) {
    Write-Host "Android directory not found!" -ForegroundColor Red
    exit 1
}

Set-Location $androidPath

# Clean previous builds
Write-Host "`nCleaning previous builds..." -ForegroundColor Yellow
if (Test-Path ".\app\build") {
    Remove-Item -Path ".\app\build" -Recurse -Force
}

# Build APK
Write-Host "`nBuilding APK..." -ForegroundColor Yellow
$startTime = Get-Date

# Execute gradlew
cmd /c "gradlew.bat assembleDebug"

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nBuild failed!" -ForegroundColor Red
    exit 1
}

$endTime = Get-Date
$duration = [math]::Round(($endTime - $startTime).TotalSeconds, 2)

# Check if APK exists
$apkPath = ".\app\build\outputs\apk\debug\app-debug.apk"
if (Test-Path $apkPath) {
    $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
    Write-Host "`n======================================" -ForegroundColor Green
    Write-Host "Build Successful!" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host "APK: $apkPath" -ForegroundColor White
    Write-Host "Size: $apkSize MB" -ForegroundColor White
    Write-Host "Duration: $duration seconds" -ForegroundColor White
} else {
    Write-Host "`nAPK not found!" -ForegroundColor Red
    exit 1
}

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "New UI Features:" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "✓ Warm beige primary color (#F5E6D3)" -ForegroundColor Green
Write-Host "✓ Deep olive green accent (#4A5D3A)" -ForegroundColor Green
Write-Host "✓ Minimal shadows and flat design" -ForegroundColor Green
Write-Host "✓ Rounded corners (12dp)" -ForegroundColor Green
Write-Host "✓ Clean typography" -ForegroundColor Green
Write-Host "✓ Universal appeal design" -ForegroundColor Green