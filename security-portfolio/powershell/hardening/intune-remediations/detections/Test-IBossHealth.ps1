<#
.SYNOPSIS
    Intune Proactive Remediation DETECTION — iBoss cloud connector health check.

.DESCRIPTION
    Checks the IBSA service (iBoss cloud connector) and verifies the installed
    ibsa.dll version meets the minimum required version. Fails if the service is
    missing/stopped OR if the DLL is absent/outdated.

    Exit codes:
      0 = Service running and DLL meets minimum version — do NOT remediate
      1 = One or more checks failed — run Invoke-IBossServiceRemediation.ps1
#>

$Issues     = @()
$MinVersion = [version]'6.4.110.0'

# 1. Service check
$ibossService = Get-Service -Name 'IBSA' -ErrorAction SilentlyContinue
if ($null -eq $ibossService) {
    $Issues += "Service missing"
}
elseif ($ibossService.Status -ne 'Running') {
    $Issues += "Service stopped"
}

# 2. DLL version check
$IbsaDLL = "$env:ProgramFiles\Phantom\IBSA\ibsa.dll"
if (Test-Path $IbsaDLL) {
    $CurrentVersion = [version](Get-Item $IbsaDLL).VersionInfo.FileVersionRaw
    if ($CurrentVersion -lt $MinVersion) {
        $Issues += "DLL version $CurrentVersion below minimum $MinVersion"
    }
}
else {
    $Issues += "ibsa.dll missing at expected path"
}

if ($Issues.Count -gt 0) {
    Write-Output "Non-compliant: $($Issues -join ' | ')"
    exit 1
}

Write-Output "iBoss health: OK"
exit 0
