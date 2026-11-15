/*
====================================================================
SALES GROWTH ANALYSIS | MoM & YoY
====================================================================

Business Overview:
    Analyze sales revenue growth over time to evaluate short-term
    performance fluctuations and long-term business growth.

Business Questions:
    1. Monthly MoM Growth:
       How does monthly sales revenue change compared to the previous
       month, and what are the corresponding growth or decline rates?

    2. Annual YoY Growth:
       How does annual sales revenue change compared to the previous
       year, and what does this reveal about the company's long-term
       growth performance?

Analytical Decisions:
    - YoY analysis is restricted to complete calendar years (2011–2013)
      to ensure fair annual comparisons.
    - LAG() retrieves the previous period's sales revenue.
    - Growth rates are calculated as percentage changes relative
      to the previous period.
    - NULLIF() prevents division-by-zero errors.

Key Metrics:
    - Monthly Sales Growth (MoM %)
    - Year-over-Year Sales Growth (YoY %)
================================================================================================================================
*/

WITH monthly_sales_cte AS
(
SELECT
	DATETRUNC(MONTH, order_date) AS year_month,
	SUM(sales) AS monthly_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
)

SELECT
	*,
	LAG(monthly_sales) OVER(ORDER BY year_month) AS previous_month_sales,
	ROUND(
        CAST(monthly_sales - LAG(monthly_sales) OVER(ORDER BY year_month) AS FLOAT) /
	            NULLIF(LAG(monthly_sales) OVER(ORDER BY year_month), 0) * 100, 2) AS MoM_analysis
FROM monthly_sales_cte;

--------------------

-- Enclude only the entire years.
WITH yearly_sales_cte AS
(
SELECT
	YEAR(order_date) AS [year],
	SUM(sales) AS yearly_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL AND YEAR(order_date) IN (2011, 2012, 2013)
GROUP BY YEAR(order_date)
)

SELECT
	*,
	LAG(yearly_sales) OVER(ORDER BY [year]) AS previous_year_sales,
	ROUND(
        CAST(
            yearly_sales - LAG(yearly_sales) OVER(ORDER BY [year]) AS FLOAT) /
	            NULLIF(LAG(yearly_sales) OVER(ORDER BY [year]), 0) * 100, 2) AS YoY_analysis
FROM yearly_sales_cte;

--==============================================================================================================================