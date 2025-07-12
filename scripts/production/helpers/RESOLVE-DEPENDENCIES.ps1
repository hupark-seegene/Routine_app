<#
.SYNOPSIS
    Dependency Resolution Helper for React Native Integration
#>

param(
    [string]$BuildGradlePath,
    [switch]$CheckOnly = $false
)

function Check-ReactNativeDependencies {
    $nodeModulesPath = Join-Path (Split-Path -Parent (Split-Path -Parent $BuildGradlePath)) "node_modules"
    $rnAndroidPath = Join-Path $nodeModulesPath "react-native\android"
    
    $results = @{
        NodeModulesExists = Test-Path $nodeModulesPath
        ReactNativeExists = Test-Path $rnAndroidPath
        ReactNativeVersion = $null
    }
    
    if ($results.ReactNativeExists) {
        $packageJsonPath = Join-Path $nodeModulesPath "react-native\package.json"
        if (Test-Path $packageJsonPath) {
            $packageJson = Get-Content $packageJsonPath -Raw | ConvertFrom-Json
            $results.ReactNativeVersion = $packageJson.version
        }
    }
    
    return $results
}

function Add-ReactNativeDependencies {
    param([string]$GradlePath)
    
    $content = Get-Content $GradlePath -Raw
    
    # Check if already has RN dependencies
    if ($content -match "com.facebook.react") {
        Write-Host "React Native dependencies already present"
        return $true
    }
    
    # Add dependencies safely
    $dependencyBlock = @"
    
    // React Native core dependencies (Cycle 5)
    implementation fileTree(dir: "libs", include: ["*.jar"])
    
    // Check for local React Native
    def rnPath = file('../../node_modules/react-native/android')
    if (rnPath.exists()) {
        implementation fileTree(dir: rnPath.absolutePath + '/libs', include: ['*.aar'])
    }
"@
    
    # Insert before closing brace of dependencies block
    $content = $content -replace '(dependencies\s*\{[^}]+)(})', "`$1$dependencyBlock`n}"
    
    $content | Out-File -FilePath $GradlePath -Encoding ASCII -NoNewline
    return $true
}

# Main execution
$depCheck = Check-ReactNativeDependencies
Write-Host "Node Modules: $($depCheck.NodeModulesExists)"
Write-Host "React Native: $($depCheck.ReactNativeExists)"
Write-Host "RN Version: $($depCheck.ReactNativeVersion)"

if (-not $CheckOnly) {
    Add-ReactNativeDependencies -GradlePath $BuildGradlePath
}
