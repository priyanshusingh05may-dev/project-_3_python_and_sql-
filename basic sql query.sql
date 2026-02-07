-- =========================
-- BASIC PROBLEMS
-- =========================

-- 1. Unique customer cities
SELECT DISTINCT customer_city
FROM customers
ORDER BY customer_city;

-- 2. Orders in 2017
SELECT COUNT(*) AS total_orders_2017
FROM orders
WHERE YEAR(order_purchase_timestamp) = 2017;

-- 3. Total sales per category
SELECT 
    p.product_category_name AS category,
    ROUND(SUM(oi.price), 2) AS total_sales
FROM order_items oi
JOIN products p 
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_sales DESC;

-- 4. Percentage of installment orders
SELECT 
    ROUND(
        (COUNT(DISTINCT CASE WHEN payment_installments > 1 THEN order_id END) 
        / COUNT(DISTINCT order_id)) * 100, 
    2) AS installment_order_percentage
FROM payments;

-- 5. Customers by state
SELECT 
    customer_state,
    COUNT(DISTINCT customer_id) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC;

