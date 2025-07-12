#!/usr/bin/env pwsh
# UTIL-FILE-GUARD.ps1
# File Creation Guard System
# Prevents duplicate file creation and enforces naming conventions
# Usage: .\UTIL-FILE-GUARD.ps1 -FileName "NEW-SCRIPT.ps1" -FileType "script" -Category "BUILD"

param(
    [Parameter(Mandatory=$true)]
    [string]$FileName,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("script", "document", "config")]
    [string]$FileType,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("BUILD", "RUN", "SETUP", "FIX", "DEPLOY", "UTIL", "GUIDE", "REFERENCE")]
    [string]$Category,
    
    [Parameter(Mandatory=$false)]
    [string]$Description,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

# File Management Rules from FILE_MANAGEMENT_SYSTEM.md
$SCRIPT_CATEGORIES = @{
    "BUILD" = @{
        "pattern" = "BUILD-*.ps1|*-BUILD.ps1"
        "purpose" = "Android/APK build automation"
        "examples" = "BUILD-APK.ps1, GRADLE-BUILD.ps1"
    }
    "RUN" = @{
        "pattern" = "RUN-*.ps1|*-RUN.ps1|START-*.ps1"
        "purpose" = "App execution and deployment"
        "examples" = "RUN-APP.ps1, START-EMULATOR.ps1"
    }
    "SETUP" = @{
        "pattern" = "SETUP-*.ps1|INSTALL-*.ps1|CONFIG-*.ps1"
        "purpose" = "Environment configuration"
        "examples" = "SETUP-ENV.ps1, INSTALL-DEPS.ps1"
    }
    "FIX" = @{
        "pattern" = "FIX-*.ps1|REPAIR-*.ps1|*-FIX.ps1"
        "purpose" = "Problem resolution"
        "examples" = "FIX-GRADLE.ps1, REPAIR-CACHE.ps1"
    }
    "DEPLOY" = @{
        "pattern" = "DEPLOY-*.ps1|INSTALL-*.ps1|PUBLISH-*.ps1"
        "purpose" = "APK installation and distribution"
        "examples" = "DEPLOY-APK.ps1, INSTALL-APK.ps1"
    }
    "UTIL" = @{
        "pattern" = "UTIL-*.ps1|TOOL-*.ps1|HELPER-*.ps1"
        "purpose" = "Utility and helper functions"
        "examples" = "UTIL-CLEAN.ps1, TOOL-ADB.ps1"
    }
}

$DOCUMENT_CATEGORIES = @{
    "GUIDE" = @{
        "pattern" = "*_GUIDE.md|GUIDE_*.md|HOW_TO_*.md"
        "purpose" = "Step-by-step instructions"
        "examples" = "BUILD_GUIDE.md, SETUP_GUIDE.md"
    }
    "REFERENCE" = @{
        "pattern" = "*_REFERENCE.md|REFERENCE_*.md|*_STATUS.md"
        "purpose" = "Technical documentation and status"
        "examples" = "API_REFERENCE.md, BUILD_STATUS.md"
    }
}

function Test-FileExists {
    param([string]$FilePath)
    
    $existingFiles = @()
    
    # Check exact match
    if (Test-Path $FilePath) {
        $existingFiles += $FilePath
    }
    
    # Check similar names (fuzzy matching)
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    $extension = [System.IO.Path]::GetExtension($FilePath)
    $directory = [System.IO.Path]::GetDirectoryName($FilePath)
    
    if ([string]::IsNullOrEmpty($directory)) {
        $directory = "."
    }
    
    # Find similar files
    $pattern = "*$baseName*$extension"
    $similarFiles = Get-ChildItem -Path $directory -Filter $pattern -ErrorAction SilentlyContinue
    
    foreach ($file in $similarFiles) {
        if ($file.Name -ne [System.IO.Path]::GetFileName($FilePath)) {
            $existingFiles += $file.FullName
        }
    }
    
    return $existingFiles
}

function Test-NamingConvention {
    param(
        [string]$FileName,
        [string]$FileType,
        [string]$Category
    )
    
    $errors = @()
    
    if ($FileType -eq "script") {
        if (-not $FileName.EndsWith(".ps1")) {
            $errors += "PowerShell scripts must have .ps1 extension"
        }
        
        if ($Category) {
            $rules = $SCRIPT_CATEGORIES[$Category]
            if ($rules) {
                $patterns = $rules.pattern -split '\|'
                $matchesPattern = $false
                foreach ($pattern in $patterns) {
                    if ($FileName -like $pattern) {
                        $matchesPattern = $true
                        break
                    }
                }
                if (-not $matchesPattern) {
                    $errors += "Script name '$FileName' doesn't match $Category pattern: $($rules.pattern)"
                    $errors += "Examples: $($rules.examples)"
                }
            }
        }
        
        # Check for deprecated patterns
        $deprecatedPatterns = @("*-v2.*", "*-v3.*", "*-old.*", "*-backup.*", "*-temp.*")
        foreach ($pattern in $deprecatedPatterns) {
            if ($FileName -like $pattern) {
                $errors += "Filename contains deprecated pattern '$pattern' - use versioned directories instead"
            }
        }
    }
    
    if ($FileType -eq "document") {
        if (-not $FileName.EndsWith(".md")) {
            $errors += "Documentation files must have .md extension"
        }
        
        if ($Category) {
            $rules = $DOCUMENT_CATEGORIES[$Category]
            if ($rules) {
                $patterns = $rules.pattern -split '\|'
                $matchesPattern = $false
                foreach ($pattern in $patterns) {
                    if ($FileName -like $pattern) {
                        $matchesPattern = $true
                        break
                    }
                }
                if (-not $matchesPattern) {
                    $errors += "Document name '$FileName' doesn't match $Category pattern: $($rules.pattern)"
                    $errors += "Examples: $($rules.examples)"
                }
            }
        }
    }
    
    return $errors
}

function Show-ExistingFiles {
    param([array]$Files)
    
    Write-Host "⚠️  Existing files found:" -ForegroundColor Yellow
    foreach ($file in $Files) {
        Write-Host "   📄 $file" -ForegroundColor Red
    }
    Write-Host ""
}

function Show-Recommendations {
    param(
        [string]$FileName,
        [string]$FileType,
        [string]$Category
    )
    
    Write-Host "💡 Recommendations:" -ForegroundColor Cyan
    
    if ($FileType -eq "script" -and $Category) {
        $rules = $SCRIPT_CATEGORIES[$Category]
        if ($rules) {
            Write-Host "   📋 $Category scripts: $($rules.purpose)" -ForegroundColor Green
            Write-Host "   📝 Naming pattern: $($rules.pattern)" -ForegroundColor Green
            Write-Host "   📖 Examples: $($rules.examples)" -ForegroundColor Green
        }
    }
    
    if ($FileType -eq "document" -and $Category) {
        $rules = $DOCUMENT_CATEGORIES[$Category]
        if ($rules) {
            Write-Host "   📋 $Category documents: $($rules.purpose)" -ForegroundColor Green
            Write-Host "   📝 Naming pattern: $($rules.pattern)" -ForegroundColor Green
            Write-Host "   📖 Examples: $($rules.examples)" -ForegroundColor Green
        }
    }
    
    Write-Host "   🗂️  Consider using existing files or archive/scripts/experimental/ for testing" -ForegroundColor Green
    Write-Host ""
}

# Main execution
Clear-Host
Write-Host "🛡️  FILE CREATION GUARD SYSTEM" -ForegroundColor Magenta
Write-Host "================================" -ForegroundColor Magenta
Write-Host ""

Write-Host "📋 Checking file: $FileName" -ForegroundColor White
Write-Host "📦 Type: $FileType" -ForegroundColor White
if ($Category) {
    Write-Host "🏷️  Category: $Category" -ForegroundColor White
}
Write-Host ""

# Check if file already exists
$existingFiles = Test-FileExists -FilePath $FileName
if ($existingFiles.Count -gt 0) {
    Show-ExistingFiles -Files $existingFiles
    
    if (-not $Force) {
        Write-Host "❌ File creation blocked: Similar files already exist" -ForegroundColor Red
        Write-Host "   Use -Force to override or choose a different name" -ForegroundColor Yellow
        Show-Recommendations -FileName $FileName -FileType $FileType -Category $Category
        exit 1
    } else {
        Write-Host "⚠️  Force flag used - proceeding despite existing files" -ForegroundColor Yellow
        Write-Host ""
    }
}

# Check naming conventions
$namingErrors = Test-NamingConvention -FileName $FileName -FileType $FileType -Category $Category
if ($namingErrors.Count -gt 0) {
    Write-Host "❌ Naming convention violations:" -ForegroundColor Red
    foreach ($error in $namingErrors) {
        Write-Host "   • $error" -ForegroundColor Red
    }
    Write-Host ""
    
    if (-not $Force) {
        Show-Recommendations -FileName $FileName -FileType $FileType -Category $Category
        exit 1
    } else {
        Write-Host "⚠️  Force flag used - proceeding despite naming violations" -ForegroundColor Yellow
        Write-Host ""
    }
}

# All checks passed
Write-Host "✅ File creation approved!" -ForegroundColor Green
Write-Host "📝 File: $FileName" -ForegroundColor Green
if ($Description) {
    Write-Host "📖 Description: $Description" -ForegroundColor Green
}
Write-Host ""

# Log the file creation
$logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | $FileType | $Category | $FileName | $Description"
$logFile = "scripts/utility/file-creation.log"

if (-not (Test-Path $logFile)) {
    New-Item -ItemType File -Path $logFile -Force | Out-Null
    Add-Content -Path $logFile -Value "# File Creation Log"
    Add-Content -Path $logFile -Value "# Format: Timestamp | Type | Category | FileName | Description"
    Add-Content -Path $logFile -Value ""
}

Add-Content -Path $logFile -Value $logEntry

Write-Host "📊 File creation logged to: $logFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "🎯 Remember to:" -ForegroundColor Yellow
Write-Host "   • Follow the established patterns" -ForegroundColor Yellow
Write-Host "   • Add descriptive comments to scripts" -ForegroundColor Yellow
Write-Host "   • Update FILE_MANAGEMENT_SYSTEM.md if needed" -ForegroundColor Yellow
Write-Host "   • Test your script before committing" -ForegroundColor Yellow

exit 0