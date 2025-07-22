# FINAL-COMPLETE-FIX.ps1
# Final complete fix for all XML files

$ErrorActionPreference = "Stop"

Write-Host "Final complete XML fix..." -ForegroundColor Yellow

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$androidDir = Join-Path $scriptDir "..\..\android"
$layoutPath = Join-Path $androidDir "app\src\main\res\layout"

# Fix activity_profile.xml - add background attribute before textColor
$file = Join-Path $layoutPath "activity_profile.xml"
if (Test-Path $file) {
    Write-Host "Fixing activity_profile.xml..." -ForegroundColor Gray
    $content = Get-Content $file -Raw -Encoding UTF8
    $content = $content -replace '(android:text="[^"]*"\s*/>\s*)(android:textColor=)', '$1android:background="?attr/selectableItemBackgroundBorderless"`n                    $2'
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($file, $content, $utf8NoBom)
    Write-Host "  Fixed" -ForegroundColor Green
}

Write-Host "`nFinal fixes complete!" -ForegroundColor Green