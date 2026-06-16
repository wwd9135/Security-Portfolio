# Contains functions for analyzing file data
import logging
import os
import re


class analyze:
    def __init__(self,path: str):
        self.path = path
    
    # Not sure how to get this inherited logging to work properly yet.
    def logging_setup(self):
        logging.basicConfig(level=logging.DEBUG, filename='main.log', filemode='w',
                            format='%(asctime)s - %(levelname)s - %(message)s')
        logger = logging.getLogger(__name__)
        handler = logging.FileHandler('main.log')
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        logger.addHandler(handler)

    def parse(self, path):
        # Check if the file is in the correct format, and exists
        if not path.lower().endswith(".txt"):
            raise NameError
        if not os.path.isfile(path):
            raise FileNotFoundError
        return path
        

    def pattern_check(self, file_contents):
        patterns_found = []

        pattern_list = [
            re.compile(r"[^\s@]+@[^\s@]+\.[^\s@]+"),          # email
            re.compile(r"\+?[0-9\s\-()]{7,20}"),              # phone
            re.compile(r"\berror\b", re.IGNORECASE),          # "error" (case-insensitive)
        ]
        
        for line in file_contents:
            for pattern in pattern_list:
                if pattern.search(line):
                    patterns_found.append(line)
                    break
    
        return patterns_found
    def length_check(self, File_contents):

        if 1 == 1:
            return 1
        else:
            return 0


    



