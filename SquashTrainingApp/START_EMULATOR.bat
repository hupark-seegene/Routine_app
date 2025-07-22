@echo off
echo ======================================
echo Starting Android Emulator with Microphone
echo ======================================
echo.

cd scripts\production
powershell -ExecutionPolicy Bypass -File START-EMULATOR-WITH-MIC.ps1

pause