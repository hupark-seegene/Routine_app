# Simple Build Script
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

Write-Host "Building APK..."

# Clean
if (Test-Path "app\build") { Remove-Item -Recurse -Force "app\build" }

# Use minimal config without React Native plugin
@"
apply plugin: 'com.android.application'

android {
    compileSdkVersion 34
    buildToolsVersion "34.0.0"
    
    namespace "com.squashtrainingapp"
    
    defaultConfig {
        applicationId "com.squashtrainingapp"
        minSdkVersion 24
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
    }
    
    signingConfigs {
        debug {
            storeFile file('debug.keystore')
            storePassword 'android'
            keyAlias 'androiddebugkey'
            keyPassword 'android'
        }
    }
    
    buildTypes {
        debug {
            signingConfig signingConfigs.debug
        }
    }
}

dependencies {
    implementation 'com.facebook.react:react-android:0.80.1'
    implementation 'com.facebook.react:hermes-android:0.80.1'
    implementation 'androidx.appcompat:appcompat:1.6.1'
}

task bundleJS(type: Exec) {
    workingDir rootProject.file('../')
    commandLine 'cmd', '/c', 'npx', 'react-native', 'bundle', '--platform', 'android', '--dev', 'true', '--entry-file', 'index.js', '--bundle-output', 'android/app/src/main/assets/index.android.bundle'
}

preBuild.dependsOn bundleJS
"@ | Out-File -Encoding ASCII "app\build.gradle"

# Build
.\gradlew.bat assembleDebug --no-daemon

# Check result
if (Test-Path "app\build\outputs\apk\debug\app-debug.apk") {
    Write-Host "BUILD SUCCESS!" -ForegroundColor Green
} else {
    Write-Host "BUILD FAILED!" -ForegroundColor Red
}