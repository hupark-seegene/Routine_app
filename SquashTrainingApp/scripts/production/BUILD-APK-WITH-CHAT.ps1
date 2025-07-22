# BUILD-APK-WITH-CHAT.ps1
# Builds the APK with the new chat interface and UI updates

$ErrorActionPreference = "Stop"

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "Building APK with Chat Interface & Zen UI" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Cyan

# Set Java environment
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

# Navigate to Android directory
Set-Location -Path "..\..\android"

Write-Host "`nCleaning previous builds..." -ForegroundColor Yellow
.\gradlew.bat clean

Write-Host "`nBuilding debug APK..." -ForegroundColor Yellow
$buildStartTime = Get-Date

try {
    .\gradlew.bat assembleDebug --stacktrace
    
    $buildEndTime = Get-Date
    $buildDuration = $buildEndTime - $buildStartTime
    
    Write-Host "`n=================================================" -ForegroundColor Green
    Write-Host "✓ Build completed successfully!" -ForegroundColor Green
    Write-Host "Build duration: $($buildDuration.ToString('mm\:ss'))" -ForegroundColor Yellow
    
    # Get APK info
    $apkPath = "app\build\outputs\apk\debug\app-debug.apk"
    if (Test-Path $apkPath) {
        $apkSize = (Get-Item $apkPath).Length / 1MB
        Write-Host "APK size: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Yellow
        Write-Host "APK location: $((Get-Item $apkPath).FullName)" -ForegroundColor Cyan
        
        # Copy to easy location
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $outputPath = "$desktopPath\SquashTraining-ZenUI-Chat.apk"
        Copy-Item $apkPath $outputPath -Force
        Write-Host "`nAPK copied to: $outputPath" -ForegroundColor Green
    }
    
    Write-Host "`nKey features in this build:" -ForegroundColor Cyan
    Write-Host "✓ Zen Minimal UI design (warm beige & sage green)" -ForegroundColor Gray
    Write-Host "✓ AI Coach with chat interface" -ForegroundColor Gray
    Write-Host "✓ Voice/Text mode toggle" -ForegroundColor Gray
    Write-Host "✓ Korean language support" -ForegroundColor Gray
    Write-Host "✓ Guest mode access" -ForegroundColor Gray
    Write-Host "✓ All 37 screens updated" -ForegroundColor Gray
    
} catch {
    Write-Host "`n❌ Build failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host "`n=================================================" -ForegroundColor Cyan
Write-Host "Ready for deployment!" -ForegroundColor Green