# Final AI Test - Single Device

$env:PATH = "C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools;$env:PATH"

# Get first device
$deviceLine = adb devices | Select-String "device$" | Select-Object -First 1
if ($deviceLine) {
    $device = ($deviceLine -split "`t")[0]
    Write-Host "Using device: $device" -ForegroundColor Green
    
    # Create directory
    $dir = "ai-screenshots-final"
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    
    # Screenshots with specific device
    Write-Host "Taking screenshots..." -ForegroundColor Yellow
    
    # 1. Launch and go to AI
    adb -s $device shell am start -n com.squashtrainingapp/.MainActivity
    Start-Sleep -Seconds 3
    adb -s $device shell screencap -p /sdcard/screen1.png
    adb -s $device pull /sdcard/screen1.png "$dir/01_home.png"
    
    # 2. Navigate to Coach
    adb -s $device shell input swipe 540 900 780 700 500
    Start-Sleep -Seconds 2
    adb -s $device shell screencap -p /sdcard/screen2.png
    adb -s $device pull /sdcard/screen2.png "$dir/02_coach.png"
    
    # 3. Open AI Chat
    adb -s $device shell input tap 540 1250
    Start-Sleep -Seconds 2
    adb -s $device shell screencap -p /sdcard/screen3.png
    adb -s $device pull /sdcard/screen3.png "$dir/03_ai_chat_open.png"
    
    # 4. Send message
    adb -s $device shell input tap 540 1400
    Start-Sleep -Milliseconds 500
    adb -s $device shell input text "Hello_I_need_help_with_squash"
    adb -s $device shell input tap 980 1400
    Start-Sleep -Seconds 3
    adb -s $device shell screencap -p /sdcard/screen4.png
    adb -s $device pull /sdcard/screen4.png "$dir/04_ai_response.png"
    
    # 5. Another message
    adb -s $device shell input tap 540 1400
    Start-Sleep -Milliseconds 500
    adb -s $device shell input text "How_can_I_improve_my_serve"
    adb -s $device shell input tap 980 1400
    Start-Sleep -Seconds 3
    adb -s $device shell screencap -p /sdcard/screen5.png
    adb -s $device pull /sdcard/screen5.png "$dir/05_serve_advice.png"
    
    # 6. Full conversation
    adb -s $device shell input swipe 540 1000 540 400 300
    Start-Sleep -Seconds 1
    adb -s $device shell screencap -p /sdcard/screen6.png
    adb -s $device pull /sdcard/screen6.png "$dir/06_full_chat.png"
    
    # Clean up
    adb -s $device shell rm /sdcard/screen*.png
    
    Write-Host "`nScreenshots saved!" -ForegroundColor Green
    Get-ChildItem $dir -Filter "*.png" | ForEach-Object {
        Write-Host " - $($_.Name) ($(([Math]::Round($_.Length/1KB, 2))) KB)" -ForegroundColor Cyan
    }
} else {
    Write-Host "No device found!" -ForegroundColor Red
}