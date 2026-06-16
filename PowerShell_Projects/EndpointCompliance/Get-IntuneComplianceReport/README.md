# Intune Compliance Reporter

A PowerShell utility for gathering bulk compliance data from Microsoft Intune based on a hostname list, using server-side OData filtering for efficiency.

## Use Case

System Administrators often receive lists of specific assets from HR or Procurement that need immediate compliance verification. Rather than searching the Intune GUI manually for 50+ devices, this script automates the retrieval of:

* **Compliance State** (Compliant, Non-Compliant, Grace Period, etc.)
* **Primary User UPN**
* **Operating System & Version**
* **Managed Device ID**
* **Encryption & Supervision Status**
* **Exchange Access State**
* **Storage Metrics**
* **Compliance & Configuration Policy Counts**

## Requirements

* **Microsoft Graph PowerShell SDK:** `Install-Module Microsoft.Graph`
* **Permissions:** The following scopes are requested automatically at runtime:
  * `DeviceManagementManagedDevices.Read.All`
  * `DeviceManagementConfiguration.Read.All`
  * `Directory.Read.All`
* **Input File:** A plain text file containing one device hostname per line (see [Input File](#input-file) below).

## Usage
````powershell
# Default CSV output
Get-AdvancedComplianceReport -HostnameFile "C:\hostnames.txt"

# HTML report with custom output path
Get-AdvancedComplianceReport -HostnameFile "C:\hostnames.txt" -Format HTML -OutputPath "C:\report.html"

# JSON output
Get-AdvancedComplianceReport -HostnameFile "C:\hostnames.txt" -Format JSON
````

### Parameters

| Parameter       | Required | Default                                      | Description                                  |
| --------------- | -------- | -------------------------------------------- | -------------------------------------------- |
| `-HostnameFile` | ✅ Yes   | —                                            | Path to a `.txt` file with one hostname per line |
| `-OutputPath`   | No       | `ComplianceReport_<timestamp>.csv`           | Full path for the output file                |
| `-Format`       | No       | `CSV`                                        | Output format: `CSV`, `JSON`, or `HTML`      |

## Input File

Create a plain `.txt` file with one device hostname per line:
````
LAP2323232
LAP2323233
DESK001234
````

* Blank lines are ignored automatically
* Hostnames are normalised to uppercase at runtime, so casing does not matter (`lap001` and `LAP001` are treated identically)
* Devices not found in Intune are skipped silently

## How It Works

Rather than pulling all managed devices and filtering locally, the script queries Intune **per hostname** using an OData server-side filter:
````powershell
Get-MgDeviceManagementManagedDevice -Filter "deviceName eq '$Hostname'"
````

This keeps the script efficient even against large Intune tenants, as only matching records are returned over the wire.

## Output Fields

| Field                       | Description                              |
| --------------------------- | ---------------------------------------- |
| `DeviceName`                | Hostname as registered in Intune         |
| `DeviceId`                  | Intune Managed Device ID (GUID)          |
| `UserPrincipalName`         | Primary enrolled user                    |
| `Platform`                  | Operating system (Windows, iOS, etc.)    |
| `OSVersion`                 | OS build version                         |
| `ComplianceState`           | Compliant / NonCompliant / Unknown / etc.|
| `LastSyncDateTime`          | Last Intune check-in                     |
| `EnrollmentDateTime`        | When the device was enrolled             |
| `ManagementAgent`           | MDM agent type                           |
| `DeviceType`                | Form factor (Laptop, Desktop, Mobile)    |
| `Manufacturer`              | Hardware manufacturer                    |
| `Model`                     | Device model                             |
| `SerialNumber`              | Hardware serial number                   |
| `TotalStorageSpaceInBytes`  | Total disk capacity                      |
| `FreeStorageSpaceInBytes`   | Available disk space                     |
| `CompliancePoliciesCount`   | Number of compliance policies applied    |
| `ConfigurationPoliciesCount`| Number of configuration policies applied |
| `IsEncrypted`               | BitLocker / FileVault encryption status  |
| `IsSupervised`              | Whether the device is supervised         |
| `ExchangeAccessState`       | Exchange conditional access state        |
| `ExchangeAccessStateReason` | Reason for the Exchange access state     |

## Extras

Optionally restrict which properties are returned per device to reduce response payload:
````powershell
Get-MgDeviceManagementManagedDevice -Filter "deviceName eq '$Hostname'" `
    -Property "id,deviceName,userPrincipalName,operatingSystem,complianceState"
````

To query **all managed devices** without a hostname list (e.g. for tenant-wide audits):
````powershell
$AllDevices = Invoke-MgGraphRequest -Method GET `
    -Uri 'https://graph.microsoft.com/beta/devices?$filter=managementType ne null&$count=true&$select=id' `
    -Headers @{ ConsistencyLevel = "eventual" }
````