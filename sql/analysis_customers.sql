-- View: each customer's first order and days from registration to first order
CREATE OR REPLACE VIEW customers_details AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.registration_date,
    MIN(o.order_date) AS first_order_date,
    DATEDIFF(MIN(o.order_date), c.registration_date) AS days_to_first_order
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
GROUP BY c.customer_id;


-- Average, fastest and slowest time to first order
SELECT
    ROUND(AVG(days_to_first_order), 1) AS avg_days,
    MIN(days_to_first_order) AS fastest,
    MAX(days_to_first_order) AS slowest
FROM customers_details;


-- Total customers and customers who ordered
SELECT
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(DISTINCT customer_id) FROM orders) AS customers_who_ordered;


-- Customers who never placed an order
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.registration_date
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;


-- Average revenue per customer
SELECT
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
        / COUNT(DISTINCT o.customer_id), 2) AS avg_revenue_per_customer
FROM order_items AS oi
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed';


-- Top 10 customers by total spend
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_spent
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, customer_name
ORDER BY total_spent DESC
LIMIT 10;


-- Revenue and average spend by gender
SELECT
    c.gender,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
        / COUNT(DISTINCT c.customer_id), 2) AS avg_spend_per_customer
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.gender;


-- Revenue and average spend by age decade (20s, 30s, ...)
SELECT
    FLOOR(c.age / 10) * 10 AS age_decade,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
        / COUNT(DISTINCT c.customer_id), 2) AS avg_spend_per_customer
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY age_decade
ORDER BY age_decade;


-- Customers and revenue by city
SELECT
    c.city,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.city
ORDER BY revenue DESC;


-- New customer registrations per month
SELECT
    DATE_FORMAT(registration_date, '%Y-%m') AS month,
    COUNT(*) AS new_customers
FROM customers
GROUP BY month
ORDER BY month;


-- Customers with no order in the last 6 months of data
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    MAX(o.order_date) AS last_order_date
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, customer_name
HAVING MAX(o.order_date) < (SELECT MAX(order_date) FROM orders) - INTERVAL 6 MONTH
ORDER BY last_order_date;
