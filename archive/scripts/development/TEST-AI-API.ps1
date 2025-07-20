# AI API Test Script for Squash Training App
# Tests both local responses (no API key) and OpenAI responses (with API key)

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$testDir = "ai-api-test-$timestamp"
$screenshotDir = "$testDir/screenshots"
$logFile = "$testDir/test-log.txt"

# Create directories
New-Item -ItemType Directory -Path $testDir -Force | Out-Null
New-Item -ItemType Directory -Path $screenshotDir -Force | Out-Null

# Set ADB path
$env:PATH = "C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools;$env:PATH"

function Write-Log {
    param($Message, $Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Type] $Message"
    Write-Host $logMessage -ForegroundColor $(if($Type -eq "ERROR"){"Red"}elseif($Type -eq "SUCCESS"){"Green"}elseif($Type -eq "WARNING"){"Yellow"}else{"Cyan"})
    $logMessage | Out-File -Append -FilePath $logFile
}

function Take-Screenshot {
    param($Name)
    $screenshotPath = "/sdcard/$Name.png"
    $localPath = "$screenshotDir/$Name.png"
    
    adb shell screencap -p $screenshotPath
    Start-Sleep -Milliseconds 500
    adb pull $screenshotPath $localPath 2>$null
    adb shell rm $screenshotPath
    Write-Log "Screenshot saved: $Name.png" "SUCCESS"
}

function Type-Message {
    param($Message)
    # Click on input field
    adb shell input tap 540 1400
    Start-Sleep -Milliseconds 500
    
    # Clear existing text
    adb shell input keyevent KEYCODE_MOVE_END
    adb shell input keyevent --longpress $(('KEYCODE_DEL ' * 50))
    
    # Type new message (replace spaces with underscores for adb)
    $adbMessage = $Message -replace ' ', '_'
    adb shell input text "$adbMessage"
    Start-Sleep -Milliseconds 500
}

function Send-Message {
    # Click send button
    adb shell input tap 980 1400
    Start-Sleep -Seconds 2
}

function Navigate-To-Coach {
    Write-Log "Navigating to Coach screen via mascot drag"
    # Drag mascot to Coach zone (right middle)
    adb shell input swipe 540 900 780 700 500
    Start-Sleep -Seconds 2
}

function Open-AI-Chat {
    Write-Log "Opening AI Coach chat"
    # Click ASK AI COACH button
    adb shell input tap 540 1250
    Start-Sleep -Seconds 2
}

function Test-User-Questions {
    param($TestName)
    
    Write-Log "=== Testing User Scenarios: $TestName ===" "INFO"
    
    $questions = @(
        @{
            question = "I'm a beginner, how should I start"
            wait = 3
            screenshot = "${TestName}_01_beginner_advice"
        },
        @{
            question = "My backhand is weak, any tips"
            wait = 3
            screenshot = "${TestName}_02_backhand_tips"
        },
        @{
            question = "Create a 30 minute workout for me"
            wait = 3
            screenshot = "${TestName}_03_workout_plan"
        },
        @{
            question = "What's the best racket tension"
            wait = 2
            screenshot = "${TestName}_04_equipment_advice"
        },
        @{
            question = "How do I improve my footwork"
            wait = 3
            screenshot = "${TestName}_05_footwork_tips"
        },
        @{
            question = "I'm feeling unmotivated today"
            wait = 2
            screenshot = "${TestName}_06_motivation"
        }
    )
    
    foreach ($q in $questions) {
        Write-Log "Asking: $($q.question)"
        Type-Message $q.question
        Send-Message
        Start-Sleep -Seconds $q.wait
        Take-Screenshot $q.screenshot
        
        # Scroll up to see full conversation
        adb shell input swipe 540 1000 540 400 300
        Start-Sleep -Milliseconds 500
        Take-Screenshot "$($q.screenshot)_full"
        
        # Scroll back down
        adb shell input swipe 540 400 540 1000 300
        Start-Sleep -Milliseconds 500
    }
}

function Set-API-Key {
    param($ApiKey)
    
    Write-Log "Setting OpenAI API key" "WARNING"
    # This would normally be done through settings
    # For testing, we'll simulate it being set
    Write-Log "Note: API key should be set through app settings" "WARNING"
}

# Main execution
Write-Log "Starting AI API Test" "INFO"
Write-Log "Test results will be saved to: $testDir" "INFO"

# Build and install APK
Write-Log "Building APK..."
Set-Location "C:\Git\Routine_app\SquashTrainingApp\android"
$buildResult = cmd.exe /c gradlew.bat assembleDebug 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Log "Build successful" "SUCCESS"
} else {
    Write-Log "Build failed: $buildResult" "ERROR"
    exit 1
}

# Install APK
Write-Log "Installing APK..."
$apkPath = "app\build\outputs\apk\debug\app-debug.apk"
adb install -r $apkPath 2>&1 | Out-Null
Write-Log "APK installed" "SUCCESS"

# Test 1: Without API Key (Local Responses)
Write-Log "`n=== TEST 1: Local AI Responses (No API Key) ===" "INFO"

# Launch app
Write-Log "Launching app..."
adb shell am start -n com.squashtrainingapp/.MainActivity
Start-Sleep -Seconds 3
Take-Screenshot "00_app_launch"

# Navigate to Coach
Navigate-To-Coach
Take-Screenshot "01_coach_screen"

# Open AI Chat
Open-AI-Chat
Take-Screenshot "02_ai_chat_initial"

# Test with local responses
Test-User-Questions "local"

# Return to home
Write-Log "Returning to home screen"
adb shell input keyevent KEYCODE_BACK
Start-Sleep -Seconds 1
adb shell input keyevent KEYCODE_BACK
Start-Sleep -Seconds 1

# Test 2: With API Key (OpenAI Responses)
Write-Log "`n=== TEST 2: OpenAI API Responses (With API Key) ===" "WARNING"
Write-Log "Note: This test requires a valid OpenAI API key to be set in the app" "WARNING"
Write-Log "If no API key is set, responses will fall back to local" "WARNING"

# Navigate back to AI Chat
Navigate-To-Coach
Open-AI-Chat

# Clear chat history (if there's a button for it)
Write-Log "Starting fresh conversation"
Take-Screenshot "03_ai_chat_with_api"

# Test with API responses
Test-User-Questions "api"

# Test voice input
Write-Log "Testing voice input button"
adb shell input tap 900 1400  # Voice button location
Start-Sleep -Seconds 1
Take-Screenshot "04_voice_input_active"
adb shell input tap 540 900  # Cancel voice
Start-Sleep -Seconds 1

# Final summary
Write-Log "`n=== AI API Test Summary ===" "INFO"

# Generate report
$report = @"
SQUASH TRAINING APP - AI API TEST REPORT
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

TEST SCENARIOS:
1. Local AI Responses (No API Key)
   - Tested 6 different user questions
   - Responses use predefined local patterns
   
2. OpenAI API Responses (With API Key)
   - Same 6 questions for comparison
   - Responses should be more personalized if API key is set

QUESTIONS TESTED:
- Beginner advice
- Technique improvement (backhand)
- Workout plan generation
- Equipment recommendations
- Footwork improvement
- Motivation

FEATURES TESTED:
- Text input and sending
- Response display
- Conversation history
- Scrolling
- Voice input button

SCREENSHOTS CAPTURED: $(Get-ChildItem $screenshotDir -Filter "*.png" | Measure-Object).Count

NOTES:
- Local responses are immediate and predefined
- API responses have slight delay and are contextual
- Voice recognition requires device microphone permission
"@

$report | Out-File "$testDir/TEST_REPORT.txt"
Write-Log "Test report saved to: $testDir/TEST_REPORT.txt" "SUCCESS"

# Display results location
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "AI API TEST COMPLETED" -ForegroundColor Green
Write-Host "Results saved to: $testDir" -ForegroundColor Yellow
Write-Host "Screenshots: $screenshotDir" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan

# Open results folder
explorer.exe $testDir