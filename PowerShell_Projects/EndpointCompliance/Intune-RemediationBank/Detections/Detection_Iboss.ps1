## iboss Agent Health: Combined PR

This script targets the **IBSA service** and the **ibsa.dll** file to ensure the cloud connector is both installed and functioning.

$Issues = @()

#### #1. Service Check

$ibossService = Get-Service -Name 'IBSA' -ErrorAction SilentlyContinue
if ($null -eq $ibossService) {
$Issues += "Service Missing"
} elseif ($ibossService.Status -ne 'Running') {
$Issues += "Service Stopped"
}

#### 2. DLL Version Check

$IbsaDLL = "$env:ProgramFiles\Phantom\IBSA\ibsa.dll"
$MinVersion = [version]'6.4.110.0'

if (Test-Path $IbsaDLL) {
$CurrentVersion = [version](Get-Item $IbsaDLL).VersionInfo.FileVersionRaw
if ($CurrentVersion -lt $MinVersion) {
$Issues += "Old Version ($CurrentVersion)"
}
} else {
$Issues += "DLL Missing"
}

#### #Final Reporting

if ($Issues.Count -gt 0) {
Write-Output "Non-Compliant: $($Issues -join ' | ')"
exit 1 # Triggers Remediation
}

Write-Output "iboss Health: OK"
exit 0