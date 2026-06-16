<#
.SYNOPSIS
    Intune Proactive Remediation DETECTION — Defender core health composite check.

.DESCRIPTION
    Checks five Defender health indicators in a single pass:
      1. WinDefend service status
      2. MDE onboarding state (registry)
      3. MAPS cloud connectivity (MpCmdRun.exe -ValidateMapsConnection)
      4. Antivirus signature age (<= 3 days)
      5. Engine running mode (must be Normal)

    Exits 1 (unhealthy) if any check fails, surfacing a pipe-separated summary
    of all failures to the Intune portal for triage.

    Exit codes:
      0 = All checks passed — do NOT remediate
      1 = One or more checks failed — run Invoke-DefenderRemediation.ps1
#>

try {
    $Issues = @()

    # 1. Service status
    $defService = Get-Service -Name 'WinDefend' -ErrorAction SilentlyContinue
    if (-not $defService -or $defService.Status -ne 'Running') {
        $Issues += "WinDefend service stopped/missing"
    }

    # 2. MDE onboarding (registry heartbeat written by the sensor installer)
    $OnboardPath = 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status'
    $Onboard = (Get-ItemProperty -Path $OnboardPath -ErrorAction SilentlyContinue).OnboardingState
    if ($Onboard -ne 1) {
        $Issues += "MDE not onboarded (OnboardingState = $Onboard)"
    }

    # 3. MAPS connectivity
    $MpCmdRun = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
    if (-not (Test-Path $MpCmdRun)) {
        $Issues += "MpCmdRun.exe missing"
    }
    else {
        $Output   = & $MpCmdRun -ValidateMapsConnection 2>&1
        $ExitCode = $LASTEXITCODE
        if ($ExitCode -ne 0 -or $Output -notmatch 'successfully established a connection') {
            $Issues += "MAPS connection failed (exit $ExitCode)"
        }
    }

    # 4 & 5. Signature age and engine mode
    try {
        $MPStat = Get-MpComputerStatus -ErrorAction Stop
        if ($MPStat.AntivirusSignatureAge -gt 3) {
            $Issues += "Signatures stale ($($MPStat.AntivirusSignatureAge) days)"
        }
        if ($MPStat.AMRunningMode -ne 'Normal') {
            $Issues += "Engine mode abnormal: $($MPStat.AMRunningMode)"
        }
    }
    catch {
        $Issues += "Engine degraded (Get-MpComputerStatus failed)"
    }

    if ($Issues.Count -gt 0) {
        Write-Output "DEFENDER UNHEALTHY: $($Issues -join ' | ')"
        exit 1
    }

    Write-Output "Defender core health: COMPLIANT"
    exit 0
}
catch {
    Write-Output "SCRIPT ERROR: $($_.Exception.Message)"
    exit 1
}
