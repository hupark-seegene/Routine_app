@echo off
REM RUN_DEBUG.bat - Execute comprehensive app debugging

echo ========================================
echo Starting Squash Training App Debug
echo ========================================
echo.

cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "scripts\production\DEBUG-ALL-FEATURES.ps1"

echo.
echo Debug complete! Check the debug-results folder for all screenshots and logs.
pause