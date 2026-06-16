# IPv4 Subnetting Tool

A command-line utility for calculating IPv4 subnet allocations from named department/host-count pairs. Given a list of names and required host counts, the tool allocates subnets sequentially within `192.168.0.0/16`, rounding each block up to the nearest valid host count. Outputs network address, broadcast address, usable host range, and subnet mask per allocation.

## Project Structure

```
Subnetting_Tool/
├── src/
│   ├── _main_.py          # Entry point
│   └── Modules/
│       ├── Subnet.py      # Subnet sizing and IP addressing logic
│       └── cli.py         # Argument parsing and input validation
└── Tests/
    └── Main_test.py
```

## Usage

Run from the `Subnetting_Tool/src/` directory:

```
python _main_.py Marketing:55/IT:21/HR:90
```

Input format: `Name:HostCount` pairs separated by `/`. Host counts are automatically rounded up to the nearest valid subnet size.

**Example output:**
```
-------------------------
Subnet: Marketing
-------------------------
Total Host Count: 62
Network address:  192.168.0.1
Broadcast address: 192.168.0.64
Last usable host: 192.168.0.63
Subnet mask: 255.255.0.0
```

Execution events and input validation errors are written to `main.log`.

## Constraints

Subnet allocation is fixed to the `192.168.0.0/16` private block. Input is validated against the pattern `Name:Count` — arbitrary network entry is not supported in this version.
