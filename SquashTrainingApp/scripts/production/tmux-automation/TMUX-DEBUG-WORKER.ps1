# TMUX-DEBUG-WORKER.ps1
# Debug worker process for continuous automation
# Analyzes failures and applies automated fixes

param(
    [Parameter(Mandatory=$true)]
    [int]$Iteration,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("build", "test")]
    [string]$Phase
)

$ErrorActionPreference = "Stop"

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item "$ScriptDir/../../../..").FullName
$AppDir = "$ProjectRoot/SquashTrainingApp"
$AndroidDir = "$AppDir/android"
$LogFile = "$ScriptDir/logs/debug-logs/debug-$Iteration-$Phase.log"

# Ensure log directory exists
$logDir = Split-Path -Parent $LogFile
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# Initialize log
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Write to console
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARN"  { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        "FIX" { Write-Host $logMessage -ForegroundColor Magenta }
        default { Write-Host $logMessage }
    }
    
    # Write to file
    $logMessage | Add-Content $LogFile
}

# Common error patterns and automated fixes
$ErrorPatterns = @{
    Build = @{
        "Could not find com.android.tools.build:gradle" = {
            Write-Log "Fixing Gradle plugin version" "FIX"
            $buildGradle = "$AndroidDir/build.gradle"
            $content = Get-Content $buildGradle -Raw
            $content = $content -replace 'com.android.tools.build:gradle:[0-9.]+', 'com.android.tools.build:gradle:8.2.1'
            [System.IO.File]::WriteAllText($buildGradle, $content)
        }
        
        "Duplicate class.*kotlin" = {
            Write-Log "Fixing Kotlin duplicate classes" "FIX"
            $buildGradle = "$AndroidDir/build.gradle"
            $content = Get-Content $buildGradle -Raw
            $content = $content -replace 'kotlinVersion = "[0-9.]+"', 'kotlinVersion = "1.9.24"'
            [System.IO.File]::WriteAllText($buildGradle, $content)
        }
        
        "SDK location not found" = {
            Write-Log "Creating local.properties with SDK path" "FIX"
            $localProps = "$AndroidDir/local.properties"
            $sdkPath = "$env:LOCALAPPDATA\Android\Sdk".Replace('\', '\\')
            "sdk.dir=$sdkPath" | Set-Content $localProps
        }
        
        "java.lang.OutOfMemoryError" = {
            Write-Log "Increasing Gradle memory allocation" "FIX"
            $gradleProps = "$AndroidDir/gradle.properties"
            $content = Get-Content $gradleProps -Raw
            if ($content -notmatch "org.gradle.jvmargs") {
                $content += "`norg.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=1024m"
            } else {
                $content = $content -replace 'org.gradle.jvmargs=.*', 'org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=1024m'
            }
            [System.IO.File]::WriteAllText($gradleProps, $content)
        }
        
        "Unable to resolve dependency" = {
            Write-Log "Clearing Gradle cache and retrying" "FIX"
            Remove-Item "$AndroidDir/.gradle" -Recurse -Force -ErrorAction SilentlyContinue
            & cd $AndroidDir
            & ./gradlew.bat clean
        }
    }
    
    Test = @{
        "android.content.ActivityNotFoundException" = {
            Write-Log "Fixing activity export in manifest" "FIX"
            $manifestPath = "$AndroidDir/app/src/main/AndroidManifest.xml"
            $content = Get-Content $manifestPath -Raw
            
            # Ensure all activities are exported
            $activities = @("ChecklistActivity", "RecordActivity", "ProfileActivity", "CoachActivity", "HistoryActivity")
            foreach ($activity in $activities) {
                if ($content -match "<activity[^>]*android:name=`".$activity`"[^>]*>") {
                    if ($content -notmatch "<activity[^>]*android:name=`".$activity`"[^>]*android:exported=`"true`"") {
                        $content = $content -replace "(<activity[^>]*android:name=`".$activity`")", '$1 android:exported="true"'
                        Write-Log "Added export flag to $activity" "FIX"
                    }
                }
            }
            
            [System.IO.File]::WriteAllText($manifestPath, $content)
        }
        
        "java.lang.NullPointerException.*findViewById" = {
            Write-Log "Fixing null view references" "FIX"
            Write-Log "This requires manual code review - marking for attention" "WARN"
            
            # Log the specific file and line if available
            $testLog = "$ScriptDir/logs/test-logs/test-$Iteration.log"
            if (Test-Path $testLog) {
                $stackTrace = Get-Content $testLog | Select-String "at com.squashtrainingapp" | Select-Object -First 5
                Write-Log "Stack trace: $stackTrace" "FIX"
            }
        }
        
        "INSTALL_FAILED_VERSION_DOWNGRADE" = {
            Write-Log "Uninstalling app before install" "FIX"
            $ADB = "C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools\adb.exe"
            & $ADB uninstall com.squashtrainingapp
        }
        
        "Permission denied.*RECORD_AUDIO" = {
            Write-Log "Granting audio permission" "FIX"
            $ADB = "C:\Users\hwpar\AppData\Local\Android\Sdk\platform-tools\adb.exe"
            & $ADB shell pm grant com.squashtrainingapp android.permission.RECORD_AUDIO
        }
    }
}

function Analyze-Logs {
    param([string]$LogPath)
    
    Write-Log "Analyzing logs from $LogPath"
    
    if (-not (Test-Path $LogPath)) {
        Write-Log "Log file not found: $LogPath" "WARN"
        return @()
    }
    
    $content = Get-Content $LogPath -Raw
    $detectedErrors = @()
    
    foreach ($pattern in $ErrorPatterns[$Phase].Keys) {
        if ($content -match $pattern) {
            Write-Log "Detected error pattern: $pattern" "FIX"
            $detectedErrors += @{
                Pattern = $pattern
                Fix = $ErrorPatterns[$Phase][$pattern]
            }
        }
    }
    
    return $detectedErrors
}

function Apply-Fixes {
    param($Errors)
    
    $fixCount = 0
    
    foreach ($error in $Errors) {
        try {
            Write-Log "Applying fix for: $($error.Pattern)" "FIX"
            
            # Execute the fix
            & $error.Fix
            
            $fixCount++
            Write-Log "Fix applied successfully" "SUCCESS"
            
        } catch {
            Write-Log "Failed to apply fix: $_" "ERROR"
        }
    }
    
    return $fixCount
}

function Generate-DebugReport {
    param($Errors, $FixCount)
    
    $report = @{
        iteration = $Iteration
        phase = $Phase
        errorsFound = $Errors.Count
        fixesApplied = $FixCount
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        errorDetails = $Errors | ForEach-Object { $_.Pattern }
    }
    
    $reportPath = "$ScriptDir/logs/debug-logs/report-$Iteration-$Phase.json"
    $report | ConvertTo-Json -Depth 10 | Set-Content $reportPath
    
    Write-Log "Debug report saved to: $reportPath" "SUCCESS"
}

function Check-CommonIssues {
    Write-Log "Checking for common environmental issues" "FIX"
    
    # Check Java version
    $javaVersion = & java -version 2>&1
    if ($javaVersion -match "version `"17") {
        Write-Log "Java 17 detected - OK" "SUCCESS"
    } else {
        Write-Log "Java 17 not detected - may cause issues" "WARN"
    }
    
    # Check Android SDK
    if (Test-Path "$env:LOCALAPPDATA\Android\Sdk") {
        Write-Log "Android SDK found - OK" "SUCCESS"
    } else {
        Write-Log "Android SDK not found at expected location" "ERROR"
    }
    
    # Check Gradle wrapper
    if (Test-Path "$AndroidDir/gradlew.bat") {
        Write-Log "Gradle wrapper found - OK" "SUCCESS"
    } else {
        Write-Log "Gradle wrapper missing" "ERROR"
    }
}

# Main execution
try {
    Write-Log "=== DEBUG WORKER STARTED ==="
    Write-Log "Iteration: $Iteration"
    Write-Log "Debugging Phase: $Phase"
    
    # Determine log file to analyze
    $targetLog = switch ($Phase) {
        "build" { "$ScriptDir/logs/build-logs/build-$Iteration.log" }
        "test" { "$ScriptDir/logs/test-logs/test-$Iteration.log" }
    }
    
    # Check common issues first
    Check-CommonIssues
    
    # Analyze logs for errors
    $errors = Analyze-Logs -LogPath $targetLog
    
    if ($errors.Count -eq 0) {
        Write-Log "No recognized error patterns found" "WARN"
        Write-Log "Manual intervention may be required" "WARN"
        
        # Try to extract any error messages
        if (Test-Path $targetLog) {
            $errorLines = Get-Content $targetLog | Select-String -Pattern "ERROR|FAILED|Exception" | Select-Object -Last 10
            if ($errorLines) {
                Write-Log "Recent error lines:" "WARN"
                $errorLines | ForEach-Object { Write-Log $_ "WARN" }
            }
        }
        
        Write-Log "DEBUG_FAILED" "ERROR"
    } else {
        Write-Log "Found $($errors.Count) error patterns to fix" "FIX"
        
        # Apply fixes
        $fixCount = Apply-Fixes -Errors $errors
        
        # Generate report
        Generate-DebugReport -Errors $errors -FixCount $fixCount
        
        if ($fixCount -gt 0) {
            Write-Log "Applied $fixCount fixes successfully" "SUCCESS"
            Write-Log "DEBUG_COMPLETE" "SUCCESS"
        } else {
            Write-Log "No fixes could be applied" "ERROR"
            Write-Log "DEBUG_FAILED" "ERROR"
        }
    }
    
} catch {
    Write-Log "Debug worker error: $_" "ERROR"
    Write-Log "DEBUG_FAILED" "ERROR"
    exit 1
} finally {
    Write-Log "=== DEBUG WORKER COMPLETED ==="
}