<#
.SYNOPSIS
    Intune Proactive Remediation DETECTION — WinDefend service check.

.DESCRIPTION
    Checks whether the WinDefend service exists and is running.
    Also surfaces engine running mode as a warning (passive mode is flagged
    but does not fail the check by default — comment in the exit 1 below to
    enforce active-mode-only in your environment).

    Exit codes:
      0 = Service running — do NOT remediate
      1 = Service missing or stopped — run Invoke-DefenderServiceRemediation.ps1
#>

$defService = Get-Service -Name 'WinDefend' -ErrorAction SilentlyContinue

if ($null -eq $defService) {
    Write-Output "FAIL: WinDefend service missing"
    exit 1
}

if ($defService.Status -ne 'Running') {
    Write-Output "FAIL: WinDefend service not running (Status: $($defService.Status))"
    exit 1
}

$mpStatus = Get-MpComputerStatus -ErrorAction SilentlyContinue
if ($mpStatus -and $mpStatus.AMRunningMode -notin @('Normal', 'Not running')) {
    Write-Output "WARN: Defender running in '$($mpStatus.AMRunningMode)' mode"
    # Uncomment to treat passive/EDR-block mode as a failure:
    # exit 1
}

Write-Output "PASS: WinDefend running (Mode: $($mpStatus.AMRunningMode))"
exit 0
