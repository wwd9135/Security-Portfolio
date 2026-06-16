import logging
from src import Cli, LogParser

def main():
    try:
        args = Cli.get_arguments()
        
        parser = LogParser()
        # Pass both potential filters
        data = parser.parse(
            filename=args.FileName, 
            since_str=args.since, 
            target_ids=args.ids
        )
        
        Cli.display_results(data)
        
    except Exception as e:
        logging.error(f"Fatal error: {e}", exc_info=True)
        print(f"\n[!] Error: {e}")

if __name__ == "__main__":
    main()