/*
================================================================================
             END-TO-END PRODUCT ANALYTICS REPORT
          PRODUCT PERFORMANCE, FINANCIAL VALUE & PROFITABILITY
================================================================================

Purpose:
Develop a comprehensive product-level analytical report that integrates
product attributes, sales behavior, financial performance, and profitability
into a unified product reporting view.

The analysis evaluates product sales frequency, recency, sales volume,
order characteristics, average selling values, revenue generation, cost,
profitability, and profit margins.

Additionally, products are ranked according to their financial
contributions and profitability, while profitability-based segmentation
classifies products into distinct value groups.

The resulting report provides a consolidated view of individual product
performance, enabling the business to evaluate product demand, assess
financial contributions, identify profitable products, and support
data-driven product management strategies.

Business Questions:

1. Product Profile:

   - What are the characteristics of the product portfolio across
     product lines, categories, and subcategories?
   - When did each product enter the product portfolio?

2. Sales Behavior:

   - How frequently is each product purchased?
   - How many orders and total quantities does each product generate?
   - What are the average quantities sold per order?
   - What are the average unit selling values and average order values?

3. Product Engagement:

   - How recently was each product sold?
   - How long has each product maintained an active sales history?

4. Financial Performance:

   - How much revenue, cost, and profit does each product generate?
   - What is the profit margin associated with each product?
   - Which products generate the highest absolute profit?
   - Which products achieve the highest profit margins?

5. Product Profitability Ranking:

   - How do products rank based on their total profit contributions?
   - Which products demonstrate the highest profitability efficiency
     based on profit margins?

6. Product Segmentation:

   - How can products be classified into profitability-based segments?
   - Which products qualify as VIP, Golden, or Normal based on
     their profit margins?
   - How does product profitability differ across these segments?

Business Value:

Provide a unified product-level reporting foundation that supports
product profiling, sales behavior analysis, financial performance
evaluation, and profitability-based segmentation.

The insights enable management to identify high-value products,
prioritize profitable product categories, evaluate product demand,
and develop more effective product pricing, marketing, and
portfolio management strategies.

================================================================================
*/

DROP VIEW IF EXISTS gold.product_report;
GO

CREATE VIEW gold.product_report AS

WITH product_aggregation AS
(
    SELECT
        p.[key] AS product_key,
        p.id AS product_id,
        p.[name] AS product_name,
        p.[line] AS product_line,
        p.subcategory_name,
        p.subcategory_maintenance,
        p.category_name,
        p.[start_date],
        p.cost AS unit_cost,
        COUNT(DISTINCT s.order_number) AS total_orders,
        SUM(s.quantity) AS total_quantity,
        MIN(s.order_date) AS first_sale_date,
        MAX(s.order_date) AS last_sale_date,
        SUM(s.sales) AS revenue,
        SUM(s.quantity * p.cost) AS total_cost,
        SUM(s.sales) - SUM(s.quantity * p.cost) AS profit
    FROM gold.dim_products AS p
    INNER JOIN gold.fact_sales AS s
    ON p.[key] = s.product_key
    GROUP BY
        p.[key],
        p.id,
        p.[name],
        p.[line],
        p.subcategory_name,
        p.subcategory_maintenance,
        p.category_name,
        p.[start_date],
        p.cost
)

SELECT
    product_key,
    product_id,
    product_name,
    product_line,
    subcategory_name,
    subcategory_maintenance,
    category_name,
    [start_date],
    unit_cost,
    total_orders,
    total_quantity,
    ROUND(
        CAST(total_quantity AS FLOAT) /
            NULLIF(total_orders, 0) * 100, 2) AS avg_quantity_per_order,
    ROUND(
        CAST(revenue AS FLOAT) /
            NULLIF(total_quantity, 0) * 100, 2) AS avg_unit_selling_value,
    ROUND(
        CAST(revenue AS FLOAT) /
            NULLIF(total_orders, 0) * 100, 2) AS avg_order_value,
    ROUND(
        CAST(total_orders AS FLOAT) /
            NULLIF(DATEDIFF(MONTH, first_sale_date, last_sale_date), 0), 2) AS sales_frequency_per_month,
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS product_recency_by_month,
    DATEDIFF(DAY, first_sale_date, last_sale_date) / 30.0 AS sales_lifespan,
    DATEDIFF(MONTH, [start_date], GETDATE()) AS product_age_by_month,
    COALESCE(revenue, 0) AS revenue,
    COALESCE(total_cost, 0) AS total_cost,
    COALESCE(profit, 0) AS profit,
    ROUND(CAST(profit AS FLOAT) / NULLIF(revenue, 0) * 100, 3) AS profit_margin,
    DENSE_RANK() OVER(ORDER BY ROUND(CAST(profit AS FLOAT) / NULLIF(revenue, 0) * 100, 3) DESC) AS product_profit_margin_rank,
    DENSE_RANK() OVER(ORDER BY profit DESC) AS product_profit_rank,
    CASE
        WHEN ROUND(CAST(profit AS FLOAT) / NULLIF(revenue, 0) * 100, 3) > 60 THEN 'VIP'
        WHEN ROUND(CAST(profit AS FLOAT) / NULLIF(revenue, 0) * 100, 3) > 50 THEN 'Golden'
        ELSE 'Normal'
    END AS product_segment
FROM product_aggregation;

GO

SELECT
    *
FROM gold.product_report;
--================================================================================