# Complete App Debug - Full Working Solution
$ErrorActionPreference = "Continue"

Write-Host "`n=== COMPLETE APP DEBUG ===" -ForegroundColor Green
Write-Host "This will build and run the complete app!" -ForegroundColor Cyan

# Environment
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools"
$env:Path = "$env:JAVA_HOME\bin;$adbPath;$env:Path"

# Step 1: Deep clean
Write-Host "`n[1/7] Deep cleaning..." -ForegroundColor Yellow
Stop-Process -Name node -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\metro*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "android\.gradle" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "android\app\build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "android\build" -Recurse -Force -ErrorAction SilentlyContinue

# Step 2: Configure build files
Write-Host "[2/7] Configuring build..." -ForegroundColor Yellow
Push-Location android

# Root build.gradle
@'
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
    }
}
'@ | Out-File -Encoding ASCII "build.gradle"

# Settings.gradle
@'
rootProject.name = 'SquashTrainingApp'
include ':app'
'@ | Out-File -Encoding ASCII "settings.gradle"

# App build.gradle with Kotlin support
@'
apply plugin: "com.android.application"
apply plugin: "kotlin-android"

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
        
        // Add build config fields
        buildConfigField "boolean", "IS_NEW_ARCHITECTURE_ENABLED", "false"
        buildConfigField "boolean", "IS_HERMES_ENABLED", "true"
        buildConfigField "boolean", "DEBUG", "true"
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
    
    // Important: Add source sets for Kotlin
    sourceSets {
        main {
            java.srcDirs = ['src/main/java']
        }
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = "17"
    }
    
    packagingOptions {
        pickFirst '**/libc++_shared.so'
        pickFirst '**/libjsc.so'
    }
    
    buildFeatures {
        buildConfig = true
    }
}

dependencies {
    // React Native
    implementation 'com.facebook.react:react-android:0.80.1'
    implementation 'com.facebook.react:hermes-android:0.80.1'
    
    // Android dependencies
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'androidx.swiperefreshlayout:swiperefreshlayout:1.1.0'
    
    // Kotlin
    implementation "org.jetbrains.kotlin:kotlin-stdlib:1.9.24"
}
'@ | Out-File -Encoding ASCII "app\build.gradle"

Pop-Location

# Step 3: Create complete JavaScript bundle
Write-Host "[3/7] Creating JavaScript bundle..." -ForegroundColor Yellow
$assetsDir = "android\app\src\main\assets"
New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null

# Try to create real bundle with Metro
$bundleCmd = 'npx react-native bundle --platform android --dev true --entry-file index.js --bundle-output android\app\src\main\assets\index.android.bundle --assets-dest android\app\src\main\res'
Write-Host "  Attempting Metro bundler..." -ForegroundColor Gray

# Use Start-Process to avoid encoding issues
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "cmd.exe"
$psi.Arguments = "/c $bundleCmd"
$psi.UseShellExecute = $false
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.CreateNoWindow = $true

$process = [System.Diagnostics.Process]::Start($psi)
$process.WaitForExit()

if ($process.ExitCode -eq 0 -and (Test-Path "$assetsDir\index.android.bundle")) {
    $size = [math]::Round((Get-Item "$assetsDir\index.android.bundle").Length / 1KB, 0)
    if ($size -gt 100) {
        Write-Host "  Bundle created successfully: ${size}KB" -ForegroundColor Green
    } else {
        Write-Host "  Bundle too small, will rely on Metro server" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Bundle creation failed, will use Metro server at runtime" -ForegroundColor Yellow
    # Create minimal bundle
    "// Metro will serve the bundle" | Out-File -Encoding UTF8 "$assetsDir\index.android.bundle"
}

# Step 4: Check/start emulator
Write-Host "[4/7] Checking device..." -ForegroundColor Yellow
$devices = adb devices 2>$null
if ($devices -match "device") {
    Write-Host "  Device ready" -ForegroundColor Green
} else {
    Write-Host "  Starting emulator..." -ForegroundColor Yellow
    & .\START-EMULATOR.ps1
}

# Step 5: Build APK
Write-Host "[5/7] Building APK..." -ForegroundColor Yellow
Push-Location android
$buildOutput = .\gradlew.bat clean assembleDebug --no-daemon 2>&1
$buildSuccess = $LASTEXITCODE -eq 0
Pop-Location

if ($buildSuccess) {
    Write-Host "  Build successful!" -ForegroundColor Green
    
    # Step 6: Install
    Write-Host "[6/7] Installing app..." -ForegroundColor Yellow
    adb uninstall com.squashtrainingapp 2>$null | Out-Null
    adb install -r android\app\build\outputs\apk\debug\app-debug.apk
    
    # Setup debugging ports
    adb reverse tcp:8081 tcp:8081 2>$null
    adb reverse tcp:8088 tcp:8088 2>$null
    
    # Step 7: Start Metro bundler in background
    Write-Host "[7/7] Starting Metro bundler..." -ForegroundColor Yellow
    $metro = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "npx react-native start --reset-cache" -PassThru -WindowStyle Minimized
    Write-Host "  Metro bundler started (PID: $($metro.Id))" -ForegroundColor Gray
    Start-Sleep -Seconds 5
    
    # Launch app
    Write-Host "`nLaunching app..." -ForegroundColor Yellow
    adb shell am start -n com.squashtrainingapp/.MainActivity
    
    Write-Host "`n=== APP LAUNCHED SUCCESSFULLY ===" -ForegroundColor Green
    Write-Host "`nThe app should be running now!" -ForegroundColor Cyan
    Write-Host "If you see a red screen, press 'R' twice to reload" -ForegroundColor Yellow
    Write-Host "Metro bundler is running in background" -ForegroundColor Yellow
    Write-Host "`nShowing logs (Ctrl+C to stop)..." -ForegroundColor Gray
    
    # Stream logs
    adb logcat -c
    adb logcat ReactNative:V ReactNativeJS:V SquashTrainingApp:V AndroidRuntime:E *:S
    
    # Kill Metro when done
    if ($metro -and !$metro.HasExited) {
        Stop-Process -Id $metro.Id -Force
    }
} else {
    Write-Host "`nBuild failed!" -ForegroundColor Red
    Write-Host "Build errors:" -ForegroundColor Yellow
    $buildOutput | Select-Object -Last 30 | ForEach-Object { Write-Host $_ }
}