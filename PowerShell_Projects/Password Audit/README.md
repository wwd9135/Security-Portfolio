# Cred-Audit-Toolkit: Local Password & Policy Auditor

A modular PowerShell framework for auditing and remediating credential hygiene across Windows endpoints. This toolkit enables System Administrators to identify "low-hanging fruit" vulnerabilities and enforce security baselines at scale.



## Toolkit Architecture
The toolkit is divided into two distinct phases to ensure a "Verify, then Act" workflow.

### Phase 1: Assessment ([AuditPreRequisites](./AuditPreRequisites))
The `AuditPreRequisites.ps1` script performs a non-destructive audit of the local Security Accounts Manager (SAM) and system configurations to identify common attack vectors:

* **Password Age Analysis:** Detects accounts that have exceeded the 90-day rotation threshold.
* **Administrative Enumeration:** Identifies "Admin Sprawl" by listing all accounts with local privileged access.
* **Encryption Verification:** Scans the registry to ensure reversible `ClearTextPassword` storage is disabled.
* **Baseline Comparison:** Compares local `MinimumPasswordLength` and `PasswordHistory` against organizational policy.

### Phase 2: Remediation ([AuditAction](./AuditAction))
Once the assessment is complete, `AuditAction.ps1` is used to enforce compliance and reduce the attack surface:

* **Stale Data Purging:** Automatically cleans up identified legacy or orphaned account data.
* **Credential Rotation Enforcement:** Triggers the `pwdLastSet` attribute to `0` in Active Directory, forcing a 'Change Password at Next Logon' for non-compliant users.



## Usage

> **Note:** Administrative privileges are required to query high-integrity registry keys and modify Active Directory attributes.

```powershell
# 1. Open PowerShell as Administrator
# 2. Bypass execution policy for the current session
Set-ExecutionPolicy Bypass -Scope Process

# 3. Step One: Generate the Audit Report
.\AuditPreRequisites\AuditPreRequisites.ps1

# 4. Step Two: Execute Remediation based on Report findings
.\AuditAction\AuditAction.ps1

 Security Review
- Non-Destructive Scanning: Phase 1 makes no changes to the system environment, ensuring it is safe for production use during business hours.
- Audited Logic: The remediation logic is designed to be targeted; it only acts on accounts explicitly flagged during the assessment phase.
- Disclaimer: This toolkit is intended for authorized administrative use only. Always test remediation scripts in a staging environment before wide-scale deployment.