# REBUILD-ACHIEVEMENTS.ps1
# Rebuild activity_achievements.xml with correct Korean text

$ErrorActionPreference = "Stop"

Write-Host "Rebuilding activity_achievements.xml..." -ForegroundColor Yellow

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$androidDir = Join-Path $scriptDir "..\..\android"
$layoutPath = Join-Path $androidDir "app\src\main\res\layout"
$achievementsFile = Join-Path $layoutPath "activity_achievements.xml"

# Read the current file
$content = Get-Content $achievementsFile -Encoding UTF8 -Raw

# Replace all corrupted Korean text
$replacements = @{
    '"\?[^\s"]*\uc801"' = '"업적"'
    '"0 \?[^\s"]*\?"' = '"0 포인트"'
    '"[^\s"]*\?\?[^\s"]*\uc778\?\?"' = '"총 포인트"'
    '"0% \?[^\s"]*"' = '"0% 완료"'
    '"\?[^\s"]*\?[^\s"]*\uc801[^\s"]*\uc2b5[^\s"]*"' = '"해당하는 업적이 없습니다"'
}

foreach ($pattern in $replacements.Keys) {
    $content = $content -replace $pattern, $replacements[$pattern]
}

# Write back the file
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($achievementsFile, $content, $utf8NoBom)

Write-Host "✓ Fixed activity_achievements.xml" -ForegroundColor Green

# Also fix any other remaining files with Korean text issues
$otherFiles = @(
    "activity_checklist.xml",
    "activity_coach.xml",
    "activity_simple_main.xml"
)

foreach ($fileName in $otherFiles) {
    $filePath = Join-Path $layoutPath $fileName
    if (Test-Path $filePath) {
        $fileContent = Get-Content $filePath -Encoding UTF8 -Raw
        $hasChanges = $false
        
        # Check if file has corrupted Korean text
        if ($fileContent -match '\?[^\s"]*[\uac00-\ud7af]') {
            Write-Host "Found corrupted Korean text in $fileName" -ForegroundColor Yellow
            $hasChanges = $true
        }
        
        if ($hasChanges) {
            # Apply common Korean text fixes
            $fileContent = $fileContent -replace '\?[^\s"]*\ub3d9', '동'
            $fileContent = $fileContent -replace '\?[^\s"]*\uc801', '적'
            $fileContent = $fileContent -replace '\?[^\s"]*\uc778', '인'
            
            [System.IO.File]::WriteAllText($filePath, $fileContent, $utf8NoBom)
            Write-Host "✓ Fixed $fileName" -ForegroundColor Green
        }
    }
}

Write-Host "`nAll Korean text issues fixed!" -ForegroundColor Green