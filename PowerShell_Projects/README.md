# Overview
This repository contains a collection of **Enterprise Administration & Security Automation** projects developed during my professional placement. The primary focus is solving real-world infrastructure challenges through automation, specifically targeting Intune fleet management, Active Directory security, and endpoint health.

---

## Strategic Objectives
* **Automation at Scale:** Reducing manual intervention for repetitive administrative tasks.
* **Security Hardening:** Implementing modern replacements for legacy security tools and auditing identity strength.
* **User Experience:** Utilizing the PowerShell App Deployment Toolkit (PSADT) and custom GUIs to provide a professional interface for end-users.

---

## Folder Navigation & Project Details

### [Dell-Driver-Packaging](./DCU_packaging/)
* **Focus:** Automated hardware lifecycle management.
* **Implementation:** A comprehensive package using **PSADT4** deployable via Microsoft Intune.,
* **Outcome:** Facilitates automated driver updates with integrated user-facing popups to manage reboots and installation status.

### [MBAM-Replacement](./MBAM_replacement/)
* **Focus:** Modernizing BitLocker administration.
* **Implementation:** A custom PowerShell-based GUI designed to replace legacy MBAM solutions. 
* **Outcome:** Enforces PIN complexity checks and provides a secure, scalable method for BitLocker PIN resets on Entra-joined devices.

### [Password-Audit](./Password%20Audit/)
* **Focus:** Identity security and credential hygiene.
* **Implementation:** A suite of scripts for auditing Windows user account password strength.
* **Outcome:** Enforces mandatory changes for weak accounts and automates the notification process via an integrated email list system.

### [Endpoint-Compliance](./EndpointCompliance/)
* **Focus:** Security baseline enforcement.
* **Implementation:** Scripts designed to monitor and report on device compliance within an Intune environment.
* **Outcome:** Ensures all endpoints meet specific security telemetry requirements before accessing corporate resources.

### [Update-Status](./UpdateStatus/)
* **Focus:** Automated data gathering using KQL/ PowerShell- Ping devices found in KQL queries/ automated remediations.
* **Implementation:** Diagnostic tools that identify stalled or broken Windows Update agents.
* **Outcome:** Combine scripts using Azure automate- triggers automated remediation cycles to fix local update components without requiring a full OS wipe/ device rebuild.

---

## Technical Stack
* **Language:** PowerShell 5.1 / 7+
* **Frameworks:** PSAppDeployToolkit (PSADT), WinForms
* **Environment:** Microsoft Intune, Active Directory, Azure/Entra ID
* **Deployment:** Win32 App Packaging, Proactive Remediations

---

## Future Roadmap
1.  **Graph API Integration:** Transitioning AD scripts to utilize Microsoft Graph for cloud-native environments.
2.  **Enhanced Logging:** Standardizing JSON-based logging across all scripts for ingestion into Log Analytics/SIEM.
3.  **Module Creation:** Converting standalone scripts into a unified PowerShell module for easier distribution.
