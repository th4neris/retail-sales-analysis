--Total revenue, profit, profit margin and number of orders (completed orders)
--Total revenue
SELECT ROUND(SUM(oi.quantity * (oi.unit_price * (1 - oi.discount))),2) AS revenue
FROM order_items oi INNER JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_status = "Completed";

--Profit
SELECT ROUND(SUM(oi.quantity * (oi.unit_price * (1 - oi.discount) - p.unit_cost)),2) AS profit
FROM orders o 
INNER JOIN order_items oi ON oi.order_id = o.order_id
INNER JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = "Completed";

--profit margin
SELECT ROUND(SUM(oi.quantity * (oi.unit_price * (1 - oi.discount) - p.unit_cost)),2)/
	     ROUND(SUM(oi.quantity * (oi.unit_price * (1 - oi.discount))),2) AS profit_margin
FROM orders o 
INNER JOIN order_items oi ON oi.order_id = o.order_id
INNER JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = "Completed";

--number of orders
SELECT COUNT(order_id) AS number_of_orders FROM orders;

-- Average order value
SELECT
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
        / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM order_items AS oi
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed';


-- Orders by status
SELECT
    order_status,
    COUNT(*) AS orders,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 1) AS pct_of_orders
FROM orders
GROUP BY order_status
ORDER BY orders DESC;


-- Revenue lost to cancelled and returned orders
SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS lost_revenue
FROM order_items AS oi
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.order_status IN ('Cancelled', 'Returned')
GROUP BY o.order_status WITH ROLLUP;


-- Total discount given
SELECT
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue_at_list_price,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS actual_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * oi.discount), 2) AS discount_given
FROM order_items AS oi
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed';


-- Monthly revenue and profit
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue,
    ROUND(SUM((oi.unit_price * (1 - oi.discount) - p.unit_cost) * oi.quantity), 2) AS profit
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY month
ORDER BY month;


-- Revenue and profit by year
SELECT
    YEAR(o.order_date) AS year,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue,
    ROUND(SUM((oi.unit_price * (1 - oi.discount) - p.unit_cost) * oi.quantity), 2) AS profit
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY year
ORDER BY year;


-- Profit by store
SELECT
    IF(GROUPING(s.store_name), 'TOTAL', s.store_name) AS store,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue,
    ROUND(SUM((oi.unit_price * (1 - oi.discount) - p.unit_cost) * oi.quantity), 2) AS profit
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
JOIN orders AS o ON o.order_id = oi.order_id
JOIN stores AS s ON s.store_id = o.store_id
WHERE o.order_status = 'Completed'
GROUP BY s.store_name WITH ROLLUP
ORDER BY GROUPING(s.store_name), profit DESC;


-- Revenue, profit and margin by region
SELECT
    s.region,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue,
    ROUND(SUM((oi.unit_price * (1 - oi.discount) - p.unit_cost) * oi.quantity), 2) AS profit,
    ROUND(SUM((oi.unit_price * (1 - oi.discount) - p.unit_cost) * oi.quantity)
        / SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) * 100, 1) AS margin_pct
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
JOIN orders AS o ON o.order_id = oi.order_id
JOIN stores AS s ON s.store_id = o.store_id
WHERE o.order_status = 'Completed'
GROUP BY s.region
ORDER BY profit DESC;


-- Orders and revenue by payment method
SELECT
    o.payment_method,
    COUNT(*) AS orders,
    ROUND(SUM(pay.amount), 2) AS revenue,
    ROUND(AVG(pay.amount), 2) AS avg_order_value
FROM orders AS o
JOIN payments AS pay ON pay.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY o.payment_method
ORDER BY revenue DESC;


-- Check that payments match revenue
SELECT
    (SELECT ROUND(SUM(amount), 2) FROM payments WHERE payment_status = 'Paid') AS total_paid,
    (SELECT ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2)
       FROM order_items AS oi
       JOIN orders AS o ON o.order_id = oi.order_id
      WHERE o.order_status = 'Completed') AS completed_revenue;
