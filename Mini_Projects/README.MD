# Mini Projects

A collection of focused Python utilities covering input validation, file analysis, network fundamentals, and testing. Each project is self-contained with its own CLI interface and structured source layout.

---

## Projects

### Password Validator — `CLI_tool.py`

A command-line input validation script demonstrating sanitisation and security policy enforcement on password input. Validates length (8–20 characters) and character composition (minimum two character types) via `argparse` before accepting input.

```
python CLI_tool.py <password>
python CLI_tool.py <password> -v 1
```

---

### File Analyser — `Fileanalyzer/`

Scans a `.txt` file for sensitive patterns — email addresses, phone numbers, and error-level log entries — using compiled regex. Outputs a line count and a list of flagged lines, with verbosity control via `-v`.

```
python src/main.py <filename>.txt -v 1
```

---

### IPv4 Subnetting Tool — `Subnetting_Tool/`

Calculates subnet allocations from named department/host-count pairs. Allocates sequentially within `192.168.0.0/16`, rounding each block up to the nearest valid host count. Outputs network address, broadcast address, usable host range, and subnet mask per allocation.

```
python src/_main_.py Marketing:55/IT:21/HR:90
```

---

### Pytest Practice — `PyTestPractice/`

Demonstrates pytest fundamentals — fixtures, test class organisation, and assertion patterns — against a small arithmetic module.

```
pytest test/
```

---

### Windows Event Log Parser v1 — `LogParser/`

An earlier iteration of the Windows Event Log parser. Demonstrates the initial progression from a single-file script to a modular CLI tool with decoupled parser and CLI modules. The full-featured version lives at the repository root.

```
python __main__.py -v 0
```

---
