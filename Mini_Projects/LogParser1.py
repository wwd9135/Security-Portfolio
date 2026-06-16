#**** I created a log parser, I used a PowerShell script to gather logs (see immediately below) ****#
#**** I extracted this data using subprocess lib in python, the data was incredibly vast so took 2-3 minutes each time the program ran ****#
#**** I saved this data to a txt file to finish my python script easier, I couldn't figure out how to quicken the overall process within PS so will learn C and see if I can master low level ****# 
#**** effiency and redo this project. The parsing works great but as mentioned the process is slow. ****#

import subprocess
import json
import os

def run_powershell(event_id, start_date, output_file):
    """Run PowerShell command to fetch logs and save to a file."""
    ps_command = f"""
    Get-WinEvent |
    Where-Object {{ $_.TimeCreated -gt '{start_date}' -and $_.Id -eq {event_id} }} |
    ForEach-Object {{
        "$($_.TimeCreated) - ID:$($_.Id) - $($_.Message)"
    }} |
    Out-File '{output_file}' -Encoding UTF8
    """
    try:
        subprocess.run(["powershell", "-Command", ps_command], check=True)
        print(f"Logs saved to {output_file}")
    except subprocess.CalledProcessError as e:
        print(f"PowerShell command failed: {e}")

def parse_logs(file_path, keyword):
    """Parse logs and summarize results."""
    row_count = 0
    warnings = 0
    successes = 0
    keyword_matches = []

    try:
        with open(file_path, "r", encoding="utf-8") as file:
            for row in file:
                row_count += 1
                if "warning" in row.lower():
                    warnings += 1
                if "success" in row.lower():
                    successes += 1
                if keyword.lower() in row.lower():
                    keyword_matches.append(row.strip())
    except FileNotFoundError:
        print("Log file not found.")
        return None

    return {
        "Total Rows": row_count,
        "Warnings": warnings,
        "Successes": successes,
        "Keyword Matches": keyword_matches
    }

def main():
    event_id = input("Enter Event ID: ")
    start_date = input("Enter start date (e.g., 2024-12-01): ")
    keyword = input("Enter keyword to search for: ")

    output_file = os.path.join(os.getcwd(), "LogResult.txt")
    summary_file = os.path.join(os.getcwd(), "summary.json")

    run_powershell(event_id, start_date, output_file)
    summary = parse_logs(output_file, keyword)

    if summary:
        with open(summary_file, "w", encoding="utf-8") as f:
            json.dump(summary, f, indent=4)
        print(f"Summary saved to {summary_file}")

if __name__ == "__main__":
    main()
