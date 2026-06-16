# Modules

Shared configuration and helper modules used across the PSADT-based deployments in this
portfolio.

## Contents

| File | Purpose |
|---|---|
| `PSAppDeployToolkit.config.psm1` | PSADT v4 framework configuration hashtable |

---

## PSAppDeployToolkit.config.psm1

Shared configuration for all PSAppDeployToolkit v4 packages in this portfolio
(Dell Command Update BIOS/driver packages, BitLocker PIN setup).

Drop this file into the `Config\` folder of your PSADT v4 package alongside
`PSAppDeployToolkit.psd1`. PSADT loads it automatically at session open.

### Key settings

| Setting | Value | Notes |
|---|---|---|
| `LogStyle` | `CMTrace` | Compatible with CMTrace and Support Center One-Click Log Viewer |
| `LogPath` | `%WinDir%\Logs\Software` | Standard Intune/SCCM log location |
| `LogMaxHistory` | 10 | Keeps last 10 rotated log files per deployment |
| `DialogStyle` | `Fluent` | Modern PSADT v4 dialogs |
| `DefaultTimeout` | 3300 s | 55 min — expires before Intune's 60-min script timeout |
| `SessionDetection` | `$true` | Silences UI when running as SYSTEM in session 0 |
| `OobeDetection` | `$true` | Silences UI during OOBE provisioning |

### Usage

Place in `<package-root>\Config\PSAppDeployToolkit.config.psm1`.
PSADT v4 will load it via the standard module initialization path.

Reference: [PSAppDeployToolkit v4 Configuration](https://psappdeploytoolkit.com/docs/reference/config)
