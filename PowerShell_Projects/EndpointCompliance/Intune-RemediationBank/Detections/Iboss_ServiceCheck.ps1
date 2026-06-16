#### #1. Service Check
$ibossService = Get-Service -Name 'IBSA' -ErrorAction SilentlyContinue
if ($null -eq $ibossService) {
exit 1 # Triggers Remediation if service is missing
} elseif ($ibossService.Status -ne 'Running') {
exit 1 # Triggers Remediation if service is stopped
} else {
    exit 0 # COMPLIANT: Tells Intune everything is fine
}
