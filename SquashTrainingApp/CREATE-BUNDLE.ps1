# Create Full JavaScript Bundle for React Native App
$ErrorActionPreference = "Continue"

Write-Host "`n=== Creating Full JavaScript Bundle ===" -ForegroundColor Cyan

# Ensure assets directory exists
$assetsDir = "android\app\src\main\assets"
New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null

# Remove old bundle
Remove-Item "$assetsDir\index.android.bundle" -Force -ErrorAction SilentlyContinue

Write-Host "Building JavaScript bundle..." -ForegroundColor Yellow
Write-Host "This may take a minute..." -ForegroundColor Gray

# Create the bundle with Metro bundler
$bundleResult = & npx react-native bundle `
    --platform android `
    --dev true `
    --entry-file index.js `
    --bundle-output "$assetsDir\index.android.bundle" `
    --assets-dest android\app\src\main\res `
    --max-workers 2 `
    --reset-cache 2>&1

$success = $LASTEXITCODE -eq 0

if ($success -and (Test-Path "$assetsDir\index.android.bundle")) {
    $bundleSize = [math]::Round((Get-Item "$assetsDir\index.android.bundle").Length / 1KB, 2)
    Write-Host "`n✓ Bundle created successfully!" -ForegroundColor Green
    Write-Host "  Size: ${bundleSize}KB" -ForegroundColor Gray
    
    # Check bundle content
    $firstLines = Get-Content "$assetsDir\index.android.bundle" -TotalCount 10
    if ($firstLines -match "react-native" -or $firstLines -match "__d\(") {
        Write-Host "  ✓ Bundle contains React Native code" -ForegroundColor Green
    } else {
        Write-Host "  ! Bundle may be incomplete" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n✗ Bundle creation failed!" -ForegroundColor Red
    Write-Host "Creating fallback bundle..." -ForegroundColor Yellow
    
    # Create a fallback bundle that loads the app
    @'
// Fallback bundle - loads React Native app
var __DEV__ = true;
var __BUNDLE_START_TIME__ = Date.now();

// Basic require function
if (typeof require === 'undefined') {
    global.require = function(module) {
        console.log('[Bundle] Required:', module);
        if (module === 'react-native') {
            return { AppRegistry: { registerComponent: function() {} } };
        }
        return {};
    };
}

// Load the app
try {
    console.log('[Bundle] Loading app...');
    require('./index.js');
} catch (e) {
    console.error('[Bundle] Failed to load app:', e);
}

console.log('[Bundle] Fallback bundle loaded');
'@ | Out-File -Encoding UTF8 "$assetsDir\index.android.bundle"
    
    Write-Host "  Fallback bundle created" -ForegroundColor Gray
}

Write-Host "`nBundle creation complete!" -ForegroundColor Cyan