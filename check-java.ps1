# Check Java installations
Write-Host "Checking Java installations..." -ForegroundColor Yellow

# Check common Java locations
$locations = @(
    "C:\Program Files\Android\Android Studio\jbr",
    "C:\Program Files\Android\Android Studio\jre",
    "C:\Program Files\Java",
    "C:\Program Files (x86)\Java"
)

foreach ($loc in $locations) {
    if (Test-Path $loc) {
        Write-Host "Found: $loc" -ForegroundColor Green
        Get-ChildItem $loc | Select-Object Name
    }
}

# Check current JAVA_HOME
Write-Host "`nCurrent JAVA_HOME: $env:JAVA_HOME" -ForegroundColor Cyan

# Check if java command is available
try {
    java -version 2>&1 | Out-String | Write-Host
} catch {
    Write-Host "Java command not found in PATH" -ForegroundColor Red
}