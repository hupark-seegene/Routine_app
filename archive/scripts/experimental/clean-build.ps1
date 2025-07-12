# PowerShell script to clean all React Native build caches
Write-Host "🧹 Starting complete React Native clean..." -ForegroundColor Green

# 1. Kill any running Metro bundler processes
Write-Host "`n📦 Stopping Metro bundler..." -ForegroundColor Yellow
Get-Process node -ErrorAction SilentlyContinue | Where-Object {$_.Path -like "*react-native*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# 2. Clear Metro bundler cache
Write-Host "`n🗑️ Clearing Metro bundler cache..." -ForegroundColor Yellow
npx react-native start --reset-cache --max-workers=1 &
Start-Sleep -Seconds 3
Get-Process node -ErrorAction SilentlyContinue | Where-Object {$_.Path -like "*react-native*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# 3. Delete node_modules cache
Write-Host "`n🗑️ Clearing node_modules cache..." -ForegroundColor Yellow
if (Test-Path "node_modules\.cache") {
    Remove-Item -Path "node_modules\.cache" -Recurse -Force
}

# 4. Clean Android build
Write-Host "`n🤖 Cleaning Android build..." -ForegroundColor Yellow
if (Test-Path "android\app\build") {
    Remove-Item -Path "android\app\build" -Recurse -Force
}
if (Test-Path "android\build") {
    Remove-Item -Path "android\build" -Recurse -Force
}
if (Test-Path "android\.gradle") {
    Remove-Item -Path "android\.gradle" -Recurse -Force
}

# 5. Remove old JavaScript bundle
Write-Host "`n📄 Removing old JavaScript bundle..." -ForegroundColor Yellow
if (Test-Path "android\app\src\main\assets\index.android.bundle") {
    Remove-Item -Path "android\app\src\main\assets\index.android.bundle" -Force
}

# 6. Clean gradle cache
Write-Host "`n🏗️ Running gradle clean..." -ForegroundColor Yellow
Set-Location android
.\gradlew.bat clean
Set-Location ..

Write-Host "`n✅ Clean complete! Now you can rebuild:" -ForegroundColor Green
Write-Host "   cd android" -ForegroundColor Cyan
Write-Host "   .\gradlew.bat assembleDebug" -ForegroundColor Cyan
Write-Host "`n💡 Tip: Run Metro bundler separately with:" -ForegroundColor Yellow
Write-Host "   npx react-native start" -ForegroundColor Cyan