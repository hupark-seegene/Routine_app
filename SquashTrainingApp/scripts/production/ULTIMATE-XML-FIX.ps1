# ULTIMATE-XML-FIX.ps1
# Ultimate fix for all XML issues

$ErrorActionPreference = "Stop"

Write-Host "Ultimate XML fix - fixing all issues..." -ForegroundColor Yellow

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$androidDir = Join-Path $scriptDir "..\..\android"
$layoutPath = Join-Path $androidDir "app\src\main\res\layout"

# Define all files with issues and their specific line numbers from build errors
$fixes = @(
    @{File="activity_login.xml"; Line=92; Issue="Missing closing tag"},
    @{File="item_custom_exercise.xml"; Line=74; Issue="Missing closing tag"},
    @{File="dialog_exercise_details.xml"; Line=71; Issue="Missing closing tag"},
    @{File="activity_voice_guided_workout.xml"; Line=53; Issue="Missing closing tag"},
    @{File="activity_voice_record.xml"; Line=183; Issue="Missing closing tag"},
    @{File="item_workout_program.xml"; Line=75; Issue="Missing closing tag"},
    @{File="dialog_create_exercise.xml"; Line=51; Issue="Missing closing tag"},
    @{File="global_voice_overlay.xml"; Line=80; Issue="Missing closing tag"}
)

foreach ($fix in $fixes) {
    $filePath = Join-Path $layoutPath $fix.File
    Write-Host "Processing $($fix.File) at line $($fix.Line)..." -ForegroundColor Gray
    
    if (Test-Path $filePath) {
        $lines = Get-Content $filePath -Encoding UTF8
        $lineIndex = $fix.Line - 1
        
        if ($lineIndex -lt $lines.Count) {
            $currentLine = $lines[$lineIndex]
            
            # Check if this line needs a closing tag
            if ($currentLine -match 'android:' -and $currentLine -notmatch '/>\s*$') {
                # Add closing tag
                $lines[$lineIndex] = $currentLine.TrimEnd() + ' />'
                Write-Host "  Fixed: Added /> to line $($fix.Line)" -ForegroundColor Green
                
                # Save the file
                $utf8NoBom = New-Object System.Text.UTF8Encoding $false
                [System.IO.File]::WriteAllLines($filePath, $lines, $utf8NoBom)
            } else {
                Write-Host "  Line already has closing tag or doesn't need one" -ForegroundColor Yellow
            }
        }
    }
}

Write-Host "`nAll XML issues have been fixed!" -ForegroundColor Green
Write-Host "Ready to build the app." -ForegroundColor Cyan