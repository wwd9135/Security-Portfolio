# powershell/automation

Scripts for querying and interrogating the Intune/Entra ID environment via Microsoft Graph, and for basic connectivity triage.

## Files

| File | Purpose |
|---|---|
| `Find-IntunePolicies.ps1` | Searches Intune scripts, proactive remediations, OMA-URI profiles, and Settings Catalog policies for keyword terms — useful for auditing which policies configure a specific registry key or setting |
| `Test-HostConnectivity.ps1` | Pings a list of managed devices from a Defender KQL export (Excel) and reports which are reachable over the network |

## Prerequisites

**Find-IntunePolicies.ps1**
- `Microsoft.Graph` and `Microsoft.Graph.Beta` PowerShell modules
- An Entra ID app registration with `DeviceManagementConfiguration.Read.All` and `DeviceManagementScripts.Read.All` delegated permissions
- Replace `<TENANT-ID>` and `<CLIENT-ID>` in the script before running

**Test-HostConnectivity.ps1**
- `ImportExcel` module (`Install-Module ImportExcel`)
- An Excel export from the Defender KQL `DeviceNetworkInfo` query with `DeviceName` and `IPAddresses` columns
- Network access to device subnets (ICMP not blocked by firewall)

## Example usage

```powershell
# Search for policies containing certificate/TLS hardening terms
.\Find-IntunePolicies.ps1 -Terms "EnableCertPaddingCheck","TLS 1.2"

# Check reachability for a list of devices from a KQL export
.\Test-HostConnectivity.ps1 -Path "C:\exports\DefenderDevices.xlsx"
```
