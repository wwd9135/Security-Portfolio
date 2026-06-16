# Please refer to README> Developer Notes for an recent code review




# Unused modules
import random
import math


class decryptor:
    def __init__(self) -> None:
        self.final = ""
        self.Table = []
        self.input = []
        self.binary_str = ""
        self.final_output = ""
        self.section1 = ""
        self.section2 = ""
        self.section3 = ""
        self.section4 = ""
        self.encryptionHeader = []
        self.final_str = ""
        self.List = []
        self.iv = []
        self.hash = ""
        self.shiftValue = []  # Changed to list
        self.fileType = ""  # txt, doc, img from caller class.
        self.sec3choice = ""
        self.sec4choice = ""
        self.padding = ""
        self.sec1len = ""
        self.sec2len = ""
        self.sec3len = ""
        self.sec4len = ""
        self.secTotLen = ""

    def TakingInput(self, iencHeader):
        self.input = [item[0] for item in iencHeader]  # Flatten the list of lists to a list of strings
        print(f"Received Input: {self.input}") 
        ls1 = []  # For IV
        ls2 = []  # For ShiftValue
        ls3 = []  # For hash

        for row in self.input:
            print(f"\nProcessing row: {row}")
            # Extract IV (e.g., IV: 12 -> ['1', '2']) 
            if "IV:" in row: 
                iv_string = row.split(':')[1].strip()  # Split by ':' 
                ls1 = int(iv_string)  # Convert to a list of digits 
                self.iv = ls1 
                print(f"IV: {self.iv}")

            # Extract Shift Value (e.g., This is the shifting value 123456 -> [1, 2, 3, 4, 5, 6]) 
            elif "shifting value" in row: 
                shift_string = row.split(':')[1].strip()  # Split by ':' 
                ls2 = int(shift_string)  # Convert each digit to an integer 
                self.shiftValue = ls2 
                print(f"ShiftValue: {self.shiftValue}")
            elif "padding used" in row:
                pad = row.split(":")[1].strip()
                self.padding = pad
                print(f"Padding: {self.padding}")

            # Extract Hash (e.g., This is the hash value: ... -> hash value itself) 
            elif "hash value" in row: 
                self.hash = row.split(':')[1].strip()  # Split by ':' 
                print(f"Hash: {self.hash}")

            # Extract Final Encrypted String (e.g., This is the final encrypted string: ... -> binary string)
            elif "final encrypted string" in row: 
                self.final_str = row.split(':')[1].strip()  # Take the encrypted binary string 
                print(f"Encrypted binary string: {self.final_str}")

            elif "block 3 method choice" in row: 
                self.sec3choice = row.split(':')[1].strip() 
                print(f"Method 3 choice: {self.sec3choice}")

            elif "block 4 method choice" in row: 
                self.sec4choice = row.split(':')[1].strip() 
                print(f"Method 4 choice: {self.sec4choice}")

            # Taking the data to error check the un XOR'd blocks
            elif "Sec1 total" in row:
                self.sec1len = row.split(':')[1].strip()
                print(f"Section 1 pre XOR length: {self.sec1len}")
            elif "Sec2 total" in row:
                self.sec2len = row.split(':')[1].strip()
                print(f"Section 2 pre XOR length: {self.sec2len}")
            elif "Sec3 total" in row:
                self.sec3len = row.split(':')[1].strip()
                print(f"Section 3 pre XOR length: {self.sec3len}")
            elif "Sec4 total" in row:
                self.sec4len = row.split(':')[1].strip()
                print(f"Section 4 pre XOR length: {self.sec4len}")
            elif "overall total" in row:
                self.secTotLen = row.split(':')[1].strip()
                print(f"Combined total pre XOR length: {self.secTotLen}")

            # Check if all critical data is collected
            if self.sec3choice and self.sec4choice and self.final_str and self.hash and self.iv:
                print("Data successfully collected")
            else:
                print("Error in encryption header")

    def xor_binary(self, data, key):
        """ Reversing the XOR operation by XORing again with the same key """
        key = key * (len(data) // len(key)) + key[:len(data) % len(key)]  # Repeat or truncate key
        # XOR each bit of data with the corresponding bit of the key
        result = ''.join(str(int(d) ^ int(k)) for d, k in zip(data, key))
        return result

    def reverse_caesar_shift(self, data, shift):
        """ Apply reverse Caesar cipher shift (shift by -value) """
        shifted_binary = [(int(binary) - shift) % 2 for binary in data]  # Reverse the shift
        
        # Convert the list of shifted binary digits back to a string
        shifted_binary_str = ''.join(str(binary) for binary in shifted_binary)
        return shifted_binary_str

    def reverse_substitution(self, input):
        """ Reverse the substitution using a reverse substitution box """
        reverse_substitution_box = {
            'A': 'X', 'B': 'Y', 'C': 'Z', 'D': 'A', 'E': 'B', 
            'F': 'C', 'G': 'D', 'H': 'E', 'I': 'F', 'J': 'G',
            'K': 'H', 'L': 'I', 'M': 'J', 'N': 'K', 'O': 'L', 
            'P': 'M', 'Q': 'N', 'R': 'O', 'S': 'P', 'T': 'Q',
            'U': 'R', 'V': 'S', 'W': 'T', 'X': 'U', 'Y': 'V',
            'Z': 'W'
        }
        
        substituted_string = ""
        for char in input:
            if char in reverse_substitution_box:
                substituted_string += reverse_substitution_box[char]
            else:
                substituted_string += char
        return substituted_string

    def reverse_permutation(self, input):
        """ Reverse the permutation step applied to the data """
        input_str = str(input)
        section_length = len(input_str) // 4
        remainder = len(input_str) % 4

        section1 = input_str[:section_length + (1 if remainder > 0 else 0)]
        section2 = input_str[section_length + (1 if remainder > 0 else 0):section_length * 2 + (1 if remainder > 1 else 0)]
        section3 = input_str[section_length * 2 + (1 if remainder > 1 else 0):section_length * 3 + (1 if remainder > 2 else 0)]
        section4 = input_str[section_length * 3 + (1 if remainder > 2 else 0):]

        combo = [section1, section2, section3, section4]
        perm_scheme = [1, 4, 2, 3]  # Reverse the permutation scheme (as given)
        permuted_blocks = [None] * len(combo)

        for i, new_position in enumerate(perm_scheme):
            permuted_blocks[i] = combo[new_position - 1]
        
        final = ''.join(permuted_blocks)
        return final

    def decrypt(self):
        # Step 1: Reverse XOR operation using the encrypted data and key
        xor_key = "01000000100010100000111111010000000010100000100101001101110110110111001100010110001001000101000011100011110001101111000001111001"  # Replace with actual XOR key
        xor_decrypted_data = self.xor_binary(self.final_str, xor_key)

        print(f"After XOR decryption: {xor_decrypted_data}")

        # Step 2: Reverse the Caesar shift (shift by -9)
        caesar_decrypted_data = self.reverse_caesar_shift(xor_decrypted_data, self.shiftValue)

        print(f"After Caesar shift reversal: {caesar_decrypted_data}")

        # Step 3: Reverse the substitution (if applied)
        substituted_data = self.reverse_substitution(caesar_decrypted_data)
        print(f"After substitution reversal: {substituted_data}")

        # Step 4: Reverse the permutation
        permuted_data = self.reverse_permutation(substituted_data)
        print(f"After permutation reversal: {permuted_data}")
        
        return permuted_data

    def validate_decryption(self, decrypted_data):
        """ Validate the decrypted data by comparing hashes """
        hash_in_header = self.hash  # Replace with the hash from the header (e.g., "59c9a96ad3b1aeccc181183491c9920ef69cc8f3d98ac60fd8755ace65da7f0e")
        
        sha256 = hashlib.sha256()
        sha256.update(decrypted_data.encode('utf-8'))
        hash_256 = sha256.hexdigest()
        
        if hash_in_header == hash_256:
            print("Decryption successful! The hashes match.")
        else:
            print(f"Decryption failed. Expected hash: {hash_in_header}, but got: {hash_256}")
with open("output.txt", "r") as file:
    encHead = file.read().strip().splitlines()

encHead = [line.split(',') for line in encHead]

decryptor_instance = decryptor()
decryptor_instance.TakingInput(encHead)
decrypted_data = decryptor_instance.decrypt()
decryptor_instance.validate_decryption(decrypted_data)
