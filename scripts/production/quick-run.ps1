#!/usr/bin/env pwsh
# Quick Run Script - Simplified launcher for common scenarios
# Usage: .\quick-run.ps1 [1-5]

param(
    [int]$Option = 0
)

function Show-Menu {
    Write-Host "`n🚀 SQUASH TRAINING APP - QUICK LAUNCHER" -ForegroundColor Cyan
    Write-Host "=======================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Select an option:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Full Build & Run (Recommended)" -ForegroundColor Green
    Write-Host "      → Builds app, installs, starts Metro, launches app"
    Write-Host ""
    Write-Host "  [2] Quick Install Only" -ForegroundColor Yellow
    Write-Host "      → Uses existing APK, just installs to device"
    Write-Host ""
    Write-Host "  [3] Build Only (No Install)" -ForegroundColor White
    Write-Host "      → Builds APK but doesn't install"
    Write-Host ""
    Write-Host "  [4] Simple Build with Auto-Install" -ForegroundColor White
    Write-Host "      → Uses simplified build process with auto-install"
    Write-Host ""
    Write-Host "  [5] Check Device Connection" -ForegroundColor Gray
    Write-Host "      → Shows connected devices and ADB status"
    Write-Host ""
    Write-Host "  [0] Exit" -ForegroundColor DarkGray
    Write-Host ""
}

function Execute-Option($choice) {
    switch ($choice) {
        1 {
            Write-Host "`n→ Starting Full Build & Run..." -ForegroundColor Green
            & .\build-and-run.ps1 -LaunchApp
        }
        2 {
            Write-Host "`n→ Quick Install..." -ForegroundColor Yellow
            & .\install-apk.ps1 -Launch
        }
        3 {
            Write-Host "`n→ Build Only..." -ForegroundColor White
            & .\build-simple.ps1
        }
        4 {
            Write-Host "`n→ Simple Build with Auto-Install..." -ForegroundColor White
            & .\build-simple.ps1 -AutoInstall
        }
        5 {
            Write-Host "`n→ Checking Devices..." -ForegroundColor Gray
            $adb = "C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools\adb.exe"
            
            if (Test-Path $adb) {
                Write-Host "`nADB Location: $adb" -ForegroundColor Cyan
                Write-Host "`nConnected Devices:" -ForegroundColor Yellow
                & $adb devices -l
                
                Write-Host "`nDevice Properties:" -ForegroundColor Yellow
                $devices = & $adb devices 2>&1 | Select-String -Pattern "^(\S+)\s+(device|emulator)$"
                foreach ($device in $devices) {
                    $deviceId = $device.Matches[0].Groups[1].Value
                    $model = (& $adb -s $deviceId shell getprop ro.product.model 2>&1).Trim()
                    $android = (& $adb -s $deviceId shell getprop ro.build.version.release 2>&1).Trim()
                    Write-Host "  → $deviceId : $model (Android $android)" -ForegroundColor Green
                }
            } else {
                Write-Host "ADB not found!" -ForegroundColor Red
            }
        }
        0 {
            Write-Host "`nExiting..." -ForegroundColor Gray
            exit 0
        }
        default {
            Write-Host "`nInvalid option!" -ForegroundColor Red
        }
    }
}

# Main execution
if ($Option -ne 0) {
    # Direct execution if option provided
    Execute-Option $Option
} else {
    # Interactive menu
    while ($true) {
        Show-Menu
        $choice = Read-Host "Enter your choice (0-5)"
        
        if ($choice -match '^\d+$') {
            $choiceInt = [int]$choice
            Execute-Option $choiceInt
            
            if ($choiceInt -eq 0) {
                break
            }
            
            Write-Host "`nPress any key to return to menu..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}