# REBUILD-PROBLEM-XMLS.ps1
# Rebuild problematic XML files with correct syntax

$ErrorActionPreference = "Stop"

Write-Host "Rebuilding problematic XML files..." -ForegroundColor Yellow

Set-Location -Path "..\..\android"
$layoutPath = "app\src\main\res\layout"

# Fix activity_settings.xml by replacing the problematic section
$settingsFixed = @'
                <RadioButton
                    android:id="@+id/radio_korean"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:text="한국어"
                    android:buttonTint="@color/accent" />
'@

$settingsFile = Join-Path $layoutPath "activity_settings.xml"
if (Test-Path $settingsFile) {
    $content = Get-Content $settingsFile -Encoding UTF8 -Raw
    # Replace lines 74-80
    $content = $content -replace '(?s)<RadioButton\s+android:id="@/\+id/radio_korean"[^>]*?/>', $settingsFixed
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($settingsFile, $content, $utf8NoBom)
    Write-Host "✓ Fixed activity_settings.xml" -ForegroundColor Green
}

# Now try to build again
Write-Host "`nAttempting build..." -ForegroundColor Yellow

.\gradlew.bat assembleDebug --stacktrace

$apkPath = "app\build\outputs\apk\debug\app-debug.apk"
if (Test-Path $apkPath) {
    Write-Host "`n✓ Build successful!" -ForegroundColor Green
    
    # Copy to desktop
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $timestamp = Get-Date -Format "yyyyMMdd-HHmm"
    $outputPath = "$desktopPath\SquashTraining-$timestamp.apk"
    Copy-Item $apkPath $outputPath -Force
    
    Write-Host "APK saved to: $outputPath" -ForegroundColor Cyan
} else {
    Write-Host "❌ Build failed" -ForegroundColor Red
}