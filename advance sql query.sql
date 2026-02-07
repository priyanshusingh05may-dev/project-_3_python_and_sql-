# 1 Moving average of order values for each customer (over their order history)
SELECT
    o.customer_id,
    o.order_id,
    DATE(o.order_purchase_timestamp) AS order_date,
    SUM(oi.price) AS order_value,
    ROUND(
        AVG(SUM(oi.price)) OVER (
            PARTITION BY o.customer_id 
            ORDER BY o.order_purchase_timestamp
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS moving_avg_last_3_orders
FROM orders o
JOIN order_items oi 
    ON o.order_id = oi.order_id
GROUP BY o.customer_id, o.order_id, o.order_purchase_timestamp
ORDER BY o.customer_id, o.order_purchase_timestamp;
#2️ Cumulative sales per month for each year
WITH monthly_sales AS (
    SELECT
        YEAR(o.order_purchase_timestamp) AS year,
        MONTH(o.order_purchase_timestamp) AS month,
        SUM(oi.price) AS monthly_revenue
    FROM orders o
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    GROUP BY year, month
)
SELECT
    year,
    month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        PARTITION BY year 
        ORDER BY month
    ) AS cumulative_revenue
FROM monthly_sales
ORDER BY year, month;
#3️⃣ Year-over-Year (YoY) growth rate of total sales
WITH yearly_sales AS (
    SELECT
        YEAR(o.order_purchase_timestamp) AS year,
        SUM(oi.price) AS total_revenue
    FROM orders o
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    GROUP BY year
)
SELECT
    year,
    total_revenue,
    ROUND(
        ((total_revenue - LAG(total_revenue) OVER (ORDER BY year)) 
        / LAG(total_revenue) OVER (ORDER BY year)) * 100,
        2
    ) AS yoy_growth_percentage
FROM yearly_sales
ORDER BY year;
# 4 Customer retention rate
WITH first_orders AS (
    SELECT 
        customer_id,
        MIN(order_purchase_timestamp) AS first_order_date
    FROM orders
    GROUP BY customer_id
),
repeat_within_6_months AS (
    SELECT DISTINCT 
        o.customer_id
    FROM orders o
    JOIN first_orders f 
        ON o.customer_id = f.customer_id
    WHERE o.order_purchase_timestamp > f.first_order_date
      AND o.order_purchase_timestamp <= DATE_ADD(f.first_order_date, INTERVAL 6 MONTH)
)
SELECT 
    ROUND(
        (COUNT(DISTINCT r.customer_id) / COUNT(DISTINCT f.customer_id)) * 100, 
        2
    ) AS retention_rate_percentage
FROM first_orders f
LEFT JOIN repeat_within_6_months r 
    ON f.customer_id = r.customer_id;
    # 5 Top 3 customers who spent the most money in each year
    WITH customer_yearly_spend AS (
    SELECT
        YEAR(o.order_purchase_timestamp) AS year,
        o.customer_id,
        SUM(oi.price) AS total_spent
    FROM orders o
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    GROUP BY year, o.customer_id
),
ranked_customers AS (
    SELECT
        year,
        customer_id,
        total_spent,
        RANK() OVER (PARTITION BY year ORDER BY total_spent DESC) AS spend_rank
    FROM customer_yearly_spend
)
SELECT
    year,
    customer_id,
    ROUND(total_spent, 2) AS total_spent
FROM ranked_customers
WHERE spend_rank <= 3
ORDER BY year, spend_rank;




