@echo off
REM Batch file wrapper for PowerShell build script
REM This allows users to simply double-click or run "build" from command prompt

echo ========================================
echo  React Native Android Build
echo  Starting PowerShell build script...
echo ========================================
echo.

REM Check if PowerShell is available
where powershell >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PowerShell not found in PATH!
    echo Please install PowerShell or use Windows PowerShell.
    pause
    exit /b 1
)

REM Run the PowerShell build script
powershell -ExecutionPolicy Bypass -File "%~dp0build-android.ps1"

REM Capture the exit code
set BUILD_RESULT=%ERRORLEVEL%

REM Show result
echo.
if %BUILD_RESULT% EQU 0 (
    echo ========================================
    echo  BUILD SUCCESSFUL!
    echo ========================================
) else (
    echo ========================================
    echo  BUILD FAILED! (Exit code: %BUILD_RESULT%^)
    echo ========================================
)

REM Pause so user can see the output when double-clicking
echo.
echo Press any key to exit...
pause >nul

exit /b %BUILD_RESULT%