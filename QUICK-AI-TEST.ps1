# Quick AI Test Script - Manual approach

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$screenshotDir = "ai-test-screenshots-$timestamp"
New-Item -ItemType Directory -Path $screenshotDir -Force | Out-Null

Write-Host "[INFO] Quick AI Test - Capturing screenshots" -ForegroundColor Green
Write-Host "[INFO] Screenshots will be saved to: $screenshotDir" -ForegroundColor Yellow

# Function to take screenshot with specific device
function Take-Screenshot {
    param($Name)
    Write-Host "Taking screenshot: $Name" -ForegroundColor Cyan
    
    # Get device list
    $devices = adb devices | Select-String "emulator"
    if ($devices) {
        $deviceId = ($devices[0] -split "`t")[0]
        adb -s $deviceId shell screencap -p /sdcard/$Name.png
        adb -s $deviceId pull /sdcard/$Name.png "$screenshotDir/$Name.png" 2>$null
        adb -s $deviceId shell rm /sdcard/$Name.png
        Write-Host "Screenshot saved: $Name.png" -ForegroundColor Green
    } else {
        Write-Host "No emulator found!" -ForegroundColor Red
    }
}

# Get specific device
$devices = adb devices | Select-String "emulator"
if ($devices) {
    $deviceId = ($devices[0] -split "`t")[0]
    Write-Host "Using device: $deviceId" -ForegroundColor Green
    
    # Launch app
    Write-Host "`n[1] Launching app..." -ForegroundColor Yellow
    adb -s $deviceId shell am start -n com.squashtrainingapp/.MainActivity
    Start-Sleep -Seconds 3
    Take-Screenshot "01_app_home"
    
    # Navigate to Coach
    Write-Host "`n[2] Navigating to Coach screen..." -ForegroundColor Yellow
    adb -s $deviceId shell input swipe 540 900 780 700 500
    Start-Sleep -Seconds 2
    Take-Screenshot "02_coach_screen"
    
    # Open AI Chat
    Write-Host "`n[3] Opening AI Coach chat..." -ForegroundColor Yellow
    adb -s $deviceId shell input tap 540 1250
    Start-Sleep -Seconds 2
    Take-Screenshot "03_ai_chat_initial"
    
    # Send first message
    Write-Host "`n[4] Sending message: 'Hello coach'" -ForegroundColor Yellow
    adb -s $deviceId shell input tap 540 1400
    Start-Sleep -Milliseconds 500
    adb -s $deviceId shell input text "Hello_coach"
    Start-Sleep -Milliseconds 500
    adb -s $deviceId shell input tap 980 1400
    Start-Sleep -Seconds 2
    Take-Screenshot "04_ai_response_1"
    
    # Send second message
    Write-Host "`n[5] Sending message: 'I need help with my backhand'" -ForegroundColor Yellow
    adb -s $deviceId shell input tap 540 1400
    Start-Sleep -Milliseconds 500
    adb -s $deviceId shell input text "I_need_help_with_my_backhand"
    Start-Sleep -Milliseconds 500
    adb -s $deviceId shell input tap 980 1400
    Start-Sleep -Seconds 2
    Take-Screenshot "05_ai_response_2"
    
    # Send third message
    Write-Host "`n[6] Sending message: 'What exercises should I do'" -ForegroundColor Yellow
    adb -s $deviceId shell input tap 540 1400
    Start-Sleep -Milliseconds 500
    adb -s $deviceId shell input text "What_exercises_should_I_do"
    Start-Sleep -Milliseconds 500
    adb -s $deviceId shell input tap 980 1400
    Start-Sleep -Seconds 2
    Take-Screenshot "06_ai_response_3"
    
    # Scroll to see full conversation
    Write-Host "`n[7] Scrolling to see full conversation..." -ForegroundColor Yellow
    adb -s $deviceId shell input swipe 540 1000 540 400 500
    Start-Sleep -Seconds 1
    Take-Screenshot "07_conversation_full"
    
    # Test voice button
    Write-Host "`n[8] Testing voice input button..." -ForegroundColor Yellow
    adb -s $deviceId shell input tap 900 1400
    Start-Sleep -Seconds 1
    Take-Screenshot "08_voice_active"
    
    Write-Host "`n[SUCCESS] AI Test completed!" -ForegroundColor Green
    Write-Host "Screenshots saved to: $screenshotDir" -ForegroundColor Yellow
    
    # Open folder
    explorer.exe $screenshotDir
} else {
    Write-Host "[ERROR] No emulator found!" -ForegroundColor Red
    Write-Host "Please start an emulator first." -ForegroundColor Yellow
}