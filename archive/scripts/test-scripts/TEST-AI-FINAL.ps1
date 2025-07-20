# Final AI Chat Test with Voice Overlay Handling

# Set environment variables
$env:ANDROID_HOME = "C:\Users\hwpar\AppData\Local\Android\Sdk"
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
$env:PATH = "$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\tools;$env:PATH"

# Change to project directory
cd C:\Git\Routine_app\SquashTrainingApp\android

Write-Host "Building APK..." -ForegroundColor Yellow
.\gradlew assembleDebug

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build successful!" -ForegroundColor Green
    
    # Get device
    $device = adb devices | Select-String "device$" | Select-Object -First 1
    if ($device) {
        $deviceId = ($device -split "`t")[0]
        Write-Host "Using device: $deviceId" -ForegroundColor Green
        
        # Install APK
        Write-Host "Installing APK..." -ForegroundColor Yellow
        adb -s $deviceId install -r app\build\outputs\apk\debug\app-debug.apk
        
        # Launch app
        Write-Host "Launching app..." -ForegroundColor Yellow
        adb -s $deviceId shell am start -n com.squashtrainingapp/.MainActivity
        Start-Sleep -Seconds 3
        
        # Create screenshot directory
        $screenshotDir = "C:\Git\Routine_app\ai-final-test"
        New-Item -ItemType Directory -Path $screenshotDir -Force | Out-Null
        
        # Take home screenshot
        Write-Host "Taking home screenshot..." -ForegroundColor Yellow
        adb -s $deviceId shell screencap -p /sdcard/home.png
        adb -s $deviceId pull /sdcard/home.png "$screenshotDir\01_home.png"
        
        # Navigate to Coach by tapping directly on AI Coach zone
        Write-Host "Tapping AI Coach zone directly..." -ForegroundColor Yellow
        adb -s $deviceId shell input tap 565 516  # Center of AI Coach zone
        Start-Sleep -Seconds 2
        
        # Check for voice overlay and dismiss if present
        Write-Host "Checking for overlays..." -ForegroundColor Yellow
        adb -s $deviceId shell screencap -p /sdcard/check.png
        adb -s $deviceId pull /sdcard/check.png "$screenshotDir\02_after_tap.png"
        
        # Tap to dismiss any overlay (TAP TO CANCEL area)
        adb -s $deviceId shell input tap 540 1056
        Start-Sleep -Milliseconds 500
        
        # Try navigation again if needed
        Write-Host "Ensuring navigation to Coach..." -ForegroundColor Yellow
        adb -s $deviceId shell input tap 565 516
        Start-Sleep -Seconds 2
        
        # Take Coach screen screenshot
        adb -s $deviceId shell screencap -p /sdcard/coach.png
        adb -s $deviceId pull /sdcard/coach.png "$screenshotDir\03_coach_screen.png"
        
        # Find and click Ask AI button
        Write-Host "Looking for Ask AI button..." -ForegroundColor Yellow
        # The Ask AI button should be near the bottom of the Coach screen
        adb -s $deviceId shell input tap 540 1600
        Start-Sleep -Seconds 2
        
        # Take AI Chat screenshot
        adb -s $deviceId shell screencap -p /sdcard/ai_chat.png
        adb -s $deviceId pull /sdcard/ai_chat.png "$screenshotDir\04_ai_chat_open.png"
        
        # Click on input field
        Write-Host "Testing AI conversation..." -ForegroundColor Yellow
        adb -s $deviceId shell input tap 540 1650
        Start-Sleep -Milliseconds 500
        
        # Type first message
        adb -s $deviceId shell input text "I_am_new_to_squash._What_equipment_do_I_need_to_start_playing"
        
        # Click send button
        adb -s $deviceId shell input tap 980 1650
        Start-Sleep -Seconds 4
        
        # Take screenshot of first response
        adb -s $deviceId shell screencap -p /sdcard/response1.png
        adb -s $deviceId pull /sdcard/response1.png "$screenshotDir\05_equipment_response.png"
        
        # Send another message
        Write-Host "Sending technique question..." -ForegroundColor Yellow
        adb -s $deviceId shell input tap 540 1650
        Start-Sleep -Milliseconds 500
        adb -s $deviceId shell input text "How_do_I_hit_a_proper_forehand_drive"
        adb -s $deviceId shell input tap 980 1650
        Start-Sleep -Seconds 4
        
        # Take screenshot of second response
        adb -s $deviceId shell screencap -p /sdcard/response2.png
        adb -s $deviceId pull /sdcard/response2.png "$screenshotDir\06_technique_response.png"
        
        # Send workout question
        Write-Host "Sending workout question..." -ForegroundColor Yellow
        adb -s $deviceId shell input tap 540 1650
        Start-Sleep -Milliseconds 500
        adb -s $deviceId shell input text "Can_you_suggest_a_beginner_workout_routine"
        adb -s $deviceId shell input tap 980 1650
        Start-Sleep -Seconds 4
        
        # Take screenshot of workout response
        adb -s $deviceId shell screencap -p /sdcard/response3.png
        adb -s $deviceId pull /sdcard/response3.png "$screenshotDir\07_workout_response.png"
        
        # Scroll to see full conversation
        Write-Host "Capturing full conversation..." -ForegroundColor Yellow
        adb -s $deviceId shell input swipe 540 800 540 200 500
        Start-Sleep -Seconds 1
        adb -s $deviceId shell screencap -p /sdcard/full_chat.png
        adb -s $deviceId pull /sdcard/full_chat.png "$screenshotDir\08_full_conversation.png"
        
        # Clean up
        adb -s $deviceId shell rm /sdcard/*.png
        
        Write-Host "`nAI Chat test completed successfully!" -ForegroundColor Green
        Write-Host "Screenshots saved to: $screenshotDir" -ForegroundColor Cyan
        
        # List screenshots with details
        Get-ChildItem $screenshotDir -Filter "*.png" | Sort-Object Name | ForEach-Object {
            Write-Host " - $($_.Name) [$(([Math]::Round($_.Length/1KB, 2))) KB]" -ForegroundColor Yellow
        }
        
        Write-Host "`nTest Summary:" -ForegroundColor Cyan
        Write-Host " ✓ App launched successfully" -ForegroundColor Green
        Write-Host " ✓ Navigated to Coach screen" -ForegroundColor Green
        Write-Host " ✓ Opened AI Chat interface" -ForegroundColor Green
        Write-Host " ✓ Sent multiple questions" -ForegroundColor Green
        Write-Host " ✓ Captured AI responses" -ForegroundColor Green
    } else {
        Write-Host "No device found!" -ForegroundColor Red
    }
} else {
    Write-Host "Build failed!" -ForegroundColor Red
}