# BUILD-API-INTEGRATION.ps1
# Build script for testing API integration

$ErrorActionPreference = "Stop"

# Configuration
$SCRIPT_NAME = "BUILD-API-INTEGRATION"
$BUILD_VERSION = "ddd005"
$APP_NAME = "SquashTrainingApp"
$PROJECT_ROOT = "C:\Git\Routine_app\SquashTrainingApp"
$GRADLE_PATH = "$PROJECT_ROOT\android\gradlew.bat"
$APK_OUTPUT = "$PROJECT_ROOT\android\app\build\outputs\apk\debug\app-debug.apk"

# Colors
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

# Start build process
Write-Info "`n========================================="
Write-Info " $SCRIPT_NAME - Build $BUILD_VERSION"
Write-Info " API Integration Build"
Write-Info "========================================="

# Navigate to project
Set-Location $PROJECT_ROOT

# Clean previous builds
Write-Info "`n[1/5] Cleaning previous builds..."
if (Test-Path "$PROJECT_ROOT\android\app\build") {
    Remove-Item -Path "$PROJECT_ROOT\android\app\build" -Recurse -Force
}
if (Test-Path "$PROJECT_ROOT\android\.gradle") {
    Remove-Item -Path "$PROJECT_ROOT\android\.gradle" -Recurse -Force
}

# Update version in build.gradle
Write-Info "`n[2/5] Updating version..."
$buildGradlePath = "$PROJECT_ROOT\android\app\build.gradle"
$buildGradle = Get-Content $buildGradlePath -Raw
$buildGradle = $buildGradle -replace 'versionCode \d+', "versionCode 5"
$buildGradle = $buildGradle -replace 'versionName "[^"]*"', "versionName `"1.0-$BUILD_VERSION`""
[System.IO.File]::WriteAllText($buildGradlePath, $buildGradle, [System.Text.Encoding]::UTF8)

# Build APK
Write-Info "`n[3/5] Building APK with API integration..."
Set-Location "$PROJECT_ROOT\android"
$buildStart = Get-Date

try {
    & $GRADLE_PATH assembleDebug --no-daemon --warning-mode all
    if ($LASTEXITCODE -ne 0) {
        throw "Gradle build failed"
    }
    
    $buildEnd = Get-Date
    $buildTime = ($buildEnd - $buildStart).TotalSeconds
    Write-Success "Build completed in $([math]::Round($buildTime, 1)) seconds"
} catch {
    Write-Error "Build failed: $_"
    exit 1
}

# Verify APK
Write-Info "`n[4/5] Verifying APK..."
if (Test-Path $APK_OUTPUT) {
    $apkSize = (Get-Item $APK_OUTPUT).Length / 1MB
    Write-Success "APK created successfully: $([math]::Round($apkSize, 2)) MB"
    
    # Show APK details
    Write-Info "`nAPK Details:"
    Write-Host "  - Path: $APK_OUTPUT"
    Write-Host "  - Size: $([math]::Round($apkSize, 2)) MB"
    Write-Host "  - Version: 1.0-$BUILD_VERSION"
} else {
    Write-Error "APK not found at expected location"
    exit 1
}

# Generate summary
Write-Info "`n[5/5] Build Summary"
Write-Info "==================="
Write-Success "✓ API Integration added:"
Write-Host "  - OpenAI Service"
Write-Host "  - API Key Manager (Encrypted)"
Write-Host "  - Network State Manager"
Write-Host "  - Retrofit & OkHttp"
Write-Host "  - LiveData & ViewModel"
Write-Success "✓ New Features:"
Write-Host "  - API Settings in Developer Mode"
Write-Host "  - Real-time AI Chat with OpenAI"
Write-Host "  - Network connectivity monitoring"
Write-Host "  - Secure API key storage"

Write-Info "`n========================================="
Write-Success " BUILD COMPLETED SUCCESSFULLY!"
Write-Info "========================================="
Write-Host "`nNext steps:"
Write-Host "1. Install APK: adb install `"$APK_OUTPUT`""
Write-Host "2. Enable Developer Mode: Tap version 5 times in Profile"
Write-Host "3. Configure API Key: Profile > Developer Options > API Settings"
Write-Host "4. Test AI Chat: Long press mascot for 2 seconds"

# Open output directory
explorer.exe "$PROJECT_ROOT\android\app\build\outputs\apk\debug"