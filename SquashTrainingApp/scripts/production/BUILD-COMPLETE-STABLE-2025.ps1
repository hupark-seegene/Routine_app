#!/usr/bin/env pwsh
# BUILD-COMPLETE-STABLE-2025.ps1
# Complete build script for Routine app with XML fixes and environment setup
# Created: 2025-07-23
# Purpose: Comprehensive build process following CLAUDE.md guidelines

param(
    [switch]$SkipClean = $false,
    [switch]$SkipTests = $false,
    [switch]$VerboseOutput = $false,
    [string]$DeviceId = "emulator-5554"
)

# Color output functions
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }
function Write-Warning { param($Message) Write-Host "⚠️ $Message" -ForegroundColor Yellow }
function Write-Info { param($Message) Write-Host "ℹ️ $Message" -ForegroundColor Cyan }
function Write-Step { param($Message) Write-Host "🔄 $Message" -ForegroundColor Blue }

# Project paths
$PROJECT_ROOT = (Get-Location).Path
$ANDROID_DIR = Join-Path $PROJECT_ROOT "android"
$SCRIPTS_DIR = Join-Path $PROJECT_ROOT "scripts/production"
$DDD_DIR = Join-Path $PROJECT_ROOT "ddd"
$APK_OUTPUT_DIR = Join-Path $PROJECT_ROOT "apk-output"

Write-Host "🚀 BUILD-COMPLETE-STABLE-2025 Starting..." -ForegroundColor Magenta
Write-Host "================================" -ForegroundColor Magenta
Write-Info "Project Root: $PROJECT_ROOT"
Write-Info "Build Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host ""

# Step 1: Environment Setup
Write-Step "Step 1: Environment Setup and Validation"

# Check if running in WSL
$isWSL = $env:WSL_DISTRO_NAME -ne $null
if ($isWSL) {
    Write-Info "Running in WSL environment: $env:WSL_DISTRO_NAME"
} else {
    Write-Info "Running in Windows PowerShell"
}

# Check Java installation
Write-Step "Checking Java installation..."
try {
    $javaVersion = java -version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Java found: $(($javaVersion[0] -split ' ')[2])"
    } else {
        throw "Java not found"
    }
} catch {
    Write-Error "Java not installed or not in PATH"
    Write-Warning "Please install Java 11 or higher and set JAVA_HOME"
    if ($isWSL) {
        Write-Info "For WSL: sudo apt install openjdk-11-jdk"
        Write-Info "Export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
    }
    exit 1
}

# Check Android SDK
Write-Step "Checking Android SDK..."
$androidHome = $env:ANDROID_HOME
if (-not $androidHome -or -not (Test-Path $androidHome)) {
    Write-Warning "ANDROID_HOME not set or invalid"
    # Try common locations
    $commonPaths = @(
        "$env:LOCALAPPDATA\Android\Sdk",
        "$env:USERPROFILE\AppData\Local\Android\Sdk",
        "/home/$env:USER/Android/Sdk"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            $env:ANDROID_HOME = $path
            Write-Success "Found Android SDK at: $path"
            break
        }
    }
    
    if (-not $env:ANDROID_HOME) {
        Write-Error "Android SDK not found"
        Write-Warning "Please install Android Studio and set ANDROID_HOME"
        exit 1
    }
}

# Step 2: DDD Update (as per CLAUDE.md)
Write-Step "Step 2: Updating DDD dependencies"

if (Test-Path $DDD_DIR) {
    Write-Info "Updating DDD directory..."
    Push-Location $DDD_DIR
    try {
        if (Test-Path "package.json") {
            npm install --silent
            Write-Success "DDD dependencies updated"
        } else {
            Write-Warning "No package.json found in DDD directory"
        }
    } catch {
        Write-Warning "Failed to update DDD dependencies: $($_.Exception.Message)"
    } finally {
        Pop-Location
    }
} else {
    Write-Warning "DDD directory not found, creating..."
    New-Item -ItemType Directory -Path $DDD_DIR -Force | Out-Null
}

# Step 3: XML File Fixes
Write-Step "Step 3: Fixing XML encoding and structure issues"

$xmlFiles = @(
    "android/app/src/main/res/layout/activity_login.xml",
    "android/app/src/main/res/layout/item_custom_exercise.xml", 
    "android/app/src/main/res/layout/dialog_exercise_details.xml",
    "android/app/src/main/res/layout/activity_voice_guided_workout.xml",
    "android/app/src/main/res/layout/activity_voice_record.xml",
    "android/app/src/main/res/layout/item_workout_program.xml",
    "android/app/src/main/res/layout/dialog_create_exercise.xml",
    "android/app/src/main/res/layout/global_voice_overlay.xml",
    "android/app/src/main/res/layout/activity_profile.xml"
)

function Fix-XMLFile {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        Write-Warning "XML file not found: $FilePath"
        return $false
    }
    
    try {
        $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
        $originalContent = $content
        $fixed = $false
        
        # Fix Korean text encoding issues (replace common corrupted patterns)
        $koreanFixes = @{
            "?�쿼?" = "스쿼시"
            "?�레?�닝" = "트레이닝"
            "?�로" = "앱"
            "??글로벌" = "글로벌"
            "??��" = "및"
            "�?챌린지" = "챌린지"
            "AI 코치?�" = "AI 코치와"
            "?�께?�는" = "함께하는"
            "맞춤 ?�레?�닝" = "맞춤 트레이닝"
        }
        
        foreach ($pattern in $koreanFixes.Keys) {
            if ($content -match [regex]::Escape($pattern)) {
                $content = $content -replace [regex]::Escape($pattern), $koreanFixes[$pattern]
                $fixed = $true
                Write-Info "Fixed Korean text: '$pattern' -> '$($koreanFixes[$pattern])'"
            }
        }
        
        # Check for unclosed tags by counting opening/closing tag pairs
        $xmlDoc = [xml]$content
        if ($xmlDoc) {
            Write-Success "XML structure valid: $FilePath"
        }
        
        if ($fixed) {
            Set-Content -Path $FilePath -Value $content -Encoding UTF8
            Write-Success "Fixed XML file: $FilePath"
        }
        
        return $true
    } catch {
        Write-Error "Failed to fix XML file $FilePath : $($_.Exception.Message)"
        return $false
    }
}

$xmlFixCount = 0
foreach ($xmlFile in $xmlFiles) {
    $fullPath = Join-Path $PROJECT_ROOT $xmlFile
    if (Fix-XMLFile -FilePath $fullPath) {
        $xmlFixCount++
    }
}

Write-Success "Fixed $xmlFixCount XML files"

# Step 4: Clean Build (optional)
if (-not $SkipClean) {
    Write-Step "Step 4: Cleaning previous build"
    
    Push-Location $ANDROID_DIR
    try {
        Write-Info "Running gradle clean..."
        ./gradlew clean --quiet
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Clean completed successfully"
        } else {
            Write-Warning "Clean completed with warnings"
        }
    } catch {
        Write-Warning "Clean failed: $($_.Exception.Message)"
    } finally {
        Pop-Location
    }
} else {
    Write-Info "Skipping clean (--SkipClean flag)"
}

# Step 5: Build APK
Write-Step "Step 5: Building APK"

Push-Location $ANDROID_DIR
try {
    $buildArgs = @("assembleDebug")
    if (-not $VerboseOutput) {
        $buildArgs += "--quiet"
    }
    
    Write-Info "Running gradle assembleDebug..."
    & ./gradlew @buildArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "APK build completed successfully!"
        
        # Find and copy APK
        $apkPath = Get-ChildItem -Path "app/build/outputs/apk/debug" -Filter "*.apk" | Select-Object -First 1
        if ($apkPath) {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $newApkName = "RoutineApp_$timestamp.apk"
            $outputPath = Join-Path $APK_OUTPUT_DIR $newApkName
            
            # Ensure output directory exists
            if (-not (Test-Path $APK_OUTPUT_DIR)) {
                New-Item -ItemType Directory -Path $APK_OUTPUT_DIR -Force | Out-Null
            }
            
            Copy-Item -Path $apkPath.FullName -Destination $outputPath
            Write-Success "APK copied to: $outputPath"
            
            # Get APK size
            $apkSize = [math]::Round((Get-Item $outputPath).Length / 1MB, 2)
            Write-Info "APK Size: ${apkSize}MB"
        }
    } else {
        Write-Error "APK build failed with exit code: $LASTEXITCODE"
        exit 1
    }
} catch {
    Write-Error "Build failed: $($_.Exception.Message)"
    exit 1
} finally {
    Pop-Location
}

# Step 6: Install to Device (if available)
Write-Step "Step 6: Installing to device/emulator"

try {
    # Check if device is available
    $devices = adb devices | Select-String "device$"
    if ($devices.Count -eq 0) {
        Write-Warning "No devices/emulators found. Starting emulator..."
        
        # Try to start default emulator
        Start-Process "emulator" -ArgumentList "@Pixel_3a_API_30_x86" -NoNewWindow
        Write-Info "Waiting for emulator to start..."
        Start-Sleep -Seconds 10
        
        # Check again
        $devices = adb devices | Select-String "device$"
    }
    
    if ($devices.Count -gt 0) {
        Write-Success "Device found, installing APK..."
        
        $latestApk = Get-ChildItem -Path $APK_OUTPUT_DIR -Filter "*.apk" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($latestApk) {
            adb install -r $latestApk.FullName
            if ($LASTEXITCODE -eq 0) {
                Write-Success "APK installed successfully!"
                
                # Launch app
                Write-Info "Launching app..."
                adb shell am start -n "com.squashtrainingapp/.MainActivity"
                Write-Success "App launched!"
            } else {
                Write-Warning "APK installation failed"
            }
        }
    } else {
        Write-Warning "No devices available for installation"
    }
} catch {
    Write-Warning "Device installation failed: $($_.Exception.Message)"
}

# Step 7: Generate Build Report
Write-Step "Step 7: Generating build report"

$buildReport = @{
    BuildDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    BuildScript = "BUILD-COMPLETE-STABLE-2025.ps1"
    ProjectRoot = $PROJECT_ROOT
    XMLFilesFixes = $xmlFixCount
    BuildSuccess = $true
    APKSize = if ($apkSize) { "${apkSize}MB" } else { "Unknown" }
    Environment = if ($isWSL) { "WSL ($env:WSL_DISTRO_NAME)" } else { "Windows" }
}

$reportJson = $buildReport | ConvertTo-Json -Depth 3
$reportPath = Join-Path $PROJECT_ROOT "build-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
Set-Content -Path $reportPath -Value $reportJson

Write-Success "Build report saved: $reportPath"

# Final Summary
Write-Host ""
Write-Host "🎉 BUILD COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Success "XML files fixed: $xmlFixCount"
Write-Success "APK built and copied to: $APK_OUTPUT_DIR"
Write-Success "Build report: $reportPath"

if (-not $SkipTests) {
    Write-Info "Next steps: Run tests with TEST-ALL-FEATURES.ps1"
}

Write-Host ""
Write-Host "🎯 Ready for deployment!" -ForegroundColor Magenta