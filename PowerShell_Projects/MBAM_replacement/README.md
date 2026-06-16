# 🔐 MBAM Replacement Solution

A modern BitLocker administration and PIN management framework designed to replace **Microsoft BitLocker Administration and Monitoring (MBAM)** ahead of its **July 2026 deprecation**.

## Overview
As MBAM moves to legacy status, organizations face a critical gap in BitLocker management—specifically the ability for non-admin users to manage PINs without help desk intervention. 

This solution provides a hardened GUI that allows users to rotate or reset their BitLocker PINs while enforcing security complexity requirements that exceed the native capabilities of `manage-bde.exe`.

## Problem & Solution
| The Challenge | The MBAM Replacement Solution |
| :--- | :--- |
| **Legacy Deprecation** | Fully replaces MBAM features before the 2026 EOL. |
| **Admin Requirements** | Allows PIN resets without local administrative privileges. |
| **Weak PINs** | Enforces advanced complexity (Sequential/Repeating checks). |
| **Automation Gaps** | Built specifically for PSADT4 and Intune Win32 workflows. |

---

## Architecture & Core Logic
The solution is decoupled into a modular framework to facilitate maintainability and security auditing:

* **Logic Engine (`Files/mod.psm1`):** A dedicated PowerShell module containing the Windows Form GUI code and the validation logic.
* **Deployment Wrapper:** Utilizes the **PowerShell App Deployment Toolkit (PSADT)** to handle Intune installation states, deferrals, and user interaction.
* **Security Validation:** Unlike native Windows UI, this engine implements:
    * **Length Constraints:** Strict Min/Max PIN length enforcement.
    * **Pattern Filtering:** Prevents sequential (1234) or repeating (1111) patterns.
    * **Enhanced Characters:** Checks for the use of multiple character types.
    * **Dictionary Filtering:** Blocks known weak or commonly used PINs.

---

## Deployment Options
Optimized for **Microsoft Intune** using the Win32 App model:

1.  **Automatic Rollout:** Force-deploy to devices identified as non-compliant or missing recovery keys using Intune detection scripts.
2.  **Self-Service:** Publish to the **Company Portal**, allowing users to rotate PINs on-demand, reducing Help Desk ticket volume.
3.  **Build Process:** Can be triggered during the Autopilot or imaging phase to ensure a PIN is set before the device reaches the user.

---

## Repository Structure
```text
├── AppDeployToolkit/      # PSADT core framework files
├── Files/
│   └── mod.psm1           # Core Module (GUI, Regex, & Validation)
├── Deploy-Application.ps1  # Main entry point for Intune/PSADT
└── README.md              # Project documentation
```
## Security & Compliance
Built for compliance-driven environments, the tool includes:
- Hardened Input: Sanitizes user input to prevent command injection during the manage-bde handoff.
- Audit Logging: Records attempts and validation failures to local event logs for SIEM ingestion.
- Defense in Depth: Reduces "Admin Account Sprawl" by removing the need for technicians to log in locally to perform resets.

## How to Use
- Package: Wrap the root folder into an .intunewin file using the Microsoft Win32 Content Prep Tool.
- Install Command: Deploy-Application.exe
- Uninstall Command: Deploy-Application.exe -DeploymentType Uninstall
- Detection: Use a PowerShell script to check for a specific registry key or the presence of the mod.psm1 file.

[!TIP] Use this tool alongside an efficient identity verification procedure at the Help Desk to ensure attack surface creep isn't introduced via social engineering.
