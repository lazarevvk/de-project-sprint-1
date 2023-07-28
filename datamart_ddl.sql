-- Если тебе не трудно, было бы круто, если бы ты оставил свою телегу или написал в мою для коммуникации,
-- не совсем понял некоторые комментарии, но постараюсь исправить в любом случае
-- Моя телега - @lazarevvk

-- Тут, как я понял, я накосячил и неправильно назвал таблицы, проделав лищние телодвижения с кодом и неправильно понял задание
--Походу в этом задании имелся в виду этот код для создания самой витрины:

-- Создаем витрину dm_rfm_segments

CREATE TABLE analysis.dm_rfm_segments (
    user_id INT NOT NULL PRIMARY KEY,
    recency INT NOT NULL CHECK (recency >= 1 AND recency <= 5),
    frequency INT NOT NULL CHECK (frequency >= 1 AND frequency <= 5),
    monetary_value INT NOT NULL CHECK (monetary_value >= 1 AND monetary_value <= 5)
);

-- Так же убрал order status, я его удаляю в коде впоследствии, но его действительно лучше просто не добавлять