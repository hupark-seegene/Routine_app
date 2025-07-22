# EMERGENCY-FIX.ps1
# Emergency fix for XML files

$ErrorActionPreference = "Stop"

Write-Host "Emergency XML fix..." -ForegroundColor Yellow

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$androidDir = Join-Path $scriptDir "..\..\android"
$layoutPath = Join-Path $androidDir "app\src\main\res\layout"

# Fix activity_login.xml line 92
$file = Join-Path $layoutPath "activity_login.xml"
if (Test-Path $file) {
    $lines = Get-Content $file -Encoding UTF8
    if ($lines[91] -notmatch '/>\s*$') {
        $lines[91] = $lines[91].TrimEnd() + ' />'
        [System.IO.File]::WriteAllLines($file, $lines, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "Fixed activity_login.xml" -ForegroundColor Green
    }
}

# Fix item_custom_exercise.xml line 74
$file = Join-Path $layoutPath "item_custom_exercise.xml"
if (Test-Path $file) {
    $lines = Get-Content $file -Encoding UTF8
    if ($lines[73] -notmatch '/>\s*$') {
        $lines[73] = $lines[73].TrimEnd() + ' />'
        [System.IO.File]::WriteAllLines($file, $lines, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "Fixed item_custom_exercise.xml" -ForegroundColor Green
    }
}

# Fix dialog_exercise_details.xml line 71
$file = Join-Path $layoutPath "dialog_exercise_details.xml"
if (Test-Path $file) {
    $lines = Get-Content $file -Encoding UTF8
    if ($lines[70] -notmatch '/>\s*$') {
        $lines[70] = $lines[70].TrimEnd() + ' />'
        [System.IO.File]::WriteAllLines($file, $lines, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "Fixed dialog_exercise_details.xml" -ForegroundColor Green
    }
}

# Fix activity_voice_guided_workout.xml line 53
$file = Join-Path $layoutPath "activity_voice_guided_workout.xml"
if (Test-Path $file) {
    $lines = Get-Content $file -Encoding UTF8
    if ($lines[52] -notmatch '/>\s*$') {
        $lines[52] = $lines[52].TrimEnd() + ' />'
        [System.IO.File]::WriteAllLines($file, $lines, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "Fixed activity_voice_guided_workout.xml" -ForegroundColor Green
    }
}

# Fix activity_voice_record.xml line 183
$file = Join-Path $layoutPath "activity_voice_record.xml"
if (Test-Path $file) {
    $lines = Get-Content $file -Encoding UTF8
    if ($lines[182] -notmatch '/>\s*$') {
        $lines[182] = $lines[182].TrimEnd() + ' />'
        [System.IO.File]::WriteAllLines($file, $lines, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "Fixed activity_voice_record.xml" -ForegroundColor Green
    }
}

# Fix item_workout_program.xml line 75
$file = Join-Path $layoutPath "item_workout_program.xml"
if (Test-Path $file) {
    $lines = Get-Content $file -Encoding UTF8
    if ($lines[74] -notmatch '/>\s*$') {
        $lines[74] = $lines[74].TrimEnd() + ' />'
        [System.IO.File]::WriteAllLines($file, $lines, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "Fixed item_workout_program.xml" -ForegroundColor Green
    }
}

# Fix dialog_create_exercise.xml line 51
$file = Join-Path $layoutPath "dialog_create_exercise.xml"
if (Test-Path $file) {
    $lines = Get-Content $file -Encoding UTF8
    if ($lines[50] -notmatch '/>\s*$') {
        $lines[50] = $lines[50].TrimEnd() + ' />'
        [System.IO.File]::WriteAllLines($file, $lines, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "Fixed dialog_create_exercise.xml" -ForegroundColor Green
    }
}

# Fix global_voice_overlay.xml line 80
$file = Join-Path $layoutPath "global_voice_overlay.xml"
if (Test-Path $file) {
    $lines = Get-Content $file -Encoding UTF8
    if ($lines[79] -notmatch '/>\s*$') {
        $lines[79] = $lines[79].TrimEnd() + ' />'
        [System.IO.File]::WriteAllLines($file, $lines, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "Fixed global_voice_overlay.xml" -ForegroundColor Green
    }
}

Write-Host "`nAll emergency fixes complete!" -ForegroundColor Green