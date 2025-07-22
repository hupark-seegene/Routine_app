# FIX-XML-SYNTAX.ps1
# Fixes XML syntax issues in layout files

$ErrorActionPreference = "Stop"

Write-Host "Fixing XML syntax issues in layout files..." -ForegroundColor Yellow

$layoutPath = "..\..\android\app\src\main\res\layout"

# Problem files from the error messages with specific line numbers
$problemFiles = @{
    "activity_achievements.xml" = 56
    "item_custom_exercise.xml" = 74
    "activity_settings.xml" = 79
    "dialog_exercise_details.xml" = 43
    "activity_voice_guided_workout.xml" = 53
    "activity_voice_record.xml" = 183
    "activity_profile.xml" = 77
    "dialog_create_exercise.xml" = 51
    "global_voice_overlay.xml" = 80
}

$fixedCount = 0

foreach ($fileName in $problemFiles.Keys) {
    $filePath = Join-Path $layoutPath $fileName
    $lineNumber = $problemFiles[$fileName]
    
    if (Test-Path $filePath) {
        try {
            $content = Get-Content -Path $filePath -Encoding UTF8
            
            # Common fix patterns for XML syntax issues
            # Replace color references that might have syntax issues
            for ($i = 0; $i -lt $content.Count; $i++) {
                $line = $content[$i]
                
                # Fix incomplete android:textColor attributes
                if ($line -match 'android:textColor="@color/[^"]*$') {
                    $content[$i] = $line + '"'
                    Write-Host "Fixed missing quote on line $($i+1) in $fileName" -ForegroundColor Green
                }
                
                # Fix missing closing brackets
                if ($line -match '<(TextView|Button|RadioButton|ImageView)[^>]*[^/>]$') {
                    if ($content[$i+1] -notmatch '^\s*android:' -and $content[$i+1] -notmatch '^\s*/>') {
                        $content[$i] = $line + ">"
                        Write-Host "Fixed missing > on line $($i+1) in $fileName" -ForegroundColor Green
                    }
                }
                
                # Fix self-closing tags
                if ($line -match '<(TextView|Button|RadioButton|ImageView)[^>]*[^/>]\s*$' -and 
                    $i -lt $content.Count - 1 -and 
                    $content[$i+1] -match '^\s*<') {
                    $content[$i] = $line.TrimEnd() + " />"
                    Write-Host "Fixed self-closing tag on line $($i+1) in $fileName" -ForegroundColor Green
                }
            }
            
            # Write back the fixed content
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllLines($filePath, $content, $utf8NoBom)
            
            Write-Host "✓ Processed: $fileName" -ForegroundColor Green
            $fixedCount++
        } catch {
            Write-Host "✗ Failed to fix: $fileName - $_" -ForegroundColor Red
        }
    } else {
        Write-Host "✗ File not found: $fileName" -ForegroundColor Yellow
    }
}

# Additional validation pass
Write-Host "`nValidating all XML files..." -ForegroundColor Yellow

$allXmlFiles = Get-ChildItem -Path $layoutPath -Filter "*.xml" -File
$validationErrors = 0

foreach ($file in $allXmlFiles) {
    try {
        [xml]$xmlContent = Get-Content -Path $file.FullName -Encoding UTF8
        # If this succeeds, the XML is valid
    } catch {
        Write-Host "✗ XML validation failed: $($file.Name)" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Gray
        $validationErrors++
    }
}

Write-Host "`n=================================================" -ForegroundColor Green
Write-Host "XML syntax fixes complete!" -ForegroundColor Green
Write-Host "Files processed: $fixedCount" -ForegroundColor Yellow
Write-Host "Validation errors remaining: $validationErrors" -ForegroundColor $(if ($validationErrors -eq 0) { "Green" } else { "Red" })