# My CLI arg parse functionalty.
# This is meant to be reusable so my main function will pass the necessary inputs to create desired arg parse
from argparse import ArgumentDefaultsHelpFormatter, Namespace, ArgumentParser
import logging
import re
import os

class CLI:
    def __init__(self, verboseC, ):
        self.verboseCount = verboseC

    def logging_setup(self):
        logging.basicConfig(level=logging.DEBUG, filename='main.log', filemode='w',
                        format='%(asctime)s - %(levelname)s - %(message)s')
        logger = logging.getLogger(__name__)
        handler = logging.FileHandler('main.log')
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        
    def instantiate(self):
        # Collects data from user,

        parser = ArgumentParser()
        parser.usage = "Example input: FileName.py [-h] [-v {0,1}] fileName.txt  # Do not include another file type as it won't be supported."
        parser.add_argument("fileName", help="Enter a filename, .txt file type only!", type=str)
        if self.verboseCount == 1:
            parser.add_argument("-v","--verbose", help="Provides advanced description, 1 being the full analysis of file, 0 a print out of files contents.", choices=[0,1], type=int)
        else:
            parser.add_argument("-v","--verbose", help="Provides advanced description, 0 a print out of files contents.", choices=[0], type=int)
        arg : Namespace = parser.parse_args()
        result: Namespace = arg.fileName
    
        return arg, result

    def EndResult(self, arg, One = type(str),Zero = type(str),Blank = type(str)):
        # Prints outputs, it's designed to be generic and take any CLI programs inputs.
        match arg.verbose:
            case 1:
                return(One)  
            case 0:
                return(Zero)
            case _:
                return(Blank)

