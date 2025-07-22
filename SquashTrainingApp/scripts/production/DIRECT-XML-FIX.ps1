# DIRECT-XML-FIX.ps1
# Direct XML fix using file replacement

$ErrorActionPreference = "Stop"

Write-Host "Direct XML fix - Replacing problematic sections..." -ForegroundColor Yellow

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$androidDir = Join-Path $scriptDir "..\..\android"
Set-Location -Path $androidDir
$layoutPath = Join-Path (Get-Location) "app\src\main\res\layout"

# Fix activity_profile.xml
$profileFile = Join-Path $layoutPath "activity_profile.xml"
if (Test-Path $profileFile) {
    $content = Get-Content $profileFile -Encoding UTF8 -Raw
    # Fix the duplicate android:text issue
    $content = $content -replace '(?s)android:text="[^"]*\?\?[^"]*"\s*\r?\nandroid:text="[^"]*"', 'android:text="수정"'
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($profileFile, $content, $utf8NoBom)
    Write-Host "✓ Fixed activity_profile.xml" -ForegroundColor Green
}

# Fix activity_voice_guided_workout.xml - ensure all TextViews are properly closed
$voiceWorkoutFile = Join-Path $layoutPath "activity_voice_guided_workout.xml"
if (Test-Path $voiceWorkoutFile) {
    $content = Get-Content $voiceWorkoutFile -Encoding UTF8
    for ($i = 0; $i -lt $content.Count; $i++) {
        $line = $content[$i]
        if ($line -match '<TextView' -and $line -notmatch '/>\s*$' -and $line -notmatch '>\s*$') {
            # Check if next lines have more attributes
            $j = $i + 1
            while ($j -lt $content.Count -and $content[$j] -match '^\s*android:') {
                $j++
            }
            # Ensure the last attribute line ends with />
            if ($j-1 -ge 0 -and $content[$j-1] -notmatch '/>\s*$') {
                $content[$j-1] = $content[$j-1].TrimEnd() + ' />'
            }
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
        if ($content[$i] -match 'android:textColor="@color/text_secondary"$' -and 
            ($i+1 -ge $content.Count -or $content[$i+1] -notmatch '^\s*android:')) {
            $content[$i] = $content[$i] + ' />'
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
        if ($content[$i] -match 'android:textColor="@color/text_secondary"$' -and 
            ($i+1 -ge $content.Count -or $content[$i+1] -notmatch '^\s*android:')) {
            $content[$i] = $content[$i] + ' />'
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
        if ($content[$i] -match 'android:textColor="#[^"]*"') {
            $content[$i] = $content[$i] -replace 'android:textColor="#[^"]*"', 'android:textColor="@color/text_primary"'
        }
        if ($content[$i] -match 'android:textColor="@color/text_primary"$' -and 
            ($i+1 -ge $content.Count -or $content[$i+1] -notmatch '^\s*android:')) {
            $content[$i] = $content[$i] + ' />'
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
        if ($content[$i] -match 'android:textColor="@color/text_secondary"$' -and 
            ($i+1 -ge $content.Count -or $content[$i+1] -notmatch '^\s*android:')) {
            $content[$i] = $content[$i] + ' />'
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
        if ($content[$i] -match 'android:textColor="@color/text_secondary"$' -and 
            ($i+1 -ge $content.Count -or $content[$i+1] -notmatch '^\s*android:')) {
            $content[$i] = $content[$i] + ' />'
        }
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($workoutProgramFile, $content, $utf8NoBom)
    Write-Host "✓ Fixed item_workout_program.xml" -ForegroundColor Green
}

Write-Host "`n=================================================" -ForegroundColor Green
Write-Host "XML fixes applied!" -ForegroundColor Green
Write-Host "Now attempting to build..." -ForegroundColor Cyan