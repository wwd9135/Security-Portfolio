# Main application file
from analyzer import analyze
from CommandLine import CLI
import logging

logging.basicConfig(level=logging.DEBUG, filename='main.log', filemode='a',
                    format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


def main():
    # Instantiate and pass necessary variables
    CmdLine = CLI(1)
    FileName = (CmdLine.instantiate()[1])

    # Pass FileName and parse it to check if it's valud
    analyzeInsance = analyze
    try:
        analyzeInsance.parse(None, FileName)
    except Exception as e:
        logger.error(f"Error parsing file {FileName}: {e}")
        return
    with open(FileName, "r") as file:
           File_contents = file.readlines()
    

    with open(FileName,"r")as file:
        count = 0
        for i in file:
            count +=1

        if count == 0:
            logger.warning(f"The file {FileName} is empty.")
    arg = CmdLine.instantiate()[0]  
    
    

    PatternsFound = analyzeInsance.pattern_check(None, File_contents)
    if PatternsFound is None:
        logger.info(f"No patterns found in file {FileName}.")
    else:
        logger.warning(f"Patterns found in file {FileName}: {PatternsFound}")
    analyzeInsance.length_check(None, File_contents)

    result1 = (f"File name given is: {FileName}, \n Count of lines in file is: {count}\n List of identified patterns is: {PatternsFound}")
    result2 = (f"full file data: {File_contents}")
    result3 = (f"line count: {count}, patterns: {PatternsFound}")
    print(CmdLine.EndResult(arg, result1, result2, result3))
    logger.info("Analysis completed successfully.")
    

main()