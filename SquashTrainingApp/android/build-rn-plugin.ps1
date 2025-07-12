#!/usr/bin/env pwsh
# Build React Native Gradle Plugin for Android Studio
# This script builds the required JARs for React Native 0.80+

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " React Native Plugin Builder" -ForegroundColor Cyan
Write-Host " for React Native 0.80+" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$currentUser
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check Java
Write-Host "[1/4] Checking Java installation..." -ForegroundColor Yellow
$javaVersion = & java -version 2>&1 | Select-String "version"
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Java not found. Please install JDK 17" -ForegroundColor Red
    Write-Host "Set JAVA_HOME to: C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "✓ Java found: $javaVersion" -ForegroundColor Green
}

# Navigate to plugin directory
$pluginPath = "..\node_modules\@react-native\gradle-plugin"
if (-not (Test-Path $pluginPath)) {
    Write-Host "✗ React Native plugin not found at $pluginPath" -ForegroundColor Red
    Write-Host "Please run 'npm install' from the project root first" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "[2/4] Navigating to plugin directory..." -ForegroundColor Yellow
Push-Location $pluginPath

try {
    # Clean previous builds
    Write-Host ""
    Write-Host "[3/4] Cleaning previous builds..." -ForegroundColor Yellow
    if (Test-Path "settings-plugin\build") {
        Remove-Item "settings-plugin\build" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "✓ Cleaned settings-plugin build" -ForegroundColor Green
    }
    if (Test-Path "react-native-gradle-plugin\build") {
        Remove-Item "react-native-gradle-plugin\build" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "✓ Cleaned react-native-gradle-plugin build" -ForegroundColor Green
    }
    if (Test-Path "shared\build") {
        Remove-Item "shared\build" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "✓ Cleaned shared build" -ForegroundColor Green
    }

    # Build the plugin
    Write-Host ""
    Write-Host "[4/4] Building React Native gradle plugin..." -ForegroundColor Yellow
    Write-Host "This may take 2-3 minutes on first run..." -ForegroundColor Cyan
    
    # Use gradlew.bat with proper error handling
    $buildOutput = & cmd /c "gradlew.bat build -x test 2>&1"
    $buildSuccess = $LASTEXITCODE -eq 0
    
    if (-not $buildSuccess) {
        Write-Host "✗ Build failed with error code $LASTEXITCODE" -ForegroundColor Red
        Write-Host "Build output:" -ForegroundColor Yellow
        Write-Host $buildOutput
        
        # Try alternative build command
        Write-Host ""
        Write-Host "Trying alternative build method..." -ForegroundColor Yellow
        $altBuildOutput = & cmd /c "gradlew.bat jar -x test 2>&1"
        $buildSuccess = $LASTEXITCODE -eq 0
        
        if (-not $buildSuccess) {
            Write-Host "✗ Alternative build also failed" -ForegroundColor Red
            exit 1
        }
    }
    
    # Verify JARs were created
    Write-Host ""
    Write-Host "Verifying build artifacts..." -ForegroundColor Yellow
    
    $requiredJars = @(
        "settings-plugin\build\libs\settings-plugin.jar",
        "react-native-gradle-plugin\build\libs\react-native-gradle-plugin.jar",
        "shared\build\libs\shared.jar"
    )
    
    $allJarsExist = $true
    foreach ($jar in $requiredJars) {
        if (Test-Path $jar) {
            $size = (Get-Item $jar).Length / 1KB
            Write-Host "✓ Found $jar (${size}KB)" -ForegroundColor Green
        } else {
            Write-Host "✗ Missing $jar" -ForegroundColor Red
            $allJarsExist = $false
        }
    }
    
    if ($allJarsExist) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host " Plugin Build Successful!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "The React Native gradle plugin JARs have been built." -ForegroundColor Cyan
        Write-Host "You can now run fix-android-studio.ps1" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "✗ Some JARs are missing. Build may have partially failed." -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "✗ An error occurred: $_" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run .\fix-android-studio.ps1" -ForegroundColor Cyan
Write-Host "2. Open Android Studio" -ForegroundColor Cyan
Write-Host "3. File -> Open -> Select the 'android' folder" -ForegroundColor Cyan