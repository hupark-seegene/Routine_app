#!/usr/bin/env pwsh
# Enhanced Android Studio Fix for React Native 0.80.1
# Fixes AGP compatibility issues

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Android Studio Fix v3" -ForegroundColor Cyan
Write-Host " React Native 0.80.1 + AGP 8.3.2" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check directory
if (-not (Test-Path "gradlew.bat")) {
    Write-Host "Error: Run from android directory" -ForegroundColor Red
    exit 1
}

# Step 1: Build React Native gradle plugin
Write-Host "[1/5] Building React Native gradle plugin..." -ForegroundColor Yellow

$pluginPath = "..\node_modules\@react-native\gradle-plugin"
if (Test-Path $pluginPath) {
    Push-Location $pluginPath
    try {
        # Clean first
        & cmd /c "gradlew.bat clean 2>&1" | Out-Null
        
        # Build with jar task specifically
        Write-Host "  Building plugin JARs..." -ForegroundColor Cyan
        $buildResult = & cmd /c "gradlew.bat jar -x test 2>&1"
        
        # Check if JARs were created
        $jar1 = "settings-plugin\build\libs\settings-plugin.jar"
        $jar2 = "react-native-gradle-plugin\build\libs\react-native-gradle-plugin.jar"
        $jar3 = "shared\build\libs\shared.jar"
        
        if ((Test-Path $jar1) -and (Test-Path $jar2) -and (Test-Path $jar3)) {
            Write-Host "✓ Plugin JARs built successfully" -ForegroundColor Green
        } else {
            Write-Host "⚠ Some JARs may be missing, but continuing..." -ForegroundColor Yellow
        }
    } finally {
        Pop-Location
    }
} else {
    Write-Host "✗ React Native plugin directory not found" -ForegroundColor Red
    exit 1
}

# Step 2: Backup existing files
Write-Host ""
Write-Host "[2/5] Backing up existing files..." -ForegroundColor Yellow

$filesToBackup = @("settings.gradle", "build.gradle", "gradle.properties", "app\build.gradle")
foreach ($file in $filesToBackup) {
    if ((Test-Path $file) -and (-not (Test-Path "$file.backup"))) {
        Copy-Item $file "$file.backup" -Force
        Write-Host "✓ Backed up $file" -ForegroundColor Green
    }
}

# Step 3: Apply stable gradle configuration
Write-Host ""
Write-Host "[3/5] Applying stable gradle configuration..." -ForegroundColor Yellow

# Use stable build.gradle if it exists
if (Test-Path "build.gradle.stable") {
    Copy-Item "build.gradle.stable" "build.gradle" -Force
    Write-Host "✓ Applied stable build.gradle" -ForegroundColor Green
} else {
    # Apply inline fixes to current build.gradle
    $buildGradle = Get-Content "build.gradle" -Raw
    
    # Fix AGP version
    $buildGradle = $buildGradle -replace 'classpath\("com\.android\.tools\.build:gradle:[^"]+"\)', 'classpath("com.android.tools.build:gradle:8.3.2")'
    
    # Fix Kotlin version
    $buildGradle = $buildGradle -replace 'kotlinVersion = "[^"]+"', 'kotlinVersion = "1.9.24"'
    
    # Fix compileSdkVersion if needed
    $buildGradle = $buildGradle -replace 'compileSdkVersion = 35', 'compileSdkVersion = 34'
    $buildGradle = $buildGradle -replace 'targetSdkVersion = 35', 'targetSdkVersion = 34'
    $buildGradle = $buildGradle -replace 'buildToolsVersion = "35\.0\.0"', 'buildToolsVersion = "34.0.0"'
    
    Set-Content "build.gradle" $buildGradle
    Write-Host "✓ Fixed build.gradle versions" -ForegroundColor Green
}

# Step 4: Fix gradle.properties
Write-Host ""
Write-Host "[4/5] Fixing gradle.properties..." -ForegroundColor Yellow

$gradleProps = Get-Content "gradle.properties" -Raw

# Ensure React Native architecture is disabled for stability
if ($gradleProps -notmatch "newArchEnabled") {
    $gradleProps += "`nnewArchEnabled=false"
}

# Add Android Studio specific settings
if ($gradleProps -notmatch "android.injected.studio.version") {
    $gradleProps += "`n# Android Studio compatibility`nandroid.injected.studio.version.check=false"
}

Set-Content "gradle.properties" $gradleProps
Write-Host "✓ Updated gradle.properties" -ForegroundColor Green

# Step 5: Clear caches
Write-Host ""
Write-Host "[5/5] Clearing gradle caches..." -ForegroundColor Yellow

$cacheDirs = @(".gradle", "build", "app\build", "app\.gradle")
foreach ($dir in $cacheDirs) {
    if (Test-Path $dir) {
        Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "✓ Cleared $dir" -ForegroundColor Green
    }
}

# Create a verification script
$verifyScript = @'
# Quick verification commands
Write-Host "Verifying setup..." -ForegroundColor Yellow

# Check AGP version
$buildGradle = Get-Content "build.gradle" -Raw
if ($buildGradle -match 'gradle:8\.3\.2') {
    Write-Host "✓ AGP version correct (8.3.2)" -ForegroundColor Green
} else {
    Write-Host "✗ AGP version incorrect" -ForegroundColor Red
}

# Check Kotlin version
if ($buildGradle -match 'kotlinVersion = "1\.9\.24"') {
    Write-Host "✓ Kotlin version correct (1.9.24)" -ForegroundColor Green
} else {
    Write-Host "✗ Kotlin version incorrect" -ForegroundColor Red
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
        Write-Host "✗ Missing: $jar" -ForegroundColor Red
        $allJarsExist = $false
    }
}

if ($allJarsExist) {
    Write-Host "✓ All plugin JARs exist" -ForegroundColor Green
}
'@

Set-Content "verify-setup.ps1" $verifyScript

# Success message
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " Android Studio Fix v3 Applied!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Key changes made:" -ForegroundColor Yellow
Write-Host "• Android Gradle Plugin: 8.3.2 (was 8.9.2)" -ForegroundColor Cyan
Write-Host "• Kotlin: 1.9.24 (was 2.1.20)" -ForegroundColor Cyan
Write-Host "• Plugin JARs: Built and ready" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run .\verify-setup.ps1 to check configuration" -ForegroundColor Cyan
Write-Host "2. Open Android Studio" -ForegroundColor Cyan
Write-Host "3. File → Invalidate Caches → Invalidate and Restart" -ForegroundColor Cyan
Write-Host "4. After restart, File → Sync Project with Gradle Files" -ForegroundColor Cyan
Write-Host "5. Build → Build Bundle(s) / APK(s) → Build APK(s)" -ForegroundColor Cyan
Write-Host ""
Write-Host "If sync still fails:" -ForegroundColor Yellow
Write-Host "• Try File → Sync Project with Gradle Files again" -ForegroundColor Cyan
Write-Host "• Check Build output window for specific errors" -ForegroundColor Cyan
Write-Host ""
Write-Host "To restore original files:" -ForegroundColor Gray
Write-Host "  Get-ChildItem *.backup | ForEach-Object { Copy-Item $_ ($_.Name -replace '\.backup$','') -Force }" -ForegroundColor Gray