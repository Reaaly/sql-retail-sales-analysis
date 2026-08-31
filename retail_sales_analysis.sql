-- =========================================================
-- RETAIL SALES ANALYSIS
-- SQL Portfolio Project
-- =========================================================

-- 1. DATA QUALITY CHECKS

SELECT COUNT(*) AS total_records
FROM retail_sales;

-- Check for duplicate order IDs
SELECT
    order_id,
    COUNT(*) AS occurrences
FROM retail_sales
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 2. OVERALL SALES PERFORMANCE

SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(CAST(quantity AS INTEGER)) AS total_quantity_sold,
    ROUND(SUM(CAST(revenue AS REAL)), 2) AS total_revenue,
    ROUND(
        SUM(CAST(revenue AS REAL)) /
        COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM retail_sales;

-- 3. REVENUE BY REGION

SELECT
    region,
    ROUND(SUM(CAST(revenue AS REAL)), 2) AS total_revenue
FROM retail_sales
GROUP BY region
ORDER BY total_revenue DESC;

-- 4. PRODUCT CATEGORY PERFORMANCE

SELECT
    product_category,
    ROUND(SUM(CAST(revenue AS REAL)), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(CAST(quantity AS INTEGER)) AS units_sold
FROM retail_sales
GROUP BY product_category
ORDER BY total_revenue DESC;

-- 5. SALES CHANNEL PERFORMANCE

SELECT
    sales_channel,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(CAST(quantity AS INTEGER)) AS units_sold,
    ROUND(SUM(CAST(revenue AS REAL)), 2) AS total_revenue,
    ROUND(AVG(CAST(revenue AS REAL)), 2) AS avg_order_value
FROM retail_sales
GROUP BY sales_channel
ORDER BY total_revenue DESC;

-- 6. CUSTOMER TYPE ANALYSIS

SELECT
    customer_type,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(CAST(quantity AS INTEGER)) AS units_sold,
    ROUND(SUM(CAST(revenue AS REAL)), 2) AS total_revenue,
    ROUND(AVG(CAST(revenue AS REAL)), 2) AS avg_order_value
FROM retail_sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- 7. TOP 10 PRODUCTS BY REVENUE

SELECT
    product,
    product_category,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(CAST(quantity AS INTEGER)) AS units_sold,
    ROUND(SUM(CAST(revenue AS REAL)), 2) AS total_revenue
FROM retail_sales
GROUP BY product, product_category
ORDER BY total_revenue DESC
LIMIT 10;

-- 8. TOP 3 PRODUCTS WITHIN EACH CATEGORY

WITH product_revenue AS (
    SELECT
        product_category,
        product,
        ROUND(SUM(CAST(revenue AS REAL)), 2) AS total_revenue
    FROM retail_sales
    GROUP BY product_category, product
),

ranked_products AS (
    SELECT
        product_category,
        product,
        total_revenue,
        RANK() OVER (
            PARTITION BY product_category
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM product_revenue
)

SELECT
    product_category,
    product,
    total_revenue,
    revenue_rank
FROM ranked_products
WHERE revenue_rank <= 3
ORDER BY product_category, revenue_rank;

-- 9. MONTHLY REVENUE TREND

SELECT
    CASE
        WHEN instr(order_date, '/') = 2
            THEN '0' || substr(order_date, 1, 1)
        ELSE substr(order_date, 1, 2)
    END AS month_number,
    ROUND(SUM(CAST(revenue AS REAL)), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders
FROM retail_sales
GROUP BY month_number
ORDER BY month_number;

-- 10. PRODUCT CATEGORY REVENUE CONTRIBUTION

WITH category_revenue AS (
    SELECT
        product_category,
        SUM(CAST(revenue AS REAL)) AS total_revenue
    FROM retail_sales
    GROUP BY product_category
),

overall_revenue AS (
    SELECT
        SUM(CAST(revenue AS REAL)) AS company_revenue
    FROM retail_sales
)

SELECT
    c.product_category,
    ROUND(c.total_revenue, 2) AS total_revenue,
    ROUND(
        (c.total_revenue / o.company_revenue) * 100,
        2
    ) AS revenue_percentage
FROM category_revenue c
CROSS JOIN overall_revenue o
ORDER BY revenue_percentage DESC;
