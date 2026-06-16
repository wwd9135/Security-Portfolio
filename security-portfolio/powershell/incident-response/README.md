# Incident Response & Security Testing

Scripts for attack surface hardening validation and AD account hygiene.

## Contents

| Script | Purpose |
|---|---|
| `Invoke-AtomicAuditMode.ps1` | Set all 15 ASR rules to Audit mode for Atomic Red Team simulation |
| `password-audit/Invoke-PasswordAuditPrereqs.ps1` | Query AD for accounts with stale/never-expiring passwords |
| `password-audit/Invoke-PasswordAuditAction.ps1` | Force ChangePasswordAtLogon on flagged accounts |

---

## ASR Audit Mode (`Invoke-AtomicAuditMode.ps1`)

Sets all 15 Attack Surface Reduction rule GUIDs to **AuditMode** (value 2). Audit mode
records triggers to the event log without blocking — safe to enable in production before
committing to Block mode.

**Use case**: Run before Atomic Red Team T1059 / T1048 simulations to validate that
Defender for Endpoint is generating the expected detections in MDE Advanced Hunting.

### Prerequisites
- Windows Defender / MDE running on endpoint
- Administrator or SYSTEM context

### Usage
```powershell
.\Invoke-AtomicAuditMode.ps1
```

### Verify
```powershell
Get-MpPreference | Select-Object -ExpandProperty AttackSurfaceReductionRules_Actions
# All values should be 2 (AuditMode)
```

### Switch to Block mode
```powershell
# Replace AuditMode with Enabled for individual rules once detections are validated
Add-MpPreference -AttackSurfaceReductionRules_Ids '<GUID>' `
                 -AttackSurfaceReductionRules_Actions Enabled
```

---

## Password Audit (`password-audit/`)

Two-phase workflow for AD password hygiene — typically run during an IR engagement or
scheduled security review.

### Phase 1 — Prerequisites (enumerate flagged accounts)

```powershell
.\Invoke-PasswordAuditPrereqs.ps1 -DaysUntilStale 60 -ExportPath .\flagged.csv
```

Flags accounts where any of the following is true:
- `PasswordNeverExpires` is set
- Password age exceeds the domain max-age policy
- No logon in the last `-DaysUntilStale` days (default: 90)

Output: CSV report for review before actioning.

### Phase 2 — Action (force password change)

```powershell
.\Invoke-PasswordAuditAction.ps1 -UserListFile .\flagged.csv -AuditDate "2025-10-01"
```

For each SamAccountName in the input file:
- If not found in AD → logged as removed
- If `PasswordLastSet` is on or before `-AuditDate` → `ChangePasswordAtLogon = $true`
- Failures collected and reported at exit

Supports `-WhatIf` for a dry run before committing changes.

### Prerequisites
- RSAT Active Directory module (`Import-Module ActiveDirectory`)
- Account with `Set-ADUser` permission (or Domain Admin for initial audit)
