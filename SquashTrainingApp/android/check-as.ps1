# Check for Android Studio installation
$androidStudioPaths = @(
    "${env:ProgramFiles}\Android\Android Studio\bin\studio64.exe",
    "${env:ProgramFiles(x86)}\Android\Android Studio\bin\studio64.exe",
    "${env:LOCALAPPDATA}\JetBrains\Toolbox\apps\AndroidStudio\ch-0\*\bin\studio64.exe"
)

$found = $false
foreach ($path in $androidStudioPaths) {
    if (Test-Path $path) {
        Write-Host "✓ Android Studio found at: $path" -ForegroundColor Green
        $found = $true
        break
    }
}

if (-not $found) {
    Write-Host "✗ Android Studio not found" -ForegroundColor Red
    Write-Host "Install from: https://developer.android.com/studio"
}