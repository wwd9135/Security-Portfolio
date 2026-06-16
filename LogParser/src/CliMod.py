from argparse import ArgumentParser, Namespace
import logging
import os

logger = logging.getLogger(__name__)

class Cli:
    @staticmethod
    def get_arguments() -> Namespace:
        parser = ArgumentParser(description="Windows Event Log XML Parser")
        parser.add_argument("FileName", help="Path to the XML log file")
        
        # New: Filter by specific Event IDs
        parser.add_argument(
            "--ids", 
            help="Filter for specific Event IDs (e.g., --ids 1000 2000)", 
            type=int, 
            nargs='+'
        )
        
        parser.add_argument(
            "--since", 
            help="Filter logs from this time (Format: YYYY-MM-DD HH:MM)", 
            type=str
        )
        
        args = parser.parse_args()
        
        if not os.path.isfile(args.FileName):
            logger.error(f"Target file missing: {args.FileName}")
            raise FileNotFoundError(f"Cannot locate: {args.FileName}")
            
        return args

    @staticmethod
    def display_results(data: dict):
        summary = data['summary']
        print(f"\n--- Results: {summary['total']} Matches Found ---")
        print(f"Success: {summary['success']} | Failed: {summary['failed']}")
        
        if not data['data']:
            print("No entries match your filters.")
            return

        print("\n" + "-" * 75)
        print(f"{'Timestamp':<30} | {'ID':<6} | {'Message'}")
        print("-" * 75)
        for entry in data['data']:
            print(f"{entry['timestamp']:<30} | {entry['event_id']:<6} | {entry['message']}")
        print("-" * 75)