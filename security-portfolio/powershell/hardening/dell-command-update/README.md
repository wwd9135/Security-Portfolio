# powershell/hardening/dell-command-update

Intune Win32 app packages and Proactive Remediation pairs for automated Dell BIOS and driver updates using Dell Command Update (DCU) CLI.

## Architecture

Each update type (BIOS and drivers) follows the same two-component pattern:

```
Win32 App (PSAppDeployToolkit v4)         Proactive Remediation
─────────────────────────────────         ─────────────────────
Invoke-BIOSUpdatePackage.ps1    ←─ reset ─ Invoke-BIOSUpdateRemediation.ps1
                                  detect → Test-BIOSUpdateHeartbeat.ps1

Invoke-DriverUpdatePackage.ps1  ←─ reset ─ Invoke-DriverUpdateRemediation.ps1
                                  detect → Test-DriverUpdateHeartbeat.ps1
```

**Heartbeat pattern:** Each Win32 app stamps `HKLM:\SOFTWARE\DELL\DCU*LastRun` with an ISO 8601 timestamp on every successful run. The detection script in the PR pair reads this stamp; when it is older than 14 days (or missing/malformed) the remediation deletes the key, flipping Intune app detection to "not installed" and triggering a fresh scan+update cycle.

## Files

| File | Role | Description |
|---|---|---|
| `Invoke-BIOSUpdatePackage.ps1` | Win32 App | Scans for and applies Dell BIOS/firmware updates |
| `Invoke-DriverUpdatePackage.ps1` | Win32 App | Scans for and applies Dell driver/utility updates |
| `Test-BIOSUpdateHeartbeat.ps1` | PR Detection | Checks BIOS heartbeat freshness (exit 0 = healthy, exit 1 = remediate) |
| `Invoke-BIOSUpdateRemediation.ps1` | PR Remediation | Deletes BIOS heartbeat key to trigger app re-run |
| `Test-DriverUpdateHeartbeat.ps1` | PR Detection | Checks driver heartbeat freshness |
| `Invoke-DriverUpdateRemediation.ps1` | PR Remediation | Deletes driver heartbeat key to trigger app re-run |

## Prerequisites

- **Dell Command Update** installed at `%ProgramFiles%\Dell\CommandUpdate\dcu-cli.exe`
- **PSAppDeployToolkit v4.0.6+** — place in a `PSAppDeployToolkit\` subfolder alongside the package scripts
- Intune Win32 app wrapped with [IntuneWinAppUtil](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool)
- Always-On VPN detection (optional) — the packages automatically toggle a custom proxy when AOVPN is not connected

## Configuration

Before deploying, update the following placeholders in the package scripts:

| Placeholder | Description |
|---|---|
| `<BIOS-PASSWORD>` | Dell BIOS supervisor password (BIOS package only) |
| `proxy.contoso.com` | Corporate proxy hostname used when AOVPN is not connected |

## Exit codes

| Code | Meaning |
|---|---|
| 0 | Success |
| 3010 | Success — reboot required |
| 12000 | Not Dell hardware |
| 12001 | DCU not installed |
| 12003 | Device on battery — BIOS update skipped |
| 60001 | PSAppDeployToolkit unhandled error |
