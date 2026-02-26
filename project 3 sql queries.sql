CREATE DATABASE IF NOT EXISTS e_commerce_db;
USE e_commerce_db;
SET GLOBAL local_infile = 1;
-- 1. Create Customers Table
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);
-- Load Customers
LOAD DATA LOCAL INFILE 'D:/project 3/my sql file/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- 2. Create Sellers Table
CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);
LOAD DATA LOCAL INFILE 'D:/project 3/my sql file/sellers.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

LOAD DATA LOCAL INFILE 'D:/project 3/my sql file/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_id, customer_id, order_status, @v_purchase, @v_approved, @v_carrier, @v_customer, @v_estimated)
SET 
    order_purchase_timestamp = NULLIF(@v_purchase, ''),
    order_approved_at = NULLIF(@v_approved, ''),
    order_delivered_carrier_date = NULLIF(@v_carrier, ''),
    order_delivered_customer_date = NULLIF(@v_customer, ''),
    order_estimated_delivery_date = NULLIF(@v_estimated, '');
    
CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm FLOAT
);
LOAD DATA LOCAL INFILE 'D:/project 3/my sql file/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    product_id, 
    @v_category, 
    @v_name_len, 
    @v_desc_len, 
    @v_photos, 
    @v_weight, 
    @v_length, 
    @v_height, 
    @v_width
)
SET 
    product_category = NULLIF(@v_category, ''),
    product_name_length = NULLIF(@v_name_len, ''),
    product_description_length = NULLIF(@v_desc_len, ''),
    product_photos_qty = NULLIF(@v_photos, ''),
    product_weight_g = NULLIF(@v_weight, ''),
    product_length_cm = NULLIF(@v_length, ''),
    product_height_cm = NULLIF(@v_height, ''),
    product_width_cm = NULLIF(@v_width, '');
  

-- Create Order Items Table
CREATE TABLE IF NOT EXISTS order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10 , 2 ),
    freight_value DECIMAL(10 , 2 )
);
LOAD DATA LOCAL INFILE 'D:/project 3/my sql file/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Create Payments Table
CREATE TABLE IF NOT EXISTS payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value DECIMAL(10 , 2 )
);
LOAD DATA LOCAL INFILE 'D:/project 3/my sql file/payments.csv'
INTO TABLE payments
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
    
    -- 1. List all unique cities where customers are located.
SELECT DISTINCT 
    customer_city 
FROM customers
ORDER BY customer_city;

-- 2. Count the number of orders placed in 2017.
SELECT 
    COUNT(order_id)
FROM
    orders
WHERE
    YEAR(order_purchase_timestamp) = 2017;

-- 3. Find the total sales per category.
SELECT 
    p.product_category, ROUND(SUM(oi.price), 2) AS total_sales
FROM
    order_items oi
        JOIN
    products p ON oi.product_id = p.product_id
GROUP BY p.product_category
ORDER BY total_sales DESC;

-- 4. Calculate the percentage of orders that were paid in installments.
SELECT 
    (COUNT(CASE
        WHEN payment_installments > 1 THEN 1
    END) / COUNT(*)) * 100 AS pct_installments
FROM
    payments;

-- 5. Count the number of customers from each state.
SELECT 
    customer_state, COUNT(customer_id) AS customer_count
FROM
    customers
GROUP BY customer_state
ORDER BY customer_count DESC;
SELECT 
    MONTHNAME(order_purchase_timestamp) AS month,
    COUNT(order_id) AS order_count
FROM
    orders
WHERE
    YEAR(order_purchase_timestamp) = 2018
GROUP BY month
ORDER BY MONTH(order_purchase_timestamp);

-- 2. Find the average number of products per order, grouped by customer city.
WITH count_per_order AS (
    SELECT o.order_id, c.customer_city, COUNT(oi.product_id) AS product_count
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id, c.customer_city
)
SELECT customer_city, ROUND(AVG(product_count), 2) AS avg_products_per_order
FROM count_per_order
GROUP BY customer_city
ORDER BY avg_products_per_order Desc;

-- 3. Calculate the percentage of total revenue contributed by each product category.
SELECT 
    p.product_category,
    ROUND((SUM(oi.price) / (SELECT 
                    SUM(price)
                FROM
                    order_items)) * 100,
            2) AS revenue_percentage
FROM
    order_items oi
        JOIN
    products p ON oi.product_id = p.product_id
GROUP BY p.product_category
ORDER BY revenue_percentage DESC;

-- 4. Identify the correlation between product price and purchase frequency.
-- (SQL doesn't have a CORR() function in all versions; we aggregate data for Python analysis)
SELECT 
    oi.product_id,
    AVG(oi.price) AS avg_price,
    COUNT(oi.order_id) AS purchase_count
FROM
    order_items oi
GROUP BY oi.product_id;

-- 5. Calculate total revenue generated by each seller and rank them.
SELECT seller_id, ROUND(SUM(price), 2) AS total_revenue,
       RANK() OVER(ORDER BY SUM(price) DESC) AS revenue_rank
FROM order_items
GROUP BY seller_id;

#Advanced Level: Strategic Insights
-- 1. Calculate the moving average of order values for each customer.
WITH OrderTotals AS (
    SELECT order_id, SUM(payment_value) as total_order_value FROM payments GROUP BY order_id
),CustomerHistory AS (SELECT 
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        ot.total_order_value FROM orders o
    JOIN OrderTotals ot ON o.order_id = ot.order_id
    JOIN customers c ON o.customer_id = c.customer_id)SELECT 
    customer_unique_id,
    order_id,
    order_purchase_timestamp,
    total_order_value,AVG(total_order_value) OVER (
        PARTITION BY customer_unique_id 
        ORDER BY order_purchase_timestamp 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as moving_avg
FROM CustomerHistory
ORDER BY customer_unique_id, order_purchase_timestamp;



-- 2. Calculate the cumulative sales per month for each year.
SELECT year, month, ROUND(monthly_sales, 2),
       ROUND(SUM(monthly_sales) OVER(PARTITION BY year ORDER BY month), 2) AS cumulative_sales
FROM (
    SELECT YEAR(order_purchase_timestamp) AS year, MONTH(order_purchase_timestamp) AS month, SUM(payment_value) AS monthly_sales
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY year, month
) AS t;

-- 3. Calculate the Year-over-Year (YoY) growth rate of total sales.
WITH yearly_sales AS (
    SELECT YEAR(order_purchase_timestamp) AS year, SUM(payment_value) AS total_sales
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY year
)
SELECT year, total_sales,
       LAG(total_sales) OVER(ORDER BY year) AS prev_year_sales,
       ROUND(((total_sales - LAG(total_sales) OVER(ORDER BY year)) / LAG(total_sales) OVER(ORDER BY year)) * 100, 2) AS yoy_growth_percentage
FROM yearly_sales;

-- 4. Calculate the retention rate (Repurchase within 6 months).
WITH FirstPurchases AS (
    -- 1. Identify the first purchase date for every unique customer
  WITH first_purchase AS (
    SELECT customer_unique_id, MIN(order_purchase_timestamp) AS first_order_date
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY customer_unique_id
)
SELECT 
    (COUNT(DISTINCT CASE WHEN DATEDIFF(o.order_purchase_timestamp, fp.first_order_date) BETWEEN 1 AND 180 THEN fp.customer_unique_id END) / COUNT(DISTINCT fp.customer_unique_id)) * 100 AS retention_rate
FROM first_purchase fp
LEFT JOIN customers c ON fp.customer_unique_id = c.customer_unique_id
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- 5. Identify the top 3 customers who spent the most money in each year.
WITH OrderTotals AS (
    SELECT order_id, SUM(payment_value) AS total_order_value FROM payments GROUP BY order_id
),
CustomerSpendPerYear AS (
    SELECT c.customer_unique_id,EXTRACT(YEAR FROM o.order_purchase_timestamp) AS order_year,SUM(ot.total_order_value) AS total_spent
    FROM orders o JOIN OrderTotals ot ON o.order_id = ot.order_id JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id, order_year
),
RankedCustomers AS (
    SELECT order_year,customer_unique_id,total_spent,RANK() OVER (PARTITION BY order_year ORDER BY total_spent DESC) as spend_rank
    FROM CustomerSpendPerYear
)
SELECT order_year,customer_unique_id,total_spent FROM RankedCustomers
WHERE spend_rank <= 3
ORDER BY order_year ASC, total_spent DESC;


