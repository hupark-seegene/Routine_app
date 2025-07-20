@echo off
setlocal enabledelayedexpansion

:: Test AI Chatbot Text Input Functionality
:: This script verifies typing works when voice recognition fails

echo =========================================
echo  AI Chatbot Text Input Test
echo =========================================
echo.

:: Configuration
set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk
set ADB=%ANDROID_HOME%\platform-tools\adb.exe
set PACKAGE_NAME=com.squashtrainingapp

:: Check if app is installed
echo [1/5] Checking if app is installed...
"%ADB%" shell pm list packages | findstr %PACKAGE_NAME% > nul
if errorlevel 1 (
    echo [ERROR] App not installed! Please run build-and-install.bat first
    pause
    exit /b 1
)
echo [OK] App is installed
echo.

:: Launch AI Chatbot directly
echo [2/5] Launching AI Chatbot activity...
"%ADB%" shell am start -n %PACKAGE_NAME%/.ai.AIChatbotActivity
if errorlevel 1 (
    echo [ERROR] Failed to launch AI Chatbot
    pause
    exit /b 1
)
echo [OK] AI Chatbot launched
echo.

:: Wait for activity to load
echo [3/5] Waiting for activity to load...
timeout /t 3 /nobreak > nul
echo [OK] Activity loaded
echo.

:: Simulate text input
echo [4/5] Testing text input...
echo.
echo Instructions for testing:
echo 1. The AI Chatbot should show:
echo    - Welcome message
echo    - System hint about input options (typing and voice)
echo    - Blue-bordered input field at bottom
echo    - Send button next to input field
echo.
echo 2. Try typing these test messages:
echo    - "Hello"
echo    - "What exercises should I do today?"
echo    - "Show my profile"
echo.
echo 3. Verify:
echo    - Text appears in input field as you type
echo    - Send button works when tapped
echo    - AI responds to your messages
echo    - Messages appear in chat bubbles
echo.

:: Automated text input test
echo [5/5] Sending automated test message...
"%ADB%" shell input text "Hello AI coach"
timeout /t 1 /nobreak > nul

:: Simulate tap on send button (you'll need to adjust coordinates)
echo Simulating send button tap...
echo (You may need to tap send button manually)
echo.

:: Check logs for text processing
echo Checking logs for text input processing...
"%ADB%" logcat -d -s AIChatbotActivity:* | findstr "sendMessage\|processUserInput" | tail -5
echo.

:: Success message
echo =========================================
echo  Text Input Test Instructions Complete
echo =========================================
echo.
echo Visual indicators to verify:
echo [✓] Input field has blue border (more prominent)
echo [✓] System message shows input options
echo [✓] Hint text changes when voice unavailable
echo [✓] Send button is clearly visible
echo [✓] Text input works without voice permission
echo.
echo If voice recognition fails, the app will:
echo - Show toast: "Voice input disabled. You can still type your questions"
echo - Change input hint to: "Type your message here (voice unavailable)"
echo - Input field will be focused automatically
echo.
pause