# Windows Event Log Parser

A Python-based utility for parsing, normalizing, and filtering Windows Event Logs exported in XML format. This tool converts complex, nested XML data into structured dictionaries and provides granular filtering based on timestamps and Event IDs.

## Features

- **Namespace Normalization:** Automatically handles Microsoft Windows Event XML namespaces to extract clean data.
- **Timestamp Filtering:** Filter logs using a specific cutoff date and time (ISO 8601 format).
- **Event ID Filtering:** Scan for single or multiple specific Event IDs simultaneously.
- **Robustness Layer:** Handles common XML encoding issues, hidden Byte Order Marks (BOM), and empty data elements.
- **Architecture:** Decoupled design separating CLI presentation logic from core parsing logic.

## Project Structure

- `_main_.py`: The application orchestrator and entry point.
- `src/Cli.py`: Handles argument parsing and terminal output formatting.
- `src/Parser.py`: Contains the core logic for XML processing and data normalization.
- `test_parser.py`: Suite for validating parser logic against baseline and edge-case XML files.
- `main.log`: Persistent log file tracking application execution and errors.

## Installation

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/yourusername/LogParser.git](https://github.com/yourusername/LogParser.git)
   cd LogParser
2. **Configure a virtual environment:**
python -m venv venv
- Windows:
.\venv\Scripts\activate
- Linux/macOS:
source venv/bin/activate

## Usage
The tool is executed through _main_.py. It requires a path to an XML log file.

**Basic Command:**

- python _main_.py path/to/log.xml

**Filter by Event IDs:**

- Use the --ids flag followed by one or more integers. Run:
- python _main_.py path/to/log.xml --ids 1000 2000

**Filter by Date:**

- Use the --since flag with the format "YYYY-MM-DD HH:MM". Run:
    -python _main_.py path/to/log.xml --since "2026-01-21 14:30"

**Testing:**

The included test suite validates the parser against four specific scenarios: 
- baseline parsing
- ID filtering accuracy
- Chronological cutoff logic
- Malformed XML handling. 

python test_parser.py

**Logging:**

- The application logs debug and error information to main.log.
- This includes validation of the virtual environment status, file path resolution, and XML parsing exceptions.
