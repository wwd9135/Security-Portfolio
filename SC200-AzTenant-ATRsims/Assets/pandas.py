import pandas as pd

# Load it
df = pd.read_csv('C:\Users\theri\Downloads\datasetPandas\single_amazon_laptop_messy_dataset_1-10.csv')

# First thing always — understand what you have
df.head()          # first 5 rows
df.shape           # rows and columns
df.info()          # column names and types
df.describe()      # basic statistics
df.isnull().sum()  # count nulls per column