CREATE TABLE analysis.tmp_rfm_monetary_value AS
SELECT 
    user_id,
    NTILE(5) OVER (ORDER BY SUM(payment) DESC) AS monetary_value
FROM orders
GROUP BY user_id
ORDER BY monetary_value DESC;