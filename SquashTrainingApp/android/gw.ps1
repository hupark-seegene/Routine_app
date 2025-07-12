#!/usr/bin/env pwsh
# Gradle Wrapper with automatic React Native plugin building for RN 0.80+
# PowerShell version - Use this instead of gradlew to ensure the RN plugin is built

# Get the directory of this script
$scriptDir = $PSScriptRoot
$projectRoot = Split-Path -Parent $scriptDir
$pluginPath = Join-Path $projectRoot "node_modules\@react-native\gradle-plugin"
$pluginJar = Join-Path $pluginPath "react-native-gradle-plugin\build\libs\react-native-gradle-plugin.jar"
$settingsJar = Join-Path $pluginPath "settings-plugin\build\libs\settings-plugin.jar"

# Check if we need to set up Java
if (-not $env:JAVA_HOME) {
    Write-Host "[gw] Setting up Java environment..." -ForegroundColor Cyan
    $env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
    $env:Path = "$env:JAVA_HOME\bin;$env:Path"
}

# Check if plugin directory exists
if (-not (Test-Path $pluginPath)) {
    Write-Host ""
    Write-Host "[gw] ERROR: React Native gradle plugin not found!" -ForegroundColor Red
    Write-Host "[gw] Expected at: $pluginPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "[gw] Please run 'npm install' in the project root first." -ForegroundColor Yellow
    exit 1
}

# Check if plugin is built
$pluginBuilt = (Test-Path $pluginJar) -and (Test-Path $settingsJar)

# Build plugin if needed
if (-not $pluginBuilt) {
    Write-Host ""
    Write-Host "[gw] React Native gradle plugin not built. Building it now..." -ForegroundColor Yellow
    Write-Host "[gw] This is a one-time process that takes 1-2 minutes." -ForegroundColor Cyan
    Write-Host ""
    
    Push-Location $pluginPath
    
    try {
        # Try to build with tests first
        Write-Host "[gw] Building plugin (including tests)..." -ForegroundColor Cyan
        $buildResult = & cmd /c "gradlew.bat build 2>&1"
        $buildSuccess = $LASTEXITCODE -eq 0
        
        if (-not $buildSuccess) {
            Write-Host ""
            Write-Host "[gw] Build with tests failed. Retrying without tests..." -ForegroundColor Yellow
            Write-Host "[gw] Note: This is common on Windows due to test compatibility issues." -ForegroundColor Yellow
            Write-Host ""
            
            # Try building without tests
            $buildResult = & cmd /c "gradlew.bat build -x test 2>&1"
            $buildSuccess = $LASTEXITCODE -eq 0
        }
        
        if (-not $buildSuccess) {
            Write-Host ""
            Write-Host "[gw] ERROR: Failed to build React Native gradle plugin even without tests!" -ForegroundColor Red
            Write-Host "[gw] Please check the error messages above." -ForegroundColor Red
            Pop-Location
            exit 1
        }
    }
    catch {
        Write-Host "[gw] ERROR: $_" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    
    Pop-Location
    
    # Verify the build succeeded
    if ((Test-Path $pluginJar) -and (Test-Path $settingsJar)) {
        Write-Host ""
        Write-Host "[gw] React Native gradle plugin built successfully!" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "[gw] ERROR: Plugin build completed but JAR files not found!" -ForegroundColor Red
        exit 1
    }
}

# Now run the actual gradlew with all arguments
& "$scriptDir\gradlew.bat" @args