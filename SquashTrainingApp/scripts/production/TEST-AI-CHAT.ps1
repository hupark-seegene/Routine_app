# AI Chat Test Script

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
        $screenshotDir = "C:\Git\Routine_app\ai-test-screenshots"
        New-Item -ItemType Directory -Path $screenshotDir -Force | Out-Null
        
        # Take home screenshot
        Write-Host "Taking screenshots..." -ForegroundColor Yellow
        adb -s $deviceId shell screencap -p /sdcard/home.png
        adb -s $deviceId pull /sdcard/home.png "$screenshotDir\01_home.png"
        
        # Navigate to Coach (swipe from mascot to AI Coach zone)
        Write-Host "Navigating to Coach..." -ForegroundColor Yellow
        # First tap to dismiss any overlay
        adb -s $deviceId shell input tap 540 1200
        Start-Sleep -Milliseconds 500
        # Now navigate
        adb -s $deviceId shell input swipe 540 900 780 700 500
        Start-Sleep -Seconds 2
        adb -s $deviceId shell screencap -p /sdcard/coach.png
        adb -s $deviceId pull /sdcard/coach.png "$screenshotDir\02_coach.png"
        
        # Click Ask AI button (assuming it's at the bottom of the screen)
        Write-Host "Opening AI Chat..." -ForegroundColor Yellow
        adb -s $deviceId shell input tap 540 1600
        Start-Sleep -Seconds 2
        adb -s $deviceId shell screencap -p /sdcard/ai_chat.png
        adb -s $deviceId pull /sdcard/ai_chat.png "$screenshotDir\03_ai_chat.png"
        
        # Click on input field
        Write-Host "Sending test message..." -ForegroundColor Yellow
        adb -s $deviceId shell input tap 540 1400
        Start-Sleep -Milliseconds 500
        
        # Type message (underscores instead of spaces)
        adb -s $deviceId shell input text "How_can_I_improve_my_backhand_technique"
        
        # Click send button
        adb -s $deviceId shell input tap 980 1400
        Start-Sleep -Seconds 3
        
        # Take screenshot of response
        adb -s $deviceId shell screencap -p /sdcard/ai_response.png
        adb -s $deviceId pull /sdcard/ai_response.png "$screenshotDir\04_ai_response.png"
        
        # Send another message
        Write-Host "Sending second message..." -ForegroundColor Yellow
        adb -s $deviceId shell input tap 540 1400
        Start-Sleep -Milliseconds 500
        adb -s $deviceId shell input text "What_exercises_help_with_footwork"
        adb -s $deviceId shell input tap 980 1400
        Start-Sleep -Seconds 3
        
        # Take final screenshot
        adb -s $deviceId shell screencap -p /sdcard/ai_conversation.png
        adb -s $deviceId pull /sdcard/ai_conversation.png "$screenshotDir\05_ai_conversation.png"
        
        # Clean up
        adb -s $deviceId shell rm /sdcard/*.png
        
        Write-Host "`nAI Chat test completed!" -ForegroundColor Green
        Write-Host "Screenshots saved to: $screenshotDir" -ForegroundColor Cyan
        
        # List screenshots
        Get-ChildItem $screenshotDir -Filter "*.png" | ForEach-Object {
            Write-Host " - $($_.Name)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "No device found!" -ForegroundColor Red
    }
} else {
    Write-Host "Build failed!" -ForegroundColor Red
}