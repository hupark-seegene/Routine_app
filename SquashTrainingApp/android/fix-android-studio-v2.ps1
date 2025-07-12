Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Android Studio Sync Fix v2" -ForegroundColor Cyan
Write-Host " for React Native 0.80+" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set JAVA_HOME if not set
if (-not $env:JAVA_HOME) {
    $env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
    $env:Path = "$env:JAVA_HOME\bin;$env:Path"
    Write-Host "[0/5] Set JAVA_HOME to $env:JAVA_HOME" -ForegroundColor Yellow
}

Write-Host "[1/5] Building React Native gradle plugin..." -ForegroundColor Yellow
$pluginDir = "..\node_modules\@react-native\gradle-plugin"
if (Test-Path $pluginDir) {
    Push-Location $pluginDir
    Write-Host "Building plugin (this may take 1-2 minutes)..." -ForegroundColor Gray
    
    # Use the existing gradlew in the plugin directory
    if (Test-Path ".\gradlew.bat") {
        & .\gradlew.bat build --quiet 2>&1 | Out-Null
    } else {
        Write-Host "Warning: gradlew.bat not found in plugin directory" -ForegroundColor Yellow
    }
    
    Pop-Location
    
    # Check if JARs were built
    $jarPath = "..\node_modules\@react-native\gradle-plugin\gradle-plugin\react-native-gradle-plugin\build\libs\react-native-gradle-plugin.jar"
    if (Test-Path $jarPath) {
        Write-Host "✓ Plugin JARs built successfully" -ForegroundColor Green
    } else {
        Write-Host "! Plugin JARs not found, will rely on Android Studio to build them" -ForegroundColor Yellow
    }
} else {
    Write-Host "! React Native gradle plugin directory not found" -ForegroundColor Red
    Write-Host "  Please run 'npm install' first" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2/5] Creating Android Studio compatible gradle configuration..." -ForegroundColor Yellow

# Create a proper build.gradle for Android Studio
$buildGradleContent = @'
// Android Studio compatible build.gradle for React Native 0.80+
buildscript {
    ext {
        buildToolsVersion = "35.0.0"
        minSdkVersion = 24
        compileSdkVersion = 35
        targetSdkVersion = 35
        ndkVersion = "27.1.12297006"
        kotlinVersion = "2.1.20"
    }
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.9.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

// Configure the React Native plugin
apply from: file("../node_modules/@react-native/gradle-plugin/gradle-plugin/settings-plugin.gradle.kts")
apply plugin: "com.facebook.react.rootproject"

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url "https://www.jitpack.io" }
        maven {
            url("$rootDir/../node_modules/react-native/android")
        }
    }
}

// React Native version override
ext {
    versionOverrides = [
        "react-native": "0.80.1"
    ]
}
'@

# Backup existing files
Write-Host "[3/5] Backing up current gradle files..." -ForegroundColor Yellow
if (Test-Path "build.gradle") {
    Copy-Item "build.gradle" "build.gradle.backup" -Force
}
if (Test-Path "settings.gradle") {
    Copy-Item "settings.gradle" "settings.gradle.backup" -Force
}

# Write new build.gradle
$buildGradleContent | Out-File -FilePath "build.gradle" -Encoding UTF8
Write-Host "✓ Created Android Studio compatible build.gradle" -ForegroundColor Green

Write-Host ""
Write-Host "[4/5] Clearing gradle caches..." -ForegroundColor Yellow
if (Test-Path ".gradle") {
    Remove-Item -Path ".gradle" -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Host "✓ Cleared local gradle cache" -ForegroundColor Green

Write-Host ""
Write-Host "[5/5] Creating gradle wrapper properties fix..." -ForegroundColor Yellow
$wrapperPropsPath = "gradle\wrapper\gradle-wrapper.properties"
if (Test-Path $wrapperPropsPath) {
    $content = Get-Content $wrapperPropsPath -Raw
    if ($content -notmatch "distributionUrl=.*gradle-8\.14\.1.*") {
        $content = $content -replace 'distributionUrl=.*', 'distributionUrl=https\://services.gradle.org/distributions/gradle-8.14.1-all.zip'
        $content | Out-File -FilePath $wrapperPropsPath -Encoding UTF8 -NoNewline
        Write-Host "✓ Updated gradle wrapper to version 8.14.1" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Android Studio Fix Applied!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Open Android Studio" -ForegroundColor White
Write-Host "2. File -> Open -> Select this 'android' folder" -ForegroundColor White
Write-Host "3. If prompted about trusting the project, click 'Trust Project'" -ForegroundColor White
Write-Host "4. Wait for 'Sync Project with Gradle Files' to complete" -ForegroundColor White
Write-Host ""
Write-Host "If sync still fails:" -ForegroundColor Yellow
Write-Host "- File -> Invalidate Caches -> Invalidate and Restart" -ForegroundColor White
Write-Host "- After restart, let Android Studio sync again" -ForegroundColor White
Write-Host "- Build -> Clean Project" -ForegroundColor White
Write-Host "- Build -> Rebuild Project" -ForegroundColor White
Write-Host ""
Write-Host "To restore original files:" -ForegroundColor Gray
Write-Host "  Copy-Item build.gradle.backup build.gradle -Force" -ForegroundColor Gray
Write-Host "  Copy-Item settings.gradle.backup settings.gradle -Force" -ForegroundColor Gray