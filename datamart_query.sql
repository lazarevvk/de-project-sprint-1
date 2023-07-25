-- Добавляем недостающие поля в таблицы
ALTER TABLE analysis.tmp_rfm_recency
ADD COLUMN last_order_dt timestamp;

ALTER TABLE analysis.tmp_rfm_frequency
ADD COLUMN order_count int;

ALTER TABLE analysis.tmp_rfm_monetary_value
ADD COLUMN order_sum numeric(19, 5);

-- Обновляем метрику last_order_dt в таблице analysis.tmp_rfm_recency
UPDATE analysis.tmp_rfm_recency AS r
SET last_order_dt = (
    SELECT MAX(o.order_ts)
    FROM production.orders AS o
    WHERE o.user_id = r.user_id
);

-- Обновляем метрику order_count в таблице analysis.tmp_rfm_frequency
UPDATE analysis.tmp_rfm_frequency AS f
SET order_count = (
    SELECT COUNT(*)
    FROM production.orders AS o
    WHERE o.user_id = f.user_id
);

-- Обновляем метрику order_sum в таблице analysis.tmp_rfm_monetary_value
UPDATE analysis.tmp_rfm_monetary_value AS m
SET order_sum = (
    SELECT SUM(o."cost")
    FROM production.orders AS o
    WHERE o.user_id = m.user_id
);

-----------------------------------------------------------------------------------

-- Создаем витрину dm_rfm_segments

CREATE TABLE analysis.dm_rfm_segments (
    user_id INT NOT NULL PRIMARY KEY,
    recency INT NOT NULL CHECK (recency >= 1 AND recency <= 5),
    frequency INT NOT NULL CHECK (frequency >= 1 AND frequency <= 5),
    monetary_value INT NOT NULL CHECK (monetary_value >= 1 AND monetary_value <= 5),
    order_status VARCHAR(50) NOT NULL
);

-- Заполняем витрину данными на основе статуса заказа

INSERT INTO analysis.dm_rfm_segments (user_id, recency, frequency, monetary_value, order_status)
SELECT
    recency.user_id,
    recency.recency,
    frequency.frequency,
    monetary_value.monetary_value,
    4 AS order_status
FROM
    analysis.tmp_rfm_recency AS recency
JOIN analysis.tmp_rfm_frequency AS frequency ON recency.user_id = frequency.user_id
JOIN analysis.tmp_rfm_monetary_value AS monetary_value ON recency.user_id = monetary_value.user_id
JOIN production.orders AS orders ON recency.user_id = orders.user_id
WHERE
    orders.status = 4
ON CONFLICT DO NOTHING;

ALTER TABLE analysis.dm_rfm_segments
DROP COLUMN order_status;