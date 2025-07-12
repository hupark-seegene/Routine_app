<#
.SYNOPSIS
    Automation Status Checker
#>

$AutomationChecks = @{
    EmulatorManagement = Test-Path "$PSScriptRoot\..\..\utility\START-EMULATOR.ps1"
    DependencyResolution = Test-Path "$PSScriptRoot\RESOLVE-DEPENDENCIES.ps1"
    BundleCreation = Test-Path "$PSScriptRoot\CREATE-BUNDLE.ps1"
    BuildScripts = (Get-ChildItem "$PSScriptRoot\.." -Filter "ENHANCED-BUILD-V*.ps1").Count -ge 5
    ArtifactsOrganization = Test-Path "$PSScriptRoot\..\..\..\build-artifacts"
}

$completionRate = ($AutomationChecks.Values | Where-Object { $_ -eq $true }).Count / $AutomationChecks.Count * 100

Write-Host "`nFoundation Automation Status Report" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

foreach ($check in $AutomationChecks.GetEnumerator()) {
    $status = if ($check.Value) { "?? } else { "?? }
    $color = if ($check.Value) { "Green" } else { "Red" }
    Write-Host "$status $($check.Key)" -ForegroundColor $color
}

Write-Host "`nAutomation Completion: $($completionRate.ToString('F0'))%" -ForegroundColor $(if($completionRate -eq 100){"Green"}else{"Yellow"})

return $completionRate
