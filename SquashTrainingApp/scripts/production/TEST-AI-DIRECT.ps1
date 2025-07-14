# Direct AI Chat Test Script

# Set environment variables
$env:ANDROID_HOME = "C:\Users\hwpar\AppData\Local\Android\Sdk"
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:PATH = "$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\tools;$env:PATH"

# Get device
$device = adb devices | Select-String "device$" | Select-Object -First 1
if ($device) {
    $deviceId = ($device -split "`t")[0]
    Write-Host "Using device: $deviceId" -ForegroundColor Green
    
    # Create screenshot directory
    $screenshotDir = "C:\Git\Routine_app\ai-chat-direct"
    New-Item -ItemType Directory -Path $screenshotDir -Force | Out-Null
    
    # Launch AI Chat directly
    Write-Host "Launching AI Chat directly..." -ForegroundColor Yellow
    adb -s $deviceId shell am start -n com.squashtrainingapp/.ai.AIChatbotActivity
    Start-Sleep -Seconds 3
    
    # Take initial screenshot
    Write-Host "Taking initial screenshot..." -ForegroundColor Yellow
    adb -s $deviceId shell screencap -p /sdcard/ai_chat_open.png
    adb -s $deviceId pull /sdcard/ai_chat_open.png "$screenshotDir\01_ai_chat_open.png"
    
    # Click on input field at bottom
    Write-Host "Clicking input field..." -ForegroundColor Yellow
    adb -s $deviceId shell input tap 540 1650
    Start-Sleep -Milliseconds 500
    
    # Type first message
    Write-Host "Sending first message..." -ForegroundColor Yellow
    adb -s $deviceId shell input text "Hello,_I_am_a_beginner_at_squash._What_should_I_focus_on_first"
    
    # Click send button (assuming it's to the right of input)
    adb -s $deviceId shell input tap 980 1650
    Start-Sleep -Seconds 3
    
    # Take screenshot of first response
    adb -s $deviceId shell screencap -p /sdcard/ai_response1.png
    adb -s $deviceId pull /sdcard/ai_response1.png "$screenshotDir\02_first_response.png"
    
    # Send second message
    Write-Host "Sending second message..." -ForegroundColor Yellow
    adb -s $deviceId shell input tap 540 1650
    Start-Sleep -Milliseconds 500
    adb -s $deviceId shell input text "Can_you_show_me_some_basic_drills"
    adb -s $deviceId shell input tap 980 1650
    Start-Sleep -Seconds 3
    
    # Take screenshot of second response
    adb -s $deviceId shell screencap -p /sdcard/ai_response2.png
    adb -s $deviceId pull /sdcard/ai_response2.png "$screenshotDir\03_second_response.png"
    
    # Send third message about technique
    Write-Host "Sending third message..." -ForegroundColor Yellow
    adb -s $deviceId shell input tap 540 1650
    Start-Sleep -Milliseconds 500
    adb -s $deviceId shell input text "How_do_I_improve_my_backhand_technique"
    adb -s $deviceId shell input tap 980 1650
    Start-Sleep -Seconds 3
    
    # Take screenshot of third response
    adb -s $deviceId shell screencap -p /sdcard/ai_response3.png
    adb -s $deviceId pull /sdcard/ai_response3.png "$screenshotDir\04_technique_response.png"
    
    # Scroll up to see full conversation
    Write-Host "Scrolling to see conversation..." -ForegroundColor Yellow
    adb -s $deviceId shell input swipe 540 1000 540 400 500
    Start-Sleep -Seconds 1
    
    # Take final screenshot
    adb -s $deviceId shell screencap -p /sdcard/ai_conversation.png
    adb -s $deviceId pull /sdcard/ai_conversation.png "$screenshotDir\05_full_conversation.png"
    
    # Clean up
    adb -s $deviceId shell rm /sdcard/*.png
    
    Write-Host "`nDirect AI Chat test completed!" -ForegroundColor Green
    Write-Host "Screenshots saved to: $screenshotDir" -ForegroundColor Cyan
    
    # List screenshots
    Get-ChildItem $screenshotDir -Filter "*.png" | ForEach-Object {
        Write-Host " - $($_.Name) [$(([Math]::Round($_.Length/1KB, 2))) KB]" -ForegroundColor Yellow
    }
} else {
    Write-Host "No device found!" -ForegroundColor Red
}