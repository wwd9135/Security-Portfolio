# 2. Onboarding Status (Registry)
$OnboardPath = "HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status"
$Onboard = (Get-ItemProperty -Path $OnboardPath -ErrorAction SilentlyContinue).OnboardingState
if ($Onboard -ne 1) {
    exit 1 # CRITICAL: Triggers the Remediation script
} else {
    exit 0 # COMPLIANT: Tells Intune everything is fine
}