<#
.SYNOPSIS
    Intune Proactive Remediation REMEDIATION — DCU BIOS auto-update heartbeat reset.

.DESCRIPTION
    Removes the BIOS update heartbeat registry value so that the Win32 app detection
    flips to "not installed". Intune then re-runs Invoke-BIOSUpdatePackage.ps1, which
    re-scans for BIOS updates and re-stamps the key in the current invariant format.

    Designed to be deployed as the Remediation script of an Intune Proactive Remediation
    paired with Test-BIOSUpdateHeartbeat.ps1.

.NOTES
    Registry path : HKLM:\SOFTWARE\DELL\DCUAutoBIOSUpdatesLastRun
#>

$RegPath = 'HKLM:\SOFTWARE\DELL'
$RegName = 'DCUAutoBIOSUpdatesLastRun'

try {
    if (Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue) {
        Remove-ItemProperty -Path $RegPath -Name $RegName -Force -ErrorAction Stop
        Write-Output "Removed '$RegName' from '$RegPath'. App will re-run on next Intune evaluation."
        exit 0
    }
    else {
        Write-Output "'$RegName' not present at '$RegPath' — nothing to remove."
        exit 0
    }
}
catch {
    Write-Error "Failed to remove '$RegName' from '$RegPath': $_"
    exit 1
}
