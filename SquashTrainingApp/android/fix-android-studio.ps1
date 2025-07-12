#!/usr/bin/env pwsh
# Fix Android Studio Sync Issues for React Native 0.80+
# Run this from Windows PowerShell before opening in Android Studio

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Android Studio Sync Fix" -ForegroundColor Cyan
Write-Host " for React Native 0.80+" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in android directory
if (-not (Test-Path "gradlew.bat")) {
    Write-Host "Error: Run from android directory" -ForegroundColor Red
    exit 1
}

# Step 1: Check/Build React Native gradle plugin
Write-Host "[1/4] Checking React Native gradle plugin..." -ForegroundColor Yellow

$pluginPath = "..\node_modules\@react-native\gradle-plugin"
if (Test-Path $pluginPath) {
    # Check if JARs already exist
    $jar1 = "$pluginPath\settings-plugin\build\libs\settings-plugin.jar"
    $jar2 = "$pluginPath\react-native-gradle-plugin\build\libs\react-native-gradle-plugin.jar"
    $jar3 = "$pluginPath\shared\build\libs\shared.jar"
    
    if ((Test-Path $jar1) -and (Test-Path $jar2) -and (Test-Path $jar3)) {
        Write-Host "✓ Plugin JARs already exist" -ForegroundColor Green
    } else {
        Write-Host "Plugin JARs not found. Building them now..." -ForegroundColor Yellow
        
        # Run the dedicated build script
        if (Test-Path ".\build-rn-plugin.ps1") {
            & .\build-rn-plugin.ps1
            if ($LASTEXITCODE -ne 0) {
                Write-Host "✗ Failed to build plugin JARs" -ForegroundColor Red
                Write-Host "Try running build-rn-plugin.ps1 manually for detailed error messages" -ForegroundColor Yellow
                exit 1
            }
        } else {
            # Fallback: try to build inline
            Push-Location $pluginPath
            try {
                Write-Host "Building plugin (this may take 1-2 minutes)..." -ForegroundColor Cyan
                $buildOutput = & cmd /c "gradlew.bat build -x test 2>&1"
                
                if ($LASTEXITCODE -ne 0) {
                    Write-Host "✗ Build failed. Trying jar task..." -ForegroundColor Yellow
                    & cmd /c "gradlew.bat jar -x test 2>&1" | Out-Null
                }
                
                # Re-check if JARs were created
                if ((Test-Path "settings-plugin\build\libs\settings-plugin.jar") -and 
                    (Test-Path "react-native-gradle-plugin\build\libs\react-native-gradle-plugin.jar") -and
                    (Test-Path "shared\build\libs\shared.jar")) {
                    Write-Host "✓ Plugin JARs built successfully" -ForegroundColor Green
                } else {
                    Write-Host "✗ Failed to build all required JARs" -ForegroundColor Red
                    Write-Host "Missing JARs. The build may fail." -ForegroundColor Yellow
                    # Continue anyway - maybe partial build will work
                }
            } finally {
                Pop-Location
            }
        }
    }
} else {
    Write-Host "✗ React Native plugin directory not found" -ForegroundColor Red
    Write-Host "Run 'npm install' first" -ForegroundColor Yellow
    exit 1
}

# Step 2: Backup current gradle files
Write-Host ""
Write-Host "[2/4] Backing up current gradle files..." -ForegroundColor Yellow

if (-not (Test-Path "settings.gradle.backup")) {
    Copy-Item "settings.gradle" "settings.gradle.backup" -Force
    Write-Host "✓ Backed up settings.gradle" -ForegroundColor Green
}

if (-not (Test-Path "build.gradle.backup")) {
    Copy-Item "build.gradle" "build.gradle.backup" -Force
    Write-Host "✓ Backed up build.gradle" -ForegroundColor Green
}

# Step 3: Apply Android Studio compatible configuration
Write-Host ""
Write-Host "[3/4] Applying Android Studio compatible configuration..." -ForegroundColor Yellow

if ((Test-Path "settings.gradle.studio") -and (Test-Path "build.gradle.studio")) {
    Copy-Item "settings.gradle.studio" "settings.gradle" -Force
    Copy-Item "build.gradle.studio" "build.gradle" -Force
    Write-Host "✓ Applied Android Studio compatible gradle files" -ForegroundColor Green
} else {
    Write-Host "✗ Studio configuration files not found" -ForegroundColor Red
    Write-Host "Creating them now..." -ForegroundColor Yellow
    
    # Create inline if files don't exist
    $settingsContent = @'
// Android Studio compatible settings.gradle
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    resolutionStrategy {
        eachPlugin {
            if (requested.id.id == "com.facebook.react.settings") {
                useClass("com.facebook.react.ReactSettingsPlugin")
            } else if (requested.id.id == "com.facebook.react") {
                useClass("com.facebook.react.ReactPlugin")
            }
        }
    }
}

buildscript {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    dependencies {
        def rnPluginDir = file("../node_modules/@react-native/gradle-plugin")
        if (rnPluginDir.exists()) {
            classpath files(
                "${rnPluginDir}/settings-plugin/build/libs/settings-plugin.jar",
                "${rnPluginDir}/react-native-gradle-plugin/build/libs/react-native-gradle-plugin.jar",
                "${rnPluginDir}/shared/build/libs/shared.jar"
            )
        }
        classpath 'com.google.code.gson:gson:2.10.1'
        classpath 'com.google.guava:guava:31.1-jre'
        classpath 'com.squareup:javapoet:1.13.0'
    }
}

apply plugin: "com.facebook.react.settings"
rootProject.name = 'SquashTrainingApp'
include ':app'
'@
    
    Set-Content -Path "settings.gradle" -Value $settingsContent
    Write-Host "✓ Created Android Studio compatible settings.gradle" -ForegroundColor Green
}

# Step 4: Clear gradle caches
Write-Host ""
Write-Host "[4/4] Clearing gradle caches..." -ForegroundColor Yellow

if (Test-Path ".gradle") {
    Remove-Item ".gradle" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✓ Cleared local gradle cache" -ForegroundColor Green
}

if (Test-Path "app\build") {
    Remove-Item "app\build" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✓ Cleared app build directory" -ForegroundColor Green
}

# Success message
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " Android Studio Fix Applied!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Open Android Studio" -ForegroundColor Cyan
Write-Host "2. File -> Open -> Select this 'android' folder" -ForegroundColor Cyan
Write-Host "3. If prompted, click 'Trust Project'" -ForegroundColor Cyan
Write-Host "4. Wait for 'Sync Project with Gradle Files'" -ForegroundColor Cyan
Write-Host "5. If sync fails, try:" -ForegroundColor Cyan
Write-Host "   - File -> Invalidate Caches -> Invalidate and Restart" -ForegroundColor Cyan
Write-Host "   - Build -> Clean Project" -ForegroundColor Cyan
Write-Host "   - Build -> Rebuild Project" -ForegroundColor Cyan
Write-Host ""
Write-Host "To restore original files:" -ForegroundColor Gray
Write-Host "  Copy-Item settings.gradle.backup settings.gradle -Force" -ForegroundColor Gray
Write-Host "  Copy-Item build.gradle.backup build.gradle -Force" -ForegroundColor Gray