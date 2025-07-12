#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Generate Android app icons from SVG source in multiple resolutions
    
.DESCRIPTION
    This script generates all required Android app icon sizes from the SVG design.
    Creates icons for different DPI densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi).
    Features a professional squash racket design with volt green theme.
    
.NOTES
    Author: Claude Code
    Version: 2.0
    Enhanced: SVG-based with fallback to GDI+ rendering
#>

param(
    [switch]$Force,          # Force regenerate all icons
    [switch]$UseImageMagick, # Use ImageMagick instead of Node.js
    [switch]$UseFallback,    # Use GDI+ fallback rendering
    [switch]$Verbose         # Verbose output
)

# Color scheme
$Colors = @{
    Primary = "`e[38;2;201;255;0m"    # Volt green #C9FF00
    Success = "`e[32m"                # Green
    Error   = "`e[31m"                # Red
    Warning = "`e[33m"                # Yellow
    Info    = "`e[36m"                # Cyan
    Reset   = "`e[0m"                 # Reset
}

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "Reset")
    Write-Host "$($Colors[$Color])$Message$($Colors.Reset)"
}

# Paths
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$SVGSource = Join-Path $ProjectRoot "assets\icon-design.svg"
$AndroidRes = Join-Path $PSScriptRoot "app\src\main\res"

Write-ColorOutput "🎨 Squash Training App - Advanced Icon Generator" "Primary"
Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Primary"

# Function to check if command exists
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Fallback GDI+ icon creation function (enhanced)
function Create-Icon-Fallback {
    param(
        [int]$Size,
        [string]$OutputPath,
        [bool]$IsRound = $false
    )
    
    Add-Type -AssemblyName System.Drawing
    
    # Create bitmap
    $bitmap = New-Object System.Drawing.Bitmap $Size, $Size
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    
    # Set highest quality
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    
    # Create gradient background
    $bgBrush = New-Object System.Drawing.Drawing2D.RadialGradientBrush(
        [System.Drawing.Point]::new($Size/2, $Size/3),
        [System.Drawing.Point]::new($Size/2, $Size/2),
        [System.Drawing.Color]::FromArgb(44, 44, 44),
        [System.Drawing.Color]::FromArgb(26, 26, 26)
    )
    
    if ($IsRound) {
        # Create circular clipping
        $path = New-Object System.Drawing.Drawing2D.GraphicsPath
        $path.AddEllipse(2, 2, $Size-4, $Size-4)
        $graphics.SetClip($path)
    }
    
    $graphics.FillRectangle($bgBrush, 0, 0, $Size, $Size)
    
    # Draw enhanced squash racket
    $voltColor = [System.Drawing.Color]::FromArgb(201, 255, 0)
    $darkGray = [System.Drawing.Color]::FromArgb(100, 100, 100)
    
    # Racket frame (with gradient)
    $racketPen = New-Object System.Drawing.Pen $voltColor, ($Size * 0.08)
    $racketSize = $Size * 0.55
    $racketX = ($Size - $racketSize) / 2
    $racketY = $Size * 0.15
    
    # Outer frame
    $graphics.DrawEllipse($racketPen, $racketX, $racketY, $racketSize, $racketSize * 0.9)
    
    # Inner frame (thinner)
    $innerPen = New-Object System.Drawing.Pen $voltColor, ($Size * 0.03)
    $innerPen.Color = [System.Drawing.Color]::FromArgb(180, 220, 0)
    $graphics.DrawEllipse($innerPen, $racketX + $Size * 0.05, $racketY + $Size * 0.05, 
                         $racketSize - $Size * 0.1, $racketSize * 0.9 - $Size * 0.1)
    
    # Racket strings (more detailed)
    $stringPen = New-Object System.Drawing.Pen $voltColor, ($Size * 0.015)
    $stringPen.Color = [System.Drawing.Color]::FromArgb(150, 201, 255, 0)
    
    # Horizontal strings
    $stringCount = 6
    for ($i = 1; $i -lt $stringCount; $i++) {
        $y = $racketY + ($racketSize * 0.9 / $stringCount) * $i
        $stringWidth = [Math]::Sqrt([Math]::Pow($racketSize/2, 2) - [Math]::Pow($y - ($racketY + $racketSize * 0.45), 2)) * 2
        $startX = $racketX + ($racketSize - $stringWidth) / 2
        $graphics.DrawLine($stringPen, $startX, $y, $startX + $stringWidth, $y)
    }
    
    # Vertical strings
    for ($i = 1; $i -lt $stringCount; $i++) {
        $x = $racketX + ($racketSize / $stringCount) * $i
        $centerY = $racketY + $racketSize * 0.45
        $stringHeight = [Math]::Sqrt([Math]::Pow($racketSize * 0.45, 2) - [Math]::Pow($x - ($racketX + $racketSize/2), 2)) * 2
        $startY = $centerY - $stringHeight / 2
        $graphics.DrawLine($stringPen, $x, $startY, $x, $startY + $stringHeight)
    }
    
    # Handle (with gradient)
    $handleWidth = $Size * 0.18
    $handleHeight = $Size * 0.35
    $handleX = ($Size - $handleWidth) / 2
    $handleY = $racketY + $racketSize * 0.9 - $Size * 0.05
    
    $handleBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        [System.Drawing.Point]::new($handleX, $handleY),
        [System.Drawing.Point]::new($handleX + $handleWidth, $handleY),
        [System.Drawing.Color]::FromArgb(102, 102, 102),
        [System.Drawing.Color]::FromArgb(51, 51, 51)
    )
    
    $graphics.FillRectangle($handleBrush, $handleX, $handleY, $handleWidth, $handleHeight)
    
    # Handle grip texture
    $gripPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(153, 153, 153)), ($Size * 0.01)
    for ($i = 1; $i -lt 8; $i++) {
        $gripY = $handleY + ($handleHeight / 8) * $i
        $graphics.DrawLine($gripPen, $handleX + 2, $gripY, $handleX + $handleWidth - 2, $gripY)
    }
    
    # Squash ball (with shadow)
    $ballSize = $Size * 0.12
    $ballX = $Size * 0.68
    $ballY = $Size * 0.32
    
    # Ball shadow
    $shadowBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(50, 0, 0, 0))
    $graphics.FillEllipse($shadowBrush, $ballX + 2, $ballY + 2, $ballSize, $ballSize)
    
    # Ball
    $ballBrush = New-Object System.Drawing.SolidBrush $voltColor
    $graphics.FillEllipse($ballBrush, $ballX, $ballY, $ballSize, $ballSize)
    
    # Ball highlight
    $highlightSize = $ballSize * 0.3
    $highlightBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(100, 255, 255, 255))
    $graphics.FillEllipse($highlightBrush, $ballX + $ballSize * 0.2, $ballY + $ballSize * 0.1, $highlightSize, $highlightSize)
    
    # Motion trail
    $trailBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(80, 201, 255, 0))
    $graphics.FillEllipse($trailBrush, $ballX - $Size * 0.08, $ballY + $Size * 0.08, $ballSize * 0.6, $ballSize * 0.6)
    $graphics.FillEllipse($trailBrush, $ballX - $Size * 0.15, $ballY + $Size * 0.15, $ballSize * 0.4, $ballSize * 0.4)
    
    # Save
    $directory = Split-Path $OutputPath -Parent
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    
    $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Cleanup
    $racketPen.Dispose()
    $innerPen.Dispose()
    $stringPen.Dispose()
    $gripPen.Dispose()
    $handleBrush.Dispose()
    $ballBrush.Dispose()
    $highlightBrush.Dispose()
    $trailBrush.Dispose()
    $shadowBrush.Dispose()
    $bgBrush.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
    
    return $true
}

# Android icon specifications
$IconSizes = @{
    "mipmap-mdpi"    = 48
    "mipmap-hdpi"    = 72
    "mipmap-xhdpi"   = 96
    "mipmap-xxhdpi"  = 144
    "mipmap-xxxhdpi" = 192
}

# Determine conversion method
Write-ColorOutput "🔍 Checking available conversion methods..." "Info"

$UseNodeSharp = $false
$ConversionMethod = "fallback"

if ($UseFallback) {
    $ConversionMethod = "fallback"
    Write-ColorOutput "🛠️  Using GDI+ fallback rendering (forced)" "Info"
} elseif ($UseImageMagick -and (Test-Command "convert")) {
    $ConversionMethod = "imagemagick"
    Write-ColorOutput "🛠️  Using ImageMagick for conversion" "Info"
} elseif ((Test-Path $SVGSource) -and (Test-Command "node")) {
    $ConversionMethod = "nodejs"
    Write-ColorOutput "🛠️  Using Node.js with sharp for SVG conversion" "Info"
} elseif (Test-Command "convert") {
    $ConversionMethod = "imagemagick"
    Write-ColorOutput "🛠️  Using ImageMagick for SVG conversion" "Info"
} else {
    $ConversionMethod = "fallback"
    Write-ColorOutput "🛠️  Using GDI+ fallback rendering" "Warning"
}

Write-ColorOutput "📁 Source: $(if (Test-Path $SVGSource) { 'SVG Design' } else { 'GDI+ Rendering' })" "Info"
Write-ColorOutput "📁 Output: $AndroidRes" "Info"

# Generate icons
$GeneratedCount = 0
$TotalCount = $IconSizes.Count * 2  # Normal + round icons

Write-ColorOutput "`n🚀 Generating app icons..." "Primary"

foreach ($Density in $IconSizes.Keys) {
    $Size = $IconSizes[$Density]
    $OutputDir = Join-Path $AndroidRes $Density
    
    # Create output directory
    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    }
    
    $IconPath = Join-Path $OutputDir "ic_launcher.png"
    $RoundIconPath = Join-Path $OutputDir "ic_launcher_round.png"
    
    # Skip if exists and not forcing
    if ((Test-Path $IconPath) -and (Test-Path $RoundIconPath) -and -not $Force) {
        Write-ColorOutput "⏭️  Skipping $Density (already exists, use -Force to regenerate)" "Warning"
        $GeneratedCount += 2
        continue
    }
    
    try {
        $success = $false
        
        switch ($ConversionMethod) {
            "nodejs" {
                # Try Node.js with sharp (SVG)
                if (Test-Path $SVGSource) {
                    $nodeScript = "const sharp = require('sharp'); sharp('$($SVGSource.Replace('\', '\\'))').resize($Size, $Size).png().toFile('$($IconPath.Replace('\', '\\'))').then(() => console.log('OK')).catch(err => { console.error(err); process.exit(1); });"
                    $result = & node -e $nodeScript 2>$null
                    if ($LASTEXITCODE -eq 0) {
                        Copy-Item $IconPath $RoundIconPath -Force
                        $success = $true
                        $GeneratedCount += 2
                    }
                }
            }
            "imagemagick" {
                # Try ImageMagick (SVG or fallback)
                if (Test-Path $SVGSource) {
                    & convert $SVGSource -resize "${Size}x${Size}" $IconPath 2>$null
                    if ($LASTEXITCODE -eq 0) {
                        Copy-Item $IconPath $RoundIconPath -Force
                        $success = $true
                        $GeneratedCount += 2
                    }
                }
            }
        }
        
        # Fallback to GDI+ rendering
        if (-not $success) {
            if (Create-Icon-Fallback -Size $Size -OutputPath $IconPath -IsRound $false) {
                if (Create-Icon-Fallback -Size $Size -OutputPath $RoundIconPath -IsRound $true) {
                    $success = $true
                    $GeneratedCount += 2
                }
            }
        }
        
        if ($success) {
            Write-ColorOutput "✅ Generated: $Density ($Size x $Size)" "Success"
            if ($Verbose) {
                Write-ColorOutput "   📁 $OutputDir" "Info"
            }
        } else {
            Write-ColorOutput "❌ Failed to generate icons for $Density" "Error"
        }
    }
    catch {
        Write-ColorOutput "❌ Error generating $Density icons: $($_.Exception.Message)" "Error"
    }
}

# Generate adaptive icon XML files
Write-ColorOutput "`n🎯 Generating adaptive icon configuration..." "Primary"

$AdaptiveIconXML = @"
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher"/>
</adaptive-icon>
"@

$AdaptiveIconPaths = @(
    "mipmap-anydpi-v26\ic_launcher.xml",
    "mipmap-anydpi-v26\ic_launcher_round.xml"
)

foreach ($AdaptivePath in $AdaptiveIconPaths) {
    $FullPath = Join-Path $AndroidRes $AdaptivePath
    $AdaptiveDir = Split-Path $FullPath -Parent
    
    if (-not (Test-Path $AdaptiveDir)) {
        New-Item -ItemType Directory -Path $AdaptiveDir -Force | Out-Null
    }
    
    $AdaptiveIconXML | Out-File -FilePath $FullPath -Encoding UTF8
    Write-ColorOutput "✅ Generated: $AdaptivePath" "Success"
}

# Update or create colors.xml for adaptive icon background
$ColorsXML = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#1a1a1a</color>
    <color name="ic_launcher_foreground">#C9FF00</color>
    <!-- App theme colors -->
    <color name="volt_green">#C9FF00</color>
    <color name="dark_background">#1a1a1a</color>
    <color name="card_background">#2c2c2c</color>
</resources>
"@

$ColorsPath = Join-Path $AndroidRes "values\colors.xml"
$ColorsDir = Split-Path $ColorsPath -Parent

if (-not (Test-Path $ColorsDir)) {
    New-Item -ItemType Directory -Path $ColorsDir -Force | Out-Null
}

if (-not (Test-Path $ColorsPath) -or $Force) {
    $ColorsXML | Out-File -FilePath $ColorsPath -Encoding UTF8
    Write-ColorOutput "✅ Generated: values\colors.xml" "Success"
} else {
    Write-ColorOutput "⏭️  Skipping colors.xml (already exists, use -Force to overwrite)" "Warning"
}

# Summary
Write-ColorOutput "`n📊 Icon Generation Summary" "Primary"
Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Primary"
Write-ColorOutput "✅ Generated: $GeneratedCount/$TotalCount icons" "Success"
Write-ColorOutput "🎨 Method: $ConversionMethod" "Info"
Write-ColorOutput "📱 Densities: $($IconSizes.Keys -join ', ')" "Info"
Write-ColorOutput "🎯 Theme: Squash racket with volt green (#C9FF00)" "Info"
Write-ColorOutput "📁 Location: $AndroidRes" "Info"

if ($GeneratedCount -eq $TotalCount) {
    Write-ColorOutput "`n🎉 All icons generated successfully!" "Success"
    Write-ColorOutput "Your app now has a professional squash-themed icon!" "Success"
} else {
    Write-ColorOutput "`n⚠️  Some icons may have failed to generate." "Warning"
    Write-ColorOutput "Run with -Verbose for more details." "Warning"
}

Write-ColorOutput "`n🔧 Next steps:" "Info"
Write-ColorOutput "1. Build your app: .\build-and-run.ps1" "Info"
Write-ColorOutput "2. Check the new icon on device/emulator" "Info"
Write-ColorOutput "3. Test adaptive icon behavior on Android 8.0+" "Info"
Write-ColorOutput "4. Consider app store icon (512x512) for publishing" "Info"

# Optional: Generate app store icon
if ((Test-Path $SVGSource) -and ($ConversionMethod -ne "fallback")) {
    $AppStoreIconPath = Join-Path $ProjectRoot "assets\app-store-icon.png"
    Write-ColorOutput "`n💡 Generating app store icon (512x512)..." "Info"
    
    try {
        if ($ConversionMethod -eq "nodejs") {
            $nodeScript = "const sharp = require('sharp'); sharp('$($SVGSource.Replace('\', '\\'))').resize(512, 512).png().toFile('$($AppStoreIconPath.Replace('\', '\\'))').then(() => console.log('App store icon generated')).catch(err => console.error(err));"
            & node -e $nodeScript 2>$null
        } elseif ($ConversionMethod -eq "imagemagick") {
            & convert $SVGSource -resize "512x512" $AppStoreIconPath 2>$null
        }
        
        if (Test-Path $AppStoreIconPath) {
            Write-ColorOutput "✅ App store icon: $AppStoreIconPath" "Success"
        }
    }
    catch {
        # Silent failure for optional feature
    }
}