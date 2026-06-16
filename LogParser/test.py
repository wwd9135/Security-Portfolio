import pandas as pd

df = pd.DataFrame({
    'customer': ['William', 'William', 'John', 'John', 'Sarah', 'Sarah'],
    'product': ['Laptop', 'Phone', 'Laptop', 'Tablet', 'Phone', 'Laptop'],
    'amount': [999, 499, 999, 299, 499, 999],
    'region': ['North', 'North', 'South', 'South', 'North', 'South']
})
# Find the most expensive purchase per customer
# Show customer, product, amount

df['dept_max'] = df.groupby('customer')['amount'].transform('max')
print(df[['customer', 'product', 'amount', 'dept_max']]).