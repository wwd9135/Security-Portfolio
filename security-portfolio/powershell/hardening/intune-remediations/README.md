# Intune Proactive Remediations

Detection + remediation script pairs for Microsoft Intune Proactive Remediations (now
**Remediations** in the Intune portal). Each pair exits 0 (healthy / remediated) or 1
(needs action / remediation incomplete).

## Structure

```
intune-remediations/
├── detections/          ← Detection scripts (exit 0 = healthy, 1 = needs remediation)
│   ├── Test-DefenderHealth.ps1
│   ├── Test-DefenderService.ps1
│   ├── Test-MDEOnboarding.ps1
│   ├── Test-IBossHealth.ps1
│   ├── Test-TenableAgentLink.ps1
│   ├── Test-ChromeInstall.ps1
│   └── Test-VSCodeExtensionPolicy.ps1
└── remediations/        ← Remediation scripts (exit 0 = success, 1 = incomplete)
    ├── Invoke-DefenderRemediation.ps1
    ├── Invoke-IBossServiceRemediation.ps1
    ├── Invoke-TenableServiceRemediation.ps1
    ├── Invoke-TenableAgentLink.ps1
    └── Invoke-VSCodePolicyRemediation.ps1
```

## Detection / Remediation Pairs

| Detection | Remediation | Checks |
|---|---|---|
| `Test-DefenderHealth.ps1` | `Invoke-DefenderRemediation.ps1` | WinDefend service, MDE onboarding, MAPS, signature age ≤3 days, engine Normal mode |
| `Test-DefenderService.ps1` | `Invoke-DefenderRemediation.ps1` | WinDefend running + Normal mode |
| `Test-MDEOnboarding.ps1` | *(investigate manually)* | `OnboardingState = 1` in registry |
| `Test-IBossHealth.ps1` | `Invoke-IBossServiceRemediation.ps1` | IBSA service running, DLL version ≥ 6.4.110.0 |
| `Test-TenableAgentLink.ps1` | `Invoke-TenableAgentLink.ps1` | Agent linked to `cloud.tenable.com:443` |
| `Test-ChromeInstall.ps1` | *(use Intune app deployment)* | Chrome in ARP + exe present |
| `Test-VSCodeExtensionPolicy.ps1` | `Invoke-VSCodePolicyRemediation.ps1` | VS Code ≥ 1.96, `AllowedExtensions` policy key set |

## Prerequisites

All scripts run in SYSTEM context via the Intune Management Extension (IME).

- **Defender scripts**: Windows Defender / MDE present
- **iBoss scripts**: iBoss IBSA agent installed
- **Tenable scripts**: Nessus Agent installed at `%ProgramFiles%\Tenable\Nessus Agent\`
  - `Invoke-TenableAgentLink.ps1` requires `<NESSUS-LINKING-KEY>` and proxy hostnames — replace before deployment
- **Chrome / VS Code**: apps already deployed via Intune

## Logs

All output captured by IME and visible in:
`C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\AgentExecutor.log`
