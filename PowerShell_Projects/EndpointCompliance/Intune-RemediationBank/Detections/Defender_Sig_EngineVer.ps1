# 4 & 5. Engine Health & Signature Age
    try {
        $MPStat = Get-MpComputerStatus -ErrorAction Stop
        
        # 4. Signatures
        if ($MPStat.AntivirusSignatureAge -gt 3) {
            $Issues += "Signatures Stale ($($MPStat.AntivirusSignatureAge) days)"
        }
        
        # 5. Engine Running Mode
        if ($MPStat.AMRunningMode -ne 'Normal') {
            $Issues += "Engine Mode Abnormal: $($MPStat.AMRunningMode)"
        }

    } catch {
        $Issues += "Engine Degraded (Get-MpComputerStatus failed)"
    }
# --- Final Evaluation & Intune Logging ---
    if ($Issues.Count -gt 0) {
        # Outputs the specific failures to the Intune portal
        Write-Output "DEFENDER UNHEALTHY: $($Issues -join ' | ')"
        exit 1 # CRITICAL: Triggers the Remediation script
    } else {
        Write-Output "Defender Core Health: COMPLIANT"
        exit 0 # COMPLIANT: Tells Intune everything is fine
    }