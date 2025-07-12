# DEBUG.ps1 - One-command debug solution
Write-Host "`n=== SQUASH APP DEBUG ===" -ForegroundColor Green
Write-Host "This script handles everything automatically`n" -ForegroundColor Gray

# First ensure emulator is running
Write-Host "Checking emulator..." -ForegroundColor Yellow
& .\START-EMULATOR.ps1

# Then run the debug build
Write-Host "`nRunning debug build..." -ForegroundColor Yellow
& .\SIMPLE-DEBUG.ps1