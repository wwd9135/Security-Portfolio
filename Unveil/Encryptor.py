# Please refer to README> Developer Notes for an recent code review




import hashlib
import math
import importlib.util
import sys
import random
class Caller:
    def __init__(self) -> None:
        self.data = ""

    def txt_import(self):
        try:
            with open(input("Enter your text file name: "), "r") as file:
                # Read the file contents
                contents = file.read()  # Reads the entire file as a string
                binary_representation = ''.join(format(ord(c), '08b') for c in contents)
                self.data = binary_representation
                print(contents)
                print("Binary Representation of the text file:")
                print(binary_representation)
        except FileNotFoundError:
            print("Error: The file was not found.")
        except Exception as e:
            print(f"An error occurred: {e}")

    def img(self):
        try:
            with open(input("Enter your image file name: "), "rb") as file:
                # Open the image file contents in binary mode
                contents = file.read()
                print("Binary data of the image (first 100 bytes):")
                print(contents[:100])  # Print the first 100 bytes for preview
        except FileNotFoundError:
            print("Error: The file was not found.")
        except Exception as e:
            print(f"An error occurred: {e}")

    def docx(self):
        try:
            file_name = input("Enter your docx file name: ")
            doc = Document(file_name)

            # Read and print all paragraphs in the document
            print("Contents of the .docx file:")
            for para in doc.paragraphs:
                print(para.text)
        except FileNotFoundError:
            print("Error: The file was not found.")
        except Exception as e:
            print(f"An error occurred: {e}")

    def decider(self):
        while True:
            try:
                choice = int(input("Choose options from the following: img(1), txt(2), docx(3): "))
                if choice == 1:
                    self.img()
                    break
                elif choice == 2:
                    self.txt_import()
                    break
                elif choice == 3:
                    self.docx()
                    break
                else:
                    print("Incorrect entry: Please choose one of the 3 provided options.")
            except ValueError as e:
                print("An error occurred:", e)
                continue  # Continue the loop if there's an invalid entry


class Caesar:
    def __init__(self, caller_instance, shift=None):
        self.shift = shift  # Default to None if not provided
        self.database = []  # Initialize the database as an empty list
        self.caller_data = caller_instance.data  # Access 'data' from Caller class
        self.encryptionHeader = ["",]

    def errorCheck(self):
        while True:
            try: 
                self.caller_data  # Access 'data' from Caller class
                if all(bit in '01' for bit in self.caller_data):
                    # The data is binary (only contains 0's and 1's)
                    print("Data is binary!")
                    break  # Break the loop once the data is valid
                else:
                    # The data is not binary
                    print("Data is not binary!")
                    caller_instance.decider()  # Re-run the decider if not binary
                    return  # Ensure we don't re-enter the errorCheck loop
            except ValueError as e:
                print("An error occurred:", e)
                break  # In case of ValueError, break the loop

    def take_shift(self):
        while True:
                for i in range(6):
                    shift = random.randint(1,9)
               
                self.shift = int(shift)  # Convert the shift to an integer
                print(f"You entered: {shift}")
                self.encryptionHeader.append(self.shift)
                return self.encryptionHeader
           
    def caeser(self):
        # Apply the Caesar cipher shift to each digit in the binary string
        if not self.caller_data or self.shift is None:
            print("No data or shift provided!")
            return None  # Return None if there's no data or shift
        
        # Apply the shift to each binary digit (convert to integer for shifting)
        shifted_binary = [(int(binary) + self.shift) % 2 for binary in self.caller_data]  # Shift binary digits
        
        # Print the original binary data
        print(f"Original binary data: {self.caller_data}")
        
        # Convert the list of shifted binary digits back to a string
        shifted_binary_str = ''.join(str(binary) for binary in shifted_binary)
        print(f"\nFinal Shifted binary: {shifted_binary_str}")
        
        # Return the shifted binary list
        return shifted_binary  # Corrected to return shifted_binary, not shifted_binary_str



# Create an instance of the Caller class
caller_instance = Caller()

# Start the decider method to make file handling decisions
caller_instance.decider()
print("############################################################################################################################# \n Hi I'm Will, and I've developed a basic cipher to be used. \n This is a Caesar cipher, a txt, doc or img file, which will be changed to binary! \n I will then apply the shifter" 
      " Which will alter the binary by a value the user chooses.  " 
      "\n \n ############################################################################################################################")

# Example usage:
caesar = Caesar(caller_instance)  # Pass caller_instance to Caesar

caesar.errorCheck()  # Check if the data is binary
caesar.take_shift()   # Prompt for the shift digit
shifted_binary = caesar.caeser()  # Apply the Caesar cipher shift


# Writing the result to a file
if shifted_binary is not None:  # Ensure the shifted binary is valid
    shifted_binary_str = ''.join(str(binary) for binary in shifted_binary)  # Convert to string
    print(f"Writing the following data to the file: {shifted_binary_str}")  # Debugging step

    with open("dis.txt", "w") as file:  # Use "w" mode to overwrite the file
        file.write(f"The final outputted hash is:\n{shifted_binary_str}")
        file.flush()  # Explicitly flush the file buffer
        print("Data successfully written to the file.")
else:
    print("No shifted binary data available to write to the file.")



# Increase the limit to a higher value
sys.set_int_max_str_digits(10000)

class Algorithm:
    def __init__(self, caesar_instance):  # Pass Caesar instance to Algorithm
        self.cipher_Text = ""
        self.final_output = ""
        self.section1 = ""
        self.section2 = ""
        self.section3 = ""
        self.section4 = ""
        self.input = ""
        self.encryptionHeader = []
        self.final_str = ""
        self.caesar_instance = caesar_instance  # Store the caesar_instance to access self.shift
        self.sec3choice = ""
        self.sec4choice = ""

    def taking_input(self):
        print("############################################################################################################### \n Hi I'm Will, and I've developed a basic cipher to be used. \n The cipher is passed to this program through a txt file called final output! "
              " This program will be taking this encrypted data, and apply more complex algorithms to it! "
              "\n \n ################################################################################################################")
        with open("dis.txt", "r") as file:
            next(file)  # Skip the first line
            self.cipher_Text = file.readline().strip()
            print(f"This is the pre-algorithm input:\n{self.cipher_Text}")

    def shifty(self):
        section_length = len(self.cipher_Text) // 4
        remainder = len(self.cipher_Text) % 4

        self.section1 = self.cipher_Text[:section_length + (1 if remainder > 0 else 0)]
        self.section2 = self.cipher_Text[section_length + (1 if remainder > 0 else 0):section_length * 2 + (1 if remainder > 1 else 0)]
        self.section3 = self.cipher_Text[section_length * 2 + (1 if remainder > 1 else 0):section_length * 3 + (1 if remainder > 2 else 0)]
        self.section4 = self.cipher_Text[section_length * 3 + (1 if remainder > 2 else 0):]

        print(f"\nInitial Block 1: {self.section1}")
        print(f"Initial Block 2: {self.section2}")
        print(f"Initial Block 3: {self.section3}")
        print(f"Initial Block 4: {self.section4}")

    def IV(self):
        # Generate two random digits
        iv_part1 = random.randint(1, 9)  # First random digit
        iv_part2 = random.randint(1, 9)  # Second random digit

        # Combine the two parts to form a two-digit IV
        self.IV = f"{iv_part1}{iv_part2}"  # Combine as string

        # Check if IV has two digits
        if len(self.IV) == 2:
            print(f"\nOur IV factor is: {self.IV}")
            self.encryptionHeader.append(f"IV: {self.IV}")
        else:
            print("Error: IV does not have two digits")
            

        

    def create_substitution_box(self):
        self.substitution_box = {
            'A': 'D', 'B': 'E', 'C': 'F', 'D': 'G', 'E': 'H',
            'F': 'I', 'G': 'J', 'H': 'K', 'I': 'L', 'J': 'M',
            'K': 'N', 'L': 'O', 'M': 'P', 'N': 'Q', 'O': 'R',
            'P': 'S', 'Q': 'T', 'R': 'U', 'S': 'V', 'T': 'W',
            'U': 'X', 'V': 'Y', 'W': 'Z', 'X': 'A', 'Y': 'B', 'Z': 'C'
        }

    def sub(self, input):
        self.create_substitution_box()
        substituted_string = ""

        for char in input:
            if char in self.substitution_box:
                substituted_string += self.substitution_box[char]
            else:
                substituted_string += char

        print(f"Substituted string: {substituted_string}")
        return substituted_string

    def shift_one(self):
        shifted_section1 = int(self.section1, 16)
        # Convert self.IV to an integer before multiplication
        self.section1 = shifted_section1 * int(self.IV)  # Convert self.IV to an integer

        print(f"Block 1 final shift:", self.section1)

    def shift_two(self):
        shifted_section2 = int(self.section2, 16)
        self.section2 = shifted_section2 * self.section1
        print("Block 2 final shift:", self.section2)

    def perm(self, input):
        input_str = str(input)
        section_length = len(input_str) // 4
        remainder = len(input_str) % 4

        section1 = input_str[:section_length + (1 if remainder > 0 else 0)]
        section2 = input_str[section_length + (1 if remainder > 0 else 0):section_length * 2 + (1 if remainder > 1 else 0)]
        section3 = input_str[section_length * 2 + (1 if remainder > 1 else 0):section_length * 3 + (1 if remainder > 2 else 0)]
        section4 = input_str[section_length * 3 + (1 if remainder > 2 else 0):]

        combo = [section1, section2, section3, section4]
        perm_scheme = [1, 4, 2, 3]
        permuted_blocks = [None] * len(combo)

        for i, new_position in enumerate(perm_scheme):
            permuted_blocks[new_position - 1] = combo[i]

        final = ''.join(permuted_blocks)
        print(f"Permuted blocks: {permuted_blocks}")
        print(f"Final result: {final}")

    def shift_three(self):
        method_choice = str(random.randint(1,2))
        
        if method_choice == "1":
            self.perm(self.section3)
            self.sec3choice = 1
        elif method_choice == "2":
            self.sub(self.section3)
            self.sec3choice = 2
        else:
            print("Invalid choice.")

    def shift_four(self):
        method_choice = str(random.randint(1,2))
        if method_choice == "1":
            self.perm(self.section4)
            self.sec4choice = 1
        elif method_choice == "2":
            self.sub(self.section4)
            self.sec4choice = 2
        else:
            print("Invalid choice.")


        

    # Function to XOR two binary strings
    def xor_binary(self,data, key):
        # Ensure the key is long enough for the data
        key = key * (len(data) // len(key)) + key[:len(data) % len(key)]  # Repeat or truncate key
        # XOR each bit of data with the corresponding bit of the key
        result = ''.join(str(int(d) ^ int(k)) for d, k in zip(data, key))
        return result



    def encrypt(self):
        key = "01000000100010100000111111010000000010100000100101001101110110110111001100010110001001000101000011100011110001101111000001111001"
        
        # Combine the sections into one string (assuming each section is a string of digits)
        combined_str = f"{self.section1}{self.section2}{self.section3}{self.section4}"

        sec11 = str(len(str(self.section1)))
        sec22 = str(len(str(self.section2)))
        sec33 = str(len(str(self.section3)))
        sec44 = str(len(str(self.section4)))
        self.encryptionHeader.append(f"Sec1 total: {sec11}")
        self.encryptionHeader.append(f"Sec2 total: {sec22}")
        self.encryptionHeader.append(f"Sec3 total: {sec33}")
        self.encryptionHeader.append(f"Sec4 total: {sec44}")
        
       
        # Convert the combined string to binary
        str_bits = ''.join(format(int(c), '08b') for c in combined_str)
        print(f"test: {str_bits}")
        # Calculate how many 128-character chunks fit into the total length
        count_128 = math.ceil(len(str_bits) / 128)
        print(f"Number of 128-character chunks: {count_128}")

        sec55 = str(len(str_bits))
        self.encryptionHeader.append(f"overall total: {sec55}")
        # List to store all blocks
        all_blocks = []  # This will store all the chunks
        
        for j in range(count_128):
            # Calculate the start and end index for each 128-bit chunk
            start_index = j * 128
            end_index = start_index + 128
            
            # Get the 128-character chunk from str_bits
            bits = str_bits[start_index:end_index]
            
            # Check if the current chunk is less than 128 bits
            if len(bits) < 128:
                # Calculate how much padding is needed
                padding_length = 128 - len(bits)
                # Generate the random binary string for padding
                binary_string = ''.join(random.choice('01') for _ in range(padding_length))
                
                # Add the padded chunk to the all_blocks list
                padded_bits = bits + binary_string
                all_blocks.append(padded_bits)
                
                # Append the padding info to the encryptionHeader
                self.encryptionHeader.append(f"This is the padding used: {binary_string}")
                print(f"Padding for this block: {binary_string}")
            else:
                # Add the chunk directly if it's already 128 bits
                all_blocks.append(bits)
                
                # XOR the binary string with the key for each block
                xor_block = self.xor_binary(bits, key)  # XOR the individual block with the key
                all_blocks[-1] = xor_block  # Replace the last block with the XOR'd version
                print(f"XOR'd block: {xor_block}")  # Print the XOR'd block for debugging

        # Join all the binary chunks into one long string
        joined_bits = ''.join(all_blocks)
        
        # Convert the long binary string to an integer
        self.final_str = int(joined_bits, 2)  # Convert binary string to integer
        self.final_str = bin(self.final_str)[2:]
        
        # Print the final output
        print(f"\nFinal output as binary: {self.final_str}")
       
    def hash(self):
        # Make sure final_str is properly assigned as a string
        final_str = str(self.final_str)
        shift_value = self.caesar_instance.shift  # Access the shift value from Caesar instance
        # Encode the string to bytes
        combined_bytes = final_str.encode('utf-8')

        # Create the SHA-256 hash
        sha256 = hashlib.sha256()
        sha256.update(combined_bytes)
        hash_256 = sha256.digest()  # The final hash (binary)

        # Print the hash in hexadecimal format
        print(f"\nFinal hash of our data, storing this to ensure integrity of data during rest/transit: {hash_256.hex()}")

        # If you want the first 128 bits (16 bytes) of the hash
        hash_128 = hash_256[:16]
        print(f"The first 128 bits of the hash: {hash_128.hex()}")

        # Append encryption details to encryptionHeader
        #self.encryptionHeader.append(f"This is the caeser cipher used: {str(self.shift)}")
        print("\n")
        self.encryptionHeader.append(f"This is the shifting value: {str(shift_value)}")
        self.encryptionHeader.append(f"This is the hash value: {str(hash_256.hex())}")
        self.encryptionHeader.append(f"This is the final encrypted string: {self.final_str}")
        self.encryptionHeader.append(f"This is the block 3 method choice: {self.sec3choice}")
        self.encryptionHeader.append(f"This is the block 4 method choice: {self.sec4choice}")
        print("here",self.encryptionHeader)
        # Write the encryption header to a file
        result = "\n".join(self.encryptionHeader)
        with open("output.txt", "w") as file:
            file.write(result)  # Write the joined string

        # Read back the content and print it
        with open("output.txt", "r") as file:
            s = file.read()
            print("Encryption header: ", s)





shifted_binary = caesar.caeser()  # Apply the Caesar cipher shift

# Now proceed with the Algorithm class, ensuring it's properly passed the Caesar instance
EncryptionH_instance = caesar  # Use the caesar instance after setting the shift

algo = Algorithm(EncryptionH_instance)  # Pass the Caesar instance to Algorithm
algo.taking_input()
algo.shifty()
algo.IV()
algo.shift_one()
algo.shift_two()
algo.shift_three()
algo.shift_four()
algo.encrypt()
algo.hash()  # Now this method can access the shift value
