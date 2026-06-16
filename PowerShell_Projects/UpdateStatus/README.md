# Device Troubleshooting Toolkit

This folder contains a collection of scripts and queries used to identify, verify, and troubleshoot faulty or non-compliant devices within the environment.

---

## Overview
The tools in this repository streamline the workflow of finding "ghost" devices or unpatched hardware and verifying their status on the network.

### Key Components

* **Defender KQL Queries:** Used to discover devices missing **2 or more months** of security patching.
* **PingChecker:** A PowerShell utility to verify if those unpatched devices are actually online.
    * *Smart Filtering:* Automatically ignores **169.254.x.x (Link-Local)** addresses, as these indicate APIPA/DHCP issues and are not routable for standard troubleshooting.
* **MBAM Replacement:** Scripts specifically designed for managing or replacing legacy BitLocker administration.

---

## Navigation

| Component | Description |
| :--- | :--- |
| [**DefenderKQL**](./DefenderKql/) | A collection of simple KQL queries for Microsoft Defender for Endpoint. |
| [**PingChecker**](./PingChecker/) | PowerShell scripts to ping devices at scale with built-in IP filtering. |

---

## Workflow Example
1.  **Identify:** Run a query from `/DefenderKQL/` to get a list of stale devices.
2.  **Verify:** Pipe that list into the `/PingChecker/` script to see which ones are physically reachable.
3.  **Remediate:** Use the results to target devices for manual updates or hardware retirement.

> [!TIP]
> Always run the PingChecker from a management segment that has ICMP access to your client VLANs for accurate results.