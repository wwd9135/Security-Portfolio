products = ["  LAPTOP pro ", "phone BASIC  ", "  TABLET Premium"]
# Strip whitespace and convert to title case
# Expected: ["Laptop Pro", "Phone Basic", "Tablet Premium"]
new = []
for i in products:
    i = i.title()
    new.append(i.strip())
#print(new)

prod_list = [
    
    item for item in products]

words = ["security", "data", "engineering", "BI", "pipeline"]
# Return only words longer than 4 characters
# Expected: ["security", "engineering", "pipeline"]
new_list = []
for item in words:
    if len(item) > 4:
        new_list.append(item)
    else:
        continue
#print(new_list)

s = "William Richardson"
# Return just the last name
# Hint: split on space
new = s.split(" ")
#print(new[1])

new_list.clear()
emails = ["William@Amazon.com", "JOHN@Google.com", "sarah@Microsoft.com"]
# Lowercase everything
# Expected: ["william@amazon.com", "john@google.com", "sarah@microsoft.com"]
for item in emails:
    item = item.lower()
    new_list.append(item)
#print(new_list)

prices = ["£1,299", "£899", "£1,099", "£499"]
# Remove £ and commas, convert to integers
# Expected: [1299, 899, 1099, 499]
new_list.clear()
for item in prices:
    item = item.removeprefix("£")
    new_list.append(item)
#print(new_list)

sentence = "business intelligence engineer at amazon"
# Capitalise first letter of each word
# Count how many words are longer than 5 characters
#print(sentence.title())
total = 0
sentence = sentence.split(" ")
for item in sentence:
    if len(item) > 5:
        total +=1
#print(f"Count of words longer than 5 characters: {total}")

order_ids = ["ORD-001", "ord002", "Ord-003", "ORD004"]

new_order = []
for oid in order_ids:
    oid = oid.upper()                     # Normalise case
    digits = "".join(filter(str.isdigit, oid))  # Extract numbers only
    formatted = f"ORD-{int(digits):03d}"  # Convert to int, pad to 3 digits
    new_order.append(formatted)
    #print(digits)

#print(new_order)



# Given this list of customer records as strings
records = [
    "William Richardson | age:21 | city:Newcastle",
    "John Smith | age:34 | city:London",
    "Sarah Jones | age:28 | city:Manchester"
]
# Parse into a list of dictionaries
# Expected:
[
    {"name": "William Richardson", "age": 21, "city": "Newcastle"},
    {"name": "John Smith", "age": 34, "city": "London"},
    {"name": "Sarah Jones", "age": 28, "city": "Manchester"}
]
new_dict = []
for i in records:
    newVal = i.split("|")
    #print(newVal)
    new_dict.append({"name": newVal[0], "age": int(newVal[1].split(":")[1]), "city": newVal[2].split(":")[1]})
#print(new_dict)



# Given this log file string
log = """
2024-01-15 ERROR Database connection failed
2024-01-15 INFO User logged in successfully  
2024-01-16 ERROR Timeout on API call
2024-01-16 WARNING High memory usage detected
2024-01-17 ERROR Authentication failed
"""
# Extract all ERROR lines and return just the error messages
# Expected: [
#   "Database connection failed",
#   "Timeout on API call", 
#   "Authentication failed"
# ]
new2 = []
new = log.split("\n")
#print(new)
for i in new:
    if "ERROR" in i:
        new2.append(i.split("ERROR",1)[1].strip())

#print(new2)