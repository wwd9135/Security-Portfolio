$defService = Get-Service -Name "WinDefend" -ErrorAction SilentlyContinue

if ($null -eq $defService) {
    Write-Output "FAIL: WinDefend service missing"
    exit 1
}

if ($defService.Status -ne 'Running') {
    Write-Output "FAIL: WinDefend service not running (Status: $($defService.Status))"
    exit 1
}

# Check for passive mode — running but not actively protecting
$mpStatus = Get-MpComputerStatus -ErrorAction SilentlyContinue
if ($mpStatus -and $mpStatus.AMRunningMode -notin @('Normal', 'Not running')) {
    # Running modes: Normal, Passive, EDR Block Mode, SxS Passive Mode
    Write-Output "WARN: Defender running in $($mpStatus.AMRunningMode) mode"
    # Decide if passive mode is a failure in your environment:
    # exit 1
}

Write-Output "PASS: WinDefend service running (Mode: $($mpStatus.AMRunningMode))"
exit 0