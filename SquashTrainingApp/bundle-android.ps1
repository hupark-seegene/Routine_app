# PowerShell script to generate JavaScript bundle for Android
Write-Host "📦 Generating JavaScript bundle for Android..." -ForegroundColor Green

# Create assets directory if it doesn't exist
$assetsDir = "android\app\src\main\assets"
if (!(Test-Path $assetsDir)) {
    Write-Host "📁 Creating assets directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
}

# Remove old bundle if exists
$bundlePath = "$assetsDir\index.android.bundle"
if (Test-Path $bundlePath) {
    Write-Host "🗑️ Removing old bundle..." -ForegroundColor Yellow
    Remove-Item $bundlePath -Force
}

# Generate new bundle
Write-Host "🚀 Building JavaScript bundle..." -ForegroundColor Cyan
npx react-native bundle --platform android --dev false --entry-file index.js --bundle-output android/app/src/main/assets/index.android.bundle --assets-dest android/app/src/main/res/

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Bundle generated successfully!" -ForegroundColor Green
    Write-Host "📍 Bundle location: $bundlePath" -ForegroundColor Gray
    
    # Get bundle size
    if (Test-Path $bundlePath) {
        $size = (Get-Item $bundlePath).Length / 1MB
        Write-Host "📊 Bundle size: $([math]::Round($size, 2)) MB" -ForegroundColor Gray
    }
    
    Write-Host "`n💡 Next step: Build the APK with:" -ForegroundColor Yellow
    Write-Host "   cd android" -ForegroundColor Cyan
    Write-Host "   .\gradlew.bat assembleDebug" -ForegroundColor Cyan
} else {
    Write-Host "`n❌ Bundle generation failed!" -ForegroundColor Red
    exit 1
}