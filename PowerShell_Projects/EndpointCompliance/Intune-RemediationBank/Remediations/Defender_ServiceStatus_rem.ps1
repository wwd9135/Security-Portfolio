$defService = Get-Service -Name 'WinDefend'
if ($null -eq $defService) {
    Write-Output "FAIL: WinDefend service not found on this device - service may have been removed or is not installed"
    exit 1
}

Write-Output "INFO: WinDefend service found - current status: $($defService.Status)"

if ($defService.Status -ne 'Running') {
    Write-Output "INFO: WinDefend is not running - attempting to start..."
    Start-Service -Name 'WinDefend' -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 45
    $defService.Refresh()

    if ($defService.Status -ne 'Running') {
        Write-Output "FAIL: WinDefend could not be started - current status: $($defService.Status). Likely blocked by Tamper Protection - manual remediation required"
        exit 1
    }

    Write-Output "SUCCESS: WinDefend successfully started"
}

Write-Output "SUCCESS: WinDefend is running - no action required"
exit 0