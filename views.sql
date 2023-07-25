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