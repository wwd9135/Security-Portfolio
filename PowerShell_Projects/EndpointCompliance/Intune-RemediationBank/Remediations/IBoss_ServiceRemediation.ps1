$ibossService = Get-Service -Name 'IBSA'
if ($null -eq $ibossService) {
    Write-Output "FAIL: IBSA service not found - iboss may not be installed on this device"
    exit 1
}

Write-Output "INFO: IBSA service found - current status: $($ibossService.Status)"

if ($ibossService.Status -ne 'Running') {
    Write-Output "INFO: IBSA is not running - attempting to start..."
    Start-Service -Name 'IBSA' -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 45
    $ibossService.Refresh()
    Write-Output "INFO: IBSA status after start attempt: $($ibossService.Status)"
}

if ($ibossService.Status -ne 'Running') {
    Write-Output "FAIL: IBSA could not be started - current status: $($ibossService.Status). Manual investigation required"
    exit 1
}

Write-Output "SUCCESS: IBSA service is running"
exit 0