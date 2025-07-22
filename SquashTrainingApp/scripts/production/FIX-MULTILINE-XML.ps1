# FIX-MULTILINE-XML.ps1
# Fix multi-line XML attribute issues

$ErrorActionPreference = "Stop"

Write-Host "Fixing multi-line XML attribute issues..." -ForegroundColor Yellow

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$androidDir = Join-Path $scriptDir "..\..\android"
$layoutPath = Join-Path $androidDir "app\src\main\res\layout"

# Fix activity_profile.xml
$profilePath = Join-Path $layoutPath "activity_profile.xml"
if (Test-Path $profilePath) {
    Write-Host "Fixing activity_profile.xml..." -ForegroundColor Gray
    $content = Get-Content $profilePath -Raw -Encoding UTF8
    
    # Fix the multi-line text attribute issue
    $content = $content -replace '(\s+android:text="[^"]*)\n\s+android:text="[^"]*"\s*/>', '$1" />'
    
    # Fix duplicate settings_button ID
    $buttonCount = 0
    $lines = $content -split "`n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match 'android:id="@\+id/settings_button"') {
            $buttonCount++
            if ($buttonCount -eq 2) {
                $lines[$i] = $lines[$i] -replace 'android:id="@\+id/settings_button"', 'android:id="@+id/settings_button_bottom"'
            }
        }
    }
    $content = $lines -join "`n"
    
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($profilePath, $content, $utf8NoBom)
    Write-Host "✓ Fixed activity_profile.xml" -ForegroundColor Green
}

# Fix dialog_exercise_details.xml
$exercisePath = Join-Path $layoutPath "dialog_exercise_details.xml"
if (Test-Path $exercisePath) {
    Write-Host "Fixing dialog_exercise_details.xml..." -ForegroundColor Gray
    $content = Get-Content $exercisePath -Raw -Encoding UTF8
    
    # Fix the duplicate closing tag on line 71-72
    $content = $content -replace '(\s+android:text="[^"]*")\s*android:textColor="@color/text_primary"\s*/>\s*android:textSize="[^"]*"\s*/>', '$1`n                    android:textColor="@color/text_primary"`n                    android:textSize="16sp" />'
    
    # Fix Korean text
    $content = $content -replace '\?[^"]*동\s+\?[^"]*름', '운동 이름'
    $content = $content -replace '\?\?[^"]*카테고리', '카테고리'
    $content = $content -replace '\?[^"]*간', '시간'
    $content = $content -replace '15분\?', '15분'
    $content = $content -replace '\?[^"]*트/반복', '세트/반복'
    $content = $content -replace '3\?[^"]*트\s+x\s+10\?\?', '3세트 x 10회'
    $content = $content -replace '\?[^"]*계', '단계'
    $content = $content -replace '\?[^"]*용:\s+5\?\?', '사용: 5회'
    $content = $content -replace '\?[^"]*행\s+방법', '수행 방법'
    $content = $content -replace '\?[^"]*동\s+\?[^"]*행\s+방법[^"]*', '운동 수행 방법이 여기에 표시됩니다'
    $content = $content -replace '\?\?[^"]*주의[^"]*항', '팁 & 주의사항'
    $content = $content -replace '\?[^"]*과\s+주의[^"]*항[^"]*', '팁과 주의사항이 여기에 표시됩니다'
    
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($exercisePath, $content, $utf8NoBom)
    Write-Host "✓ Fixed dialog_exercise_details.xml" -ForegroundColor Green
}

Write-Host "`nAll multi-line XML issues fixed!" -ForegroundColor Green