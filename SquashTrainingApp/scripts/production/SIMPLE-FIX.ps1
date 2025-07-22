# SIMPLE-FIX.ps1
# Simple fix for XML closing tags

$ErrorActionPreference = "Stop"

Write-Host "Simple XML fix - Adding closing tags..." -ForegroundColor Yellow

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$androidDir = Join-Path $scriptDir "..\..\android"
$layoutPath = Join-Path $androidDir "app\src\main\res\layout"

# Define files and their problematic lines
$filesToFix = @{
    "activity_achievements.xml" = 56
    "item_custom_exercise.xml" = 74
    "dialog_exercise_details.xml" = 71
    "activity_voice_guided_workout.xml" = 53
    "activity_voice_record.xml" = 183
    "activity_profile.xml" = 77
    "dialog_create_exercise.xml" = 51
    "global_voice_overlay.xml" = 80
}

foreach ($fileName in $filesToFix.Keys) {
    $filePath = Join-Path $layoutPath $fileName
    $lineNum = $filesToFix[$fileName]
    
    if (Test-Path $filePath) {
        Write-Host "Fixing $fileName at line $lineNum..." -ForegroundColor Gray
        
        $content = Get-Content $filePath -Encoding UTF8
        $lineIndex = $lineNum - 1
        
        if ($lineIndex -lt $content.Count) {
            $line = $content[$lineIndex]
            
            # Simply add /> if the line doesn't end with it
            if ($line -notmatch '/>\s*$' -and $line -notmatch '>\s*$') {
                $content[$lineIndex] = $line.TrimEnd() + ' />'
                Write-Host "  Added closing tag" -ForegroundColor Green
            }
        }
        
        # Write back
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllLines($filePath, $content, $utf8NoBom)
    }
}

Write-Host "`nAll files fixed!" -ForegroundColor Green