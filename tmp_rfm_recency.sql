CREATE TABLE analysis.tmp_rfm_recency (
    user_id INT NOT NULL PRIMARY KEY,
    recency INT NOT NULL CHECK (recency >= 1 AND recency <= 5)
);

INSERT INTO analysis.tmp_rfm_recency (user_id, recency)
SELECT user_id, recency_factor
FROM recency;
