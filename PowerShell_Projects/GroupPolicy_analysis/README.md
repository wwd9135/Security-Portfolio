
# Find‑GPOSetting.ps1

A lightweight PowerShell script that searches **all Group Policy Objects** in a domain for a specific text pattern inside their XML reports.  
Useful for quickly identifying which GPO configures a particular registry key, policy, or setting.

---

## Usage

### Default search (EnableCertPaddingCheck)

./Find-GPOSetting.ps1

Search for another pattern
./Find-GPOSetting.ps1 -Search "Wintrust"
./Find-GPOSetting.ps1 -Search "ImagePath" -ShowXmlMatchShow more lines
Show matching XML lines
## Show matching XML lines
./Find-GPOSetting.ps1 -Search "ImagePath" -ShowXmlMatch

### Features
- Search all GPOs for any string or regex pattern
- Clean, readable output
- Optional XML match preview
- Error‑handled GPO scanning
- Progress bar for large environments


## Requirements
- RSAT / Group Policy Management tools installed
- Permission to read GPOs in the domain


## Example Output
✔ Found match in GPO: MO - Windows 10 - Baseline Security
   GUID: 03d809ca-90ee-4367-8fcc-b0ad4181ec3a
---------------------------------------------


## Script
See Find-GPOSetting.ps1 in this repository.

## Notes
This tool is ideal for troubleshooting:

- Conflicting GPO settings
- Registry preference items
- CIS/STIG baseline overrides
- Hardening policy conflicts