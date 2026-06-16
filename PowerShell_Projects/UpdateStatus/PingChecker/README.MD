## Overview
A PowerShell utility designed to parse JSON data, extract valid IP addresses, and perform automated connectivity tests. The script identifies reachable assets and outputs a structured status table for quick troubleshooting.

## Expected Input
The script expects an object containing a `DeviceName` string and an `IPAddresses` array.

**Example Format:**
```json
{
    "DeviceName": "LAPbwd3d",
    "IPAddresses": [
        {
            "IPAddress": "192.168.1.1",
            "SubnetPrefix": 16,
            "AddressType": "Private"
        }
    ]
}
## How to use?
There are several ways to provide input data to the scanner:
- Manual Input: Import a custom list of IPs from a local .json or .csv file.
- KQL Advanced Hunting: Pipe results directly from Defender for Endpoint (using DeviceInfo or UpdateStatus tables).
- Portal Exports: Process direct exports from the Microsoft Defender Security Center.

## Output
| DeviceName                      | ChosenIP        | Reachable |   Reason |
----------------------------------------------------------------------------
| SRV-PROD-APP-02.corp.internal   | 10.144.176.23   | False     | No reply |
| LAP-JBTB4-WKSTN.sub.domain.com  | 10.213.33.45    | True      | OK |
| LAP-WCV3-REMOTE.sub.domain.com  | 169.254.68.235  | False     | No reply |
| LAP-HRK17-MOBILE.sub.domain.com | 10.213.56.129   | False     | No reply |
| LAP-FKF9-LEGACY.sub.domain.com  | 169.254.64.232  | False     | No reply |
| LAP-FG48-TEST.sub.domain.com    | 169.254.121.236 | False     | No reply |
| SRV-CTX-SHRN-03.corp.internal   | 10.153.90.209   | True      | OK |
| VDI-LDF-SPICE-DE.spice.internal | 10.138.82.206   | False     | No reply |
| LAP-Q0BT-FIELD.sub.domain.com   | 10.213.8.243    | False     | No reply |