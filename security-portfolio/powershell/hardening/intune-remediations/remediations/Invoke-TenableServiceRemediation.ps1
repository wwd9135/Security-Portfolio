<#
.SYNOPSIS
    Intune Proactive Remediation REMEDIATION — Start the Tenable Nessus Agent service.

.DESCRIPTION
    Attempts to start the 'Tenable Nessus Agent' service if it is not running.
    Waits 45 seconds for the service to initialise before checking final status.

    Exit codes:
      0 = Service running
      1 = Service not found or could not be started
#>

$nessusService = Get-Service -Name 'Tenable Nessus Agent' -ErrorAction SilentlyContinue
if ($null -eq $nessusService) {
    Write-Output "FAIL: Tenable Nessus Agent service not found — agent may not be installed"
    exit 1
}

Write-Output "INFO: Nessus Agent current status: $($nessusService.Status)"

if ($nessusService.Status -ne 'Running') {
    Write-Output "INFO: Attempting to start Tenable Nessus Agent..."
    Start-Service -Name 'Tenable Nessus Agent' -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 45
    $nessusService.Refresh()

    if ($nessusService.Status -ne 'Running') {
        Write-Output "FAIL: Nessus Agent could not be started (Status: $($nessusService.Status))"
        exit 1
    }

    Write-Output "SUCCESS: Tenable Nessus Agent started"
}

Write-Output "SUCCESS: Tenable Nessus Agent is running"
exit 0
