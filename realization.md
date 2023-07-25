# Витрина RFM

## 1.1. Выясните требования к целевой витрине.

{См. задание на платформе}
-----------

{
    1. Витрина должна располагаться в той же базе в схеме analysis
    2. Витрина должна состоять из таких полей:
            user_id
            recency (число от 1 до 5)
            frequency (число от 1 до 5)
            monetary_value (число от 1 до 5)
    3. В витрине нужны данные с начала 2022 года.
    4. Назовите витрину dm_rfm_segments.
    5. Обновления не нужны.
    6. Успешный заказ - это заказ со статусом Closed
    7. Каждую категорию должны получить 200 пользователей
}



## 1.2. Изучите структуру исходных данных.

{См. задание на платформе}

-----------

{
    Для составления витрины будут использоваться данные из таблицы orders:
            Для recency - user_id, order_ts
            Для frequency - user_id
            Для monetary_value - user_id, payment

}


## 1.3. Проанализируйте качество данных

{См. задание на платформе}
-----------

{
    ## Оцените, насколько качественные данные хранятся в источнике.
Опишите, как вы проверяли исходные данные и какие выводы сделали.

Для проверки исходных данных я использовал DBeaver, чтобы просмотреть существующие ограничения в таблицах. Основные ограничения в виде CHECK, PRIMARY KEY были прописаны, что означает целостность и логичность данных. Так же каждая колонка в таблице содержит ограничение NOT NULL, что означает отсутствие пустых и некачественных данных. В связи с этим, процесс чистки данных можно пропустить и заняться оформлением витрины. Однако есть погрешность, user_id в таблице orders никак не связан с таблицей users, что может затруднить работу приложения и усложнить написание кода в будущем.

## Укажите, какие инструменты обеспечивают качество данных в источнике.
Ответ запишите в формате таблицы со следующими столбцами:
- `Наименование таблицы` - наименование таблицы, объект которой рассматриваете.
- `Объект` - Здесь укажите название объекта в таблице, на который применён инструмент. Например, здесь стоит перечислить поля таблицы, индексы и т.д.
- `Инструмент` - тип инструмента: первичный ключ, ограничение или что-то ещё.
- `Для чего используется` - здесь в свободной форме опишите, что инструмент делает.

Пример ответа:

| Таблицы                   | Объект                                                                                   | Инструмент     | Для чего используется                                           |
| -------------------       | -----------------------------------------------------------------------------------------| -------------- | --------------------------------------------------------------- |
| production.Products       | id int NOT NULL PRIMARY KEY                                                              | Первичный ключ | Обеспечивает уникальность записей о пользователях               |
| production.orderitems     | CONSTRAINT orderitems_check CHECK (((discount >= (0)::numeric) AND (discount <= price))) | Ограничение    | Скидка не 0 и меньше цены товара                                |
| production.orderstatuslog | orderstatuslog_order_id_fkey FOREIGN KEY (order_id)                                      | Внешний ключ   | Не позволяет появление несуществующих order_id в orderstatuslog |
}


## 1.4. Подготовьте витрину данных

{См. задание на платформе}
### 1.4.1. Сделайте VIEW для таблиц из базы production.**

{См. задание на платформе}
```SQL
--Впишите сюда ваш ответ

CREATE VIEW analysis.Users AS
SELECT * FROM production.users;

CREATE VIEW analysis.OrderItems AS
SELECT * FROM production.orderitems;

CREATE VIEW analysis.OrderStatuses AS
SELECT * FROM production.orderstatuses;

CREATE VIEW analysis.Products AS
SELECT * FROM production.products;

CREATE VIEW analysis.Orders AS
SELECT * FROM production.orders;


```

### 1.4.2. Напишите DDL-запрос для создания витрины.**

{См. задание на платформе}
```SQL
--Впишите сюда ваш ответ

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


```

### 1.4.3. Напишите SQL запрос для заполнения витрины

{См. задание на платформе}
```SQL
--Впишите сюда ваш ответ

-- Создаем таблицы для витрины

CREATE TABLE analysis.tmp_rfm_recency (
    user_id INT NOT NULL PRIMARY KEY,
    recency INT NOT NULL CHECK (recency >= 1 AND recency <= 5)
);

CREATE TABLE analysis.tmp_rfm_frequency (
    user_id INT NOT NULL PRIMARY KEY,
    frequency INT NOT NULL CHECK (frequency >= 1 AND frequency <= 5)
);

CREATE TABLE analysis.tmp_rfm_monetary_value (
    user_id INT NOT NULL PRIMARY KEY,
    monetary_value INT NOT NULL CHECK (monetary_value >= 1 AND monetary_value <= 5)
);

-- Заполняем таблицы на основе созданных ранее представлений

INSERT INTO analysis.tmp_rfm_recency (user_id, recency)
SELECT user_id, recency_factor
FROM recency;

INSERT INTO analysis.tmp_rfm_frequency (user_id, frequency)
SELECT user_id, frequency_factor
FROM frequency;

INSERT INTO analysis.tmp_rfm_monetary_value (user_id, monetary_value)
SELECT user_id, monetary_value_factor
FROM monetary_value;

-----------------------------------------------------------------------------------

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


```

## 2.X Обновление Orders в связи с изменениями.

{См. задание на платформе}
```SQL

--Впишите сюда ваш ответ


CREATE OR REPLACE VIEW analysis.Orders AS
SELECT
    o.order_id,
    o.order_ts,
    o.user_id,
    o.bonus_payment,
    o.payment,
    o.cost,
    o.bonus_grant,
    osl.status_id AS status
FROM
    production.Orders o
LEFT JOIN LATERAL (
    SELECT
        status_id,
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY dttm DESC) AS rn
    FROM
        production.OrderStatusLog osl
    WHERE
        osl.order_id = o.order_id
) osl ON osl.rn = 1;


