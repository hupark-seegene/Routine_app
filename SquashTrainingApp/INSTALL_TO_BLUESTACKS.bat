@echo off
echo ======================================
echo Installing to BlueStacks
echo ======================================
echo.

cd scripts\production

echo First, let's make sure BlueStacks ADB is enabled...
echo.
powershell -ExecutionPolicy Bypass -File SETUP-BLUESTACKS-ADB.ps1

echo.
echo Now installing the app...
echo.
powershell -ExecutionPolicy Bypass -File INSTALL-TO-BLUESTACKS.ps1

pause