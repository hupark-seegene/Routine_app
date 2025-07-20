@echo off
setlocal enabledelayedexpansion

:: SquashTrainingApp APK Installer and Runner
:: This script installs and runs the app on Android emulator or device

echo =========================================
echo  SquashTrainingApp APK Installer
echo =========================================
echo.

:: Configuration
set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk
set ADB=%ANDROID_HOME%\platform-tools\adb.exe
set APK_PATH=SquashTrainingApp\android\app\build\outputs\apk\debug\app-debug.apk
set PACKAGE_NAME=com.squashtrainingapp
set MAIN_ACTIVITY=.MainActivity

:: Check if ADB exists
if not exist "%ADB%" (
    echo [ERROR] ADB not found at: %ADB%
    echo Please install Android SDK or update ANDROID_HOME
    pause
    exit /b 1
)

:: Check if APK exists
if not exist "%APK_PATH%" (
    echo [ERROR] APK not found at: %APK_PATH%
    echo Please build the app first using:
    echo   cd SquashTrainingApp\android
    echo   gradlew.bat assembleDebug
    pause
    exit /b 1
)

:: Get APK file size
for %%A in ("%APK_PATH%") do set APK_SIZE=%%~zA
set /a APK_SIZE_MB=%APK_SIZE%/1048576
echo [INFO] APK found: %APK_PATH% (%APK_SIZE_MB% MB)
echo.

:: Check connected devices
echo [1/5] Checking connected devices...
"%ADB%" devices > temp_devices.txt 2>&1
type temp_devices.txt | findstr /C:"device" | findstr /V "List" > nul
if errorlevel 1 (
    echo [ERROR] No devices found. Please:
    echo   - Start Android emulator, or
    echo   - Connect Android device with USB debugging enabled
    del temp_devices.txt
    pause
    exit /b 1
)

echo Connected devices:
type temp_devices.txt
del temp_devices.txt
echo.

:: Uninstall existing app
echo [2/5] Uninstalling existing app (if any)...
"%ADB%" uninstall %PACKAGE_NAME% 2>nul
if errorlevel 0 (
    echo [OK] Previous version uninstalled
) else (
    echo [OK] No previous version found
)
echo.

:: Install APK
echo [3/5] Installing APK...
"%ADB%" install -r "%APK_PATH%"
if errorlevel 1 (
    echo [ERROR] Failed to install APK
    echo Trying with -t flag for test APK...
    "%ADB%" install -r -t "%APK_PATH%"
    if errorlevel 1 (
        echo [ERROR] Installation failed
        pause
        exit /b 1
    )
)
echo [OK] APK installed successfully
echo.

:: Grant permissions
echo [4/5] Granting permissions...
"%ADB%" shell pm grant %PACKAGE_NAME% android.permission.RECORD_AUDIO 2>nul
"%ADB%" shell pm grant %PACKAGE_NAME% android.permission.INTERNET 2>nul
"%ADB%" shell pm grant %PACKAGE_NAME% android.permission.ACCESS_NETWORK_STATE 2>nul
"%ADB%" shell pm grant %PACKAGE_NAME% android.permission.VIBRATE 2>nul
echo [OK] Permissions granted
echo.

:: Launch app
echo [5/5] Launching app...
"%ADB%" shell am start -n %PACKAGE_NAME%/%MAIN_ACTIVITY%
if errorlevel 1 (
    echo [ERROR] Failed to launch app
    pause
    exit /b 1
)
echo [OK] App launched successfully!
echo.

:: Success message
echo =========================================
echo  Installation Complete!
echo =========================================
echo.
echo App is now running on your device/emulator
echo.
echo To enable API features:
echo   1. Go to Profile tab
echo   2. Tap version text 5 times
echo   3. Access Developer Options
echo   4. Configure API Settings
echo.
echo Press any key to exit...
pause >nul