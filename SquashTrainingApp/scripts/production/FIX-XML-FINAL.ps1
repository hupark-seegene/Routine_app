# FIX-XML-FINAL.ps1
# Final comprehensive fix for all XML issues

$ErrorActionPreference = "Stop"

Write-Host "Final XML fix - Fixing all problematic files..." -ForegroundColor Yellow

Set-Location -Path "..\..\android"
$layoutPath = "app\src\main\res\layout"

# Fix activity_profile.xml
$profileFile = Join-Path $layoutPath "activity_profile.xml"
if (Test-Path $profileFile) {
    $content = Get-Content $profileFile -Encoding UTF8
    for ($i = 0; $i -lt $content.Count; $i++) {
        if ($content[$i] -match 'android:text=".*\?\?' -and $i+1 -lt $content.Count -and $content[$i+1] -match 'android:text=') {
            # Found duplicate android:text, merge them
            $content[$i] = '                    android:text="수정"'
            $content[$i+1] = ''  # Remove the duplicate line
        }
    }
    # Remove empty lines
    $content = $content | Where-Object { $_ -ne '' }
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($profileFile, $content, $utf8NoBom)
    Write-Host "✓ Fixed activity_profile.xml" -ForegroundColor Green
}

# Fix activity_achievements.xml
$achievementsFile = Join-Path $layoutPath "activity_achievements.xml"
if (Test-Path $achievementsFile) {
    $content = Get-Content $achievementsFile -Encoding UTF8 -Raw
    $content = $content -replace '\?\ufffd\uc801', '업적'
    $content = $content -replace '0 \?\u044a\uc524\?\?', '0 포인트'
    $content = $content -replace '\ufffd\?\?\ufffd\uc778\?\?', '총 포인트'
    $content = $content -replace '0% \?\ufffd\ub8cc', '0% 완료'
    $content = $content -replace '\?\ufffd\ub2f9\?\ufffd\ub294 \?\ufffd\uc801\?\?\?\ufffd\uc2b5\?\ufffd\ub2e4', '해당하는 업적이 없습니다'
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($achievementsFile, $content, $utf8NoBom)
    Write-Host "✓ Fixed activity_achievements.xml" -ForegroundColor Green
}

# Fix activity_voice_guided_workout.xml
$voiceWorkoutFile = Join-Path $layoutPath "activity_voice_guided_workout.xml"
if (Test-Path $voiceWorkoutFile) {
    $content = Get-Content $voiceWorkoutFile -Encoding UTF8
    for ($i = 0; $i -lt $content.Count; $i++) {
        if ($content[$i] -match 'android:text="[^"]*\d+:[^"]*"' -and $content[$i] -notmatch '/>$' -and $content[$i] -notmatch '>$') {
            $content[$i] = $content[$i].TrimEnd() + ' />'
        }
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($voiceWorkoutFile, $content, $utf8NoBom)
    Write-Host "✓ Fixed activity_voice_guided_workout.xml" -ForegroundColor Green
}

# Fix activity_voice_record.xml
$voiceRecordFile = Join-Path $layoutPath "activity_voice_record.xml"
if (Test-Path $voiceRecordFile) {
    $content = Get-Content $voiceRecordFile -Encoding UTF8
    for ($i = 0; $i -lt $content.Count; $i++) {
        if ($content[$i] -match 'android:textColor="@color/[^"]*"[^/>]*$' -and $content[$i+1] -notmatch '^\s*android:') {
            $content[$i] = $content[$i].TrimEnd() + ' />'
        }
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($voiceRecordFile, $content, $utf8NoBom)
    Write-Host "✓ Fixed activity_voice_record.xml" -ForegroundColor Green
}

# Fix dialog_create_exercise.xml
$createExerciseFile = Join-Path $layoutPath "dialog_create_exercise.xml"
if (Test-Path $createExerciseFile) {
    $content = Get-Content $createExerciseFile -Encoding UTF8
    for ($i = 0; $i -lt $content.Count; $i++) {
        if ($content[$i] -match 'android:textColor="@color/text_secondary"[^/>]*$') {
            $content[$i] = $content[$i].TrimEnd() + ' />'
        }
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($createExerciseFile, $content, $utf8NoBom)
    Write-Host "✓ Fixed dialog_create_exercise.xml" -ForegroundColor Green
}

# Fix global_voice_overlay.xml
$globalVoiceFile = Join-Path $layoutPath "global_voice_overlay.xml"
if (Test-Path $globalVoiceFile) {
    $content = Get-Content $globalVoiceFile -Encoding UTF8
    for ($i = 0; $i -lt $content.Count; $i++) {
        if ($content[$i] -match 'android:textColor="[^@][^"]*"') {
            $content[$i] = $content[$i] -replace 'android:textColor="[^"]*"', 'android:textColor="@color/text_primary"'
        }
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($globalVoiceFile, $content, $utf8NoBom)
    Write-Host "✓ Fixed global_voice_overlay.xml" -ForegroundColor Green
}

# Fix item_custom_exercise.xml
$customExerciseFile = Join-Path $layoutPath "item_custom_exercise.xml"
if (Test-Path $customExerciseFile) {
    $content = Get-Content $customExerciseFile -Encoding UTF8
    for ($i = 0; $i -lt $content.Count; $i++) {
        if ($content[$i] -match 'android:textColor="@color/text_secondary"[^/>]*$' -and $content[$i+1] -notmatch '^\s*android:') {
            $content[$i] = $content[$i].TrimEnd() + ' />'
        }
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($customExerciseFile, $content, $utf8NoBom)
    Write-Host "✓ Fixed item_custom_exercise.xml" -ForegroundColor Green
}

# Fix item_workout_program.xml
$workoutProgramFile = Join-Path $layoutPath "item_workout_program.xml"
if (Test-Path $workoutProgramFile) {
    $content = Get-Content $workoutProgramFile -Encoding UTF8
    for ($i = 0; $i -lt $content.Count; $i++) {
        if ($content[$i] -match 'android:textColor="@color/text_secondary"[^/>]*$' -and $content[$i+1] -notmatch '^\s*android:') {
            $content[$i] = $content[$i].TrimEnd() + ' />'
        }
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($workoutProgramFile, $content, $utf8NoBom)
    Write-Host "✓ Fixed item_workout_program.xml" -ForegroundColor Green
}

Write-Host "`n=================================================" -ForegroundColor Green
Write-Host "All XML files have been fixed!" -ForegroundColor Green
Write-Host "Ready to build the APK" -ForegroundColor Cyan