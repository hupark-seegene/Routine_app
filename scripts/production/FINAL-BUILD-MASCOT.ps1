# FINAL-BUILD-MASCOT.ps1
# Complete mascot-based interactive app build with 50+ iterations
# Implements drag navigation, AI voice assistant, and living app features

[CmdletBinding()]
param(
    [int]$MaxCycles = 50,
    [switch]$SkipEmulator = $false,
    [switch]$DebugMode = $false
)

# Configuration
$SCRIPT_VERSION = "1.0.31-MASCOT"
$TIMESTAMP = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent (Split-Path -Parent $SCRIPT_DIR)
$APP_DIR = Join-Path $ROOT_DIR "SquashTrainingApp"
$ANDROID_DIR = Join-Path $APP_DIR "android"
$BUILD_DIR = Join-Path $ROOT_DIR "build-artifacts"
$CYCLE_DIR = Join-Path $BUILD_DIR "cycle-mascot-$SCRIPT_VERSION"
$LOG_FILE = Join-Path $CYCLE_DIR "build-log.txt"

# Android configuration
$ADB = "C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$EMULATOR = "C:\Users\hwpar\AppData\Local\Android\Sdk\emulator\emulator.exe"
$AVD_NAME = "Pixel_6"

# Create directories
New-Item -ItemType Directory -Force -Path $CYCLE_DIR | Out-Null

# Logging function
function Write-Log {
    param($Message, $Type = "INFO")
    $LogMessage = "[$TIMESTAMP] [$Type] $Message"
    Write-Host $LogMessage -ForegroundColor $(if ($Type -eq "ERROR") {"Red"} elseif ($Type -eq "SUCCESS") {"Green"} else {"White"})
    Add-Content -Path $LOG_FILE -Value $LogMessage
}

# Check emulator status
function Test-EmulatorStatus {
    try {
        $devices = & $ADB devices 2>&1
        if ($devices -match "emulator.*device$") {
            return $true
        }
        return $false
    }
    catch {
        return $false
    }
}

# Start emulator if needed
function Start-EmulatorIfNeeded {
    if (-not (Test-EmulatorStatus)) {
        Write-Log "Starting emulator..." "INFO"
        Start-Process -FilePath $EMULATOR -ArgumentList "-avd", $AVD_NAME -NoNewWindow
        
        # Wait for emulator
        $maxWait = 60
        $waited = 0
        while (-not (Test-EmulatorStatus) -and $waited -lt $maxWait) {
            Start-Sleep -Seconds 5
            $waited += 5
            Write-Log "Waiting for emulator... ($waited seconds)" "INFO"
        }
        
        if (Test-EmulatorStatus) {
            Write-Log "Emulator started successfully" "SUCCESS"
            Start-Sleep -Seconds 10 # Extra time for full boot
        } else {
            Write-Log "Failed to start emulator" "ERROR"
            return $false
        }
    }
    return $true
}

# Update AndroidManifest.xml with new permissions and activities
function Update-AndroidManifest {
    Write-Log "Updating AndroidManifest.xml with mascot features..." "INFO"
    
    $manifestPath = Join-Path $ANDROID_DIR "app\src\main\AndroidManifest.xml"
    $manifest = Get-Content $manifestPath -Raw
    
    # Add permissions if not present
    if ($manifest -notmatch 'android\.permission\.RECORD_AUDIO') {
        $manifest = $manifest -replace '(<uses-permission android:name="android\.permission\.INTERNET" />)', 
            '$1
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.VIBRATE" />'
    }
    
    # Add AI Chatbot Activity if not present
    if ($manifest -notmatch 'AIChatbotActivity') {
        $manifest = $manifest -replace '(</application>)', 
            '        <activity
            android:name=".ai.AIChatbotActivity"
            android:label="AI Coach Chat"
            android:exported="false"
            android:theme="@style/AppTheme"/>
    $1'
    }
    
    [System.IO.File]::WriteAllText($manifestPath, $manifest, [System.Text.Encoding]::UTF8)
    Write-Log "AndroidManifest.xml updated" "SUCCESS"
}

# Update build.gradle with new dependencies
function Update-BuildGradle {
    Write-Log "Updating build.gradle with mascot dependencies..." "INFO"
    
    $gradlePath = Join-Path $ANDROID_DIR "app\build.gradle"
    $gradle = Get-Content $gradlePath -Raw
    
    # Add dependencies if not present
    $newDependencies = @"
    // Voice Recognition
    implementation 'com.google.android.gms:play-services-speech:16.0.0'
    
    // Animation
    implementation 'com.airbnb.android:lottie:6.0.0'
    
    // AI Chat
    implementation 'com.squareup.okhttp3:okhttp:4.11.0'
    implementation 'com.google.code.gson:gson:2.10.1'
"@
    
    if ($gradle -notmatch 'play-services-speech') {
        $gradle = $gradle -replace '(dependencies \{)', "`$1`n$newDependencies"
    }
    
    [System.IO.File]::WriteAllText($gradlePath, $gradle, [System.Text.Encoding]::UTF8)
    Write-Log "build.gradle updated" "SUCCESS"
}

# Build the APK
function Build-APK {
    param([int]$CycleNumber)
    
    Write-Log "Building APK for cycle $CycleNumber..." "INFO"
    
    Set-Location $ANDROID_DIR
    
    # Clean previous build
    & .\gradlew.bat clean 2>&1 | Out-Null
    
    # Build debug APK
    $buildOutput = & .\gradlew.bat assembleDebug 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $apkPath = Join-Path $ANDROID_DIR "app\build\outputs\apk\debug\app-debug.apk"
        if (Test-Path $apkPath) {
            $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
            Write-Log "Build successful! APK size: ${apkSize}MB" "SUCCESS"
            
            # Copy APK to cycle directory
            $cycleApkPath = Join-Path $CYCLE_DIR "app-mascot-v$CycleNumber.apk"
            Copy-Item $apkPath $cycleApkPath
            
            return $apkPath
        }
    }
    
    Write-Log "Build failed!" "ERROR"
    $buildOutput | Out-File (Join-Path $CYCLE_DIR "build-error-cycle-$CycleNumber.log")
    return $null
}

# Test mascot features
function Test-MascotFeatures {
    param([int]$CycleNumber)
    
    Write-Log "Testing mascot features for cycle $CycleNumber..." "INFO"
    
    # Test drag navigation
    Write-Log "Testing drag navigation..." "INFO"
    
    # Simulate dragging mascot to profile zone
    & $ADB shell input swipe 540 1200 540 400 1000
    Start-Sleep -Seconds 2
    & $ADB shell screencap -p /sdcard/mascot_drag_profile_$CycleNumber.png
    & $ADB pull /sdcard/mascot_drag_profile_$CycleNumber.png (Join-Path $CYCLE_DIR "mascot_drag_profile_$CycleNumber.png") 2>&1 | Out-Null
    
    # Return to main
    & $ADB shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
    
    # Test long press for voice
    Write-Log "Testing voice activation..." "INFO"
    & $ADB shell input swipe 540 1200 540 1200 2000  # Long press
    Start-Sleep -Seconds 2
    & $ADB shell screencap -p /sdcard/mascot_voice_$CycleNumber.png
    & $ADB pull /sdcard/mascot_voice_$CycleNumber.png (Join-Path $CYCLE_DIR "mascot_voice_$CycleNumber.png") 2>&1 | Out-Null
    
    # Cancel voice
    & $ADB shell input keyevent KEYCODE_BACK
    Start-Sleep -Seconds 1
    
    # Test each zone
    $zones = @(
        @{Name="Checklist"; X=270; Y=800},
        @{Name="Coach"; X=810; Y=800},
        @{Name="Record"; X=270; Y=1600},
        @{Name="History"; X=810; Y=1600}
    )
    
    foreach ($zone in $zones) {
        Write-Log "Testing $($zone.Name) zone..." "INFO"
        & $ADB shell input swipe 540 1200 $($zone.X) $($zone.Y) 800
        Start-Sleep -Seconds 2
        & $ADB shell screencap -p /sdcard/mascot_$($zone.Name)_$CycleNumber.png
        & $ADB pull /sdcard/mascot_$($zone.Name)_$CycleNumber.png (Join-Path $CYCLE_DIR "mascot_$($zone.Name)_$CycleNumber.png") 2>&1 | Out-Null
        & $ADB shell input keyevent KEYCODE_BACK
        Start-Sleep -Seconds 1
    }
    
    Write-Log "Mascot feature testing complete" "SUCCESS"
}

# Main execution
Write-Log "=== FINAL MASCOT BUILD SCRIPT v$SCRIPT_VERSION ===" "INFO"
Write-Log "Starting complete mascot app build and test..." "INFO"

# Check for file guard utility
$fileGuardPath = Join-Path $SCRIPT_DIR "utility\UTIL-FILE-GUARD.ps1"
if (Test-Path $fileGuardPath) {
    & $fileGuardPath -FileName "FINAL-BUILD-MASCOT.ps1" -FileType "script" -Category "BUILD" -Description "Final mascot implementation build"
}

# Update manifest and gradle
Update-AndroidManifest
Update-BuildGradle

# Start emulator if needed
if (-not $SkipEmulator) {
    if (-not (Start-EmulatorIfNeeded)) {
        Write-Log "Cannot proceed without emulator" "ERROR"
        exit 1
    }
}

# Run build and test cycles
$successCount = 0
$failCount = 0

for ($i = 1; $i -le $MaxCycles; $i++) {
    Write-Log "=== CYCLE $i/$MaxCycles ===" "INFO"
    
    # Build APK
    $apkPath = Build-APK -CycleNumber $i
    
    if ($apkPath) {
        # Install APK
        Write-Log "Installing APK..." "INFO"
        & $ADB uninstall com.squashtrainingapp 2>&1 | Out-Null
        $installResult = & $ADB install $apkPath 2>&1
        
        if ($installResult -match "Success") {
            Write-Log "APK installed successfully" "SUCCESS"
            
            # Launch app
            & $ADB shell am start -n com.squashtrainingapp/.MainActivity
            Start-Sleep -Seconds 5
            
            # Test mascot features
            Test-MascotFeatures -CycleNumber $i
            
            # Collect metrics
            $memInfo = & $ADB shell dumpsys meminfo com.squashtrainingapp | Select-String "TOTAL" | Select-Object -First 1
            Write-Log "Memory usage: $memInfo" "INFO"
            
            $successCount++
        } else {
            Write-Log "Installation failed" "ERROR"
            $failCount++
        }
        
        # Uninstall for next cycle
        & $ADB uninstall com.squashtrainingapp 2>&1 | Out-Null
    } else {
        $failCount++
    }
    
    # Progress report
    Write-Log "Progress: Success=$successCount, Failed=$failCount" "INFO"
    
    # Stop if too many failures
    if ($failCount -gt 5) {
        Write-Log "Too many failures, stopping build" "ERROR"
        break
    }
}

# Final report
Write-Log "=== FINAL REPORT ===" "INFO"
Write-Log "Total cycles: $($successCount + $failCount)" "INFO"
Write-Log "Successful: $successCount" "SUCCESS"
Write-Log "Failed: $failCount" $(if ($failCount -gt 0) {"ERROR"} else {"INFO"})
Write-Log "Success rate: $([math]::Round($successCount / ($successCount + $failCount) * 100, 2))%" "INFO"

# Generate summary
$summary = @"
MASCOT BUILD SUMMARY
===================
Version: $SCRIPT_VERSION
Date: $TIMESTAMP
Cycles: $($successCount + $failCount)
Success: $successCount
Failed: $failCount
Success Rate: $([math]::Round($successCount / ($successCount + $failCount) * 100, 2))%

Features Implemented:
- Mascot character with drag navigation
- Voice recognition (2-second long press)
- AI chatbot integration
- Zone-based navigation
- Animated interactions
- Living app experience

Artifacts Location: $CYCLE_DIR
"@

$summary | Out-File (Join-Path $CYCLE_DIR "SUMMARY.txt")
Write-Log "Build complete! Check $CYCLE_DIR for all artifacts" "SUCCESS"

# Open results folder
explorer $CYCLE_DIR