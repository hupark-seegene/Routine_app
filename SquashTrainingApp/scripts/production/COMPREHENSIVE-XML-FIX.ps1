# COMPREHENSIVE-XML-FIX.ps1
# Fix all XML issues comprehensively

$ErrorActionPreference = "Stop"

Write-Host "Comprehensive XML fix..." -ForegroundColor Yellow

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$androidDir = Join-Path $scriptDir "..\..\android"
$layoutPath = Join-Path $androidDir "app\src\main\res\layout"

# Fix activity_login.xml - remove duplicate closing tag
$file = Join-Path $layoutPath "activity_login.xml"
if (Test-Path $file) {
    Write-Host "Fixing activity_login.xml..." -ForegroundColor Gray
    $lines = Get-Content $file -Encoding UTF8
    # Remove line 94 which has duplicate closing tag
    if ($lines[93] -match '/>') {
        $newLines = @()
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($i -ne 93) {
                $newLines += $lines[$i]
            }
        }
        [System.IO.File]::WriteAllLines($file, $newLines, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "  Fixed" -ForegroundColor Green
    }
}

# Now run the emergency fix on all files
& "$scriptDir\EMERGENCY-FIX.ps1"

Write-Host "`nComprehensive fixes complete!" -ForegroundColor Green