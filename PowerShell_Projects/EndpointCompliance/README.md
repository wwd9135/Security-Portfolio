# Endpoint-Management-Toolkit
A collection of specialized PowerShell utilities designed for Enterprise SysAdmins and Security Analysts to automate device auditing and patch diagnostics. 
Rather than relying on generic troubleshooters, these tools interface directly with the **Microsoft Graph API** and **Windows Event Subsystems** to provide granular visibility into endpoint health.

## Included Tools
### 1. [WinUpdate-Diagnostic-Tool](./UpdateStatus)
**Target:** Local Endpoint Troubleshooting
* **Function:** Queries the `Microsoft-Windows-WindowsUpdateClient` provider and system metadata to decipher the current update state.
* **Key Feature:** Maps raw HRESULT error codes to human-readable remediation steps for common patching failures.

### 2. [Intune-Data-Collection-Suite](./Get-IntuneComplianceReport)
**Target:** Cloud-Native Fleet Management
* **Function:** Leverages the Microsoft Graph SDK to perform bulk property retrieval for Intune-managed assets.
* **Key Feature:** Supports flexible input methods, including full-tenant export or targeted queries via external `.txt` asset lists.

## Key Features
* **Graph API Integration:** Uses delegated permissions for secure, authenticated data retrieval from Microsoft Endpoint Manager.
* **Advanced Logging:** All scripts utilize structured error handling to prevent execution hangs during bulk operations.
* **Standardized Output:** Generates audit-ready CSV reports with timestamps for historical tracking.

## Documentation
Each script is housed in its own directory with a dedicated README detailing:
1.  **Required Scopes:** Necessary API permissions (e.g., `DeviceManagementManagedDevices.Read.All`).
2.  **Usage Syntax:** Command-line examples and parameter descriptions.
3.  **Dependency Checks:** Automatic verification of the `Microsoft.Graph` module and administrative privileges.

