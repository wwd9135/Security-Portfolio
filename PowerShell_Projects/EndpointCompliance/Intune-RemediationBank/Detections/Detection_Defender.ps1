<#
.SYNOPSIS
Defender Core Health Detection Script for Intune Remediations
.DESCRIPTION
Checks Service Health, MDE Onboarding, MAPS Connectivity, Signature Age,
and Engine Degradation.
#>

try {
    $Issues = @()

    # 1. Service Status
    $defService = Get-Service -Name "WinDefend" -ErrorAction SilentlyContinue
    if (-not $defService -or $defService.Status -ne 'Running') {
        $Issues += "WinDefend Service Stopped/Missing"
    }

    # 2. Onboarding Status (Registry)
    $OnboardPath = "HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status"
    $Onboard = (Get-ItemProperty -Path $OnboardPath -ErrorAction SilentlyContinue).OnboardingState
    if ($Onboard -ne 1) {
        $Issues += "MDE Not Onboarded"
    }

    # 3. MAPS Connectivity
    $MpCmdRun = "$Env:ProgramFiles\Windows Defender\MpCmdRun.exe"
    if (-not (Test-Path $MpCmdRun)) {
        $Issues += "MpCmdRun.exe missing"
    } else {
        $Output = & $MpCmdRun -ValidateMapsConnection 2>&1
        $ExitCode = $LASTEXITCODE
        if ($ExitCode -ne 0 -or $Output -notmatch 'successfully established a connection') {
            $Issues += "MAPS Connection Failed (ExitCode: $ExitCode)"
        }
    }

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
        exit 0 # CRITICAL: Tells Intune everything is fine
    }

} catch {
    Write-Output "CRITICAL SCRIPT ERROR: $($_.Exception.Message)"
    exit 1
}