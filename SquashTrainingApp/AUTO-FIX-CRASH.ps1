# Auto Fix Crash Script - Analyzes and fixes common Android app crashes
param(
    [string]$LogFile = "",
    [switch]$Monitor = $false
)

$ErrorActionPreference = "Continue"

Write-Host "`n=== AUTO FIX CRASH ANALYZER ===" -ForegroundColor Cyan

# Common crash patterns and fixes
$crashPatterns = @{
    "java.lang.ClassNotFoundException: Didn't find class `"(.+?)`"" = {
        param($className)
        Write-Host "[Fix] Missing class: $className" -ForegroundColor Yellow
        
        # Check if it's a native module issue
        if ($className -match "com\.oblador|com\.swmansion|org\.pgsqlite") {
            Write-Host "[Fix] Native module class missing, checking configuration..." -ForegroundColor Yellow
            return "native_module"
        }
        
        # Check if it's a ProGuard issue
        if (Test-Path "android\app\proguard-rules.pro") {
            Write-Host "[Fix] Adding ProGuard keep rule for $className" -ForegroundColor Yellow
            Add-Content "android\app\proguard-rules.pro" "-keep class $className { *; }"
            return "proguard"
        }
        
        return "unknown"
    }
    
    "java.lang.NoSuchMethodError: No virtual method (.+?) in class (.+?)" = {
        param($method, $class)
        Write-Host "[Fix] Missing method: $method in $class" -ForegroundColor Yellow
        return "method_missing"
    }
    
    "Permission Denial: .+ requires (.+?) permission" = {
        param($permission)
        Write-Host "[Fix] Missing permission: $permission" -ForegroundColor Yellow
        
        # Add permission to AndroidManifest.xml
        $manifest = "android\app\src\main\AndroidManifest.xml"
        $content = Get-Content $manifest -Raw
        
        if ($content -notmatch $permission) {
            $newPermission = "    <uses-permission android:name=`"$permission`" />`n"
            $content = $content -replace "(<manifest[^>]*>)", "`$1`n$newPermission"
            Set-Content $manifest $content
            Write-Host "[Fix] Added permission to AndroidManifest.xml" -ForegroundColor Green
            return "permission_added"
        }
        
        return "permission_exists"
    }
    
    "java.lang.UnsatisfiedLinkError: couldn't find DSO to load: (.+?)" = {
        param($library)
        Write-Host "[Fix] Missing native library: $library" -ForegroundColor Yellow
        
        # Update packagingOptions in build.gradle
        $buildGradle = "android\app\build.gradle"
        $content = Get-Content $buildGradle -Raw
        
        if ($content -match "packagingOptions") {
            # Add pickFirst for the library
            $pickFirst = "        pickFirst '**/$library'"
            $content = $content -replace "(packagingOptions\s*\{)", "`$1`n$pickFirst"
            Set-Content $buildGradle $content
            Write-Host "[Fix] Updated packagingOptions for $library" -ForegroundColor Green
            return "packaging_updated"
        }
        
        return "packaging_not_found"
    }
    
    "Package (.+?) does not exist" = {
        param($package)
        Write-Host "[Fix] Missing package: $package" -ForegroundColor Yellow
        
        # Map common packages to their modules
        $packageMap = @{
            "com.oblador.vectoricons" = "react-native-vector-icons"
            "com.swmansion.rnscreens" = "react-native-screens"
            "org.pgsqlite" = "react-native-sqlite-storage"
            "com.th3rdwave.safeareacontext" = "react-native-safe-area-context"
            "com.BV.LinearGradient" = "react-native-linear-gradient"
            "com.horcrux.svg" = "react-native-svg"
        }
        
        foreach ($key in $packageMap.Keys) {
            if ($package -match $key) {
                Write-Host "[Fix] Package belongs to module: $($packageMap[$key])" -ForegroundColor Green
                return "check_module_$($packageMap[$key])"
            }
        }
        
        return "unknown_package"
    }
}

# Function to analyze log file
function Analyze-LogFile {
    param($logPath)
    
    if (-not (Test-Path $logPath)) {
        Write-Host "Log file not found: $logPath" -ForegroundColor Red
        return
    }
    
    $content = Get-Content $logPath -Raw
    $fixes = @()
    
    foreach ($pattern in $crashPatterns.Keys) {
        if ($content -match $pattern) {
            $matches = [regex]::Matches($content, $pattern)
            foreach ($match in $matches) {
                Write-Host "`nFound crash pattern: $($match.Groups[0].Value)" -ForegroundColor Red
                
                # Extract parameters and call fix function
                $params = @()
                for ($i = 1; $i -lt $match.Groups.Count; $i++) {
                    $params += $match.Groups[$i].Value
                }
                
                $fixResult = & $crashPatterns[$pattern] @params
                $fixes += @{
                    Pattern = $pattern
                    Match = $match.Groups[0].Value
                    Result = $fixResult
                }
            }
        }
    }
    
    return $fixes
}

# Function to get current logcat
function Get-CurrentCrash {
    Write-Host "Capturing current crash logs..." -ForegroundColor Yellow
    
    $tempLog = "$env:TEMP\current_crash.log"
    $adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
    
    # Get last 500 lines of logcat
    & $adb logcat -d -t 500 > $tempLog
    
    return $tempLog
}

# Main execution
if ($Monitor) {
    Write-Host "Monitoring for crashes... Press Ctrl+C to stop" -ForegroundColor Cyan
    
    $adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
    & $adb logcat -c  # Clear logcat
    
    while ($true) {
        Start-Sleep -Seconds 2
        $tempLog = "$env:TEMP\monitor_crash.log"
        & $adb logcat -d > $tempLog
        
        $content = Get-Content $tempLog -Raw
        if ($content -match "FATAL EXCEPTION|AndroidRuntime.*FATAL") {
            Write-Host "`n!!! CRASH DETECTED !!!" -ForegroundColor Red
            $fixes = Analyze-LogFile -logPath $tempLog
            
            if ($fixes.Count -gt 0) {
                Write-Host "`nApplied fixes:" -ForegroundColor Green
                $fixes | ForEach-Object {
                    Write-Host "  - $($_.Result)" -ForegroundColor Yellow
                }
                
                Write-Host "`nRecommendation: Rebuild the app with:" -ForegroundColor Cyan
                Write-Host "  .\MCP-FULL-AUTOMATION.ps1 -SkipClean" -ForegroundColor White
            }
            
            & $adb logcat -c  # Clear for next crash
        }
    }
} else {
    # Analyze specific log file or current crash
    if (-not $LogFile) {
        $LogFile = Get-CurrentCrash
        Write-Host "Analyzing current device logs..." -ForegroundColor Yellow
    }
    
    $fixes = Analyze-LogFile -logPath $LogFile
    
    if ($fixes.Count -eq 0) {
        Write-Host "`nNo known crash patterns found." -ForegroundColor Green
        Write-Host "The app might be running correctly or the crash is unknown." -ForegroundColor Gray
    } else {
        Write-Host "`n=== CRASH ANALYSIS COMPLETE ===" -ForegroundColor Cyan
        Write-Host "Found $($fixes.Count) issues" -ForegroundColor Yellow
        
        $shouldRebuild = $false
        foreach ($fix in $fixes) {
            if ($fix.Result -in @("permission_added", "packaging_updated", "proguard")) {
                $shouldRebuild = $true
            }
        }
        
        if ($shouldRebuild) {
            Write-Host "`nChanges were made. Please rebuild the app:" -ForegroundColor Cyan
            Write-Host "  .\MCP-FULL-AUTOMATION.ps1 -SkipClean" -ForegroundColor White
        }
    }
}

Write-Host "`nDone!" -ForegroundColor Green