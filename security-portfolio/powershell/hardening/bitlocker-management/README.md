# BitLocker PIN Management

PSADT v4 package that replaces MBAM with a native Windows Forms GUI for collecting and
applying a TPM+PIN BitLocker protector — deployed via Microsoft Intune as a Win32 app.

## Architecture

```
Intune Win32 app
└── Invoke-BitLockerPINSetup.ps1   ← PSADT v4 entry point
    ├── Files/
    │   ├── BitLockerPINModule.psm1  ← Windows Forms GUI + PIN validation
    │   ├── language.json            ← UI strings for en-US and de-DE
    │   └── PassList.txt             ← Top-1000 common passwords (sample)
    └── PSAppDeployToolkit/          ← PSADT v4 framework (not included here)
```

## Flow

1. PSADT displays an info prompt ("I'm Ready" / "Cancel")
2. On confirmation, `BitLockerGuiLauncher` renders a Windows Forms dialog
3. User enters and re-types a PIN; validation runs on "Set PIN":
   - Length ≥ `HKLM:\SOFTWARE\Policies\Microsoft\FVE\MinimumPIN` (default 6), max 20
   - No 3-character ascending/descending sequences (abc, 987, etc.)
   - No 3 consecutive repeated characters (aaa, 111, etc.)
   - EnhancedPIN mode requires at least 2 character types
   - Not matched in PassList.txt common passwords
4. On success, PIN is captured as `[SecureString]` and cleared from textboxes immediately
5. PSADT calls `Add-BitLockerKeyProtector -TpmAndPinProtector` on all fully-encrypted volumes

## Prerequisites

| Requirement | Details |
|---|---|
| PSAppDeployToolkit | v4.0.6 — [psappdeploytoolkit.com](https://psappdeploytoolkit.com) |
| .NET / WinForms | Windows 10/11 built-in |
| BitLocker | Volume must be `FullyEncrypted` before PIN is set |
| Intune deployment | Run as SYSTEM; user session required for Forms dialog |

## Configuration

BitLocker PIN complexity is controlled entirely by Group Policy / Intune settings:

| Registry value | Path | Effect |
|---|---|---|
| `MinimumPIN` | `HKLM:\SOFTWARE\Policies\Microsoft\FVE` | Minimum PIN length (4–20; script defaults to 6) |
| `UseEnhancedPin` | `HKLM:\SOFTWARE\Policies\Microsoft\FVE` | `1` = alphanumeric required |

No hardcoded values in the scripts.

## Files

| File | Description |
|---|---|
| `Invoke-BitLockerPINSetup.ps1` | PSADT v4 deployment entry point |
| `BitLockerPINModule.psm1` | GUI (`BitLockerGuiLauncher`) + PIN validation helpers |
| `language.json` | Localised UI strings (en-US, de-DE) |
| `PassList.txt` | Sample common-password blocklist (1 000 entries) |

## Exit Codes

| Code | Meaning |
|---|---|
| 0 | PIN set successfully |
| 1 | No encrypted volumes found, or protector add failed |
| 1602 | User cancelled |
| 60001 | Unhandled PSADT error |

## Security Notes

- The PIN is converted to `[SecureString]` immediately after the user clicks "Set PIN"
- UI textboxes are cleared before the dialog closes (`UseSystemPasswordChar = $true`)
- The plaintext PIN variable is nulled after conversion
- `PassList.txt` is a sample list; replace with your organisation's approved blocklist
