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
