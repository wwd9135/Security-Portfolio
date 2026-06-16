# Windows Event Log Parser

A command-line tool for parsing, normalising, and filtering Windows Event Logs exported in XML format. Extracts event records from Microsoft's native XML schema and produces clean, tabular terminal output — with optional filtering by Event ID and timestamp cutoff.

## Features

- **Event ID filtering** — Target one or multiple IDs in a single run (`--ids 4624 4625`)
- **Timestamp filtering** — Drop events older than a specified cutoff (`--since "YYYY-MM-DD HH:MM"`)
- **Namespace normalisation** — Handles Microsoft Windows Event XML namespaces transparently
- **Robustness** — Tolerates BOM characters, empty `<Data/>` elements, and high-precision timestamps
- **Decoupled design** — CLI logic (`CliMod.py`) is fully separated from parsing logic (`Parser.py`)

## Project Structure

```
LogParser/
├── _main_.py              # Entry point — coordinates CLI → parser → output
├── xmlTest.py             # Test suite covering all four XML scenarios
├── pyproject.toml
└── src/
    ├── CliMod.py          # Argument parsing and formatted terminal output
    ├── Parser.py          # XML parsing, event filtering, and data normalisation
    ├── __init__.py
    └── Tests/
        ├── MyTestLog.xml          # Baseline event log
        ├── MultiIDFilter.xml      # Multi-ID filter scenario
        ├── TimeRange.xml          # Timestamp cutoff scenario
        └── MalformedEdgeCase.xml  # Malformed XML / empty field scenario
```

## Usage

Run from the `LogParser/` directory.

**Basic parse:**
```
python _main_.py src/Tests/MyTestLog.xml
```

**Filter by Event ID(s):**
```
python _main_.py src/Tests/MyTestLog.xml --ids 4624 4625
```

**Filter by timestamp cutoff:**
```
python _main_.py src/Tests/MyTestLog.xml --since "2026-01-21 14:30"
```

**Combine filters:**
```
python _main_.py src/Tests/MyTestLog.xml --ids 4624 --since "2026-01-21 14:30"
```

## Testing

Run the included test suite from the `LogParser/` directory:

```
python xmlTest.py
```

Covers four scenarios:
- Baseline parsing and record counting
- Event ID filtering accuracy
- Chronological cutoff logic
- Malformed XML and empty field normalisation

## Logging

Execution events, file path validation, and parse errors are written to `main.log`.
