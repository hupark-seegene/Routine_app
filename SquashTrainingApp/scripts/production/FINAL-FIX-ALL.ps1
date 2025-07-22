# FINAL-FIX-ALL.ps1
# Final fix for all XML files

$ErrorActionPreference = "Stop"

Write-Host "Final fix for all XML files..." -ForegroundColor Yellow

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$androidDir = Join-Path $scriptDir "..\..\android"
$layoutPath = Join-Path $androidDir "app\src\main\res\layout"

# Fix each file specifically
$files = @(
    @{name="item_custom_exercise.xml"; line=74},
    @{name="dialog_exercise_details.xml"; line=71},
    @{name="activity_voice_guided_workout.xml"; line=53},
    @{name="activity_voice_record.xml"; line=183},
    @{name="item_workout_program.xml"; line=75},
    @{name="dialog_create_exercise.xml"; line=51},
    @{name="global_voice_overlay.xml"; line=80}
)

foreach ($file in $files) {
    $filePath = Join-Path $layoutPath $file.name
    if (Test-Path $filePath) {
        Write-Host "Fixing $($file.name)..." -ForegroundColor Gray
        $lines = Get-Content $filePath -Encoding UTF8
        $lineIndex = $file.line - 1
        
        if ($lineIndex -lt $lines.Count -and $lines[$lineIndex] -notmatch '/>\s*$') {
            $lines[$lineIndex] = $lines[$lineIndex].TrimEnd() + ' />'
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllLines($filePath, $lines, $utf8NoBom)
            Write-Host "  Fixed line $($file.line)" -ForegroundColor Green
        }
    }
}

Write-Host "`nAll fixes complete!" -ForegroundColor Green