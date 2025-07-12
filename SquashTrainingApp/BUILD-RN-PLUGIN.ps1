# Build React Native Gradle Plugin JARs
$ErrorActionPreference = "Continue"

Write-Host "`n=== Building React Native Gradle Plugin ===" -ForegroundColor Cyan

# Navigate to gradle plugin directory
$pluginDir = "node_modules\@react-native\gradle-plugin"
if (-not (Test-Path $pluginDir)) {
    Write-Host "✗ React Native gradle plugin not found!" -ForegroundColor Red
    exit 1
}

Push-Location $pluginDir

Write-Host "Building plugin JARs..." -ForegroundColor Yellow

# Build the plugin
$buildResult = & .\gradlew.bat build --no-daemon 2>&1
$success = $LASTEXITCODE -eq 0

if ($success) {
    Write-Host "✓ Plugin build successful!" -ForegroundColor Green
    
    # Check if JARs exist
    $jars = @(
        "settings-plugin\build\libs\settings-plugin.jar",
        "react-native-gradle-plugin\build\libs\react-native-gradle-plugin.jar",
        "shared\build\libs\shared.jar"
    )
    
    $allJarsExist = $true
    foreach ($jar in $jars) {
        if (Test-Path $jar) {
            $size = [math]::Round((Get-Item $jar).Length / 1KB, 2)
            Write-Host "  ✓ $jar (${size}KB)" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $jar missing" -ForegroundColor Red
            $allJarsExist = $false
        }
    }
    
    if ($allJarsExist) {
        Write-Host "`n✓ All plugin JARs built successfully!" -ForegroundColor Green
        Write-Host "You can now use the React Native gradle plugin." -ForegroundColor Cyan
    }
} else {
    Write-Host "✗ Plugin build failed!" -ForegroundColor Red
    Write-Host "Last 20 lines of output:" -ForegroundColor Yellow
    $buildResult | Select-Object -Last 20
}

Pop-Location