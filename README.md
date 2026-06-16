# Security Portfolio — William Richardson

A structured portfolio of security engineering and Python tooling projects, spanning an IT admin and security engineering industrial placement, independent tool development, and hands-on Azure threat simulation work.

---

## Repository Overview

```
Security-Portfolio/
├── LogParser/                   # Windows Event Log parser — production-quality CLI tool
├── Mini_Projects/               # Python utilities: networking, file analysis, input validation, testing
├── SC200-AzTenant-ATRsims/      # Azure tenant attack simulation scenarios
└── security-portfolio/          # PowerShell scripts, KQL queries, and placement resources
```

---

## Contents

### [LogParser](./LogParser/)

A command-line tool for parsing, normalising, and filtering Windows Event Logs exported in XML format. Extracts structured data from Microsoft's native XML schema with optional filtering by Event ID and timestamp cutoff.

**Highlights:**
- Decoupled architecture separating CLI logic from parsing logic
- Handles edge cases: BOM characters, empty elements, high-precision timestamps
- Four-scenario test suite covering baseline parsing, ID filtering, time filtering, and malformed XML

**Run:**
```
python _main_.py src/Tests/MyTestLog.xml --ids 4624 --since "2026-01-21 14:30"
```

---

### [Mini Projects](./Mini_Projects/)

A collection of focused Python utilities. Each is self-contained with its own CLI interface, structured source layout, and README.

| Project | Description |
|---|---|
| [Password Validator](./Mini_Projects/CLI_tool.py) | CLI input validation enforcing password length and character composition policy |
| [File Analyser](./Mini_Projects/Fileanalyzer/) | Scans `.txt` files for sensitive patterns — emails, phone numbers, error-level log entries |
| [IPv4 Subnetting Tool](./Mini_Projects/Subnetting_Tool/) | Calculates subnet allocations from department/host-count pairs within a `192.168.0.0/16` block |
| [Pytest Practice](./Mini_Projects/PyTestPractice/) | Pytest fundamentals — fixtures, test class organisation, and assertion patterns |
| [Log Parser v1](./Mini_Projects/LogParser/) | Earlier iteration of the event log parser; preserved to show architectural progression |

---

### [SC-200 Azure ATR Simulations](./SC200-AzTenant-ATRsims/)

Azure tenant attack simulation scenarios aligned with Microsoft's SC-200 Security Operations Analyst curriculum. Documents adversary technique simulations run against a live Azure tenant, covering detection, investigation, and response workflows.

---

### [Security Portfolio Resources](./security-portfolio/)

A reference bank of PowerShell scripts, KQL queries, and operational resources accumulated during an IT admin and security engineering industrial placement. All data has been desensitised.

---

## Stack

`Python` `argparse` `pytest` `Azure` `KQL` `PowerShell` `XML`
