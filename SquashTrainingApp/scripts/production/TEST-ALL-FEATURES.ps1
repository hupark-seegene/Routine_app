# TEST-ALL-FEATURES.ps1
# Comprehensive test of all app features

$ErrorActionPreference = "Continue"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing All App Features" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$device = "127.0.0.1:5556" # BlueStacks for testing

# Function to test navigation
function Test-Navigation {
    param($activity)
    Write-Host "`nTesting: $activity" -ForegroundColor Yellow
    & $adbPath -s $device shell am start -n com.squashtrainingapp/$activity
    Start-Sleep -Seconds 2
    
    # Check if activity launched
    $current = & $adbPath -s $device shell dumpsys activity activities | Select-String "mResumedActivity" | Out-String
    if ($current -match $activity.Split('.')[-1]) {
        Write-Host "✓ $activity launched successfully" -ForegroundColor Green
        return $true
    } else {
        Write-Host "✗ Failed to launch $activity" -ForegroundColor Red
        return $false
    }
}

# Function to check if service is running
function Test-Service {
    param($service)
    Write-Host "`nChecking service: $service" -ForegroundColor Yellow
    $services = & $adbPath -s $device shell dumpsys activity services | Select-String $service
    if ($services) {
        Write-Host "✓ $service is running" -ForegroundColor Green
        return $true
    } else {
        Write-Host "✗ $service is not running" -ForegroundColor Red
        return $false
    }
}

# Function to simulate user interactions
function Test-UserInteraction {
    param($x, $y, $description)
    Write-Host "`nTesting: $description" -ForegroundColor Yellow
    & $adbPath -s $device shell input tap $x $y
    Start-Sleep -Milliseconds 500
}

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "Phase 1: Authentication Features" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Test login flow
Test-Navigation ".ui.activities.LoginActivity"
Test-Navigation ".ui.activities.RegisterActivity"

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "Phase 2: Core Features" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Test main activities
Test-Navigation ".SimpleMainActivity"
Test-Navigation ".ui.activities.ProfileActivity"
Test-Navigation ".ui.activities.ChecklistActivity"
Test-Navigation ".ui.activities.RecordActivity"
Test-Navigation ".ui.activities.HistoryActivity"
Test-Navigation ".ui.activities.CoachActivity"
Test-Navigation ".ui.activities.SettingsActivity"

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "Phase 2: AI Features" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

Test-Navigation ".ai.AIChatbotActivity"
Test-Navigation ".ui.activities.VoiceAssistantActivity"

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "Phase 2: Social Features" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

Test-Navigation ".ui.activities.LeaderboardActivity"
Test-Navigation ".ui.activities.ChallengesActivity"

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "Phase 3: Advanced Features" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

Test-Navigation ".ui.activities.AnalyticsActivity"
Test-Navigation ".ui.activities.ContentMarketplaceActivity"
Test-Navigation ".ui.activities.VideoTutorialsActivity"
Test-Navigation ".ui.activities.CustomExerciseActivity"
Test-Navigation ".ui.activities.WorkoutProgramActivity"
Test-Navigation ".ui.activities.AchievementsActivity"

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "Phase 4: Marketing Features" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

Test-Navigation ".ui.activities.ReferralActivity"
Test-Navigation ".ui.activities.SplashActivity"
Test-Navigation ".ui.activities.OnboardingActivity"

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "Testing Services" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

Test-Service "NotificationService"
Test-Service "GPT4CoachingService"
Test-Service "WorkoutVoiceGuide"
Test-Service "GlobalVoiceCommandService"

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "Database Validation" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Check database
$dbPath = & $adbPath -s $device shell "ls /data/data/com.squashtrainingapp/databases/" 2>$null
if ($dbPath) {
    Write-Host "✓ Database exists" -ForegroundColor Green
    Write-Host "  Files: $dbPath" -ForegroundColor Gray
} else {
    Write-Host "✗ Database not found" -ForegroundColor Red
}

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "Memory & Performance Check" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Get memory info
$memInfo = & $adbPath -s $device shell dumpsys meminfo com.squashtrainingapp | Select-String "TOTAL"
if ($memInfo) {
    Write-Host "Memory Usage:" -ForegroundColor Yellow
    $memInfo | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
}

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "UI Theme Validation" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Take screenshot
$screenshotPath = "$PSScriptRoot\..\..\test-screenshot.png"
& $adbPath -s $device shell screencap -p /sdcard/test.png
& $adbPath -s $device pull /sdcard/test.png $screenshotPath 2>$null
if (Test-Path $screenshotPath) {
    Write-Host "✓ Screenshot saved: $screenshotPath" -ForegroundColor Green
    Write-Host "  Check for new Zen Minimal UI design" -ForegroundColor Gray
}

Write-Host "`n======================================" -ForegroundColor Green
Write-Host "Feature Test Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

Write-Host "`nNew UI Characteristics:" -ForegroundColor Cyan
Write-Host "- Warm beige backgrounds (#F5E6D3)" -ForegroundColor White
Write-Host "- Olive green accents (#4A5D3A)" -ForegroundColor White
Write-Host "- Minimal shadows (0-1dp elevation)" -ForegroundColor White
Write-Host "- Rounded corners (12dp)" -ForegroundColor White
Write-Host "- Clean, universal design" -ForegroundColor White

Write-Host "`nPress Enter to return to main screen..." -ForegroundColor Gray
Read-Host

# Return to main
& $adbPath -s $device shell am start -n com.squashtrainingapp/.SimpleMainActivity