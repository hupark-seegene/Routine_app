# Patch Native Modules Script
Write-Host "Patching native modules for React Native 0.80+" -ForegroundColor Cyan

$modules = @{
    "react-native-linear-gradient" = "com.BV.LinearGradient"
    "react-native-svg" = "com.horcrux.svg"
    "react-native-screens" = "com.swmansion.rnscreens"
    "react-native-safe-area-context" = "com.th3rdwave.safeareacontext"
    "react-native-vector-icons" = "com.oblador.vectoricons"
}

foreach ($module in $modules.Keys) {
    $buildFile = Join-Path $PSScriptRoot "node_modules\$module\android\build.gradle"
    if (Test-Path $buildFile) {
        Write-Host "Patching $module..." -ForegroundColor Yellow
        
        $content = Get-Content $buildFile -Raw
        $namespace = $modules[$module]
        
        # Check if namespace already exists
        if ($content -notmatch "namespace\s") {
            # Add namespace after android {
            $newContent = $content -replace "(android\s*\{)", "`$1`n    namespace '$namespace'"
            Set-Content $buildFile $newContent
            Write-Host "✓ Added namespace to $module" -ForegroundColor Green
        }
        
        # Add buildConfig if needed
        if ($content -notmatch "buildFeatures") {
            $newContent = Get-Content $buildFile -Raw
            $newContent = $newContent -replace "(android\s*\{[^}]*)(})", "`$1    buildFeatures {`n        buildConfig = true`n    }`n`$2"
            Set-Content $buildFile $newContent
            Write-Host "✓ Added buildFeatures to $module" -ForegroundColor Green
        }
    }
}

# Special case for SQLite storage
$sqliteDir = Join-Path $PSScriptRoot "node_modules\react-native-sqlite-storage\platforms\android-native"
if (Test-Path $sqliteDir) {
    $buildFile = Join-Path $sqliteDir "build.gradle"
    if (Test-Path $buildFile) {
        Write-Host "Patching react-native-sqlite-storage..." -ForegroundColor Yellow
        
        $content = Get-Content $buildFile -Raw
        if ($content -notmatch "namespace\s") {
            $newContent = $content -replace "(android\s*\{)", "`$1`n    namespace 'io.sqlc'"
            Set-Content $buildFile $newContent
            Write-Host "✓ Added namespace to sqlite-storage" -ForegroundColor Green
        }
    }
}

# Special case for slider
$sliderDir = Join-Path $PSScriptRoot "node_modules\@react-native-community\slider\android"
if (Test-Path $sliderDir) {
    $buildFile = Join-Path $sliderDir "build.gradle"
    if (Test-Path $buildFile) {
        Write-Host "Patching @react-native-community/slider..." -ForegroundColor Yellow
        
        $content = Get-Content $buildFile -Raw
        if ($content -notmatch "namespace\s") {
            $newContent = $content -replace "(android\s*\{)", "`$1`n    namespace 'com.reactnativecommunity.slider'"
            Set-Content $buildFile $newContent
            Write-Host "✓ Added namespace to slider" -ForegroundColor Green
        }
    }
}

Write-Host "`nPatching complete!" -ForegroundColor Green
Write-Host "Now run: .\gradlew.bat assembleDebug" -ForegroundColor Yellow