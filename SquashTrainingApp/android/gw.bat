@echo off
REM Gradle Wrapper with automatic React Native plugin building for RN 0.80+
REM Use this instead of gradlew.bat to ensure the RN plugin is built

setlocal enabledelayedexpansion

REM Get the directory of this script
set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."
set "PLUGIN_PATH=%PROJECT_ROOT%\node_modules\@react-native\gradle-plugin"
set "PLUGIN_JAR=%PLUGIN_PATH%\react-native-gradle-plugin\build\libs\react-native-gradle-plugin.jar"
set "SETTINGS_JAR=%PLUGIN_PATH%\settings-plugin\build\libs\settings-plugin.jar"

REM Check if we need to set up Java
if "%JAVA_HOME%"=="" (
    echo [gw] Setting up Java environment...
    set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
    set "PATH=%JAVA_HOME%\bin;%PATH%"
)

REM Check if plugin directory exists
if not exist "%PLUGIN_PATH%" (
    echo.
    echo [gw] ERROR: React Native gradle plugin not found!
    echo [gw] Expected at: %PLUGIN_PATH%
    echo.
    echo [gw] Please run 'npm install' in the project root first.
    exit /b 1
)

REM Check if plugin is built
set "PLUGIN_BUILT=0"
if exist "%PLUGIN_JAR%" (
    if exist "%SETTINGS_JAR%" (
        set "PLUGIN_BUILT=1"
    )
)

REM Build plugin if needed
if "%PLUGIN_BUILT%"=="0" (
    echo.
    echo [gw] React Native gradle plugin not built. Building it now...
    echo [gw] This is a one-time process that takes 1-2 minutes.
    echo.
    
    pushd "%PLUGIN_PATH%"
    
    REM Try to build with tests first
    echo [gw] Building plugin (including tests)...
    call gradlew.bat build
    
    if errorlevel 1 (
        echo.
        echo [gw] Build with tests failed. Retrying without tests...
        echo [gw] Note: This is common on Windows due to test compatibility issues.
        echo.
        
        REM Try building without tests
        call gradlew.bat build -x test
        
        if errorlevel 1 (
            echo.
            echo [gw] ERROR: Failed to build React Native gradle plugin even without tests!
            echo [gw] Please check the error messages above.
            popd
            exit /b 1
        )
    )
    
    popd
    
    REM Verify the build succeeded
    if exist "%PLUGIN_JAR%" (
        if exist "%SETTINGS_JAR%" (
            echo.
            echo [gw] React Native gradle plugin built successfully!
            echo.
        ) else (
            echo.
            echo [gw] ERROR: Plugin build completed but JAR files not found!
            exit /b 1
        )
    ) else (
        echo.
        echo [gw] ERROR: Plugin build completed but JAR files not found!
        exit /b 1
    )
)

REM Now run the actual gradlew with all arguments
call "%SCRIPT_DIR%gradlew.bat" %*