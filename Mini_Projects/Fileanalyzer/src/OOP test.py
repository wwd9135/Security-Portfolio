# This script can take a txt file, perform basic regex scanning for patterns, check length, duplicate lines etc, I implemented arg parser so the script can self run cleanly from CLI.
# Running python file_name.py -h will give help and show the expected format to get the best results from this script!

from argparse import ArgumentParser, Namespace
import re
import os

# Method in class 2
def txt_file(path: str):
    if not path.lower().endswith(".txt"):
        raise ("Expected a .txt file")
    if not os.path.isfile(path):
        raise ("File does not exist")
    return path

# class 1 method
parser = ArgumentParser()
parser.usage = "FileName.py [-h] [-v {0,1}] fileName.txt  # Do not include another file type as it won't be supported."
parser.add_argument("fileName", help="Enter a filename, .txt file type only!", type=txt_file)
parser.add_argument("-v","--verbose", help="Provides advanced description, 1 being the full analysis of file, 0 a print out of files contents.", choices=[0,1], type=int)

arg : Namespace = parser.parse_args()
result: Namespace = arg.fileName



def pattern_finder(file):
    patterns_found = []

    pattern_list = [
        re.compile(r"[^\s@]+@[^\s@]+\.[^\s@]+"),          # email
        re.compile(r"\+?[0-9\s\-()]{7,20}"),              # phone
        re.compile(r"\berror\b", re.IGNORECASE),          # "error" (case-insensitive)
    ]
    
    for line in file:
        
        for pattern in pattern_list:
            if pattern.search(line):
                patterns_found.append(line)
                break
   
    return patterns_found
# Class 1
with open(f"{result}", "r") as file:
    File_contents = file.readlines()

with open(result,"r")as file:
    count = 0
    for i in file:
        count +=1
# Calls pattern matcher, returning any found matches.
PatternsFound = pattern_finder(File_contents)
print(PatternsFound)
match arg.verbose:
    case 1:
        print(f"File name given is {result}, \n Count of lines in file is: {count}\n List of identified patterns is: {PatternsFound}")  
    case 0:
        print(f"full file data: {File_contents}")
    case _:
        print(f"line count: {count}, patterns: {PatternsFound}")