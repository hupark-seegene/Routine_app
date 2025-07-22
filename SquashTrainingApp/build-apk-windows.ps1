# PowerShell script to build APK on Windows
# Created: 2025-07-22

Write-Host "========================================"
Write-Host "   Squash Training App - APK Builder"
Write-Host "   Version: 2025.07.22"
Write-Host "========================================"
Write-Host ""

# Set project root
$PROJECT_ROOT = Get-Location
$ANDROID_DIR = Join-Path $PROJECT_ROOT "android"

# Navigate to project directory
Set-Location $PROJECT_ROOT

Write-Host "📦 Creating JavaScript bundle..." -ForegroundColor Yellow
$bundleResult = & npx react-native bundle `
    --platform android `
    --dev false `
    --entry-file index.js `
    --bundle-output android/app/src/main/assets/index.android.bundle `
    --assets-dest android/app/src/main/res/ 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Bundle creation failed!" -ForegroundColor Red
    Write-Host $bundleResult
    exit 1
}

Write-Host "✅ Bundle created successfully" -ForegroundColor Green
Write-Host ""

# Navigate to android directory
Set-Location $ANDROID_DIR

Write-Host "🔨 Building APK..." -ForegroundColor Yellow
Write-Host "This may take several minutes..."

# Clean build directories
Write-Host "Cleaning build directories..." -ForegroundColor Cyan
& .\gradlew.bat clean

# Build debug APK
Write-Host "Building debug APK..." -ForegroundColor Cyan
& .\gradlew.bat assembleDebug

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ APK build failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Build completed successfully!" -ForegroundColor Green
Write-Host ""

# Copy APK to output directory
$OUTPUT_DIR = Join-Path $PROJECT_ROOT "apk-output"
New-Item -ItemType Directory -Force -Path $OUTPUT_DIR | Out-Null

$APK_PATH = Join-Path $ANDROID_DIR "app\build\outputs\apk\debug\app-debug.apk"
if (Test-Path $APK_PATH) {
    $TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"
    $NEW_NAME = "SquashTrainingApp_$TIMESTAMP.apk"
    $DEST_PATH = Join-Path $OUTPUT_DIR $NEW_NAME
    
    Copy-Item $APK_PATH $DEST_PATH
    
    $APK_SIZE = (Get-Item $APK_PATH).Length / 1MB
    Write-Host "📱 APK saved to: $DEST_PATH" -ForegroundColor Green
    Write-Host "📊 APK size: $([math]::Round($APK_SIZE, 2)) MB" -ForegroundColor Cyan
} else {
    Write-Host "❌ APK file not found at expected location" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎉 Build process completed!" -ForegroundColor Green
Write-Host "📍 APK location: $DEST_PATH" -ForegroundColor Yellow

# Return to project root
Set-Location $PROJECT_ROOT