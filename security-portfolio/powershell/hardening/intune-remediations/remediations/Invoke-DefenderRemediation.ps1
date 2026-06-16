<#
.SYNOPSIS
    Intune Proactive Remediation REMEDIATION — Defender signature update and mode check.

.DESCRIPTION
    Attempts to update Defender antivirus signatures and verifies the engine is
    running in Normal mode post-update. Service restart is intentionally omitted
    because Tamper Protection blocks it on managed devices — manual investigation
    is flagged instead.

    Paired with Test-DefenderHealth.ps1.

    Exit codes:
      0 = Remediation succeeded
      1 = Remediation incomplete — manual investigation required
#>

$issues = @()

# Attempt signature update
try {
    Update-MpSignature -ErrorAction Stop
    Start-Sleep -Seconds 45

    $MPStat = Get-MpComputerStatus -ErrorAction Stop
    if ($MPStat.AntivirusSignatureAge -gt 3) {
        $issues += "Signatures still stale after update ($($MPStat.AntivirusSignatureAge) days)"
    }
}
catch {
    $issues += "Signature update failed: $($_.Exception.Message)"
}

# Engine mode check — cannot auto-remediate passive mode; surface for investigation
try {
    $MPStat = Get-MpComputerStatus -ErrorAction Stop
    if ($MPStat.AMRunningMode -ne 'Normal') {
        $issues += "Engine mode abnormal ($($MPStat.AMRunningMode)) — manual investigation required"
    }
}
catch {
    $issues += "Could not verify engine mode post-remediation"
}

# Attempt WinDefend service start (may fail if Tamper Protection is enabled)
$defService = Get-Service -Name 'WinDefend' -ErrorAction SilentlyContinue
if ($defService -and $defService.Status -ne 'Running') {
    Start-Service -Name 'WinDefend' -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    $defService.Refresh()
    if ($defService.Status -ne 'Running') {
        $issues += "WinDefend could not be started — Tamper Protection may be blocking"
    }
}

if ($issues.Count -gt 0) {
    Write-Output "REMEDIATION INCOMPLETE: $($issues -join ' | ')"
    exit 1
}

Write-Output "Defender health: REMEDIATED"
exit 0
