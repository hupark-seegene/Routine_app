# FIX-XML-STRUCTURE.ps1
# Fix XML structural issues without dealing with Korean encoding

$ErrorActionPreference = "Stop"

Write-Host "Fixing XML structural issues..." -ForegroundColor Yellow

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$androidDir = Join-Path $scriptDir "..\..\android"
$layoutPath = Join-Path $androidDir "app\src\main\res\layout"

# Function to fix duplicate closing tags
function Fix-DuplicateClosingTags {
    param($content)
    
    # Fix pattern where closing tag appears on multiple lines
    $content = $content -replace '(\s+android:textColor="[^"]*")\s*/>\s*android:textSize="[^"]*"\s*/>', '$1`n                android:textSize="20sp" />'
    $content = $content -replace '(\s+android:textColor="[^"]*")\s*/>\s*android:textSize="[^"]*"\s*android:textStyle="[^"]*"\s*/>', '$1`n                android:textSize="20sp"`n                android:textStyle="bold" />'
    
    return $content
}

# Process activity_achievements.xml
$achievementsPath = Join-Path $layoutPath "activity_achievements.xml"
if (Test-Path $achievementsPath) {
    Write-Host "Processing activity_achievements.xml..." -ForegroundColor Gray
    $content = Get-Content $achievementsPath -Raw -Encoding UTF8
    $content = Fix-DuplicateClosingTags $content
    
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($achievementsPath, $content, $utf8NoBom)
    Write-Host "  Fixed" -ForegroundColor Green
}

# Process dialog_exercise_details.xml
$exercisePath = Join-Path $layoutPath "dialog_exercise_details.xml"
if (Test-Path $exercisePath) {
    Write-Host "Processing dialog_exercise_details.xml..." -ForegroundColor Gray
    $content = Get-Content $exercisePath -Raw -Encoding UTF8
    $content = Fix-DuplicateClosingTags $content
    
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($exercisePath, $content, $utf8NoBom)
    Write-Host "  Fixed" -ForegroundColor Green
}

# Process activity_profile.xml
$profilePath = Join-Path $layoutPath "activity_profile.xml"
if (Test-Path $profilePath) {
    Write-Host "Processing activity_profile.xml..." -ForegroundColor Gray
    $content = Get-Content $profilePath -Raw -Encoding UTF8
    
    # Fix duplicate text attribute
    $content = $content -replace '(\s+android:text="[^"]*)\n\s+android:text="[^"]*"\s*/>', '$1" />'
    
    # Fix duplicate button IDs
    $buttonCount = 0
    $lines = $content -split "`n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match 'android:id="@\+id/settings_button"') {
            $buttonCount++
            if ($buttonCount -eq 2) {
                $lines[$i] = $lines[$i] -replace 'settings_button"', 'settings_button_bottom"'
            }
        }
    }
    $content = $lines -join "`n"
    
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($profilePath, $content, $utf8NoBom)
    Write-Host "  Fixed" -ForegroundColor Green
}

Write-Host "`nStructural fixes complete!" -ForegroundColor Green
Write-Host "Note: Korean text encoding issues need manual correction" -ForegroundColor Yellow