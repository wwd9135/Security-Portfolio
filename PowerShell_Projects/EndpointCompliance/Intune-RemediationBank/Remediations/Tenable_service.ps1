$nessusService = Get-Service -Name 'Tenable Nessus Agent' 
if ($null -eq $nessusService) {
    Write-Output "FAIL: Tenable Nessus Agent service not found - agent may not be installed on this device"
    exit 1
}

Write-Output "INFO: Tenable Nessus Agent service found - current status: $($nessusService.Status)"

if ($nessusService.Status -ne 'Running') {
    Write-Output "INFO: Nessus Agent is not running - attempting to start..."
    Start-Service -Name 'Tenable Nessus Agent' -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 45
    $nessusService.Refresh()
    Write-Output "INFO: Nessus Agent status after start attempt: $($nessusService.Status)"

    if ($nessusService.Status -ne 'Running') {
        Write-Output "FAIL: Tenable Nessus Agent could not be started - current status: $($nessusService.Status). Manual investigation required"
        exit 1
    }

    Write-Output "SUCCESS: Tenable Nessus Agent successfully started"
}

Write-Output "SUCCESS: Tenable Nessus Agent is running - no action required"
exit 0
# 