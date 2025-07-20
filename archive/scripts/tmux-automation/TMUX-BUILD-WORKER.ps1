# TMUX-BUILD-WORKER.ps1
# Build worker process for continuous automation
# Handles Android APK builds with DDD versioning

param(
    [Parameter(Mandatory=$true)]
    [int]$Iteration,
    
    [Parameter(Mandatory=$true)]
    [string]$DDDVersion
)

$ErrorActionPreference = "Stop"

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item "$ScriptDir/../../../..").FullName
$AppDir = "$ProjectRoot/SquashTrainingApp"
$AndroidDir = "$AppDir/android"
$LogFile = "$ScriptDir/logs/build-logs/build-$Iteration.log"

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
        default { Write-Host $logMessage }
    }
    
    # Write to file
    $logMessage | Add-Content $LogFile
}

function Update-BuildVersion {
    param([string]$Version)
    
    Write-Log "Updating build version to $Version"
    
    $buildGradlePath = "$AndroidDir/app/build.gradle"
    if (Test-Path $buildGradlePath) {
        $content = Get-Content $buildGradlePath -Raw
        
        # Update versionCode based on iteration
        $newVersionCode = 1000 + $Iteration
        $content = $content -replace 'versionCode\s+\d+', "versionCode $newVersionCode"
        
        # Update versionName with DDD version
        $versionName = "1.0.$Iteration-$Version"
        $content = $content -replace 'versionName\s+"[^"]*"', "versionName `"$versionName`""
        
        [System.IO.File]::WriteAllText($buildGradlePath, $content)
        Write-Log "Version updated: code=$newVersionCode, name=$versionName" "SUCCESS"
    } else {
        Write-Log "build.gradle not found at $buildGradlePath" "ERROR"
        throw "Build configuration file not found"
    }
}

function Clean-BuildCache {
    Write-Log "Cleaning build cache"
    
    # Remove build directories
    $buildDirs = @(
        "$AndroidDir/build",
        "$AndroidDir/app/build",
        "$AndroidDir/.gradle"
    )
    
    foreach ($dir in $buildDirs) {
        if (Test-Path $dir) {
            Remove-Item -Path $dir -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "Removed: $dir"
        }
    }
    
    # Clean gradle cache if needed
    if ($Iteration % 10 -eq 0) {
        Write-Log "Performing deep cache clean (every 10 iterations)"
        & cd $AndroidDir
        & ./gradlew.bat clean 2>&1 | Add-Content $LogFile
    }
}

function Build-APK {
    Write-Log "Starting APK build process"
    
    try {
        # Set environment variables
        $env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot"
        $env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
        $env:Path = "$env:JAVA_HOME\bin;$env:ANDROID_HOME\platform-tools;$env:Path"
        
        # Change to android directory
        Set-Location $AndroidDir
        
        # Run gradle build
        Write-Log "Executing gradlew assembleDebug"
        $buildStart = Get-Date
        
        $buildProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "gradlew.bat assembleDebug" `
            -WorkingDirectory $AndroidDir `
            -RedirectStandardOutput "$LogFile.tmp" `
            -RedirectStandardError "$LogFile.err" `
            -NoNewWindow `
            -PassThru
        
        # Monitor build with timeout
        $timeout = 300 # 5 minutes
        if ($buildProcess.WaitForExit($timeout * 1000)) {
            $buildTime = (Get-Date) - $buildStart
            
            # Check exit code
            if ($buildProcess.ExitCode -eq 0) {
                Write-Log "Build completed successfully in $($buildTime.TotalSeconds) seconds" "SUCCESS"
                
                # Check if APK exists
                $apkPath = "$AndroidDir/app/build/outputs/apk/debug/app-debug.apk"
                if (Test-Path $apkPath) {
                    $apkSize = (Get-Item $apkPath).Length / 1MB
                    Write-Log "APK generated: $('{0:N2}' -f $apkSize) MB" "SUCCESS"
                    
                    # Copy APK to output directory
                    $outputPath = "$ScriptDir/logs/build-logs/app-$DDDVersion.apk"
                    Copy-Item $apkPath $outputPath
                    
                    return $true
                } else {
                    Write-Log "APK not found at expected location" "ERROR"
                    return $false
                }
            } else {
                Write-Log "Build failed with exit code: $($buildProcess.ExitCode)" "ERROR"
                
                # Log error details
                if (Test-Path "$LogFile.err") {
                    $errors = Get-Content "$LogFile.err" -Raw
                    Write-Log "Build errors: $errors" "ERROR"
                }
                
                return $false
            }
        } else {
            Write-Log "Build timeout after $timeout seconds" "ERROR"
            $buildProcess.Kill()
            return $false
        }
    } catch {
        Write-Log "Build exception: $_" "ERROR"
        return $false
    } finally {
        # Cleanup temp files
        Remove-Item "$LogFile.tmp" -ErrorAction SilentlyContinue
        Remove-Item "$LogFile.err" -ErrorAction SilentlyContinue
    }
}

function Analyze-BuildFailure {
    Write-Log "Analyzing build failure"
    
    # Common error patterns and solutions
    $errorPatterns = @{
        "Could not find com.android" = "Dependency resolution issue"
        "AAPT2 aapt2" = "Resource processing error"
        "duplicate class" = "Duplicate dependencies"
        "kotlin" = "Kotlin version conflict"
        "heap space" = "Memory allocation issue"
        "SDK location not found" = "Android SDK path issue"
    }
    
    $logContent = Get-Content $LogFile -Tail 100 -ErrorAction SilentlyContinue
    $foundErrors = @()
    
    foreach ($pattern in $errorPatterns.Keys) {
        if ($logContent -match $pattern) {
            $foundErrors += $errorPatterns[$pattern]
            Write-Log "Detected error type: $($errorPatterns[$pattern])" "WARN"
        }
    }
    
    # Save error analysis
    $analysisFile = "$ScriptDir/logs/build-logs/analysis-$Iteration.txt"
    $foundErrors | Out-File $analysisFile
    
    return $foundErrors
}

# Main execution
try {
    Write-Log "=== BUILD WORKER STARTED ==="
    Write-Log "Iteration: $Iteration"
    Write-Log "DDD Version: $DDDVersion"
    Write-Log "Project: $ProjectRoot"
    
    # Update version
    Update-BuildVersion -Version $DDDVersion
    
    # Clean if needed (every 5 iterations or on first run)
    if ($Iteration -eq 1 -or $Iteration % 5 -eq 0) {
        Clean-BuildCache
    }
    
    # Build APK
    $buildSuccess = Build-APK
    
    if ($buildSuccess) {
        Write-Log "BUILD_COMPLETE" "SUCCESS"
        
        # Update metrics
        $metrics = @{
            iteration = $Iteration
            version = $DDDVersion
            status = "success"
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        }
        
        $metricsFile = "$ScriptDir/logs/build-logs/metrics-$Iteration.json"
        $metrics | ConvertTo-Json | Set-Content $metricsFile
        
    } else {
        Write-Log "BUILD_FAILED" "ERROR"
        
        # Analyze failure
        $errors = Analyze-BuildFailure
        
        # Update metrics
        $metrics = @{
            iteration = $Iteration
            version = $DDDVersion
            status = "failed"
            errors = $errors
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        }
        
        $metricsFile = "$ScriptDir/logs/build-logs/metrics-$Iteration.json"
        $metrics | ConvertTo-Json -Depth 10 | Set-Content $metricsFile
    }
    
} catch {
    Write-Log "Build worker error: $_" "ERROR"
    Write-Log "BUILD_FAILED" "ERROR"
    exit 1
} finally {
    Write-Log "=== BUILD WORKER COMPLETED ==="
}