CREATE OR REPLACE VIEW recency AS
SELECT 
    user_id,
    NTILE(5) OVER (ORDER BY MAX(order_ts) DESC) AS recency_factor
FROM orders
GROUP BY user_id
ORDER BY recency_factor DESC;

CREATE OR REPLACE VIEW frequency AS
SELECT 
    user_id,
    NTILE(5) OVER (ORDER BY COUNT(*) DESC) AS frequency_factor
FROM orders
GROUP BY user_id
ORDER BY frequency_factor DESC;

CREATE OR REPLACE VIEW monetary_value AS
SELECT 
    user_id,
    NTILE(5) OVER (ORDER BY SUM(payment) DESC) AS monetary_value_factor
FROM orders
GROUP BY user_id
ORDER BY monetary_value_factor DESC;