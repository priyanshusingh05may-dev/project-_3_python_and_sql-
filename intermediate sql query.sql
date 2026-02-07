-- =========================
-- INTERMEDIATE PROBLEMS
-- =========================

-- 1. Orders per month in 2018
SELECT 
    MONTH(order_purchase_timestamp) AS month,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
WHERE YEAR(order_purchase_timestamp) = 2018
GROUP BY MONTH(order_purchase_timestamp)
ORDER BY month;

-- 2. Avg products per order by customer city
SELECT 
    c.customer_city,
    ROUND(AVG(order_product_count), 2) AS avg_products_per_order
FROM (
    SELECT 
        o.order_id,
        c.customer_city,
        COUNT(oi.product_id) AS order_product_count
    FROM orders o
    JOIN customers c 
        ON o.customer_id = c.customer_id
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    GROUP BY o.order_id, c.customer_city
) AS city_order_counts
GROUP BY customer_city
ORDER BY avg_products_per_order DESC;

-- 3. Revenue contribution by category
SELECT 
    p.product_category_name AS category,
    ROUND(SUM(oi.price), 2) AS category_revenue,
    ROUND(
        (SUM(oi.price) / 
        (SELECT SUM(price) FROM order_items)) * 100, 
    2
    ) AS revenue_percentage
FROM order_items oi
JOIN products p 
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY revenue_percentage DESC;

-- 4. Price vs purchase frequency (for correlation analysis in Python)
SELECT 
    oi.product_id,
    ROUND(AVG(oi.price), 2) AS avg_price,
    COUNT(*) AS purchase_count
FROM order_items oi
GROUP BY oi.product_id;

-- 5. Seller revenue ranking
SELECT 
    s.seller_id,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    RANK() OVER (ORDER BY SUM(oi.price) DESC) AS revenue_rank
FROM order_items oi
JOIN sellers s 
    ON oi.seller_id = s.seller_id
GROUP BY s.seller_id
ORDER BY total_revenue DESC;
