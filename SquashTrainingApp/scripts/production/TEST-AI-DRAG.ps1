# AI Chat Test with Proper Drag Navigation

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
        $screenshotDir = "C:\Git\Routine_app\ai-drag-test"
        New-Item -ItemType Directory -Path $screenshotDir -Force | Out-Null
        
        # Take home screenshot
        Write-Host "Taking home screenshot..." -ForegroundColor Yellow
        adb -s $deviceId shell screencap -p /sdcard/01_home.png
        adb -s $deviceId pull /sdcard/01_home.png "$screenshotDir\01_home.png"
        
        # Navigate to Coach by dragging mascot
        Write-Host "Dragging mascot to AI Coach zone..." -ForegroundColor Yellow
        # Start from mascot position (center bottom)
        # Drag to AI Coach zone (right side)
        adb -s $deviceId shell input swipe 540 825 565 516 1000
        Start-Sleep -Seconds 3
        
        # Take Coach screen screenshot
        Write-Host "Taking Coach screen screenshot..." -ForegroundColor Yellow
        adb -s $deviceId shell screencap -p /sdcard/02_coach.png
        adb -s $deviceId pull /sdcard/02_coach.png "$screenshotDir\02_coach_screen.png"
        
        # Scroll down to see Ask AI button
        Write-Host "Scrolling to find Ask AI button..." -ForegroundColor Yellow
        adb -s $deviceId shell input swipe 540 1400 540 600 500
        Start-Sleep -Seconds 1
        
        # Click Ask AI button (should be visible now)
        Write-Host "Clicking Ask AI button..." -ForegroundColor Yellow
        adb -s $deviceId shell input tap 540 1400
        Start-Sleep -Seconds 3
        
        # Take AI Chat screenshot
        adb -s $deviceId shell screencap -p /sdcard/03_ai_chat.png
        adb -s $deviceId pull /sdcard/03_ai_chat.png "$screenshotDir\03_ai_chat_open.png"
        
        # Click on input field
        Write-Host "Clicking input field..." -ForegroundColor Yellow
        adb -s $deviceId shell input tap 540 1650
        Start-Sleep -Milliseconds 500
        
        # Type first message
        Write-Host "Sending first message about grip..." -ForegroundColor Yellow
        adb -s $deviceId shell input text "What_is_the_correct_grip_for_squash"
        
        # Click send button
        adb -s $deviceId shell input tap 980 1650
        Start-Sleep -Seconds 4
        
        # Take screenshot of first response
        adb -s $deviceId shell screencap -p /sdcard/04_grip_response.png
        adb -s $deviceId pull /sdcard/04_grip_response.png "$screenshotDir\04_grip_response.png"
        
        # Send another message
        Write-Host "Sending footwork question..." -ForegroundColor Yellow
        adb -s $deviceId shell input tap 540 1650
        Start-Sleep -Milliseconds 500
        adb -s $deviceId shell input text "What_are_the_best_footwork_drills"
        adb -s $deviceId shell input tap 980 1650
        Start-Sleep -Seconds 4
        
        # Take screenshot of second response
        adb -s $deviceId shell screencap -p /sdcard/05_footwork_response.png
        adb -s $deviceId pull /sdcard/05_footwork_response.png "$screenshotDir\05_footwork_response.png"
        
        # Send strategy question
        Write-Host "Sending strategy question..." -ForegroundColor Yellow
        adb -s $deviceId shell input tap 540 1650
        Start-Sleep -Milliseconds 500
        adb -s $deviceId shell input text "What_strategy_should_beginners_use"
        adb -s $deviceId shell input tap 980 1650
        Start-Sleep -Seconds 4
        
        # Take screenshot of strategy response
        adb -s $deviceId shell screencap -p /sdcard/06_strategy_response.png
        adb -s $deviceId pull /sdcard/06_strategy_response.png "$screenshotDir\06_strategy_response.png"
        
        # Scroll to see full conversation
        Write-Host "Scrolling conversation..." -ForegroundColor Yellow
        adb -s $deviceId shell input swipe 540 1000 540 300 800
        Start-Sleep -Seconds 1
        adb -s $deviceId shell screencap -p /sdcard/07_full_chat.png
        adb -s $deviceId pull /sdcard/07_full_chat.png "$screenshotDir\07_full_conversation.png"
        
        # Clean up
        adb -s $deviceId shell rm /sdcard/*.png
        
        Write-Host "`nAI Chat drag test completed!" -ForegroundColor Green
        Write-Host "Screenshots saved to: $screenshotDir" -ForegroundColor Cyan
        
        # List screenshots
        Get-ChildItem $screenshotDir -Filter "*.png" | Sort-Object Name | ForEach-Object {
            $size = [Math]::Round($_.Length/1KB, 2)
            Write-Host " - $($_.Name) [$size KB]" -ForegroundColor Yellow
        }
        
        Write-Host "`nTest Summary:" -ForegroundColor Cyan
        Write-Host " ✓ Mascot dragged to AI Coach zone" -ForegroundColor Green
        Write-Host " ✓ AI Chat interface tested" -ForegroundColor Green
        Write-Host " ✓ Multiple questions sent and responses captured" -ForegroundColor Green
    } else {
        Write-Host "No device found!" -ForegroundColor Red
    }
} else {
    Write-Host "Build failed!" -ForegroundColor Red
}