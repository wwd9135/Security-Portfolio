# IT & Security Portfolio — PowerShell & Detection Engineering

Practical work from day-to-day IT administration and security operations: endpoint hardening, Intune remediation, compliance reporting, incident response helpers, and Microsoft Sentinel / Defender KQL detection rules.

---

## Skills showcased

| Area | Tools / Platforms |
|---|---|
| Endpoint hardening & compliance | Microsoft Intune, Dell Command Update, BitLocker |
| Detection & threat hunting | Microsoft Sentinel, Microsoft Defender for Endpoint, KQL |
| Identity & access | Azure AD / Entra ID, Microsoft Graph API |
| Scripting & automation | PowerShell 5.1 / 7, PSScriptAnalyzer, comment-based help |
| Incident response | Atomic Red Team (audit mode), password audit workflows |
| Reporting & auditing | Group Policy analysis, Windows Update compliance, patch gap reporting |

---

## Repository map

```
security-portfolio/
├── detection/
│   └── kql/                        KQL rules for Sentinel & Defender (threat hunting, compliance)
├── powershell/
│   ├── automation/                 Intune policy queries, connectivity checks
│   ├── hardening/
│   │   ├── dell-command-update/    BIOS & driver update packaging for Intune Win32 apps
│   │   ├── intune-remediations/    Detection + remediation script pairs (Defender, iBoss, Tenable, Chrome, VS Code)
│   │   └── bitlocker-management/  BitLocker PIN reset workflow (MBAM replacement)
│   ├── incident-response/          Atomic Red Team audit runner, password audit tooling
│   ├── reporting/                  Intune compliance export, Windows Update gap report, GPO analysis
│   └── modules/                    Shared helper module used across scripts
└── docs/                           Longer write-ups and reference notes
```

---

## Quick start

Most scripts require the **Microsoft.Graph** PowerShell SDK and appropriate Entra ID permissions. See each folder's `README.md` for prerequisites, required Graph scopes, and example usage.

```powershell
# Example: check Windows Update compliance across managed devices
.\powershell\reporting\Get-UpdateStatus.ps1 -TenantId "<TENANT-ID>" -ClientId "<CLIENT-ID>"
```

---

## Folder READMEs

- [detection/kql](detection/kql/README.md)
- [powershell/automation](powershell/automation/README.md)
- [powershell/hardening/dell-command-update](powershell/hardening/dell-command-update/README.md)
- [powershell/hardening/intune-remediations](powershell/hardening/intune-remediations/README.md)
- [powershell/hardening/bitlocker-management](powershell/hardening/bitlocker-management/README.md)
- [powershell/incident-response](powershell/incident-response/README.md)
- [powershell/reporting](powershell/reporting/README.md)
- [powershell/modules](powershell/modules/README.md)
