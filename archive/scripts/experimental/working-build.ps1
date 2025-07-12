# Working Build Script - Direct Approach
param(
    [switch]$Clean = $false
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " React Native Working Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Set JAVA_HOME
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

# Step 1: Clean if requested
if ($Clean) {
    Write-Host "[Clean] Removing build directories..." -ForegroundColor Yellow
    @("build", "app\build", ".gradle") | ForEach-Object {
        if (Test-Path $_) { Remove-Item -Recurse -Force $_ }
    }
}

# Step 2: Create init script
Write-Host "[Setup] Creating gradle init script..." -ForegroundColor Yellow
$initScript = @'
// Load React Native plugin JARs directly
def rnPluginDir = new File(rootDir, "../node_modules/@react-native/gradle-plugin")

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Load JARs directly
        def jars = [
            new File(rnPluginDir, "settings-plugin/build/libs/settings-plugin.jar"),
            new File(rnPluginDir, "react-native-gradle-plugin/build/libs/react-native-gradle-plugin.jar"),
            new File(rnPluginDir, "shared/build/libs/shared.jar")
        ]
        
        jars.each { jar ->
            if (jar.exists()) {
                classpath files(jar)
            }
        }
        
        // Required dependencies
        classpath 'com.google.code.gson:gson:2.10.1'
        classpath 'com.google.guava:guava:31.1-jre'
        classpath 'com.squareup:javapoet:1.13.0'
    }
}

// Make plugin classes available
allprojects {
    buildscript {
        repositories {
            google()
            mavenCentral()
        }
    }
}
'@

$initScript | Out-File -Encoding ASCII "init.gradle"

# Step 3: Create working settings.gradle
Write-Host "[Setup] Creating settings.gradle..." -ForegroundColor Yellow
@'
// Load init script first
apply from: 'init.gradle'

// Plugin management
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

// Apply React Native settings plugin
apply plugin: "com.facebook.react.settings"

rootProject.name = 'SquashTrainingApp'
include ':app'
'@ | Out-File -Encoding ASCII "settings.gradle"

# Step 4: Create build.gradle
Write-Host "[Setup] Creating build.gradle..." -ForegroundColor Yellow
@'
// Apply init script
apply from: 'init.gradle'

buildscript {
    ext {
        buildToolsVersion = "34.0.0"
        minSdkVersion = 24
        compileSdkVersion = 34
        targetSdkVersion = 34
        ndkVersion = "26.1.10909125"
        kotlinVersion = "1.9.24"
    }
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.3.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url "https://www.jitpack.io" }
        maven { url "$rootDir/../node_modules/react-native/android" }
    }
}
'@ | Out-File -Encoding ASCII "build.gradle"

# Step 5: Build with init script
Write-Host ""
Write-Host "[Build] Starting gradle build with init script..." -ForegroundColor Green
& .\gradlew.bat assembleDebug --init-script init.gradle --no-daemon --stacktrace

# Check result
$apkPath = "app\build\outputs\apk\debug\app-debug.apk"
if (Test-Path $apkPath) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host " ✅ BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "APK: $((Get-Item $apkPath).FullName)" -ForegroundColor Yellow
    $size = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
    Write-Host "Size: $size MB" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "❌ Build failed" -ForegroundColor Red
    Write-Host "Check the error messages above" -ForegroundColor Red
}