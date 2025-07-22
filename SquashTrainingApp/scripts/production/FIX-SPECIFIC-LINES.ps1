# FIX-SPECIFIC-LINES.ps1
# Fix specific lines in XML files based on error messages

$ErrorActionPreference = "Stop"

Write-Host "Fixing specific XML lines based on error messages..." -ForegroundColor Yellow

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
        Write-Host "Processing $fileName at line $lineNum..." -ForegroundColor Gray
        
        $content = Get-Content $filePath -Encoding UTF8
        
        # Adjust for 0-based index
        $lineIndex = $lineNum - 1
        
        if ($lineIndex -lt $content.Count) {
            $line = $content[$lineIndex]
            
            # Check if line has closing tag issue
            if ($line -match '<(TextView|Button|RadioButton|ImageButton|ImageView)' -and $line -notmatch '/>\s*$' -and $line -notmatch '>\s*$') {
                # Add closing tag
                $content[$lineIndex] = $line.TrimEnd() + ' />'
                Write-Host "  Fixed: Added closing tag" -ForegroundColor Green
            }
            # Check if line has attribute without closing
            elseif ($line -match 'android:\w+="[^"]*"\s*$' -and $line -notmatch '/>\s*$') {
                # Check if this is the last attribute line
                if ($lineIndex + 1 -ge $content.Count -or $content[$lineIndex + 1] -notmatch '^\s*android:') {
                    $content[$lineIndex] = $line.TrimEnd() + ' />'
                    Write-Host "  Fixed: Added closing tag to attribute line" -ForegroundColor Green
                }
            }
            # Check for corrupted Korean text
            elseif ($line -match '\?[^\s"]*[\x{AC00}-\x{D7AF}]' -or $line -match '[\x{AC00}-\x{D7AF}][^\s"]*\?') {
                Write-Host "  Found corrupted Korean text, attempting to fix..." -ForegroundColor Yellow
                # Replace common corrupted patterns
                $line = $line -replace '\?[^\s"]*\x{C801}', '적'
                $line = $line -replace '\?[^\s"]*\x{C778}', '인'
                $line = $line -replace '\?[^\s"]*\x{B8CC}', '료'
                $content[$lineIndex] = $line
                Write-Host "  Fixed: Replaced corrupted Korean text" -ForegroundColor Green
            }
        }
        
        # Write back the file
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllLines($filePath, $content, $utf8NoBom)
        Write-Host "✓ Processed $fileName" -ForegroundColor Green
    }
}

Write-Host "`n=================================================" -ForegroundColor Green
Write-Host "Specific line fixes complete!" -ForegroundColor Green