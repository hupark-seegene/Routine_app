# FIX-UTF8-ENCODING.ps1
# Fixes UTF-8 encoding issues in XML layout files

$ErrorActionPreference = "Stop"

Write-Host "Fixing UTF-8 encoding issues in layout files..." -ForegroundColor Yellow

$layoutPath = "..\..\android\app\src\main\res\layout"

# List of files with encoding issues from the error
$problemFiles = @(
    "item_custom_exercise.xml",
    "activity_workout_program.xml",
    "dialog_exercise_details.xml",
    "activity_custom_exercise.xml",
    "activity_voice_guided_workout.xml",
    "item_achievement.xml",
    "activity_voice_record.xml",
    "activity_video_tutorials.xml",
    "activity_achievements.xml"
)

$fixedCount = 0

foreach ($fileName in $problemFiles) {
    $filePath = Join-Path $layoutPath $fileName
    
    if (Test-Path $filePath) {
        try {
            # Read file with explicit UTF-8 encoding
            $content = Get-Content -Path $filePath -Encoding UTF8 -Raw
            
            # Remove any BOM markers and fix encoding
            $content = $content -replace '\xEF\xBB\xBF', ''
            
            # Write back with UTF-8 encoding without BOM
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($filePath, $content, $utf8NoBom)
            
            Write-Host "✓ Fixed: $fileName" -ForegroundColor Green
            $fixedCount++
        } catch {
            Write-Host "✗ Failed to fix: $fileName - $_" -ForegroundColor Red
        }
    } else {
        Write-Host "✗ File not found: $fileName" -ForegroundColor Yellow
    }
}

# Also fix all other XML files to be safe
Write-Host "`nChecking all other layout files..." -ForegroundColor Yellow

$allXmlFiles = Get-ChildItem -Path $layoutPath -Filter "*.xml" -File
$additionalFixed = 0

foreach ($file in $allXmlFiles) {
    if ($file.Name -notin $problemFiles) {
        try {
            $content = Get-Content -Path $file.FullName -Encoding UTF8 -Raw
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
            $additionalFixed++
        } catch {
            Write-Host "✗ Failed to process: $($file.Name)" -ForegroundColor Red
        }
    }
}

Write-Host "`n=================================================" -ForegroundColor Green
Write-Host "Encoding fixes complete!" -ForegroundColor Green
Write-Host "Problem files fixed: $fixedCount" -ForegroundColor Yellow
Write-Host "Additional files processed: $additionalFixed" -ForegroundColor Yellow
Write-Host "Total files processed: $($fixedCount + $additionalFixed)" -ForegroundColor Cyan