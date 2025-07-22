# MANUAL-XML-FIX.ps1
# Manually fix XML issues

$ErrorActionPreference = "Stop"

Write-Host "Manually fixing XML issues..." -ForegroundColor Yellow

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$androidDir = Join-Path $scriptDir "..\..\android"
$layoutPath = Join-Path $androidDir "app\src\main\res\layout"

# Fix dialog_exercise_details.xml
$exercisePath = Join-Path $layoutPath "dialog_exercise_details.xml"
if (Test-Path $exercisePath) {
    Write-Host "Fixing dialog_exercise_details.xml..." -ForegroundColor Gray
    
    # Read all lines
    $lines = Get-Content $exercisePath -Encoding UTF8
    
    # Fix line 17
    if ($lines[16] -match 'android:text=') {
        $lines[16] = '            android:text="운동 이름"'
    }
    
    # Fix line 34
    if ($lines[33] -match 'android:text=') {
        $lines[33] = '                android:text="카테고리"'
    }
    
    # Fix line 63
    if ($lines[62] -match 'android:text=') {
        $lines[62] = '                    android:text="시간"'
    }
    
    # Fix line 71
    if ($lines[70] -match 'android:text=') {
        $lines[70] = '                    android:text="15분"'
    }
    
    # Fix line 84
    if ($lines[83] -match 'android:text=') {
        $lines[83] = '                    android:text="세트/반복"'
    }
    
    # Fix line 92
    if ($lines[91] -match 'android:text=') {
        $lines[91] = '                    android:text="3세트 x 10회"'
    }
    
    # Fix line 106
    if ($lines[105] -match 'android:text=') {
        $lines[105] = '                    android:text="단계"'
    }
    
    # Fix line 114
    if ($lines[113] -match 'android:text=') {
        $lines[113] = '                    android:text="사용: 5회"'
    }
    
    # Fix line 129
    if ($lines[128] -match 'android:text=') {
        $lines[128] = '            android:text="수행 방법"'
    }
    
    # Fix line 138
    if ($lines[137] -match 'android:text=') {
        $lines[137] = '            android:text="운동 수행 방법이 여기에 표시됩니다"'
    }
    
    # Fix line 147
    if ($lines[146] -match 'android:text=') {
        $lines[146] = '            android:text="팁 & 주의사항"'
    }
    
    # Fix line 156
    if ($lines[155] -match 'android:text=') {
        $lines[155] = '            android:text="팁과 주의사항이 여기에 표시됩니다"'
    }
    
    # Write back
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($exercisePath, $lines, $utf8NoBom)
    Write-Host "  Fixed" -ForegroundColor Green
}

# Fix activity_profile.xml
$profilePath = Join-Path $layoutPath "activity_profile.xml"
if (Test-Path $profilePath) {
    Write-Host "Fixing activity_profile.xml..." -ForegroundColor Gray
    
    # Read all lines
    $lines = Get-Content $profilePath -Encoding UTF8
    
    # Fix line 76
    if ($lines[75] -match 'android:text=') {
        $lines[75] = '                    android:text="설정" />'
        # Remove line 76 if it contains duplicate text
        if ($lines[76] -match 'android:background=') {
            # Line 77 already has background, so we're good
        } else {
            # Remove the duplicate line
            $lines = $lines[0..75] + $lines[77..($lines.Count-1)]
        }
    }
    
    # Write back
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($profilePath, $lines, $utf8NoBom)
    Write-Host "  Fixed" -ForegroundColor Green
}

Write-Host "`nManual fixes complete!" -ForegroundColor Green