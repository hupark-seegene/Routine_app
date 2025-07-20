@echo off
setlocal enabledelayedexpansion

:: Build and Install SquashTrainingApp
:: This script builds the APK and installs it

echo =========================================
echo  SquashTrainingApp Build and Install
echo =========================================
echo.

:: Configuration
set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk
set ADB=%ANDROID_HOME%\platform-tools\adb.exe
set PROJECT_ROOT=%CD%\SquashTrainingApp
set GRADLE=%PROJECT_ROOT%\android\gradlew.bat
set APK_PATH=%PROJECT_ROOT%\android\app\build\outputs\apk\debug\app-debug.apk
set PACKAGE_NAME=com.squashtrainingapp

:: Check if gradlew exists
if not exist "%GRADLE%" (
    echo [ERROR] gradlew.bat not found at: %GRADLE%
    echo Please ensure you're in the project root directory
    pause
    exit /b 1
)

:: Step 1: Clean previous build
echo [1/5] Cleaning previous build...
cd /d "%PROJECT_ROOT%\android"
call gradlew.bat clean >nul 2>&1
echo [OK] Clean complete
echo.

:: Step 2: Build APK
echo [2/5] Building APK (this may take a few minutes)...
call gradlew.bat assembleDebug
if errorlevel 1 (
    echo [ERROR] Build failed!
    echo Please check the error messages above
    pause
    exit /b 1
)
echo [OK] Build successful!
echo.

:: Check if APK was created
if not exist "%APK_PATH%" (
    echo [ERROR] APK not found after build!
    echo Expected location: %APK_PATH%
    pause
    exit /b 1
)

:: Get APK size
for %%A in ("%APK_PATH%") do set APK_SIZE=%%~zA
set /a APK_SIZE_MB=%APK_SIZE%/1048576
echo [OK] APK created: %APK_SIZE_MB% MB
echo.

:: Step 3: Check devices
echo [3/5] Checking connected devices...
"%ADB%" devices | findstr /C:"device" | findstr /V "List" > nul
if errorlevel 1 (
    echo [ERROR] No devices connected!
    echo.
    echo Please either:
    echo   1. Start an Android emulator in Android Studio
    echo   2. Connect a physical device with USB debugging enabled
    echo.
    echo To start emulator from command line:
    echo   %ANDROID_HOME%\emulator\emulator.exe -avd Pixel_6
    pause
    exit /b 1
)
"%ADB%" devices
echo.

:: Step 4: Install APK
echo [4/5] Installing APK...
echo Uninstalling previous version...
"%ADB%" uninstall %PACKAGE_NAME% >nul 2>&1
echo Installing new version...
"%ADB%" install -r "%APK_PATH%"
if errorlevel 1 (
    echo [WARNING] Install failed, trying with test flag...
    "%ADB%" install -r -t "%APK_PATH%"
    if errorlevel 1 (
        echo [ERROR] Installation failed!
        pause
        exit /b 1
    )
)
echo [OK] APK installed successfully!
echo.

:: Grant permissions
echo Granting permissions...
"%ADB%" shell pm grant %PACKAGE_NAME% android.permission.RECORD_AUDIO 2>nul
"%ADB%" shell pm grant %PACKAGE_NAME% android.permission.INTERNET 2>nul
"%ADB%" shell pm grant %PACKAGE_NAME% android.permission.ACCESS_NETWORK_STATE 2>nul
"%ADB%" shell pm grant %PACKAGE_NAME% android.permission.VIBRATE 2>nul
echo [OK] Permissions granted
echo.

:: Step 5: Launch app
echo [5/5] Launching app...
"%ADB%" shell am start -n %PACKAGE_NAME%/.MainActivity
if errorlevel 1 (
    echo [WARNING] Failed to launch app
) else (
    echo [OK] App launched!
)

:: Return to original directory
cd /d "%~dp0"

:: Success
echo.
echo =========================================
echo  Build and Installation Complete!
echo =========================================
echo.
echo The app should now be running on your device.
echo.
echo To enable Developer Mode:
echo   1. Go to Profile tab
echo   2. Tap version text 5 times
echo   3. Access Developer Options
echo.
pause