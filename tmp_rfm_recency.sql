-- Исправил три соответствующих запроса, раньше этот код валялся в datamart_ddl.sql 
-- и таблицы были названы неправильно, теперь всё должно быть верно

CREATE TABLE analysis.tmp_rfm_recency AS
SELECT 
    user_id,
    NTILE(5) OVER (ORDER BY MAX(order_ts) DESC) AS recency
FROM orders
GROUP BY user_id
ORDER BY recency DESC;
