#!/usr/bin/env pwsh
# Restore original React Native configuration

Write-Host "Restoring original configuration..." -ForegroundColor Yellow

$filesToRestore = @("settings.gradle", "build.gradle", "app/build.gradle")
$restored = 0

foreach ($file in $filesToRestore) {
    if (Test-Path "$file.backup") {
        Copy-Item "$file.backup" $file -Force
        Write-Host "✓ Restored $file" -ForegroundColor Green
        $restored++
    } elseif (Test-Path "$file.original") {
        Copy-Item "$file.original" $file -Force
        Write-Host "✓ Restored $file from .original" -ForegroundColor Green
        $restored++
    } else {
        Write-Host "⚠ No backup found for $file" -ForegroundColor Yellow
    }
}

if ($restored -gt 0) {
    Write-Host ""
    Write-Host "Configuration restored successfully!" -ForegroundColor Green
    Write-Host "You can now use the standard build commands." -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "No files were restored." -ForegroundColor Yellow
}