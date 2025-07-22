# REMOVE-DUPLICATE-TAGS.ps1
# Remove duplicate closing tags from XML files

$ErrorActionPreference = "Stop"

Write-Host "Removing duplicate closing tags..." -ForegroundColor Yellow

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$androidDir = Join-Path $scriptDir "..\..\android"
$layoutPath = Join-Path $androidDir "app\src\main\res\layout"

# Files with duplicate tags
$files = @(
    @{name="activity_login.xml"; duplicateLine=94},
    @{name="item_custom_exercise.xml"; duplicateLine=76},
    @{name="dialog_exercise_details.xml"; duplicateLine=72},
    @{name="activity_voice_guided_workout.xml"; duplicateLine=54},
    @{name="activity_voice_record.xml"; duplicateLine=185},
    @{name="item_workout_program.xml"; duplicateLine=77},
    @{name="dialog_create_exercise.xml"; duplicateLine=53},
    @{name="global_voice_overlay.xml"; duplicateLine=82},
    @{name="activity_profile.xml"; duplicateLine=77}
)

foreach ($file in $files) {
    $filePath = Join-Path $layoutPath $file.name
    if (Test-Path $filePath) {
        Write-Host "Processing $($file.name)..." -ForegroundColor Gray
        $lines = Get-Content $filePath -Encoding UTF8
        
        # Create new array without the duplicate line
        $newLines = @()
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($i -ne ($file.duplicateLine - 1)) {
                $newLines += $lines[$i]
            } else {
                Write-Host "  Removed duplicate tag at line $($file.duplicateLine)" -ForegroundColor Green
            }
        }
        
        # Write back
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllLines($filePath, $newLines, $utf8NoBom)
    }
}

Write-Host "`nAll duplicate tags removed!" -ForegroundColor Green