
+---------------+-----------+


subscriptions:
sub_id | customer_id | plan    | start_date | end_date   | monthly_price
-------|-------------|---------|------------|------------|-------------
1      | 1           | Pro     | 2023-01-01 | 2024-12-31 | 49.99
2      | 2           | Basic   | 2023-03-01 | 2023-12-31 | 19.99
3      | 3           | Pro     | 2023-06-01 | 2024-12-31 | 49.99
4      | 4           | Basic   | 2024-01-01 | 2024-12-31 | 19.99
5      | 1           | Premium | 2024-01-01 | 2024-12-31 | 99.99

payments:
payment_id | sub_id | amount | payment_date | status
-----------|--------|--------|--------------|--------
1          | 1      | 49.99  | 2023-01-31   | success
2          | 1      | 49.99  | 2023-02-28   | success
3          | 2      | 19.99  | 2023-03-31   | failed
4          | 3      | 49.99  | 2023-06-30   | success
5          | 1      | 49.99  | 2023-03-31   | success
6          | 4      | 19.99  | 2024-01-31   | success
7          | 5      | 99.99  | 2024-01-31   | success
8          | 3      | 49.99  | 2023-07-31   | success
9          | 2      | 19.99  | 2023-04-30   | success
10         | 5      | 99.99  | 2024-02-29   | success
For each customer show their total successful payments, total amount paid, their most recent plan, and whether they have ever had a failed payment. 
Order by total amount paid descending.

# Need to GROUP BY sub_id, plan,
# Need HAVING status = success
# SUM(amount)
# COUNT(payment_id) AS success_count
# for most recent plan likely need a first_order or a MIN/MAX(CASE WHEN)- we basically need to calculate the max end date 