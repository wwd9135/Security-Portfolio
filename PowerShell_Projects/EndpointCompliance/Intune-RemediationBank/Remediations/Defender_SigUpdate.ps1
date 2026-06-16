$issues = @()

Write-Output "INFO: Starting Defender signature update..."
try {
    Update-MpSignature -ErrorAction Stop
    Write-Output "INFO: Signature update command issued - waiting 45 seconds for completion..."
    Start-Sleep -Seconds 45

    $MPStat = Get-MpComputerStatus -ErrorAction Stop
    Write-Output "INFO: Signature age post-update: $($MPStat.AntivirusSignatureAge) day(s)"

    if ($MPStat.AntivirusSignatureAge -gt 3) {
        Write-Output "FAIL: Signatures still stale after update attempt - age: $($MPStat.AntivirusSignatureAge) days"
        $issues += "Signatures still stale after update attempt ($($MPStat.AntivirusSignatureAge) days)"
    } else {
        Write-Output "SUCCESS: Signatures are current after update"
    }
} catch {
    Write-Output "FAIL: Signature update threw an exception - $($_.Exception.Message)"
    $issues += "Signature update failed: $($_.Exception.Message)"
}

Write-Output "INFO: Checking Defender engine running mode..."
try {
    $MPStat = Get-MpComputerStatus -ErrorAction Stop
    Write-Output "INFO: Current AMRunningMode: $($MPStat.AMRunningMode)"

    if ($MPStat.AMRunningMode -ne 'Normal') {
        Write-Output "FAIL: Engine not in Normal mode - currently: $($MPStat.AMRunningMode). Cannot auto-remediate - manual investigation required"
        $issues += "Engine mode abnormal ($($MPStat.AMRunningMode)) - manual investigation required"
    } else {
        Write-Output "SUCCESS: Engine running in Normal mode"
    }#
} catch {
    Write-Output "FAIL: Could not query AMRunningMode - $($_.Exception.Message)"
    $issues += "Could not verify engine mode: $($_.Exception.Message)"
}

if ($issues.Count -gt 0) {
    Write-Output "FAIL: Remediation incomplete - $($issues.Count) issue(s): $($issues -join ' | ')"
    exit 1
}

Write-Output "SUCCESS: Defender engine health fully remediated"
exit 0