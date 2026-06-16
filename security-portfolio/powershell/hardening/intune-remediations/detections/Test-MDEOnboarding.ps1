<#
.SYNOPSIS
    Intune Proactive Remediation DETECTION — MDE sensor onboarding state.

.DESCRIPTION
    Reads the OnboardingState registry value written by the MDE sensor installer.
    A value of 1 indicates the device is onboarded to Defender for Endpoint.

    Exit codes:
      0 = Onboarded — do NOT remediate
      1 = Not onboarded or registry key missing — remediation required
#>

$OnboardPath = 'HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status'
$Onboard     = (Get-ItemProperty -Path $OnboardPath -ErrorAction SilentlyContinue).OnboardingState

if ($Onboard -ne 1) {
    Write-Output "FAIL: MDE not onboarded (OnboardingState = $Onboard)"
    exit 1
}

Write-Output "PASS: MDE onboarded"
exit 0
