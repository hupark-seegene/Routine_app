@echo off
:: Quick APK installer - minimal version

set ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe
set APK=SquashTrainingApp\android\app\build\outputs\apk\debug\app-debug.apk

echo Installing SquashTrainingApp...
echo.

:: Check if APK exists
if not exist "%APK%" (
    echo ERROR: APK not found!
    echo Build the app first with: gradlew.bat assembleDebug
    pause
    exit /b 1
)

:: Install and run
"%ADB%" devices
echo.
"%ADB%" uninstall com.squashtrainingapp 2>nul
"%ADB%" install -r "%APK%"
"%ADB%" shell am start -n com.squashtrainingapp/.MainActivity

echo.
echo Done! App should be running now.
pause