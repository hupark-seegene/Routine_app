# FIX-ALL-XML-ISSUES.ps1
# Comprehensive fix for all XML issues including Korean text corruption

$ErrorActionPreference = "Stop"

Write-Host "Comprehensive XML fix starting..." -ForegroundColor Yellow

$layoutPath = "..\..\android\app\src\main\res\layout"

# Specific fixes for each problematic file
$fixes = @{
    "activity_achievements.xml" = @{
        55 = '                android:text="0 포인트"'
    }
    "activity_profile.xml" = @{
        77 = '                android:text="수정" />'
    }
    "activity_settings.xml" = @{
        79 = '                android:text="한국어" />'
    }
    "activity_voice_guided_workout.xml" = @{
        53 = '                android:text="10:00"'
    }
    "activity_voice_record.xml" = @{
        183 = '                android:textColor="@color/text_secondary" />'
    }
    "dialog_create_exercise.xml" = @{
        51 = '                android:textColor="@color/text_secondary" />'
    }
    "dialog_exercise_details.xml" = @{
        43 = '                android:textColor="@color/text_secondary" />'
    }
    "global_voice_overlay.xml" = @{
        80 = '                android:textColor="@color/text_primary" />'
    }
    "item_custom_exercise.xml" = @{
        74 = '                android:textColor="@color/text_secondary" />'
    }
    "activity_login.xml" = @{
        92 = '                android:inputType="textEmailAddress"'
    }
    "item_workout_program.xml" = @{
        75 = '                android:textColor="@color/text_secondary" />'
    }
}

$fixedCount = 0

foreach ($fileName in $fixes.Keys) {
    $filePath = Join-Path $layoutPath $fileName
    
    if (Test-Path $filePath) {
        try {
            $content = Get-Content -Path $filePath -Encoding UTF8
            $fileFixed = $false
            
            foreach ($lineNumber in $fixes[$fileName].Keys) {
                $newLine = $fixes[$fileName][$lineNumber]
                if ($lineNumber -le $content.Count) {
                    $content[$lineNumber - 1] = $newLine
                    $fileFixed = $true
                    Write-Host "✓ Fixed line $lineNumber in $fileName" -ForegroundColor Green
                }
            }
            
            if ($fileFixed) {
                # Write back with UTF-8 encoding without BOM
                $utf8NoBom = New-Object System.Text.UTF8Encoding $false
                [System.IO.File]::WriteAllLines($filePath, $content, $utf8NoBom)
                $fixedCount++
            }
            
        } catch {
            Write-Host "✗ Failed to fix: $fileName - $_" -ForegroundColor Red
        }
    } else {
        Write-Host "✗ File not found: $fileName" -ForegroundColor Yellow
    }
}

# Final validation
Write-Host "`nValidating all XML files..." -ForegroundColor Yellow

$allXmlFiles = Get-ChildItem -Path $layoutPath -Filter "*.xml" -File
$validFiles = 0
$invalidFiles = 0

foreach ($file in $allXmlFiles) {
    try {
        [xml]$xmlContent = Get-Content -Path $file.FullName -Encoding UTF8
        $validFiles++
    } catch {
        Write-Host "✗ Still invalid: $($file.Name)" -ForegroundColor Red
        $invalidFiles++
    }
}

Write-Host "`n=================================================" -ForegroundColor Green
Write-Host "XML fixes complete!" -ForegroundColor Green
Write-Host "Files fixed: $fixedCount" -ForegroundColor Yellow
Write-Host "Valid XML files: $validFiles/$($validFiles + $invalidFiles)" -ForegroundColor $(if ($invalidFiles -eq 0) { "Green" } else { "Yellow" })