# Script to Create App Icons for Squash Training App
# This script creates simple text-based icons with squash theme

$ErrorActionPreference = "Stop"

Write-Host "Creating Squash Training App Icons..." -ForegroundColor Green

# Create icons using Windows built-in capabilities
Add-Type -AssemblyName System.Drawing

function Create-Icon {
    param(
        [int]$Size,
        [string]$OutputPath,
        [bool]$IsRound = $false
    )
    
    # Create bitmap
    $bitmap = New-Object System.Drawing.Bitmap $Size, $Size
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    
    # Set high quality
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
    
    # Background color (dark theme)
    $bgColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
    $graphics.Clear($bgColor)
    
    if ($IsRound) {
        # Create circular background
        $path = New-Object System.Drawing.Drawing2D.GraphicsPath
        $path.AddEllipse(0, 0, $Size, $Size)
        $region = New-Object System.Drawing.Region $path
        $graphics.Clip = $region
        $graphics.Clear($bgColor)
    }
    
    # Draw squash racquet shape (simplified)
    $accentColor = [System.Drawing.Color]::FromArgb(201, 255, 0) # Volt color
    $pen = New-Object System.Drawing.Pen $accentColor, ($Size * 0.05)
    
    # Racquet oval
    $racquetSize = $Size * 0.6
    $racquetX = ($Size - $racquetSize) / 2
    $racquetY = $Size * 0.1
    $graphics.DrawEllipse($pen, $racquetX, $racquetY, $racquetSize, $racquetSize * 0.8)
    
    # Racquet strings (grid)
    $stringPen = New-Object System.Drawing.Pen $accentColor, ($Size * 0.02)
    $gridCount = 4
    for ($i = 1; $i -lt $gridCount; $i++) {
        $x = $racquetX + ($racquetSize / $gridCount) * $i
        $graphics.DrawLine($stringPen, $x, $racquetY + 10, $x, $racquetY + $racquetSize * 0.8 - 10)
        
        $y = $racquetY + ($racquetSize * 0.8 / $gridCount) * $i
        $graphics.DrawLine($stringPen, $racquetX + 10, $y, $racquetX + $racquetSize - 10, $y)
    }
    
    # Handle
    $handleWidth = $Size * 0.15
    $handleHeight = $Size * 0.3
    $handleX = ($Size - $handleWidth) / 2
    $handleY = $racquetY + $racquetSize * 0.8 - 5
    $graphics.FillRectangle([System.Drawing.Brushes]::White, $handleX, $handleY, $handleWidth, $handleHeight)
    
    # Ball
    $ballSize = $Size * 0.15
    $ballX = $Size * 0.65
    $ballY = $Size * 0.35
    $graphics.FillEllipse([System.Drawing.Brushes]::White, $ballX, $ballY, $ballSize, $ballSize)
    
    # Add text for smaller icons
    if ($Size -lt 100) {
        $font = New-Object System.Drawing.Font("Arial", ($Size * 0.2), [System.Drawing.FontStyle]::Bold)
        $brush = New-Object System.Drawing.SolidBrush $accentColor
        $text = "S"
        $textSize = $graphics.MeasureString($text, $font)
        $textX = ($Size - $textSize.Width) / 2
        $textY = $Size * 0.7
        $graphics.DrawString($text, $font, $brush, $textX, $textY)
        $font.Dispose()
        $brush.Dispose()
    }
    
    # Save
    $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Cleanup
    $pen.Dispose()
    $stringPen.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}

# Icon sizes for Android
$iconSizes = @{
    "mipmap-mdpi" = 48
    "mipmap-hdpi" = 72
    "mipmap-xhdpi" = 96
    "mipmap-xxhdpi" = 144
    "mipmap-xxxhdpi" = 192
}

# Create icons for each size
foreach ($folder in $iconSizes.Keys) {
    $size = $iconSizes[$folder]
    $folderPath = "app\src\main\res\$folder"
    
    if (-not (Test-Path $folderPath)) {
        New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
    }
    
    # Regular icon
    $iconPath = Join-Path $folderPath "ic_launcher.png"
    Create-Icon -Size $size -OutputPath $iconPath
    Write-Host "Created: $iconPath ($size x $size)" -ForegroundColor Green
    
    # Round icon
    $roundIconPath = Join-Path $folderPath "ic_launcher_round.png"
    Create-Icon -Size $size -OutputPath $roundIconPath -IsRound $true
    Write-Host "Created: $roundIconPath ($size x $size) [Round]" -ForegroundColor Green
}

# Create adaptive icon configuration
$adaptiveIconXml = @'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
'@

$mipmapAnydpiPath = "app\src\main\res\mipmap-anydpi-v26"
if (-not (Test-Path $mipmapAnydpiPath)) {
    New-Item -ItemType Directory -Path $mipmapAnydpiPath -Force | Out-Null
}

$adaptiveIconXml | Out-File -FilePath "$mipmapAnydpiPath\ic_launcher.xml" -Encoding utf8
$adaptiveIconXml | Out-File -FilePath "$mipmapAnydpiPath\ic_launcher_round.xml" -Encoding utf8

# Create colors.xml for adaptive icon background
$colorsXml = @'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#121212</color>
</resources>
'@

$valuesPath = "app\src\main\res\values"
if (Test-Path "$valuesPath\colors.xml") {
    Write-Host "colors.xml already exists, skipping..." -ForegroundColor Yellow
} else {
    $colorsXml | Out-File -FilePath "$valuesPath\colors.xml" -Encoding utf8
}

Write-Host "`nApp icons created successfully!" -ForegroundColor Green
Write-Host "Icons feature a squash racquet design with volt (#C9FF00) accent color" -ForegroundColor Cyan