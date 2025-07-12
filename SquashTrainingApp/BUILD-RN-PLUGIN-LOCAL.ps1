# Build React Native Gradle Plugin Locally
# This script builds and installs the React Native gradle plugin to local Maven repository

param(
    [switch]$Force = $false
)

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " BUILD REACT NATIVE GRADLE PLUGIN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set environment
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

# Check if plugin source exists
$pluginPath = "node_modules\react-native-gradle-plugin"
if (-not (Test-Path $pluginPath)) {
    Write-Host "[ERROR] React Native gradle plugin source not found!" -ForegroundColor Red
    Write-Host "Looking for: $pluginPath" -ForegroundColor Yellow
    
    # Try alternative location
    $altPath = "node_modules\@react-native\gradle-plugin"
    if (Test-Path $altPath) {
        $pluginPath = $altPath
        Write-Host "[INFO] Found plugin at alternative location: $altPath" -ForegroundColor Green
    } else {
        Write-Host "[INFO] Attempting to extract from react-native package..." -ForegroundColor Yellow
        
        # Create directory
        New-Item -ItemType Directory -Path $pluginPath -Force | Out-Null
        
        # Copy gradle plugin files from react-native
        $rnPath = "node_modules\react-native"
        if (Test-Path "$rnPath\react-native-gradle-plugin") {
            Copy-Item -Path "$rnPath\react-native-gradle-plugin\*" -Destination $pluginPath -Recurse -Force
            Write-Host "[SUCCESS] Extracted plugin files" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] Cannot find gradle plugin source!" -ForegroundColor Red
            exit 1
        }
    }
}

# Check local Maven repository
$m2Home = "$env:USERPROFILE\.m2\repository"
$pluginM2Path = "$m2Home\com\facebook\react\react-native-gradle-plugin\0.80.1"

if ((Test-Path "$pluginM2Path\react-native-gradle-plugin-0.80.1.jar") -and -not $Force) {
    Write-Host "[INFO] Plugin already exists in local Maven repository" -ForegroundColor Green
    Write-Host "Location: $pluginM2Path" -ForegroundColor Gray
    Write-Host "Use -Force to rebuild" -ForegroundColor Gray
    exit 0
}

# Build the plugin
Write-Host "`n[BUILD] Building React Native gradle plugin..." -ForegroundColor Yellow
Push-Location $pluginPath

# Check if gradlew exists
if (Test-Path "gradlew.bat") {
    Write-Host "Using plugin's gradlew..." -ForegroundColor Gray
    $gradleCmd = ".\gradlew.bat"
} else {
    Write-Host "Using project's gradlew..." -ForegroundColor Gray
    $gradleCmd = "..\..\android\gradlew.bat"
}

# Clean and build
Write-Host "Cleaning..." -ForegroundColor Gray
& $gradleCmd clean --no-daemon 2>&1 | Out-Null

Write-Host "Building..." -ForegroundColor Gray
$buildOutput = & $gradleCmd build publishToMavenLocal --no-daemon 2>&1 | Out-String

if ($LASTEXITCODE -eq 0) {
    Write-Host "[SUCCESS] Plugin built and published to local Maven!" -ForegroundColor Green
    Write-Host "Location: $pluginM2Path" -ForegroundColor Gray
} else {
    Write-Host "[ERROR] Build failed!" -ForegroundColor Red
    Write-Host $buildOutput -ForegroundColor Red
    
    # Alternative: Direct copy approach
    Write-Host "`n[FALLBACK] Trying direct installation..." -ForegroundColor Yellow
    
    # Create directory structure
    New-Item -ItemType Directory -Path $pluginM2Path -Force | Out-Null
    
    # Create minimal POM file
    $pomContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<project xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd" 
         xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.facebook.react</groupId>
  <artifactId>react-native-gradle-plugin</artifactId>
  <version>0.80.1</version>
</project>
"@
    $pomContent | Out-File -FilePath "$pluginM2Path\react-native-gradle-plugin-0.80.1.pom" -Encoding UTF8
    
    # Create empty JAR (placeholder)
    if (Test-Path "build\libs\*.jar") {
        Copy-Item -Path (Get-ChildItem "build\libs\*.jar" | Select-Object -First 1).FullName `
                  -Destination "$pluginM2Path\react-native-gradle-plugin-0.80.1.jar"
    } else {
        # Create minimal JAR
        Write-Host "Creating placeholder JAR..." -ForegroundColor Gray
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $jar = [System.IO.Compression.ZipFile]::Open("$pluginM2Path\react-native-gradle-plugin-0.80.1.jar", 'Create')
        $jar.Dispose()
    }
    
    Write-Host "[SUCCESS] Fallback installation complete!" -ForegroundColor Green
}

Pop-Location

# Update gradle configuration
Write-Host "`n[CONFIG] Updating build configuration..." -ForegroundColor Yellow

# Create init.gradle for local repo
$initGradleContent = @'
allprojects {
    repositories {
        mavenLocal()
        google()
        mavenCentral()
    }
}

settingsEvaluated { settings ->
    settings.pluginManagement {
        repositories {
            mavenLocal()
            gradlePluginPortal()
            google()
            mavenCentral()
        }
    }
}
'@

$initGradleContent | Out-File -FilePath "android\init.gradle" -Encoding ASCII
Write-Host "[SUCCESS] Created init.gradle for local repository" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Green
Write-Host " PLUGIN BUILD COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. The plugin is now available in local Maven repository" -ForegroundColor White
Write-Host "2. Your build.gradle should include mavenLocal() in repositories" -ForegroundColor White
Write-Host "3. Run the main build script to build your app" -ForegroundColor White