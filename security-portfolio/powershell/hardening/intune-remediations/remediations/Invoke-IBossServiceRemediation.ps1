<#
.SYNOPSIS
    Intune Proactive Remediation REMEDIATION — Start the iBoss IBSA service.

.DESCRIPTION
    Attempts to start the IBSA (iBoss cloud connector) service. Waits 45 seconds
    for the service to initialise before checking its final status. Exits 1 if
    the service cannot be started, prompting manual investigation.

    Paired with Test-IBossHealth.ps1.

    Exit codes:
      0 = IBSA service is running
      1 = Service not found or could not be started
#>

$ibossService = Get-Service -Name 'IBSA' -ErrorAction SilentlyContinue
if ($null -eq $ibossService) {
    Write-Output "FAIL: IBSA service not found — iBoss may not be installed on this device"
    exit 1
}

Write-Output "INFO: IBSA current status: $($ibossService.Status)"

if ($ibossService.Status -ne 'Running') {
    Write-Output "INFO: Attempting to start IBSA..."
    Start-Service -Name 'IBSA' -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 45
    $ibossService.Refresh()
}

if ($ibossService.Status -ne 'Running') {
    Write-Output "FAIL: IBSA could not be started (Status: $($ibossService.Status)) — manual investigation required"
    exit 1
}

Write-Output "SUCCESS: IBSA service is running"
exit 0
