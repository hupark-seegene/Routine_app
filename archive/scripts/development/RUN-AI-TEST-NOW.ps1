# AI Test with proper setup

# Set ADB path
$env:PATH = "C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools;$env:PATH"

# Create screenshot directory
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$screenshotDir = "ai-test-$timestamp"
New-Item -ItemType Directory -Path $screenshotDir -Force | Out-Null

Write-Host "AI API Test Starting..." -ForegroundColor Green

# Check devices
$devices = adb devices
Write-Host "Available devices:" -ForegroundColor Yellow
Write-Host $devices

# Take screenshot function
function Screenshot {
    param($name)
    adb exec-out screencap -p > "$screenshotDir\$name.png"
    Write-Host "Screenshot: $name.png" -ForegroundColor Green
}

# Launch app
Write-Host "`nLaunching app..." -ForegroundColor Cyan
adb shell am start -n com.squashtrainingapp/.MainActivity
Start-Sleep -Seconds 3
Screenshot "01_home"

# Go to Coach
Write-Host "Going to Coach..." -ForegroundColor Cyan
adb shell input swipe 540 900 780 700 500
Start-Sleep -Seconds 2
Screenshot "02_coach"

# Open AI Chat
Write-Host "Opening AI Chat..." -ForegroundColor Cyan
adb shell input tap 540 1250
Start-Sleep -Seconds 2
Screenshot "03_ai_chat"

# Type and send messages
Write-Host "Testing conversation..." -ForegroundColor Cyan

# Message 1
adb shell input tap 540 1400
Start-Sleep -Milliseconds 300
adb shell input text "Hello"
adb shell input tap 980 1400
Start-Sleep -Seconds 2
Screenshot "04_hello_response"

# Message 2  
adb shell input tap 540 1400
Start-Sleep -Milliseconds 300
adb shell input text "I_am_beginner"
adb shell input tap 980 1400
Start-Sleep -Seconds 2
Screenshot "05_beginner_response"

# Message 3
adb shell input tap 540 1400
Start-Sleep -Milliseconds 300
adb shell input text "Give_me_tips"
adb shell input tap 980 1400
Start-Sleep -Seconds 2
Screenshot "06_tips_response"

# Scroll up to see conversation
adb shell input swipe 540 1000 540 400 300
Start-Sleep -Seconds 1
Screenshot "07_full_conversation"

Write-Host "`nTest Complete!" -ForegroundColor Green
Write-Host "Screenshots saved to: $screenshotDir" -ForegroundColor Yellow

# List screenshots
Get-ChildItem $screenshotDir -Filter "*.png" | ForEach-Object {
    Write-Host " - $($_.Name)" -ForegroundColor Gray
}

# Open folder
explorer.exe $screenshotDir