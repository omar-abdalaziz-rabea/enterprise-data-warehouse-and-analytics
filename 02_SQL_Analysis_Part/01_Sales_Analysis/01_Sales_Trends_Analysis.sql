/*
=============================================================
SALES PERFORMANCE ANALYSIS | TEMPORAL TRENDS
=============================================================
1. Monthly Sales Performance

Business Question:

How do monthly sales revenue, total quantities sold, and average selling price per unit evolve over time?

Analytical Objective:

Analyze monthly sales trends to identify changes in revenue, sales volume, and average unit selling price,
providing insights into the business's monthly performance.

Key Metrics:

- Total Sales Revenue
- Total Quantity Sold
- Average Selling Price (ASP)

2. Yearly Sales Performance

Business Question:

How does the company's annual sales performance evolve in terms of total revenue, sales volume, and average selling price per unit?

Analytical Objective:

Evaluate annual sales performance to understand long-term business trends, changes in sales volume,
and shifts in average selling prices.

Key Metrics:

- Annual Sales Revenue
- Annual Quantity Sold
- Average Selling Price (ASP)
======================================================================================================================================
*/

SELECT
	DATETRUNC(MONTH, order_date) AS year_month,
	SUM(sales) AS revenue,
	SUM(quantity) AS quantity,
	ROUND(
		CAST(
			SUM(sales) AS FLOAT) / NULLIF(SUM(quantity), 0), 2) AS monthly_avg_of_unit_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date);

------

SELECT
	YEAR(order_date) AS [year],
	SUM(sales) AS revenue,
	SUM(quantity) AS quantity,
	ROUND(
		CAST(
			SUM(sales) AS FLOAT) / NULLIF(SUM(quantity), 0), 2) AS yearly_avg_of_unit_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL AND YEAR(order_date) IN (2011, 2012, 2013) -- Include only the complete years.
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

--====================================================================================================================================