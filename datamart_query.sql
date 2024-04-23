
-- Заполняем витрину данными на основе статуса заказа

INSERT INTO analysis.dm_rfm_segments (user_id, recency, frequency, monetary_value)
SELECT
    recency.user_id,
    recency.recency,
    frequency.frequency,
    monetary_value.monetary_value
FROM
    analysis.tmp_rfm_recency AS recency
JOIN analysis.tmp_rfm_frequency AS frequency ON recency.user_id = frequency.user_id
JOIN analysis.tmp_rfm_monetary_value AS monetary_value ON recency.user_id = monetary_value.user_id
JOIN production.orders AS orders ON recency.user_id = orders.user_id
WHERE
    orders.status = 4
ON CONFLICT DO NOTHING;

-- Добавлю так же код для задания, которое пропустил

SELECT user_id, recency, frequency, monetary_value
FROM analysis.dm_rfm_segments
ORDER BY user_id
LIMIT 10;

-- Первые 10 полученных строк по user_id, recency, frequency и monetary value:

0	3	1	1
1	2	2	2
2	3	3	3
3	3	3	4
4	3	2	4
5	2	1	1
6	5	4	4
7	1	5	4
8	2	5	4
9	2	3	4

