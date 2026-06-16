import pandas as pd
import random
from PIL import Image

# ------------------ Inputs class ------------------
class inputs:
    def __init__(self):
        self.Txtinput = ""
        self.data = ""
        self.fit = 0
        self.leftover = 0
        self.pixels = ""
        self.img = ""
        self.df = pd.DataFrame(columns=['R', 'G', 'B'])

    def txt_import(self):
        try:
            with open(input("Enter your text file name: "), "r") as file:
                contents = file.read()
                return contents
        except FileNotFoundError:
            print("Error: The file was not found.")
        except Exception as e:
            print(f"An error occurred: {e}")
    def returner(self):
        return self.fit, self.leftover,self.data
    def txt(self, text):
        # Remove only spaces (leave \n etc. if needed)
        filed = [char for char in text if char != ' ']
        self.files = filed
        self.data = ''.join(format(ord(c), '08b') for c in self.files)
        self.fit = len(self.data) // 3
        self.leftover = len(self.data) % 3

        print(f"[inputs.dataStuct] Fit (triplets): {self.fit}")
        print(f"[inputs.dataStuct] Leftover characters: {self.leftover}\n \n")
        print(f"[inputs.txt] Filtered characters (without spaces):\n{filed}")
        print(f"[inputs.txt] Binary representation ({len(self.data)} bits):\n{self.data}")
    def update_image_from_df(self):
        if self.df.empty:
            print("DataFrame is empty. No image update performed.")
            return

        self.img = Image.open("sd.webp")
        self.pixels = self.img.load()

        for i in range(len(self.df)):
            x = i + 1
            y = i + 1
            row = self.df.loc[i]

            # Always get R, since it's guaranteed to exist
            r = int(row['R'], 2)

            # Handle G and B safely — only convert if valid
            g = int(row['G'], 2) if pd.notna(row.get('G')) and isinstance(row.get('G'), str) else self.pixels[x, y][1]
            b = int(row['B'], 2) if pd.notna(row.get('B')) and isinstance(row.get('B'), str) else self.pixels[x, y][2]

            self.pixels[x, y] = (r, g, b)

        self.img.save("output.png")
        print("[update_image_from_df] Image updated and saved as output.png")


    def dataStuctAddition(self, a, b=None, c=None):
        """ This function appends bits to the last binary string of each column in the DataFrame """
        # Initialize DataFrame with empty rows if it's empty
        if self.df.empty:
            self.df = pd.DataFrame(columns=['R', 'G', 'B'])
            # Initialize columns with empty strings to ensure type consistency
            self.df['R'] = self.df['R'].astype(str)
            self.df['G'] = self.df['G'].astype(str)
            self.df['B'] = self.df['B'].astype(str)

        # If it's the first entry, create a new row for R, G, B
        if b is None:
            new_row = {'R': a}
            self.df = pd.concat([self.df, pd.DataFrame([new_row])], ignore_index=True)
        elif c is None:
            new_row = {'R': a, 'G': b}
            self.df = pd.concat([self.df, pd.DataFrame([new_row])], ignore_index=True)
        else:
            new_row = {'R': a, 'G': b, 'B': c}
            self.df = pd.concat([self.df, pd.DataFrame([new_row])], ignore_index=True)

    def changer(self):
        bit_index = 0  # Index for data bits

        for i in range(len(self.df)):
            for channel in ['R', 'G', 'B']:
                if bit_index < len(self.data):
                    original_binary = self.df.at[i, channel]
                    if len(original_binary) == 8:  # Only modify if it's a full 8-bit string
                        modified_binary = original_binary[:-1] + self.data[bit_index]
                        self.df.at[i, channel] = modified_binary
                        bit_index += 1
                else:
                    break  # Stop if we run out of bits

        print("\n[Changer] DataFrame after LSB replacement:\n", self.df)

    def image(self):
        """ This function processes the image and adds binary data to the DataFrame """
        self.img = Image.open("sd.webp")
        print(f"Size of image is: {self.img.size}")
        print(f"Image mode is: {self.img.mode}")
        self.pixels = self.img.load()

        # Iterating over the pixels and extracting the RGB values
        for i in range(self.fit):
            x = i + 1
            y = i + 1
            self.current = self.pixels[x, y]
            a = self.current[0]
            b = self.current[1]
            c = self.current[2]

            # Convert RGB values to binary
            red = format(a, '08b')
            green = format(b, '08b') if b is not None else None
            blue = format(c, '08b') if c is not None else None

            # Add the binary triplet to the DataFrame
            self.dataStuctAddition(red, green, blue)

        # If leftover data is less than a full pixel, add one or two colour channels worth of data to end of output.
        if self.leftover == 1:
            self.dataStuctAddition(red)
        elif self.leftover == 2:
            self.dataStuctAddition(red, green)

        # Save the output image
        self.img.save("output.png")
        print(self.df)


# ------------------ Decryptor ------------------
class extraction:
    def __init__(self,fit,leftover,data):
        self.fit = fit
        self.leftover = leftover
        self.data = data
        self.output = ""
        self.img =  Image.open("output.png")
        self.pixels = self.img.load()
        self.df = pd.DataFrame(columns=['R', 'G', 'B'])
       
    def dataStuctAddition(self, a, b=None, c=None):
        # Initialize DataFrame with empty rows if it's empty
        if self.df.empty:
            self.df = pd.DataFrame(columns=['R', 'G', 'B'])
            # Initialize columns with empty strings to ensure type consistency
            self.df['R'] = self.df['R'].astype(str)
            self.df['G'] = self.df['G'].astype(str)
            self.df['B'] = self.df['B'].astype(str)

        # If it's the first entry, create a new row for R, G, B
        if b is None:
            new_row = {'R': a}
            self.df = pd.concat([self.df, pd.DataFrame([new_row])], ignore_index=True)
        elif c is None:
            new_row = {'R': a, 'G': b}
            self.df = pd.concat([self.df, pd.DataFrame([new_row])], ignore_index=True)
        else:
            new_row = {'R': a, 'G': b, 'B': c}
            self.df = pd.concat([self.df, pd.DataFrame([new_row])], ignore_index=True)

    def extract(self):
        bit_index = 0  # Index for data bits
        store = [ ]
        print(f"Self.data: {self.data}")
        for i in range(len(self.df)):
            for channel in ['R', 'G', 'B']:
                if bit_index < len(self.data):
                    original_binary = self.df.at[i, channel]
                    if len(original_binary) == 8:  # Only modify if it's a full 8-bit string
                       
                        store.append(original_binary[-1])


                        bit_index += 1
                else:
                    break  # Stop if we run out of bit
        s = "".join(map(str, store))
        print(f"Str before decryption: {s}")
        self.output = s
    def image(self):
        """ This function processes the image and adds binary data to the DataFrame """
        self.img = Image.open("output.png")
        print(f"Size of image is: {self.img.size}")
        print(f"Image mode is: {self.img.mode}")
        self.pixels = self.img.load()

        # Iterating over the pixels and extracting the RGB values
        for i in range(self.fit):
            x = i + 1
            y = i + 1
            self.current = self.pixels[x, y]
            a = self.current[0]
            b = self.current[1]
            c = self.current[2]

            # Convert RGB values to binary
            red = format(a, '08b')
            green = format(b, '08b') if b is not None else None
            blue = format(c, '08b') if c is not None else None

            # Add the binary triplet to the DataFrame
            self.dataStuctAddition(red, green, blue)

        # If leftover data is less than a full pixel, add one or two colour channels worth of data to end of output.
        if self.leftover == 1:
            self.dataStuctAddition(red)
        elif self.leftover == 2:
            self.dataStuctAddition(red, green)

        # Save the output image
        self.img.save("output.png")
        print(self.df)


# ------------------ Reverse Caesar Cipher Class ------------------
class reverseCaeser:
    def __init__(self, extract_instance):
        self.shifts = 5
        self.extractStr = extract_instance.output
        self.recovered = ""

    def shift(self):
        decrypted_binary = ""
        for i in range(0, len(self.extractStr) - 7, 8):
            byte = self.extractStr[i:i+8]
            integer_value = int(byte, 2)
            shifted_value = (integer_value - self.shifts) % 256
            decrypted_binary += format(shifted_value, '08b')

        # Carry any remaining bits unmodified (no padding)
        remainder = len(self.extractStr) % 8
        if remainder:
            decrypted_binary += self.extractStr[-remainder:]

        self.recovered = decrypted_binary
        print("[reverseCaeser] Recovered binary:\n", self.recovered)
    def to_ascii(self):
        ascii_string = ""
        for i in range(0, len(self.recovered) - 7, 8):
            byte = self.recovered[i:i+8]
            ascii_string += chr(int(byte, 2))
        return ascii_string


# ------------------ Caesar Cipher Class ------------------
class Caesar:
    def __init__(self, caller_instance):
        self.shift = 5
        self.caller_data = caller_instance.data
        self.encryptionHeader = [""]

    def errorCheck(self):
        if not all(bit in '01' for bit in self.caller_data):
            return
        

    def caeser(self):
        if not self.caller_data or self.shift is None:
            print("No data or shift provided!")
            return None

        shifted_binary = ""
        print("HERE",self.caller_data)
        for i in range(0, len(self.caller_data) - 7, 8):
            byte = self.caller_data[i:i + 8]
            original_value = int(byte, 2)
            shifted_value = (original_value + self.shift) % 256
            
            shifted_binary += format(shifted_value, '08b')
        print("HERE TOO",shifted_binary)
        # Carry any remaining bits unmodified (no padding)
        remainder = len(self.caller_data) % 8
        if remainder:
            shifted_binary += self.caller_data[-remainder:]

        return shifted_binary

# ------------------ Run the Program ------------------ 
caller_instance = inputs()
raw_text = caller_instance.txt_import()

caller_instance.txt(raw_text)

caesar = Caesar(caller_instance)
caesar.errorCheck()

shifted_binary = caesar.caeser()

# Pass the shifted_binary to the inputs class by setting it as the caller_instance data
caller_instance.data = shifted_binary  # Store the shifted_binary data in inputs

caller_instance.image()
caller_instance.changer()

# Saving the shifted_binary output to a file (optional)
if shifted_binary:
    with open("dis.txt", "w") as file:
        file.write(f"The final outputted hash is:\n{shifted_binary}")
else:
    print("No shifted binary data available to write.")

caller_instance.update_image_from_df()  # Add this line to update the image based on the final dataframe

# Extract data from the image and perform reverse caesar decryption
s = caller_instance.returner()

extract_instance = extraction(s[0], s[1], s[2])

extract_instance.image()
extract_instance.extract()

rCaeser = reverseCaeser(extract_instance)
rCaeser.shift()
ascii_result = rCaeser.to_ascii()

# Output the decrypted ASCII result
print("[ASCII Output]:", ascii_result)
