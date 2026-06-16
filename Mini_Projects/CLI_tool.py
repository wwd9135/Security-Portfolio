# This script demonstrates basic input filtering in Python using a password example.
# It is not production-ready and does not create accounts or store passwords.
# The goal is to illustrate best practices for validating and sanitizing input.

from argparse import ArgumentParser, Namespace
from datetime import date
import string

def length_check(pw):
    if len(pw) > 20:
        return "Error: password too long (20 max)"
    elif len(pw) < 8:
        return "Error: password too short (8 min)"
    return None


def character_type(pw):
    has_lower = any(c.islower() for c in pw)
    has_upper = any(c.isupper() for c in pw)
    has_digit = any(c.isdigit() for c in pw)
    has_symbol = any(c in string.punctuation for c in pw)

    types = sum([has_lower, has_upper, has_digit, has_symbol])

    if types >= 2:
        return None
    return "Error: password must contain 2 or more character types"

def Filtration(pw):
    # length check
    err = length_check(pw)
    if err:
        return err

    # character type check
    err = character_type(pw)
    if err:
        return err

    return pw

def inputs():
    parser = ArgumentParser()
    parser.usage = "Enter a 2 or more character type password of length 8-20, dont use common words please."
    parser.add_argument("Password_input", help="Enter a 8-20 length Password, containing 2 or more character types & no simple words." , type=Filtration)
    parser.add_argument("-v", "--verbose", help="Verbose provides a more advanced output description.", choices=[0,1])

    arg : Namespace = parser.parse_args()
    result: Namespace = arg.Password_input
    # Would use password result here to create a password store but this exercise was focused on input filtering not production level usability.

    if arg.verbose == 0:
        print("You have successfully set your password, it is now saved to your account, please log in now. If you have any issues with this re-run this program to create a new password and account.")
    elif arg.verbose == 1:
        print("Password has been set to your user account.")
    else:
        print("Password set")
    
Filtered_Password = inputs()
