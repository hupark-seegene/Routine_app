@echo off
setlocal enabledelayedexpansion

:: All-in-One: Start Emulator, Build, and Install
:: Perfect for fresh start

echo =========================================
echo  SquashTrainingApp Complete Setup
echo =========================================
echo.

:: Configuration
set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk
set ADB=%ANDROID_HOME%\platform-tools\adb.exe
set EMULATOR=%ANDROID_HOME%\emulator\emulator.exe
set AVD_NAME=Pixel_6
set PROJECT_ROOT=%CD%\SquashTrainingApp

:: Step 1: Check if emulator is already running
echo [1/6] Checking emulator status...
"%ADB%" devices | findstr "emulator" > nul
if not errorlevel 1 (
    echo Emulator is already running.
    goto BUILD_APP
)

:: List available AVDs
echo.
echo Available AVDs:
"%EMULATOR%" -list-avds
echo.

:: Ask user for AVD name
set /p user_avd="Enter AVD name (press Enter for default '%AVD_NAME%'): "
if not "%user_avd%"=="" set AVD_NAME=%user_avd%

:: Step 2: Start emulator
echo.
echo [2/6] Starting emulator '%AVD_NAME%' with microphone support...
start "Android Emulator" "%EMULATOR%" -avd %AVD_NAME% -use-host-audio
echo Emulator starting in background...
echo.

:: Step 3: Wait for emulator to boot
echo [3/6] Waiting for emulator to boot (this may take 1-2 minutes)...
set WAIT_TIME=0
:WAIT_LOOP
timeout /t 5 /nobreak > nul
set /a WAIT_TIME+=5
"%ADB%" shell getprop sys.boot_completed 2>nul | findstr "1" > nul
if not errorlevel 1 goto EMULATOR_READY
if %WAIT_TIME% geq 120 (
    echo [ERROR] Emulator failed to boot within 2 minutes
    pause
    exit /b 1
)
echo Still waiting... (%WAIT_TIME% seconds)
goto WAIT_LOOP

:EMULATOR_READY
echo [OK] Emulator is ready!
echo.

:BUILD_APP
:: Step 4: Build APK
echo [4/6] Building APK...
cd /d "%PROJECT_ROOT%\android"
call gradlew.bat assembleDebug
if errorlevel 1 (
    echo [ERROR] Build failed!
    cd /d "%~dp0"
    pause
    exit /b 1
)
cd /d "%~dp0"
echo [OK] Build successful!
echo.

:: Step 5: Install APK
echo [5/6] Installing APK...
set APK_PATH=%PROJECT_ROOT%\android\app\build\outputs\apk\debug\app-debug.apk
"%ADB%" uninstall com.squashtrainingapp >nul 2>&1
"%ADB%" install -r "%APK_PATH%"
if errorlevel 1 (
    echo [ERROR] Installation failed!
    pause
    exit /b 1
)

:: Grant permissions
"%ADB%" shell pm grant com.squashtrainingapp android.permission.RECORD_AUDIO 2>nul
"%ADB%" shell pm grant com.squashtrainingapp android.permission.INTERNET 2>nul
"%ADB%" shell pm grant com.squashtrainingapp android.permission.ACCESS_NETWORK_STATE 2>nul
echo [OK] APK installed with permissions!
echo.

:: Step 6: Launch app
echo [6/6] Launching app...
"%ADB%" shell am start -n com.squashtrainingapp/.MainActivity
echo [OK] App launched!
echo.

:: Success
echo =========================================
echo  Setup Complete!
echo =========================================
echo.
echo Emulator is running with microphone support
echo App is installed and launched
echo.
echo Quick tips:
echo - For voice input: Long press mascot for 2 seconds
echo - For developer mode: Tap version text 5 times in Profile
echo - To view logs: adb logcat | findstr squashtraining
echo.
pause