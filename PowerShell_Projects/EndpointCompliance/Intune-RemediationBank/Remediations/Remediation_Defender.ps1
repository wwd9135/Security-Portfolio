$issues = @()

# --- Attempt Signature Update ---
try {
    Update-MpSignature -ErrorAction Stop
    Start-Sleep -Seconds 45 # Give it time to pull down signatures

    $MPStat = Get-MpComputerStatus -ErrorAction Stop
    if ($MPStat.AntivirusSignatureAge -gt 3) {
        $issues += "Signatures still stale after update attempt ($($MPStat.AntivirusSignatureAge) days)"
    }
} catch {
    $issues += "Signature update failed: $($_.Exception.Message)"
}

# --- Passive Mode ---
# Cannot auto-remediate - surface it clearly for manual investigation
try {
    $MPStat = Get-MpComputerStatus -ErrorAction Stop
    if ($MPStat.AMRunningMode -ne 'Normal') {
        $issues += "Engine mode abnormal ($($MPStat.AMRunningMode)) - manual investigation required"
    }
} catch {
    $issues += "Could not verify engine mode post-remediation"
}

# --- Final Exit ---
if ($issues.Count -gt 0) {
    Write-Output "REMEDIATION INCOMPLETE: $($issues -join ' | ')"
    exit 1
}

# 2. Attempt to start the service (May fail if tamper protection enabled)
Write-Output "Defender Engine Health: REMEDIATED"
exit 0

# 1. Attempt to start the service (May fail if tamper protection enabled)
$defService = Get-Service -Name 'WinDefend' -ErrorAction SilentlyContinue
if ($null -eq $defService) {
    exit 1 # Service not found
}
if ($defService.Status -ne 'Running') {
    Start-Service -Name 'WinDefend' -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5 # Wait for the service to attempt to start
    $defService.Refresh()
    if ($defService.Status -ne 'Running') { exit 1 }
}
exit 0