# detection/kql

KQL queries for Microsoft Sentinel and Microsoft Defender for Endpoint. Covers threat detection, identity risk, compliance hunting, and anomaly detection.

## Files

| File | Platform | Purpose |
|---|---|---|
| `alert-monitoring.kql` | Sentinel | Alert volume, brute-force detection, incident MTTR, geo-anomaly sign-ins, table correlation |
| `risky-sign-ins.kql` | Sentinel / Entra ID | At-risk user sign-ins, RDP lateral movement indicators |
| `defender-compliance.kql` | Defender for Endpoint | Device patch-gap analysis with AV health and logged-on user joins |
| `internet-exfil-anomaly-detection.kql` | Sentinel | Time-series anomaly detection for outbound data volume spikes (T1048) |
| `t1059-command-scripting.kql` | Defender for Endpoint | AutoIt3 spawned by PowerShell — Atomic Red Team T1059 artefact |

## Usage

Paste queries into the **Logs** blade in Microsoft Sentinel, or the **Advanced Hunting** tab in Microsoft Defender XDR. Each file contains multiple named queries separated by comment headers.

## Prerequisites

- Microsoft Sentinel workspace with `SecurityAlert`, `SecurityIncident`, `SigninLogs`, `AuditLogs` tables ingested
- Microsoft Defender for Endpoint with Advanced Hunting enabled (`DeviceProcessEvents`, `DeviceTvmSoftwareVulnerabilities`, etc.)
- Appropriate RBAC: **Security Reader** minimum for read-only hunting
