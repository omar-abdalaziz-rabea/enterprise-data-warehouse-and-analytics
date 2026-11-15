/*
===============================================================================
MONTHLY SALES PERFORMANCE & SEASONALITY ANALYSIS
================================================================================

Purpose:
Analyze monthly sales performance to identify high and low performing
calendar months, evaluate recurring seasonal patterns, and assess
year-over-year changes in sales revenue across corresponding months.

Business Questions:

1. Best & Worst Performing Calendar Months:
   
   - Which calendar month generates the highest total sales across all years?
   - Which calendar month generates the lowest total sales across all years?
   - How does average monthly sales revenue vary across calendar months?

2. Year-over-Year Monthly Performance:
   
   - How do monthly sales compare with the corresponding month in the
     previous year?
   - What are the year-over-year percentage changes in monthly sales?
   - Which corresponding months demonstrate the strongest and weakest
     year-over-year sales growth?

3. Seasonality:
   
   - Do recurring seasonal sales patterns emerge across different years?
   - Which calendar months consistently demonstrate strong or weak
     sales performance?

Analytical Decisions:

- Calendar months are aggregated across years to identify the highest-
  and lowest-performing months.
- Weighted average selling price is calculated as total sales divided
  by total quantity sold.
- LAG() is partitioned by calendar month to compare corresponding
  months across different years.
- Year-over-year growth rates measure percentage changes relative
  to the corresponding month in the previous year.
- Monthly comparisons rely on available observations; missing calendar
  months may require calendar-based data completion for strict
  consecutive-year comparisons.

Key Metrics:

- Total Monthly Sales Revenue
- Total Quantity Sold
- Weighted Average Selling Price (ASP)
- Previous Year's Corresponding Monthly Sales
- Year-over-Year Sales Growth (%)
- Highest & Lowest Performing Calendar Months

Business Value:
Identify seasonal revenue patterns, evaluate monthly performance
consistency, and understand year-over-year changes in corresponding
months to support better sales planning and business decision-making.

====================================================================================================================================
*/
SELECT TOP 1
	DATENAME(MONTH, order_date) AS [month],
	SUM(sales) AS sales,
	SUM(quantity) AS quantity,
	SUM(sales) / NULLIF(SUM(quantity), 0) AS avg_of_unit_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATENAME(MONTH, order_date)
ORDER BY SUM(sales) DESC;

----------------------

SELECT TOP 1
	DATENAME(MONTH, order_date) AS [month],
	SUM(sales) AS sales,
	SUM(quantity) AS quantity,
	SUM(sales) / NULLIF(SUM(quantity), 0) AS avg_of_unit_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATENAME(MONTH, order_date) 
ORDER BY SUM(sales) ASC;

-----------------------

WITH ordered_monthly_sales AS
(
SELECT 
	year_month,
	sales AS monthly_sales,
	LAG(sales) OVER(PARTITION BY MONTH(year_month) ORDER BY YEAR(year_month) ASC) AS previous_year_monthly_sales
FROM 
(
SELECT 
	DATETRUNC(MONTH, order_date) AS year_month,
	SUM(sales) AS sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
) AS relation
)

-----------------------

SELECT 
	*,
	ROUND(
		(CAST
			(monthly_sales - previous_year_monthly_sales AS FLOAT)) /
				NULLIF(previous_year_monthly_sales, 0) * 100, 2) AS pct_change
FROM ordered_monthly_sales;

--=================================================================================================================================