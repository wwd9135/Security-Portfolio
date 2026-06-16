# Intune Proactive Remediation Migration Project

## Overview
This repository contains the proactive remediation scripts developed as part of a wider initiative to transition from MECM-based proactive remediations to a fully Intune‑centric approach. Shifting these workloads to Intune provides a more cloud‑aligned model and offers improved visibility, consistency, and control across our Windows fleet.

During this project, over 50 MECM Configuration Items (CIs) were reviewed to determine which were essential to migrate. Defender‑related checks were identified as the most critical, resulting in the migration and modernisation of 12 Defender CIs. Additionally, two Iboss‑related CIs are being transitioned to Intune.

The project focuses on the following key areas:

- **Registry key validation:** Ensuring Intune Management Extension (IME) policies align correctly with Defender configuration through registry-based state verification.
- **Defender behaviour monitoring:** Confirming Defender services are running, definitions are up to date, and registry-driven behaviours are taking effect.
- **Accurate remediation triggers and logging:** Producing reliable outputs that can be reviewed by Security and Compliance teams.

---

## Implementation Details

### Core Components
- A lightweight registry validation module confirming that expected Defender configuration keys exist and are receiving updates.
- A set of functions designed to verify Defender agent health, detect policy drift, and ensure all related services and behaviours operate within expected parameters.

### Remediation Capabilities
The Intune proactive remediation scripts include logic to:
- Restart the Microsoft Defender service when required.
- Trigger definition and engine updates for the Defender agent.

---

## Iboss Integration
Iboss‑related checks are intentionally simple and focused. The scripts validate:
- The Iboss service is running.
- The installed version is current and aligned with expected policy.

---

## Purpose
This work represents an incremental but meaningful shift toward modern device management—streamlining endpoint security validation, enhancing visibility, and reducing dependency on MECM for proactive health monitoring.