# Iterative Debug Test Script
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$resultsDir = "iterative-test-$timestamp"
New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null

Write-Host "[INFO] Starting iterative test of Squash Training App" -ForegroundColor Green
Write-Host "[INFO] Running 50 test cycles..." -ForegroundColor Green

$successCount = 0
$failCount = 0

for ($i = 1; $i -le 50; $i++) {
    Write-Host "`n[INFO] === CYCLE $i/50 ===" -ForegroundColor Cyan
    
    try {
        # Launch the app
        adb shell am start -n com.squashtrainingapp/.MainActivity
        Start-Sleep -Seconds 2
        
        # Take screenshot
        adb shell screencap -p /sdcard/cycle_$i.png
        adb pull /sdcard/cycle_$i.png "$resultsDir/cycle_${i}_home.png" 2>$null
        
        # Test mascot drag to random zone
        $zones = @(
            @{name="Profile"; x=540; y=400},
            @{name="Checklist"; x=300; y=700},
            @{name="Coach"; x=780; y=700},
            @{name="Record"; x=300; y=1100},
            @{name="History"; x=780; y=1100}
        )
        
        $zone = $zones | Get-Random
        Write-Host "[INFO] Testing drag to $($zone.name) zone" -ForegroundColor Yellow
        
        # Simulate drag
        adb shell input swipe 540 900 $zone.x $zone.y 500
        Start-Sleep -Seconds 2
        
        # Take screenshot after navigation
        adb shell screencap -p /sdcard/cycle_${i}_nav.png
        adb pull /sdcard/cycle_${i}_nav.png "$resultsDir/cycle_${i}_$($zone.name).png" 2>$null
        
        # Return to home
        adb shell input keyevent KEYCODE_BACK
        Start-Sleep -Seconds 1
        
        $successCount++
        Write-Host "[SUCCESS] Cycle $i completed successfully" -ForegroundColor Green
    }
    catch {
        $failCount++
        Write-Host "[ERROR] Cycle $i failed: $_" -ForegroundColor Red
    }
}

Write-Host "`n[INFO] === FINAL REPORT ===" -ForegroundColor Cyan
Write-Host "[SUCCESS] Successful cycles: $successCount" -ForegroundColor Green
Write-Host "[ERROR] Failed cycles: $failCount" -ForegroundColor Red
Write-Host "[INFO] Success rate: $([math]::Round($successCount/50*100, 2))%" -ForegroundColor Yellow
Write-Host "[INFO] Results saved to: $resultsDir" -ForegroundColor Yellow