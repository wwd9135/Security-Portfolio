# File Analyser

A command-line tool that scans a `.txt` file for sensitive patterns and produces a structured summary. Built as a practical exercise in modular design, input validation, and clean error handling.

## What it detects

- Email addresses
- Phone numbers
- Error-level log entries (case-insensitive `error` match)

## Project Structure

```
Fileanalyzer/
├── src/
│   ├── main.py          # Entry point
│   ├── analyzer.py      # Pattern matching and file validation logic
│   └── CommandLine.py   # CLI argument parsing and output formatting
└── TestLogs/
    ├── app.log
    └── test.log
```

## Usage

Run from `Fileanalyzer/src/`:

```
python main.py <filename>.txt -v 1
```

**Verbosity options:**
- `-v 0` — prints the raw file contents
- `-v 1` — prints a full analysis: file name, line count, and all matched patterns
