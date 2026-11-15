/*
================================================================================
 DAILY SALES TREND & MOMENTUM ANALYSIS
================================================================================

Purpose:
Analyze daily sales performance over time by evaluating cumulative revenue,
running averages, moving averages, daily growth rates, and sales contribution.

The analysis aims to identify underlying sales trends, monitor daily
performance fluctuations, measure revenue accumulation, and understand
the contribution of individual days to overall sales.

Business Questions:

1. How do daily sales evolve throughout the analysis period?
2. What is the cumulative sales revenue generated over time?
3. How does the running average of daily sales evolve throughout the period?
4. What is the underlying sales trend based on a 7-observation moving average?
5. How do daily sales compare with the previous day's performance?
6. What is the day-over-day sales growth rate?
7. What percentage of total sales has been accumulated over time?
8. What is the contribution of each day to total sales revenue?
9. Are there noticeable fluctuations or changes in daily sales momentum?
10. How does daily sales performance contribute to the company's overall
    revenue generation?

Key Metrics:

- Daily Sales Revenue
- Running Total Sales
- Running Average Sales
- 7-Observation Moving Average
- Previous Day Sales
- Day-over-Day Sales Growth
- Cumulative Sales Contribution
- Daily Sales Contribution

Technical Notes:

- Daily sales are aggregated at the order date level before applying
  window functions.
- Running totals and averages are calculated using ordered window functions.
- Moving averages use the current observation and the six preceding
  observations.
- LAG() is used to retrieve previous observation sales for daily comparisons.
- Cumulative and daily sales contributions are calculated relative to
  total sales revenue across the analysis period.
- Moving averages and LAG() operate on available observations. Days without
  recorded sales are not represented unless a calendar table is introduced.

Business Value:
Provide visibility into sales trends, revenue accumulation, daily growth,
and performance fluctuations. The analysis supports the identification of
sales momentum changes and helps establish a foundation for deeper
seasonality and sales performance investigations.

===================================================================================================================
*/


WITH main_cte AS
(
SELECT
	order_date,
	SUM(sales) AS sales
FROM gold.fact_sales
GROUP BY order_date
)

SELECT 
	order_date,
	sales,
	SUM(sales) OVER(ORDER BY order_date) AS running_sales,
	AVG(sales) OVER(ORDER BY order_date) AS running_avg,
	AVG(sales) OVER(ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_7_days_back,
	ROUND(
		CAST(
			SUM(sales) OVER(ORDER BY order_date) AS FLOAT) / NULLIF((SELECT SUM(sales) FROM gold.fact_sales), 0) * 100, 4) AS pct_from_total_sales,
	LAG(sales) OVER(ORDER BY order_date) AS previous_day_sales,
	ROUND(
		(CAST
			(sales AS FLOAT) - LAG(sales) OVER(ORDER BY order_date)) /
				NULLIF(LAG(sales) OVER(ORDER BY order_date), 0), 2) AS day_over_day_growth,
	ROUND(
		CAST(
			sales AS FLOAT) / NULLIF((SELECT SUM(sales) FROM gold.fact_sales), 0), 5) AS daily_sales_contribution
FROM main_cte
WHERE order_date IS NOT NULL;

--=================================================================================================================