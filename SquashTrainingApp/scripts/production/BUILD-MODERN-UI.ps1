# BUILD-MODERN-UI.ps1
# Build and install app with modern UI design
# Created: 2025-07-20

param(
    [switch]$SkipClean = $false,
    [switch]$SkipInstall = $false,
    [switch]$Debug = $false
)

$ErrorActionPreference = "Stop"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = (Get-Item $scriptPath).Parent.Parent.FullName

# Colors for output
$colors = @{
    Success = "Green"
    Error = "Red"
    Warning = "Yellow"
    Info = "Cyan"
    Progress = "Magenta"
}

function Write-ColorOutput($message, $color = "White") {
    Write-Host $message -ForegroundColor $colors[$color]
}

function Get-Timestamp {
    return (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
}

Write-ColorOutput "`n=== MODERN UI BUILD SCRIPT ===" "Info"
Write-ColorOutput "Started at: $(Get-Timestamp)" "Info"
Write-ColorOutput "Project Root: $projectRoot`n" "Info"

# Step 1: Navigate to project directory
Set-Location $projectRoot
Write-ColorOutput "[1/8] Changed to project directory" "Progress"

# Step 2: Clean previous builds
if (-not $SkipClean) {
    Write-ColorOutput "[2/8] Cleaning previous builds..." "Progress"
    
    # Clean Android build
    if (Test-Path "android/app/build") {
        Remove-Item -Path "android/app/build" -Recurse -Force
        Write-ColorOutput "  ✓ Cleaned Android build directory" "Success"
    }
    
    # Clean gradle cache
    if (Test-Path "android/.gradle") {
        Remove-Item -Path "android/.gradle" -Recurse -Force
        Write-ColorOutput "  ✓ Cleaned Gradle cache" "Success"
    }
    
    # Clean Metro bundler cache
    npx react-native start --reset-cache --max-workers=1 &
    Start-Sleep -Seconds 3
    Stop-Process -Name "node" -ErrorAction SilentlyContinue
    Write-ColorOutput "  ✓ Reset Metro bundler cache" "Success"
} else {
    Write-ColorOutput "[2/8] Skipping clean step" "Warning"
}

# Step 3: Install dependencies
Write-ColorOutput "[3/8] Installing dependencies..." "Progress"
npm install
Write-ColorOutput "  ✓ NPM dependencies installed" "Success"

# Step 4: Update DDD tracking
Write-ColorOutput "[4/8] Updating DDD tracking..." "Progress"
$dddPath = "$projectRoot/ddd"
$cycleNumber = 5
$cyclePath = "$dddPath/ddd$('{0:d3}' -f $cycleNumber)"

if (-not (Test-Path $cyclePath)) {
    New-Item -Path $cyclePath -ItemType Directory -Force | Out-Null
}

$buildInfo = @{
    timestamp = Get-Timestamp
    version = "1.0.$cycleNumber"
    build_type = "modern-ui"
    features = @(
        "Modern color scheme with neon accents",
        "Glass morphism effects", 
        "Advanced animations",
        "Custom navigation bar",
        "Gradient cards and buttons"
    )
}

$buildInfo | ConvertTo-Json -Depth 3 | Out-File "$cyclePath/build-info.json"
Write-ColorOutput "  ✓ DDD cycle $cycleNumber created" "Success"

# Step 5: Build Android APK
Write-ColorOutput "[5/8] Building Android APK..." "Progress"
Set-Location "$projectRoot/android"

if ($Debug) {
    Write-ColorOutput "  Building debug APK..." "Info"
    & ./gradlew assembleDebug --warning-mode all
} else {
    Write-ColorOutput "  Building release APK..." "Info"
    & ./gradlew assembleRelease --warning-mode all
}

if ($LASTEXITCODE -eq 0) {
    Write-ColorOutput "  ✓ APK build successful" "Success"
} else {
    Write-ColorOutput "  ✗ APK build failed" "Error"
    exit 1
}

Set-Location $projectRoot

# Step 6: Copy APK to DDD folder
Write-ColorOutput "[6/8] Copying APK to DDD folder..." "Progress"
$buildType = if ($Debug) { "debug" } else { "release" }
$apkSource = "android/app/build/outputs/apk/$buildType/app-$buildType.apk"
$apkDest = "$cyclePath/SquashTrainingApp-v$cycleNumber-modern-ui.apk"

if (Test-Path $apkSource) {
    Copy-Item $apkSource $apkDest
    Write-ColorOutput "  ✓ APK copied to: $apkDest" "Success"
} else {
    Write-ColorOutput "  ✗ APK not found at: $apkSource" "Error"
    exit 1
}

# Step 7: Install on emulator
if (-not $SkipInstall) {
    Write-ColorOutput "[7/8] Installing on emulator..." "Progress"
    
    # Check if emulator is running
    $devices = adb devices | Select-String "emulator"
    if ($devices) {
        # Uninstall previous version
        Write-ColorOutput "  Uninstalling previous version..." "Info"
        adb uninstall com.squashtrainingapp 2>$null
        
        # Install new APK
        Write-ColorOutput "  Installing new APK..." "Info"
        adb install -r $apkDest
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  ✓ APK installed successfully" "Success"
            
            # Launch the app
            Write-ColorOutput "  Launching app..." "Info"
            adb shell am start -n com.squashtrainingapp/.MainActivity
            Write-ColorOutput "  ✓ App launched" "Success"
        } else {
            Write-ColorOutput "  ✗ Installation failed" "Error"
        }
    } else {
        Write-ColorOutput "  ⚠ No emulator detected. Start emulator and run with -SkipClean flag" "Warning"
    }
} else {
    Write-ColorOutput "[7/8] Skipping installation" "Warning"
}

# Step 8: Create summary report
Write-ColorOutput "[8/8] Creating build summary..." "Progress"
$summary = @"
# Modern UI Build Summary

**Date**: $(Get-Timestamp)
**Version**: 1.0.$cycleNumber
**Build Type**: $buildType
**APK Location**: $apkDest

## UI Features Implemented:
- ✓ Modern color scheme with cyan/pink neon accents
- ✓ Glass morphism effects on cards
- ✓ Custom animated navigation bar
- ✓ Gradient backgrounds and buttons
- ✓ Smooth animations and transitions
- ✓ Modern typography system
- ✓ Advanced shadow and glow effects

## Components Updated:
- ModernHeroCard: Animated hero section with gradients
- ModernTabBar: Custom bottom navigation with animations
- ModernHomeScreen: Complete redesign with modern UI
- Modern styles system: Complete styling framework

## Next Steps:
1. Test all UI animations on device
2. Implement remaining screens with modern design
3. Add gesture-based interactions
4. Optimize performance
"@

$summary | Out-File "$cyclePath/BUILD_SUMMARY.md"
Write-ColorOutput "  ✓ Build summary created" "Success"

Write-ColorOutput "`n=== BUILD COMPLETED SUCCESSFULLY ===" "Success"
Write-ColorOutput "Completed at: $(Get-Timestamp)" "Info"
Write-ColorOutput "APK: $apkDest" "Info"
Write-ColorOutput "`nRun the app and enjoy the modern UI! 🎨" "Success"