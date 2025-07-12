# Quick verification commands
Write-Host "Verifying setup..." -ForegroundColor Yellow

# Check AGP version
$buildGradle = Get-Content "build.gradle" -Raw
if ($buildGradle -match 'gradle:8\.3\.2') {
    Write-Host "??AGP version correct (8.3.2)" -ForegroundColor Green
} else {
    Write-Host "??AGP version incorrect" -ForegroundColor Red
}

# Check Kotlin version
if ($buildGradle -match 'kotlinVersion = "1\.9\.24"') {
    Write-Host "??Kotlin version correct (1.9.24)" -ForegroundColor Green
} else {
    Write-Host "??Kotlin version incorrect" -ForegroundColor Red
}

# Check plugin JARs
$pluginPath = "..\node_modules\@react-native\gradle-plugin"
$requiredJars = @(
    "$pluginPath\settings-plugin\build\libs\settings-plugin.jar",
    "$pluginPath\react-native-gradle-plugin\build\libs\react-native-gradle-plugin.jar",
    "$pluginPath\shared\build\libs\shared.jar"
)

$allJarsExist = $true
foreach ($jar in $requiredJars) {
    if (-not (Test-Path $jar)) {
        Write-Host "??Missing: $jar" -ForegroundColor Red
        $allJarsExist = $false
    }
}

if ($allJarsExist) {
    Write-Host "??All plugin JARs exist" -ForegroundColor Green
}
