-- Profit per product
SELECT
    IF(GROUPING(p.product_name), 'TOTAL', p.product_name) AS product,
    ROUND(SUM((oi.unit_price * (1 - oi.discount) - p.unit_cost) * oi.quantity), 2) AS profit
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_name WITH ROLLUP;


-- Top 10 products by revenue
SELECT
    p.product_name,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC
LIMIT 10;


-- Top 10 products by quantity sold
SELECT
    p.product_name,
    SUM(oi.quantity) AS units_sold
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY units_sold DESC
LIMIT 10;


-- Revenue, profit and margin by category
SELECT
    c.category_name,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue,
    ROUND(SUM((oi.unit_price * (1 - oi.discount) - p.unit_cost) * oi.quantity), 2) AS profit,
    ROUND(SUM((oi.unit_price * (1 - oi.discount) - p.unit_cost) * oi.quantity)
        / SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) * 100, 1) AS margin_pct
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
JOIN categories AS c ON c.category_id = p.category_id
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.category_name
ORDER BY profit DESC;


-- Products with the lowest profit margin
SELECT
    p.product_name,
    ROUND(SUM((oi.unit_price * (1 - oi.discount) - p.unit_cost) * oi.quantity)
        / SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) * 100, 1) AS margin_pct
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY margin_pct ASC
LIMIT 10;


-- Discount given by category
SELECT
    c.category_name,
    ROUND(SUM(oi.quantity * oi.unit_price * oi.discount), 2) AS discount_given
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
JOIN categories AS c ON c.category_id = p.category_id
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.category_name
ORDER BY discount_given DESC;


-- Products returned most often
SELECT
    p.product_name,
    COUNT(DISTINCT o.order_id) AS returned_orders,
    SUM(oi.quantity) AS units_returned
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.order_status = 'Returned'
GROUP BY p.product_id, p.product_name
ORDER BY returned_orders DESC
LIMIT 10;


-- Products never sold in a completed order
SELECT
    p.product_name
FROM products AS p
WHERE p.product_id NOT IN (
    SELECT oi.product_id
    FROM order_items AS oi
    JOIN orders AS o ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
);

