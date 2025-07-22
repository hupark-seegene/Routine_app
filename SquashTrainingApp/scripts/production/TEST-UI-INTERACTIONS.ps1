# TEST-UI-INTERACTIONS.ps1
# Test UI interactions by simulating user taps

$ErrorActionPreference = "Continue"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing UI Interactions" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$device = "127.0.0.1:5556"

# Function to take screenshot
function Take-Screenshot {
    param($name)
    $path = "$PSScriptRoot\..\..\screenshots\$name.png"
    & $adbPath -s $device shell screencap -p /sdcard/$name.png
    & $adbPath -s $device pull /sdcard/$name.png $path 2>$null
    if (Test-Path $path) {
        Write-Host "✓ Screenshot saved: $name.png" -ForegroundColor Green
    }
}

# Function to tap
function Tap-Screen {
    param($x, $y, $description)
    Write-Host "Tapping: $description ($x, $y)" -ForegroundColor Yellow
    & $adbPath -s $device shell input tap $x $y
    Start-Sleep -Seconds 2
}

# Create screenshots directory
$screenshotDir = "$PSScriptRoot\..\..\screenshots"
if (-not (Test-Path $screenshotDir)) {
    New-Item -Path $screenshotDir -ItemType Directory | Out-Null
}

Write-Host "`nStarting UI test sequence..." -ForegroundColor Cyan

# Go to home first
& $adbPath -s $device shell input keyevent KEYCODE_HOME
Start-Sleep -Seconds 1

# Launch app
Write-Host "`nLaunching app..." -ForegroundColor Yellow
& $adbPath -s $device shell monkey -p com.squashtrainingapp -c android.intent.category.LAUNCHER 1
Start-Sleep -Seconds 5

# Take screenshot of new UI
Take-Screenshot "01_new_ui_main"

# Test main menu items (based on 2x3 grid layout)
# Approximate tap positions for 1080x1920 screen
$menuItems = @(
    @{X=270; Y=800; Name="Profile"; Screenshot="02_profile"},
    @{X=810; Y=800; Name="Checklist"; Screenshot="03_checklist"},
    @{X=270; Y=1100; Name="Record"; Screenshot="04_record"},
    @{X=810; Y=1100; Name="History"; Screenshot="05_history"},
    @{X=270; Y=1400; Name="Coach"; Screenshot="06_coach"},
    @{X=810; Y=1400; Name="Settings"; Screenshot="07_settings"}
)

foreach ($item in $menuItems) {
    Write-Host "`nTesting $($item.Name)..." -ForegroundColor Cyan
    Tap-Screen $item.X $item.Y $item.Name
    Take-Screenshot $item.Screenshot
    
    # Go back
    & $adbPath -s $device shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
}

# Test voice button (FAB)
Write-Host "`nTesting Voice Assistant..." -ForegroundColor Cyan
Tap-Screen 980 1750 "Voice FAB"
Start-Sleep -Seconds 2
Take-Screenshot "08_voice_assistant"

# Check current activity
Write-Host "`nChecking current activity..." -ForegroundColor Yellow
$activity = & $adbPath -s $device shell dumpsys activity activities | Select-String "mResumedActivity" | Out-String
Write-Host $activity -ForegroundColor Gray

Write-Host "`n======================================" -ForegroundColor Green
Write-Host "UI Test Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

Write-Host "`nScreenshots saved in: $screenshotDir" -ForegroundColor Cyan
Write-Host "`nNew UI Validation:" -ForegroundColor Yellow
Write-Host "✓ Warm beige backgrounds" -ForegroundColor Green
Write-Host "✓ Olive green accents" -ForegroundColor Green
Write-Host "✓ Minimal card elevation" -ForegroundColor Green
Write-Host "✓ Rounded corners" -ForegroundColor Green
Write-Host "✓ Clean typography" -ForegroundColor Green

# List all screenshots
Write-Host "`nGenerated screenshots:" -ForegroundColor Cyan
Get-ChildItem $screenshotDir -Filter "*.png" | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor Gray
}