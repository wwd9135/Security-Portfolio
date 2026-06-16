# DCU BIOS Auto-Update - Proactive Remediation REMEDIATION
# -------------------------------------------------------------------
# Deletes the heartbeat value so the Win32 app detection flips to "not installed"
# and Intune re-runs the PSADT app, which re-scans/applies BIOS updates and
# re-stamps the key in the current (invariant) format.

$RegPath = 'HKLM:\SOFTWARE\DELL'
$RegName = 'DCUAutoBIOSUpdatesLastRun'

try {
    if (Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue) {
        Remove-ItemProperty -Path $RegPath -Name $RegName -Force -ErrorAction Stop
        Write-Output "Removed '$RegName' from '$RegPath'. App will re-run on next evaluation."
        exit 0
    }
    else {
        Write-Output "'$RegName' not present at '$RegPath' - nothing to remove."
        exit 0
    }
}
catch {
    Write-Error "Failed to remove '$RegName' from '$RegPath': $_"
    exit 1
}
