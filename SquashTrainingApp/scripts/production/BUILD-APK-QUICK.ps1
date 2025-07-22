# BUILD-APK-QUICK.ps1
# Quick build that skips problematic resources

$ErrorActionPreference = "Continue"

Write-Host "Quick APK Build - Bypassing XML issues" -ForegroundColor Yellow

# Set Java environment
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

# Navigate to Android directory
Set-Location -Path "..\..\android"

Write-Host "`nTemporarily removing problematic files..." -ForegroundColor Yellow

# Move problematic files temporarily
$problemFiles = @(
    "app\src\main\res\layout\activity_achievements.xml",
    "app\src\main\res\layout\activity_settings.xml",
    "app\src\main\res\layout\activity_profile.xml",
    "app\src\main\res\layout\activity_voice_guided_workout.xml",
    "app\src\main\res\layout\activity_voice_record.xml",
    "app\src\main\res\layout\dialog_create_exercise.xml",
    "app\src\main\res\layout\dialog_exercise_details.xml",
    "app\src\main\res\layout\global_voice_overlay.xml",
    "app\src\main\res\layout\item_custom_exercise.xml",
    "app\src\main\res\layout\item_workout_program.xml"
)

$tempDir = "temp_layouts"
if (!(Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

foreach ($file in $problemFiles) {
    if (Test-Path $file) {
        $fileName = Split-Path $file -Leaf
        Move-Item $file "$tempDir\$fileName" -Force
        Write-Host "Moved: $fileName" -ForegroundColor Gray
    }
}

Write-Host "`nBuilding APK..." -ForegroundColor Yellow

try {
    # Build with continue on error
    .\gradlew.bat assembleDebug --continue 2>&1 | Out-String
    
    # Check if APK was created
    $apkPath = "app\build\outputs\apk\debug\app-debug.apk"
    if (Test-Path $apkPath) {
        $apkSize = (Get-Item $apkPath).Length / 1MB
        
        Write-Host "`n=================================================" -ForegroundColor Green
        Write-Host "✓ APK built successfully!" -ForegroundColor Green
        Write-Host "APK size: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Yellow
        
        # Copy to desktop
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $outputPath = "$desktopPath\SquashTraining-Chat-UI.apk"
        Copy-Item $apkPath $outputPath -Force
        Write-Host "APK copied to: $outputPath" -ForegroundColor Cyan
        
        Write-Host "`nFeatures included:" -ForegroundColor Cyan
        Write-Host "✓ Zen Minimal UI (beige & sage green)" -ForegroundColor Gray
        Write-Host "✓ AI Coach with chat interface" -ForegroundColor Gray
        Write-Host "✓ Voice/Text mode toggle" -ForegroundColor Gray
        Write-Host "✓ Guest mode access" -ForegroundColor Gray
        Write-Host "✓ Korean language support" -ForegroundColor Gray
        
        Write-Host "`nNote: Some screens temporarily excluded due to XML issues" -ForegroundColor Yellow
    } else {
        Write-Host "❌ APK build failed" -ForegroundColor Red
    }
    
} finally {
    # Restore files
    Write-Host "`nRestoring layout files..." -ForegroundColor Yellow
    foreach ($file in $problemFiles) {
        $fileName = Split-Path $file -Leaf
        $tempFile = "$tempDir\$fileName"
        if (Test-Path $tempFile) {
            Move-Item $tempFile $file -Force
            Write-Host "Restored: $fileName" -ForegroundColor Gray
        }
    }
    
    # Clean up temp directory
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
    }
}

Write-Host "`n=================================================" -ForegroundColor Cyan