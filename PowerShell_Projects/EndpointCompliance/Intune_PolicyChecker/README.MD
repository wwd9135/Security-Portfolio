# 🔍 IntuneFind – Intune Policy/Script Search Tool

A lightweight PowerShell tool that scans your Intune tenant for **anything enforcing or referencing a specific configuration**, such as registry keys, settings, or script content.

This script searches across:

- **PowerShell Scripts** (`deviceManagementScripts`)
- **Proactive Remediations** (`deviceHealthScripts`)
- **Custom OMA-URI Profiles**
- **Settings Catalog Policies**

All results are written into:
- Intune_EnableCertPaddingCheck_Findings.json
---

## 🚀 Usage

Run the script after authenticating with Microsoft Graph:

- pwsh.exe -File .\IntuneFind.ps1
or:
- PowerShell.\IntuneFind.ps1Show more lines
You may use a custom Client ID and disable WAM if needed:
PowerShellSet-MgGraphOption -DisableLoginByWAM $trueConnect-MgGraph -ClientId "<APP-ID>" -TenantId "<TENANT-ID>" -Scopes "DeviceManagementConfiguration.Read.All","DeviceManagementScripts.Read.All"Show more lines

## Requirements

- PowerShell 5.1 or PowerShell 7+
- Microsoft.Graph SDK
- (Optional) Microsoft.Graph.Beta module for extended beta support
- 
## Permissions:

- DeviceManagementConfiguration.Read.All
- DeviceManagementScripts.Read.All
Install modules:
PowerShellInstall-Module Microsoft.Graph -Scope CurrentUser -AllowClobberInstall-Module Microsoft.Graph.Beta -Scope CurrentUser -AllowClobberShow more lines

## Output
Results are saved in:
- Intune_EnableCertPaddingCheck_Findings.json

If the file is empty, no matching Intune objects were found- Tailor the 'Terms' array and make it more granular eg. splitting DomainNamePolicies, to domain, name, polcies it'll pull right then.