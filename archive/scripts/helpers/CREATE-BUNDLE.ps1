<#
.SYNOPSIS
    JavaScript Bundle Creation Helper
#>

param(
    [string]$ProjectDir,
    [switch]$DevMode = $true,
    [switch]$CreatePlaceholder = $true
)

$AndroidDir = Join-Path $ProjectDir "android"
$AssetsDir = Join-Path $AndroidDir "app\src\main\assets"

# Create assets directory
if (-not (Test-Path $AssetsDir)) {
    New-Item -ItemType Directory -Path $AssetsDir -Force | Out-Null
}

if ($CreatePlaceholder) {
    # Create placeholder bundle for now
    $placeholderContent = @"
// Placeholder bundle created by Cycle 5
// This will be replaced with actual React Native bundle in later cycles
console.log('React Native Placeholder Bundle v1.0.5');
"@
    
    $bundlePath = Join-Path $AssetsDir "index.android.bundle"
    $placeholderContent | Out-File -FilePath $bundlePath -Encoding UTF8
    
    Write-Host "Created placeholder bundle at: $bundlePath"
    return $bundlePath
}

# Actual bundle creation (for future cycles)
Push-Location $ProjectDir
try {
    $bundleCmd = "npx react-native bundle --platform android --dev $DevMode --entry-file index.js --bundle-output android/app/src/main/assets/index.android.bundle --assets-dest android/app/src/main/res"
    
    Write-Host "Creating React Native bundle..."
    Invoke-Expression $bundleCmd
    
    return Join-Path $AssetsDir "index.android.bundle"
}
catch {
    Write-Host "Bundle creation failed: $_" -ForegroundColor Red
    return $null
}
finally {
    Pop-Location
}
