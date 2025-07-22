# UPDATE-UI-COLORS.ps1
# Updates all layout files from old Nike-style colors to new Zen Minimal colors

$layoutPath = "../../android/app/src/main/res/layout"
$colorMappings = @{
    # Primary color replacements
    "@color/volt_green" = "@color/accent"
    "#C9FF00" = "@color/accent"
    
    # Background replacements
    "@color/dark_background" = "@color/background"
    "@color/dark_surface" = "@color/surface"
    
    # Text color replacements for dark theme
    "@color/white" = "@color/text_primary"
    "#FFFFFF" = "@color/text_primary"  # For text in dark backgrounds
    
    # Button style replacements
    "@style/VoltButton" = "@style/PrimaryButton"
}

Write-Host "Starting UI color update process..." -ForegroundColor Green

# Get all layout files
$layoutFiles = Get-ChildItem -Path $layoutPath -Filter "*.xml" -File

$updatedCount = 0
$totalFiles = $layoutFiles.Count

foreach ($file in $layoutFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $originalContent = $content
    $hasChanges = $false
    
    # Apply color mappings
    foreach ($oldColor in $colorMappings.Keys) {
        if ($content -match [regex]::Escape($oldColor)) {
            $content = $content -replace [regex]::Escape($oldColor), $colorMappings[$oldColor]
            $hasChanges = $true
        }
    }
    
    # Save if changes were made
    if ($hasChanges) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        $updatedCount++
        Write-Host "✓ Updated: $($file.Name)" -ForegroundColor Green
    }
}

Write-Host "`nUI Color Update Complete!" -ForegroundColor Cyan
Write-Host "Files updated: $updatedCount/$totalFiles" -ForegroundColor Yellow

# Special handling for complex replacements
Write-Host "`nApplying special fixes..." -ForegroundColor Yellow

# Fix any remaining dark theme issues
$specialFiles = @(
    "activity_record.xml",
    "activity_coach.xml",
    "activity_stats.xml"
)

foreach ($fileName in $specialFiles) {
    $filePath = Join-Path $layoutPath $fileName
    if (Test-Path $filePath) {
        $content = Get-Content -Path $filePath -Raw
        
        # Fix text colors on dark backgrounds
        if ($content -match 'android:background="@color/background".*android:textColor="#FFFFFF"') {
            $content = $content -replace 'android:textColor="#FFFFFF"', 'android:textColor="@color/text_primary"'
            Set-Content -Path $filePath -Value $content -NoNewline
            Write-Host "✓ Fixed text colors in: $fileName" -ForegroundColor Green
        }
    }
}

Write-Host "`nAll UI colors have been updated to Zen Minimal design!" -ForegroundColor Green
Write-Host "Next step: Create chat interface for AI assistant" -ForegroundColor Cyan