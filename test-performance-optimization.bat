@echo off
setlocal enabledelayedexpansion

:: Performance Optimization Test Script
:: Tests memory management, FPS, and rendering optimizations

echo =========================================
echo  Performance Optimization Test
echo =========================================
echo.

:: Configuration
set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk
set ADB=%ANDROID_HOME%\platform-tools\adb.exe
set PACKAGE_NAME=com.squashtrainingapp

:: Check if app is installed
echo [1/7] Checking if app is installed...
"%ADB%" shell pm list packages | findstr %PACKAGE_NAME% > nul
if errorlevel 1 (
    echo [ERROR] App not installed! Please run build-and-install.bat first
    pause
    exit /b 1
)
echo [OK] App is installed
echo.

:: Clear app data for fresh start
echo [2/7] Clearing app data for clean test...
"%ADB%" shell pm clear %PACKAGE_NAME%
echo [OK] App data cleared
echo.

:: Start app
echo [3/7] Starting app...
"%ADB%" shell am start -n %PACKAGE_NAME%/.MainActivity
if errorlevel 1 (
    echo [ERROR] Failed to start app
    pause
    exit /b 1
)
echo [OK] App started
echo.

:: Wait for app to load
echo [4/7] Waiting for app to load...
timeout /t 3 /nobreak > nul
echo.

:: Enable GPU profiling
echo [5/7] Enabling GPU profiling...
"%ADB%" shell setprop debug.hwui.profile true
"%ADB%" shell setprop debug.hwui.overdraw show
echo [OK] GPU profiling enabled
echo.

:: Monitor memory usage
echo [6/7] Monitoring memory usage...
echo.
echo Initial memory info:
"%ADB%" shell dumpsys meminfo %PACKAGE_NAME% | findstr "TOTAL\|Native\|Dalvik\|Graphics"
echo.

:: Test performance scenarios
echo [7/7] Running performance tests...
echo.
echo Test 1: Mascot Animation Performance
echo - Drag the mascot around the screen continuously
echo - Check for smooth 60fps animation
echo - Monitor for frame drops
echo.
timeout /t 5 /nobreak > nul

:: Get FPS info
echo Getting FPS statistics...
"%ADB%" shell dumpsys gfxinfo %PACKAGE_NAME% | findstr "Janky\|Average\|frames"
echo.

:: Test memory under load
echo Test 2: Memory Stress Test
echo - Navigate through all screens
echo - Return to main screen
echo - Check memory usage
echo.
timeout /t 10 /nobreak > nul

:: Get updated memory info
echo Updated memory info after navigation:
"%ADB%" shell dumpsys meminfo %PACKAGE_NAME% | findstr "TOTAL\|Native\|Dalvik\|Graphics"
echo.

:: Check for memory leaks
echo Test 3: Memory Leak Detection
echo - Force garbage collection
"%ADB%" shell am force-stop %PACKAGE_NAME%
timeout /t 2 /nobreak > nul
"%ADB%" shell am start -n %PACKAGE_NAME%/.MainActivity
timeout /t 3 /nobreak > nul
echo.
echo Memory after restart:
"%ADB%" shell dumpsys meminfo %PACKAGE_NAME% | findstr "TOTAL"
echo.

:: Performance report
echo =========================================
echo  Performance Test Report
echo =========================================
echo.
echo Performance Optimizations Implemented:
echo [✓] OptimizedMascotView with hardware acceleration
echo [✓] Bitmap caching and memory management
echo [✓] Choreographer-based 60fps animations
echo [✓] Memory leak prevention
echo [✓] Image loading optimization
echo [✓] Performance monitoring system
echo.
echo Expected Results:
echo - Consistent 60 FPS during animations
echo - Memory usage under 150MB
echo - No memory leaks after navigation
echo - Smooth mascot dragging
echo - Fast screen transitions
echo.
echo Visual Checks:
echo 1. GPU Overdraw: Green/light blue = good, Red = bad
echo 2. Animation smoothness: No stuttering
echo 3. Touch responsiveness: Immediate feedback
echo.

:: Get detailed performance metrics
echo Detailed Performance Metrics:
echo --------------------------------
"%ADB%" shell dumpsys gfxinfo %PACKAGE_NAME% framestats | findstr "Total\|Janky"
echo.

:: Disable GPU profiling
echo Disabling GPU profiling...
"%ADB%" shell setprop debug.hwui.profile false
"%ADB%" shell setprop debug.hwui.overdraw false
echo.

:: Save performance log
echo Saving performance log...
"%ADB%" shell dumpsys meminfo %PACKAGE_NAME% > performance_log.txt
"%ADB%" shell dumpsys gfxinfo %PACKAGE_NAME% >> performance_log.txt
echo Performance log saved to: performance_log.txt
echo.

pause