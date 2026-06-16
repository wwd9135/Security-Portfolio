WITH total_spend AS (
    SELECT c.customer_id, c.name, c.plan, 
           SUM(t.amount) AS total_spend
    FROM customers c 
    JOIN transactions t ON c.customer_id = t.customer_id
    GROUP BY c.customer_id, c.name, c.plan
),
ranked AS (
    SELECT customer_id, name, plan, total_spend,
           DENSE_RANK() OVER(PARTITION BY plan ORDER BY total_spend DESC) AS rnk,
           MAX(total_spend) OVER(PARTITION BY plan) AS top_spender
    FROM total_spend
)
SELECT name, plan, total_spend, rnk, top_spender
FROM ranked
ORDER BY plan, rnk

WITH total_spend AS(
    SELECT c.customer_id, c.name, c.plan, 
        SUM(t.amount) AS total_spend
    FROM customers AS c JOIN transactions AS t ON c.customer_id=t.customer_id
    GROUP BY c.customer_id, c.name, c.plan
), rnker AS(
    SELECT c.customer_id, c.name, c.plan, total_spend, DENSE_RANK() OVER() AS rnk
    FROM total_spend
    
)

SELECT c.name, c.plan, c.total_spend, total_spend.rnk, MAX(total_spend) OVER(PARTITION BY c.plan) AS max_spender
from rnker
GROUP BY c.customer_id, 