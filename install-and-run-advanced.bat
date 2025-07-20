@echo off
setlocal enabledelayedexpansion

:: Advanced SquashTrainingApp Installer with Options
:: Supports multiple devices, build options, and debugging

title SquashTrainingApp Installer

:: Colors
:: Note: Windows 10+ supports ANSI escape codes
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set ESC=%%b
)

set RED=%ESC%[31m
set GREEN=%ESC%[32m
set YELLOW=%ESC%[33m
set BLUE=%ESC%[36m
set RESET=%ESC%[0m

echo %BLUE%=========================================
echo  SquashTrainingApp Advanced Installer
echo =========================================%RESET%
echo.

:: Configuration
set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk
set ADB=%ANDROID_HOME%\platform-tools\adb.exe
set EMULATOR=%ANDROID_HOME%\emulator\emulator.exe
set PROJECT_ROOT=%CD%\SquashTrainingApp
set APK_PATH=%PROJECT_ROOT%\android\app\build\outputs\apk\debug\app-debug.apk
set PACKAGE_NAME=com.squashtrainingapp
set MAIN_ACTIVITY=.MainActivity

:: Menu
:MENU
echo Select an option:
echo %GREEN%[1]%RESET% Quick Install (default device)
echo %GREEN%[2]%RESET% Build and Install
echo %GREEN%[3]%RESET% Install with Device Selection
echo %GREEN%[4]%RESET% Start Emulator with Mic Support
echo %GREEN%[5]%RESET% View Logs (Logcat)
echo %GREEN%[6]%RESET% Clear App Data
echo %GREEN%[7]%RESET% Take Screenshot
echo %GREEN%[8]%RESET% Exit
echo.
set /p choice="Enter choice (1-8): "

if "%choice%"=="1" goto QUICK_INSTALL
if "%choice%"=="2" goto BUILD_AND_INSTALL
if "%choice%"=="3" goto SELECT_DEVICE
if "%choice%"=="4" goto START_EMULATOR
if "%choice%"=="5" goto VIEW_LOGS
if "%choice%"=="6" goto CLEAR_DATA
if "%choice%"=="7" goto SCREENSHOT
if "%choice%"=="8" exit /b 0
goto MENU

:QUICK_INSTALL
echo.
echo %BLUE%[Quick Install]%RESET%
call :CHECK_ADB
call :CHECK_APK
call :CHECK_DEVICES
call :INSTALL_APK
call :LAUNCH_APP
echo.
echo %GREEN%Done! Press any key to return to menu...%RESET%
pause >nul
cls
goto MENU

:BUILD_AND_INSTALL
echo.
echo %BLUE%[Build and Install]%RESET%
call :CHECK_ADB
echo.
echo Building APK...
cd /d "%PROJECT_ROOT%\android"
call gradlew.bat assembleDebug
if errorlevel 1 (
    echo %RED%Build failed!%RESET%
    pause
    goto MENU
)
cd /d "%~dp0"
call :CHECK_APK
call :CHECK_DEVICES
call :INSTALL_APK
call :LAUNCH_APP
echo.
echo %GREEN%Done! Press any key to return to menu...%RESET%
pause >nul
cls
goto MENU

:SELECT_DEVICE
echo.
echo %BLUE%[Device Selection]%RESET%
call :CHECK_ADB
"%ADB%" devices -l
echo.
set /p device="Enter device serial (or press Enter for default): "
if not "%device%"=="" (
    set ADB_DEVICE=-s %device%
) else (
    set ADB_DEVICE=
)
call :CHECK_APK
call :INSTALL_APK
call :LAUNCH_APP
echo.
echo %GREEN%Done! Press any key to return to menu...%RESET%
pause >nul
cls
goto MENU

:START_EMULATOR
echo.
echo %BLUE%[Start Emulator]%RESET%
echo.
echo Available AVDs:
"%EMULATOR%" -list-avds
echo.
set /p avd="Enter AVD name: "
echo Starting %avd% with microphone support...
start "" "%EMULATOR%" -avd %avd% -use-host-audio
echo.
echo %GREEN%Emulator starting... Press any key to return to menu...%RESET%
pause >nul
cls
goto MENU

:VIEW_LOGS
echo.
echo %BLUE%[Logcat - Press Ctrl+C to stop]%RESET%
echo.
"%ADB%" logcat -v time *:W | findstr /i "squashtraining"
pause
cls
goto MENU

:CLEAR_DATA
echo.
echo %BLUE%[Clear App Data]%RESET%
echo.
echo %YELLOW%Warning: This will delete all app data!%RESET%
set /p confirm="Are you sure? (y/n): "
if /i "%confirm%"=="y" (
    "%ADB%" shell pm clear %PACKAGE_NAME%
    echo %GREEN%App data cleared!%RESET%
) else (
    echo Cancelled.
)
echo.
pause
cls
goto MENU

:SCREENSHOT
echo.
echo %BLUE%[Take Screenshot]%RESET%
set timestamp=%date:~-4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set timestamp=%timestamp: =0%
set filename=screenshot_%timestamp%.png
"%ADB%" shell screencap -p /sdcard/screenshot.png
"%ADB%" pull /sdcard/screenshot.png %filename%
"%ADB%" shell rm /sdcard/screenshot.png
echo %GREEN%Screenshot saved as: %filename%%RESET%
start "" %filename%
echo.
pause
cls
goto MENU

:: Functions
:CHECK_ADB
if not exist "%ADB%" (
    echo %RED%[ERROR] ADB not found at: %ADB%%RESET%
    pause
    exit /b 1
)
exit /b 0

:CHECK_APK
if not exist "%APK_PATH%" (
    echo %RED%[ERROR] APK not found at: %APK_PATH%%RESET%
    echo Please build the app first!
    pause
    exit /b 1
)
for %%A in ("%APK_PATH%") do set APK_SIZE=%%~zA
set /a APK_SIZE_MB=%APK_SIZE%/1048576
echo %GREEN%[OK] APK found: %APK_SIZE_MB% MB%RESET%
exit /b 0

:CHECK_DEVICES
"%ADB%" devices | findstr /C:"device" | findstr /V "List" > nul
if errorlevel 1 (
    echo %RED%[ERROR] No devices connected!%RESET%
    pause
    exit /b 1
)
echo %GREEN%[OK] Device connected%RESET%
exit /b 0

:INSTALL_APK
echo.
echo Uninstalling previous version...
"%ADB%" %ADB_DEVICE% uninstall %PACKAGE_NAME% 2>nul
echo Installing APK...
"%ADB%" %ADB_DEVICE% install -r "%APK_PATH%"
if errorlevel 1 (
    echo %YELLOW%Retrying with test flag...%RESET%
    "%ADB%" %ADB_DEVICE% install -r -t "%APK_PATH%"
)
echo %GREEN%[OK] APK installed%RESET%
echo.
echo Granting permissions...
"%ADB%" %ADB_DEVICE% shell pm grant %PACKAGE_NAME% android.permission.RECORD_AUDIO 2>nul
"%ADB%" %ADB_DEVICE% shell pm grant %PACKAGE_NAME% android.permission.INTERNET 2>nul
"%ADB%" %ADB_DEVICE% shell pm grant %PACKAGE_NAME% android.permission.ACCESS_NETWORK_STATE 2>nul
echo %GREEN%[OK] Permissions granted%RESET%
exit /b 0

:LAUNCH_APP
echo.
echo Launching app...
"%ADB%" %ADB_DEVICE% shell am start -n %PACKAGE_NAME%/%MAIN_ACTIVITY%
echo %GREEN%[OK] App launched!%RESET%
exit /b 0