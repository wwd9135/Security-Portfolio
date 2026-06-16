# Reporting

Scripts for Intune compliance reporting, Windows Update diagnostics, and GPO analysis.

## Contents

| Script | Purpose |
|---|---|
| `Get-IntuneComplianceReport.ps1` | Export Intune device compliance + config state via Graph API |
| `Get-UpdateStatus.ps1` | Read-only 11-section Windows Update diagnostic |
| `Find-GPOSetting.ps1` | Search all domain GPOs for a string or regex pattern |

---

## Intune Compliance Report

Queries Microsoft Graph for each device in a hostname list and exports compliance policy
state, configuration policy state, encryption status, and device metadata.

### Prerequisites
- Microsoft.Graph PowerShell SDK: `Install-Module Microsoft.Graph -Scope CurrentUser`
- Permissions: `DeviceManagementManagedDevices.Read.All`, `DeviceManagementConfiguration.Read.All`, `Directory.Read.All`

### Usage

```powershell
# CSV report (default)
.\Get-IntuneComplianceReport.ps1 -HostnameFile .\devices.txt

# HTML report
.\Get-IntuneComplianceReport.ps1 -HostnameFile .\devices.txt -Format HTML -OutputPath .\report.html

# JSON for downstream tooling
.\Get-IntuneComplianceReport.ps1 -HostnameFile .\devices.txt -Format JSON -OutputPath .\data.json
```

**Hostname file format**: one device name per line. Blank lines are ignored.

---

## Windows Update Diagnostic

Read-only, no admin required for most sections. Designed to be pasted into a remote
PowerShell session and the full output pasted back for triage.

Covers: build version, pending reboot flags, service status, WSUS policy, last
successful detect/download/install, hotfix history, update backlog, event log errors,
and network connectivity to WU endpoints.

### Usage

```powershell
.\Get-UpdateStatus.ps1
# Copy all console output for triage
```

---

## GPO Setting Search

Searches SYSVOL XML reports for all GPOs in the domain. Useful for auditing which
policies configure a specific registry key or setting — for example, tracking down which
GPO sets `EnableCertPaddingCheck` after a Patch Tuesday.

### Prerequisites
- RSAT Group Policy Management tools
- Domain read access (standard domain user sufficient for SYSVOL)

### Usage

```powershell
# Find GPO configuring a specific registry value
.\Find-GPOSetting.ps1 -Search "EnableCertPaddingCheck"

# Show matching XML lines for debugging
.\Find-GPOSetting.ps1 -Search "Wintrust" -ShowXmlMatch

# Search for any WSUS-related setting
.\Find-GPOSetting.ps1 -Search "WUServer"
```
