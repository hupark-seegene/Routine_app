# SETUP-EMULATOR-MICROPHONE.ps1
# Script to configure Android Emulator to use host computer's microphone

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Android Emulator Microphone Setup" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Function to check if emulator is running
function Check-EmulatorRunning {
    $adbDevices = & adb devices
    if ($adbDevices -match "emulator") {
        return $true
    }
    return $false
}

# Function to get emulator name
function Get-EmulatorName {
    $emulators = & emulator -list-avds
    if ($emulators) {
        return $emulators[0]
    }
    return $null
}

# Function to configure AVD for microphone
function Configure-AVDMicrophone {
    param($avdName)
    
    $avdPath = "$env:USERPROFILE\.android\avd\$avdName.avd"
    $configFile = "$avdPath\config.ini"
    
    if (Test-Path $configFile) {
        Write-Host "`nConfiguring AVD: $avdName" -ForegroundColor Yellow
        
        # Read current config
        $config = Get-Content $configFile
        
        # Check and update microphone settings
        $microphoneSettings = @{
            "hw.audioInput" = "yes"
            "hw.microphone" = "yes"
            "hw.camera.front" = "emulated"
            "hw.camera.back" = "emulated"
        }
        
        foreach ($setting in $microphoneSettings.GetEnumerator()) {
            $found = $false
            for ($i = 0; $i -lt $config.Count; $i++) {
                if ($config[$i] -match "^$($setting.Key)=") {
                    $config[$i] = "$($setting.Key)=$($setting.Value)"
                    $found = $true
                    Write-Host "Updated: $($setting.Key)=$($setting.Value)" -ForegroundColor Green
                    break
                }
            }
            if (-not $found) {
                $config += "$($setting.Key)=$($setting.Value)"
                Write-Host "Added: $($setting.Key)=$($setting.Value)" -ForegroundColor Green
            }
        }
        
        # Write back config
        $config | Set-Content $configFile
        Write-Host "AVD configuration updated successfully!" -ForegroundColor Green
    } else {
        Write-Host "Config file not found: $configFile" -ForegroundColor Red
    }
}

# Main execution
Write-Host "`n1. Checking for running emulator..." -ForegroundColor Yellow
if (Check-EmulatorRunning) {
    Write-Host "Emulator is already running. Please close it first." -ForegroundColor Red
    Write-Host "Run: adb emu kill" -ForegroundColor Yellow
    Start-Sleep -Seconds 2
}

Write-Host "`n2. Finding available AVDs..." -ForegroundColor Yellow
$avdName = Get-EmulatorName
if (-not $avdName) {
    Write-Host "No AVD found! Please create an AVD first." -ForegroundColor Red
    exit 1
}

Write-Host "Found AVD: $avdName" -ForegroundColor Green

Write-Host "`n3. Configuring AVD for microphone access..." -ForegroundColor Yellow
Configure-AVDMicrophone -avdName $avdName

Write-Host "`n4. Starting emulator with microphone support..." -ForegroundColor Yellow
Write-Host "Launching emulator with audio input enabled..." -ForegroundColor Cyan

# Start emulator with specific audio settings
$emulatorArgs = @(
    "-avd", $avdName,
    "-feature", "VirtualMicrophone",
    "-feature", "AudioInput",
    "-no-snapshot-load"
)

Write-Host "Command: emulator $($emulatorArgs -join ' ')" -ForegroundColor Gray
Start-Process -FilePath "emulator" -ArgumentList $emulatorArgs -NoNewWindow

Write-Host "`n5. Waiting for emulator to boot..." -ForegroundColor Yellow
$timeout = 120
$elapsed = 0
while ($elapsed -lt $timeout) {
    Start-Sleep -Seconds 5
    $elapsed += 5
    
    if (Check-EmulatorRunning) {
        $bootCompleted = & adb shell getprop sys.boot_completed 2>$null
        if ($bootCompleted -eq "1") {
            Write-Host "Emulator booted successfully!" -ForegroundColor Green
            break
        }
    }
    Write-Host "Waiting... ($elapsed/$timeout seconds)" -ForegroundColor Gray
}

if ($elapsed -ge $timeout) {
    Write-Host "Emulator boot timeout!" -ForegroundColor Red
    exit 1
}

Write-Host "`n6. Configuring emulator settings..." -ForegroundColor Yellow

# Grant microphone permission to our app
Write-Host "Granting microphone permission to app..." -ForegroundColor Cyan
& adb shell pm grant com.squashtrainingapp android.permission.RECORD_AUDIO 2>$null

# Set audio recording source
Write-Host "Configuring audio settings..." -ForegroundColor Cyan
& adb shell settings put system microphone_mute 0
& adb shell settings put system master_mono 0

Write-Host "`n7. Testing microphone..." -ForegroundColor Yellow
Write-Host "Opening sound recorder to test microphone..." -ForegroundColor Cyan

# Try to open sound recorder app
& adb shell am start -a android.provider.MediaStore.RECORD_SOUND_ACTION 2>$null

Write-Host "`n======================================" -ForegroundColor Green
Write-Host "Microphone Setup Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

Write-Host "`nIMPORTANT NOTES:" -ForegroundColor Yellow
Write-Host "1. If microphone doesn't work, check Windows Sound Settings" -ForegroundColor White
Write-Host "2. Ensure your PC microphone is not muted" -ForegroundColor White
Write-Host "3. In emulator: Settings > Apps > Squash Training > Permissions > Microphone" -ForegroundColor White
Write-Host "4. Test with Google app: Say 'Ok Google'" -ForegroundColor White

Write-Host "`nTROUBLESHOOTING:" -ForegroundColor Yellow
Write-Host "- If no audio input: Restart emulator with Cold Boot" -ForegroundColor White
Write-Host "- Check Windows privacy settings for microphone access" -ForegroundColor White
Write-Host "- Try: emulator -avd $avdName -feature WindowsHypervisorPlatform" -ForegroundColor White

Write-Host "`nPress any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")