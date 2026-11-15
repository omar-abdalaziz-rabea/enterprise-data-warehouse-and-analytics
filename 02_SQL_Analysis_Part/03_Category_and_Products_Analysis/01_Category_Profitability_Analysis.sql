/*
================================================================================
             PRODUCT CATEGORY REVENUE & PROFITABILITY ANALYSIS
================================================================================

Purpose:
Analyze product category performance by evaluating revenue generation,
sales volume, cost structure, and profitability.

The analysis aims to compare category-level financial performance,
measure each category's contribution to total revenue, assess profit
margins, and identify the most profitable product categories.

Business Questions:

1. Which product categories generate the highest total revenue?
2. What is each category's contribution to overall company revenue?
3. Which product categories achieve the highest sales volume?
4. How do costs vary across different product categories?
5. Which product categories generate the highest total profit?
6. Which categories achieve the highest profit margins?

Key Metrics:
- Category Revenue
- Revenue Contribution (%)
- Total Quantity Sold
- Total Category Cost
- Total Category Profit
- Category Profit Margin (%)

================================================================================
*/

SELECT
	p.category_name,
	FORMAT(SUM(sales), 'N0') AS category_revenue,
	ROUND(CAST(SUM(sales) AS FLOAT) / NULLIF((SELECT SUM(sales) FROM gold.fact_sales), 0) * 100, 2) AS category_revenue_contribution,
	SUM(s.quantity) AS category_quantity,
	FORMAT(SUM(s.quantity * p.cost), 'N0') AS category_cost,
	FORMAT(SUM(sales) - SUM(s.quantity * p.cost), 'N0') AS category_profit,
	ROUND((SUM(sales) - SUM(s.quantity * p.cost)) / CAST(NULLIF(SUM(sales), 0) AS FLOAT) * 100, 2) AS category_profit_margin
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
ON s.product_key = p.[key]
GROUP BY p.category_name
ORDER BY SUM(sales) DESC;
--==============================================================================