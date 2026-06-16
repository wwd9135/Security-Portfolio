# Azure Sentinel & Defender XDR Home Lab
### SC-200: Microsoft Security Operations Analyst — Passed (802) ✅

> A self-built Azure security lab simulating a realistic corporate environment — covering attack simulation, detection engineering, threat hunting, and automated incident response.

---


### 🎯 What This Lab Demonstrates

| Area | Skills |
|---|---|
| **SIEM & Detection Engineering** | KQL, Analytic Rules, NRT Rules, UEBA |
| **Threat Hunting** | MITRE ATT&CK mapping, Advanced Hunting, behavioural correlation |
| **SOAR & Automation** | Sentinel Playbooks, Logic Apps, Automation Rules |
| **Attack Simulation** | Atomic Red Team, full kill-chain execution |
| **Threat Intelligence** | IP/domain enrichment, file hash analysis, IPVoid, Defender Deep Scan |
| **Compliance & DLP** | Microsoft Purview, insider threat detection |

---

### 🏗️ Architecture

The lab is built as a **closed Azure environment** to safely simulate attacker behaviour and validate detections end-to-end.

```
Attack Simulation (Atomic Red Team)
        ↓
Azure VM (Windows 10/11) — Audit Mode
        ↓
Microsoft Defender XDR  (MDE / MDI telemetry)
        ↓
Microsoft Sentinel  (Log ingestion, detection, hunting)
        ↓
Playbook / Automation Rule  (Enrichment → Response → Analyst alert)
```

**Core Components:**

- **Azure Virtual Machines (Windows 10/11)** — Onboarded to the full Defender suite, used for attack simulation and telemetry generation
- **Microsoft Defender XDR** — Full suite configured in audit mode to maximise visibility without blocking simulations
- **Microsoft Sentinel** — Central SIEM for ingestion, detection, investigation, and automated response
- **Microsoft Purview** — DLP policies for data exfiltration and insider threat scenarios

---

### ⚔️ Attack Simulation

Atomic Red Team was installed on a test VM and executed across a full attack chain, mapped to MITRE ATT&CK:

| Phase | Techniques |
|---|---|
| Discovery | T1087 (Account Discovery), T1018 (Remote System Discovery) |
| Credential Access | T1003 (OS Credential Dumping) |
| Execution | T1059 (Command & Scripting Interpreter) |
| Persistence | T1547 (Boot/Logon Autostart Execution) |

**Approach:**
- Endpoint switched to **audit-only mode** to prevent auto-blocking during simulation ([AuditMode.ps1](Assets/AuditMode.ps1))
- Full telemetry captured before prevention mechanisms interfere
- Process trees, command-line arguments, and parent-child relationships recorded for detection validation
- Outcome: ![Incident timeline](Assets/IncidentTimeline.png)
---

### 🔍 Detection Engineering

#### Key Sentinel Tables Used

| Table | Purpose |
|---|---|
| `DeviceProcessEvents` | Process creation & command-line visibility |
| `DeviceNetworkEvents` | Outbound/inbound network connections |
| `DeviceLogonEvents` | Authentication activity |
| `DeviceFileEvents` | File creation/modification |
| `DeviceRegistryEvents` | Registry persistence & changes |
| `AuditLogs` | Sign-in and cloud event logs |

**Detection philosophy:** Correlate across multiple tables rather than relying on single-event detections. Aggregate alerts and UEBA were prioritised over point-in-time triggers to reduce false positives.

### Analytic Rules Built

**[Internet Exfiltration Rule](Assets/InternetExfil.kql)**
Scans for outbound data exfiltration patterns across known transfer methods and suspicious destinations.

**[Suspicious Process Execution Rule](Assets/SuspiciousProcess.KQL)**
Targets MITRE T1059 — detects encoded command-line arguments and unusual interpreter invocations.

- Detection logic focuses on behavioural intent, not payload content.
- Encoded commands are a strong obfuscation indicator regardless of payload.
- Misc of queries used while threat hunting- ![KQL](Assets\MiscQueries.kql)

---

### 🤖 Automated Incident Response

**Incident Flow:**
```
Detection Rule → Sentinel Incident → Automation Rule → Playbook Trigger → Analyst Notification
```
**Playbook: Suspicious Process Response** 


![View](Assets/SentinelPlaybook.png)

When a suspicious process incident is triggered, the playbook automatically:
1. **Enriches the alert** — queries IPVoid for domain/IP reputation, triggers Defender deep scan on associated files
2. **Makes a risk decision** — if known-malicious hash/IP/domain confirmed, auto-remediates
3. **Blocks the threat** — isolates user account and/or blocks IP
4. **Notifies the analyst** — sends a pre-enriched email report, reducing triage time

> The goal was to give analysts *a decision*, not just an alert — by the time a human reads the incident, the context is already there.

---

### 📂 Repository Contents

| File | Description |
|---|---|
| [`Assets/AuditMode.ps1`](Assets/AuditMode.ps1) | PowerShell script to set a Windows endpoint to audit-only mode |
| [`Assets/InternetExfil.kql`](Assets/InternetExfil.kql) | KQL analytic rule — internet exfiltration detection |
| [`Assets/SuspiciousProcess.KQL`](Assets/SuspiciousProcess.KQL) | KQL hunt — MITRE T1059 suspicious command-line execution |
| [`Assets/SentinelPlaybook.webp`](Assets/SentinelPlaybook.png) | Sentinel playbook diagram |

---

### 💡 Key Takeaways

**1. False positives are the real enemy**
Building detections that fire accurately matters more than building ones that fire often. Every noisy rule degrades analyst trust in the whole system. Correlating across multiple signals before alerting was a consistent focus.

**2. Enrichment before escalation**
Plugging threat intel into the playbook (IPVoid, Defender deep scan, file hash lookups) before the analyst reads the incident halved the cognitive load of triage. It also enabled automated response for clear-cut cases, reserving human judgement for genuinely ambiguous ones.

**3. Audit mode is essential for realistic telemetry**
Running Atomic Red Team without disabling prevention first means your detections are tested against incomplete data. Real attacker behaviour only shows up fully when you let it run.

**4. KQL depth matters**
Moving from simple `where` filters to joins across tables, time-windowed aggregations, and behavioural baselining was the steepest part of the learning curve — and the most valuable.

---

## 🧠 About

Built as a hands-on study environment for the **SC-200: Microsoft Security Operations Analyst** certification. The aim was to go beyond exam prep and simulate the kind of detection and response work done in a real SOC.


Next Steps- Aiming to further utilize this lab to tackle AZ500 as I move to a detection engineering focused role in the coming weeks.

