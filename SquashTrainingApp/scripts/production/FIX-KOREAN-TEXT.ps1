# FIX-KOREAN-TEXT.ps1
# Fix Korean text in XML files

$ErrorActionPreference = "Stop"

Write-Host "Fixing Korean text in XML files..." -ForegroundColor Yellow

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$androidDir = Join-Path $scriptDir "..\..\android"
$layoutPath = Join-Path $androidDir "app\src\main\res\layout"

# Function to fix Korean text patterns
function Fix-KoreanText {
    param($content)
    
    # Common patterns
    $replacements = @{
        # Exercise related
        '(?:\?[^"]*\s*){0,1}동\s+(?:\?[^"]*\s*){0,1}름' = '운동 이름'
        '(?:\?[^"]*\s*){1,2}카테고리' = '카테고리'
        '(?:\?[^"]*\s*){0,1}간' = '시간'
        '15분(?:\?[^"]*){0,1}' = '15분'
        '(?:\?[^"]*\s*){0,1}트/반복' = '세트/반복'
        '3(?:\?[^"]*\s*){0,1}트\s*x\s*10(?:\?[^"]*){0,2}' = '3세트 x 10회'
        '(?:\?[^"]*\s*){0,1}계' = '단계'
        '(?:\?[^"]*\s*){0,1}용:\s*5(?:\?[^"]*){0,2}' = '사용: 5회'
        '(?:\?[^"]*\s*){0,1}행\s+방법' = '수행 방법'
        '(?:\?[^"]*\s*){0,1}동\s+(?:\?[^"]*\s*){0,1}행\s+방법[^"]*' = '운동 수행 방법이 여기에 표시됩니다'
        '(?:\?[^"]*){1,2}주의[^"]*항' = '팁 & 주의사항'
        '(?:\?[^"]*\s*){0,1}과\s+주의[^"]*항[^"]*' = '팁과 주의사항이 여기에 표시됩니다'
        
        # Profile related
        '(?:\?[^"]*){1,2}' = '설정'
        '(?:\?[^"]*\s*){0,1}정' = '설정'
        
        # Achievement related
        '0\s*(?:\?[^"]*){0,1}인(?:\?[^"]*){0,2}' = '0 포인트'
        '(?:珥|총)(?:\?[^"]*){0,2}인(?:\?[^"]*){0,2}' = '총 포인트'
        '0%\s*(?:\?[^"]*){0,1}료' = '0% 완료'
        '(?:\?[^"]*){0,1}당(?:\?[^"]*){0,1}는\s+(?:\?[^"]*){0,1}적(?:[^"]*){0,1}습(?:[^"]*){0,1}다' = '해당하는 업적이 없습니다'
        '(?:\?[^"]*){0,1}적' = '업적'
    }
    
    foreach ($pattern in $replacements.Keys) {
        $content = $content -replace $pattern, $replacements[$pattern]
    }
    
    return $content
}

# Fix dialog_exercise_details.xml
$exercisePath = Join-Path $layoutPath "dialog_exercise_details.xml"
if (Test-Path $exercisePath) {
    Write-Host "Processing dialog_exercise_details.xml..." -ForegroundColor Gray
    $content = Get-Content $exercisePath -Raw -Encoding UTF8
    
    # Apply Korean text fixes
    $content = Fix-KoreanText $content
    
    # Fix specific line issues
    $content = $content -replace '(android:text="15분)\s*\n\s*(android:textColor)', '$1"`n                    $2'
    
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($exercisePath, $content, $utf8NoBom)
    Write-Host "  Fixed Korean text" -ForegroundColor Green
}

# Fix activity_profile.xml
$profilePath = Join-Path $layoutPath "activity_profile.xml"
if (Test-Path $profilePath) {
    Write-Host "Processing activity_profile.xml..." -ForegroundColor Gray
    $content = Get-Content $profilePath -Raw -Encoding UTF8
    
    # Fix the specific button text issue
    $content = $content -replace '(android:text=")[^"]*("\s*/>\s*android:background)', '$1설정$2'
    
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($profilePath, $content, $utf8NoBom)
    Write-Host "  Fixed Korean text" -ForegroundColor Green
}

Write-Host "`nKorean text fixes complete!" -ForegroundColor Green