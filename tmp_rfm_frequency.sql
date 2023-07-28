CREATE TABLE analysis.tmp_rfm_frequency AS
SELECT 
    user_id,
    NTILE(5) OVER (ORDER BY COUNT(*) DESC) AS frequency
FROM orders
GROUP BY user_id
ORDER BY frequency DESC;