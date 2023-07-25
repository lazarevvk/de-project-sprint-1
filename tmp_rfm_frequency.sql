CREATE TABLE analysis.tmp_rfm_frequency (
    user_id INT NOT NULL PRIMARY KEY,
    frequency INT NOT NULL CHECK (frequency >= 1 AND frequency <= 5)
);

INSERT INTO analysis.tmp_rfm_frequency (user_id, frequency)
SELECT user_id, frequency_factor
FROM frequency;