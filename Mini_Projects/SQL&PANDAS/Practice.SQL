Question 5 — Medium/Hard
sales
sale_id | rep      | region  | product  | amount | sale_date
--------|----------|---------|----------|--------|------------
1       | William  | North   | Laptop   | 999    | 2024-01-05
2       | William  | North   | Phone    | 499    | 2024-01-20
3       | William  | North   | Laptop   | 999    | 2024-02-15
4       | Sarah    | North   | Tablet   | 299    | 2024-02-20
5       | Sarah    | North   | Laptop   | 999    | 2024-03-10
6       | John     | South   | Phone    | 499    | 2024-01-08
7       | John     | South   | Laptop   | 999    | 2024-02-22
8       | Lisa     | South   | Tablet   | 299    | 2024-01-15
9       | Lisa     | South   | Phone    | 499    | 2024-02-08
10      | Lisa     | South   | Laptop   | 999    | 2024-03-20
Find the top performing sales rep in each region by total revenue. Then show for each of those top reps, how their individual monthly revenue breaks down, 
and their running total revenue across the months shown.
Output: region, rep, month, monthly revenue, running total.



1. Need to get clever here with winfunctions, ideally one for top perfroming sales rep, find sum of amount for each rep, then identify which is highest per region (max total?)
2. make a seperate one, finding individual monthly revenue breakdown, shouldnt be too bad just cant imagine what this would be in the final table?
3. Make a running total (PARTITION BY rep, group by amount desc)
4. Combine, be careful over exact outputs here.


SELECT region, rep, month, monthly_rev, running_total