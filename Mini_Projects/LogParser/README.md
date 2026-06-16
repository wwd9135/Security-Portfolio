# Windows Event Log Parser — v1

An earlier iteration of the Windows Event Log parser and the foundation on which the full-featured version at the repository root was built. Parses XML-exported Windows Event Logs and outputs structured event records with configurable verbosity.

Preserved here to show the progression from an initial modular design to the more capable, filter-driven tool in the root `LogParser/`.

## Project Structure

```
LogParser/
├── __main__.py
├── src/
│   ├── cli.py
│   ├── parser.py
│   └── MyTestLog.xml
└── Tests/
    └── main_test.py
```

## Usage

From the `LogParser/` directory:

```
python __main__.py -v 0
```

**Verbosity:**
- `-v 0` — minimal output
- `-v 1` — verbose output

## Tests

```
pytest Tests/
```
