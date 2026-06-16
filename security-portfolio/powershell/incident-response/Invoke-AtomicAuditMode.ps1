<#
.SYNOPSIS
    Set all 15 Attack Surface Reduction (ASR) rules to Audit mode.

.DESCRIPTION
    Applies AuditMode (value 2) to every ASR rule GUID supported by Microsoft Defender
    for Endpoint. Audit mode logs rule triggers to the event log without blocking —
    safe to run in production prior to enforcing Block mode.

    Intended for use with Atomic Red Team simulations (T1059, T1048) to validate
    detection coverage before enabling block policies.

    After running, verify with:
        Get-MpPreference | Select-Object -ExpandProperty AttackSurfaceReductionRules_Actions

.NOTES
    Requires: Windows Defender / MDE — run as Administrator or SYSTEM.
    MITRE    : T1059 (Command and Scripting Interpreter), T1048 (Exfiltration over Alt Protocol)
    Reference: https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/attack-surface-reduction-rules-reference

.EXAMPLE
    .\Invoke-AtomicAuditMode.ps1
    Sets all 15 ASR rules to Audit mode and reports current state.
#>

# All 15 ASR rule GUIDs (as of Windows 11 / MDE)
$rules = @(
    'BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550', # Block executable content from email/webmail
    'D4F940AB-401B-4EFC-AADC-AD5F3C50688A', # Block Office apps from creating child processes
    '3B576869-A4EC-4529-8536-B80A7769E899', # Block Office apps from creating executable content
    '75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84', # Block Office apps from injecting into other processes
    'D3E037E1-3EB8-44C8-A917-57927947596D', # Block JavaScript/VBScript from launching downloaded executables
    '5BEB7EFE-FD9A-4556-801D-275E5FFC04CC', # Block execution of potentially obfuscated scripts
    '92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B', # Block Win32 API calls from Office macros
    '01443614-CD74-433A-B99E-2ECDC07BFC25', # Block executable files unless they meet a prevalence / age / trusted list criterion
    'C1DB55AB-C21A-4637-BB3F-A12568109D35', # Use advanced protection against ransomware
    '9E6C4E1F-7D60-472F-BA1A-A39EF669E4B0', # Block credential stealing from LSASS
    'D1E49AAC-8F56-4280-B9BA-993A6D77406C', # Block process creations from PSExec and WMI commands
    'B2B3F03D-6A65-4F7B-A9C7-1C7EF74A9BA4', # Block untrusted and unsigned processes from USB
    '26190899-1602-49E8-8B27-EB1D0A1CE869', # Block Office communication app from creating child processes
    '7674BA52-37EB-4A4F-A9A1-F0F9A1619A2C', # Block Adobe Reader from creating child processes
    'E6DB77E5-3DF2-4CF1-B95A-636979351E5B'  # Block persistence through WMI event subscription
)

$applied  = 0
$failures = @()

foreach ($rule in $rules) {
    try {
        Add-MpPreference -AttackSurfaceReductionRules_Ids $rule `
                         -AttackSurfaceReductionRules_Actions AuditMode `
                         -ErrorAction Stop
        $applied++
    }
    catch {
        $failures += [PSCustomObject]@{ Rule = $rule; Error = $_.Exception.Message }
    }
}

Write-Host "Applied AuditMode to $applied / $($rules.Count) rules."

if ($failures.Count -gt 0) {
    Write-Warning "$($failures.Count) rule(s) failed:"
    $failures | Format-Table -AutoSize
}

# Verification
$currentActions = Get-MpPreference | Select-Object -ExpandProperty AttackSurfaceReductionRules_Actions
Write-Host "Current ASR rule actions: $($currentActions -join ', ')"
