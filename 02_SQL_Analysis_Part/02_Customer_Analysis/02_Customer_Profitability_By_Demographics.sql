/*
=============================================================================
CUSTOMER PROFITABILITY & FINANCIAL CONTRIBUTION BY DEMOGRAPHICS & GEOGRAPHIC
=============================================================================
Purpose:
Evaluate customer financial performance across four demographic dimensions:
geographical location, gender, marital status, and age groups.

The analysis examines customer distribution, revenue, cost, profit,
profit margin, and financial contribution to identify the most valuable
customer segments, assess profitability efficiency, and understand
how different demographic groups contribute to overall business performance.

Business Questions:

1. Which geographical markets generate the highest revenue and profit,
   and how do their profitability margins compare?

2. How is the company's revenue and profit distributed across gender groups?

3. How does customer profitability vary across different marital status groups?

4. Which age groups contribute the most to overall revenue and profit?

5. Which demographic segments achieve the highest profit margins?

6. Does a segment's contribution to total profit exceed its contribution
   to total revenue?

7. Which demographic segments generate the highest average revenue
   and profit per customer?

8. How does customer distribution across demographic segments relate
   to their respective financial contributions?

================================================================================
*/


-- Create a temp table instead of repeating my self.
DROP TABLE IF EXISTS #customers_profitability
SELECT
	c.id,
	c.first_name +' '+ c.last_name AS full_name,
	c.gender,
	c.marital_status,
	age_data.age_group,
	c.country,
	SUM(s.sales) AS revenue,
	SUM(p.cost * s.quantity) AS cost,
	SUM(s.sales) - SUM(p.cost * s.quantity) AS profit,
	ROUND(
		CAST(
			(SUM(s.sales) - SUM(p.cost * s.quantity)) AS FLOAT) / NULLIF(SUM(s.sales), 0) * 100, 2) AS profit_margin,
	RANK() OVER(ORDER BY SUM(s.sales) - SUM(p.cost * s.quantity) DESC) AS customer_rank_high_profit
INTO #customers_profitability
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c
ON s.customer_key = c.[key]
LEFT JOIN gold.dim_products AS p
ON s.product_key = p.[key]
CROSS APPLY 
(
SELECT
	CASE
		WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) <= 20 THEN 'age<=20'
		WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) BETWEEN 21 AND 30 THEN '21-30'
		WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) BETWEEN 31 AND 40 THEN '31-40'
		WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) BETWEEN 41 AND 50 THEN '41-50'
		WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) BETWEEN 51 AND 60 THEN '51-60'
		WHEN DATEDIFF(YEAR, c.birthdate, GETDATE()) > 60 THEN 'age>60'
		ELSE 'Unknown'
	END AS age_group
) AS age_data
GROUP BY c.id,
		 c.birthdate,
		 c.first_name +' '+ c.last_name,
		 c.gender,
		 c.marital_status,
		 age_data.age_group,
		 c.country;

---------------------------------

-- Measures across the countries.
SELECT
	country,
	COUNT(*) AS total_customers,
	AVG(revenue) AS avg_revenue_per_customer,
	AVG(profit) AS avg_profit_per_customer,
	SUM(revenue) AS total_revenue,
	SUM(cost) AS total_cost,
	SUM(profit) AS total_profit,
	ROUND(
		CAST(
			SUM(profit) AS FLOAT) / NULLIF(SUM(revenue), 0) * 100, 2) AS profit_margin,
	ROUND(
		CAST(
			SUM(revenue) AS FLOAT) / NULLIF((SELECT SUM(revenue) FROM #customers_profitability), 0) * 100, 2) AS revenue_contribution,
	ROUND(
		CAST(
			SUM(profit) AS FLOAT) / NULLIF((SELECT SUM(profit) FROM #customers_profitability), 0) * 100, 2) AS profit_contribution
FROM #customers_profitability
GROUP BY country
ORDER BY SUM(profit) DESC;

---------------------------------

-- Measures across the genders.
SELECT
	gender,
	AVG(revenue) AS avg_revenue_per_customer,
	AVG(profit) AS avg_profit_per_customer,
	COUNT(*) AS total_customers,
	SUM(revenue) AS total_revenue,
	SUM(cost) AS total_cost,
	SUM(profit) AS total_profit,
	ROUND(
		CAST(
			SUM(profit) AS FLOAT) / NULLIF(SUM(revenue), 0) * 100, 2) AS profit_margin,
	ROUND(
		CAST(
			SUM(revenue) AS FLOAT) / NULLIF((SELECT SUM(revenue) FROM #customers_profitability), 0) * 100, 2) AS revenue_contribution,
	ROUND(
		CAST(
			SUM(profit) AS FLOAT) / NULLIF((SELECT SUM(profit) FROM #customers_profitability), 0) * 100, 2) AS profit_contribution
FROM #customers_profitability
GROUP BY gender
ORDER BY SUM(profit) DESC;

---------------------------------

-- Measures across the marital_status.
SELECT
	marital_status,
	AVG(revenue) AS avg_revenue_per_customer,
	AVG(profit) AS avg_profit_per_customer,
	COUNT(*) AS total_customers,
	SUM(revenue) AS total_revenue,
	SUM(cost) AS total_cost,
	SUM(profit) AS total_profit,
	ROUND(
		CAST(
			SUM(profit) AS FLOAT) / NULLIF(SUM(revenue), 0) * 100, 2) AS profit_margin,
	ROUND(
		CAST(
			SUM(revenue) AS FLOAT) / NULLIF((SELECT SUM(revenue) FROM #customers_profitability), 0) * 100, 2) AS revenue_contribution,
	ROUND(
		CAST(
			SUM(profit) AS FLOAT) / NULLIF((SELECT SUM(profit) FROM #customers_profitability), 0) * 100, 2) AS profit_contribution
FROM #customers_profitability
GROUP BY marital_status
ORDER BY SUM(profit) DESC;

---------------------------------

-- Measures across the age_group.
SELECT
	age_group,
	AVG(revenue) AS avg_revenue_per_customer,
	AVG(profit) AS avg_profit_per_customer,
	COUNT(*) AS total_customers,
	SUM(revenue) AS total_revenue,
	SUM(cost) AS total_cost,
	SUM(profit) AS total_profit,
	ROUND(
		CAST(
			SUM(profit) AS FLOAT) / NULLIF(SUM(revenue), 0) * 100, 2) AS profit_margin,
	ROUND(
		CAST(
			SUM(revenue) AS FLOAT) / NULLIF((SELECT SUM(revenue) FROM #customers_profitability), 0) * 100, 2) AS revenue_contribution,
	ROUND(
		CAST(
			SUM(profit) AS FLOAT) / NULLIF((SELECT SUM(profit) FROM #customers_profitability), 0) * 100, 2) AS profit_contribution
FROM #customers_profitability
GROUP BY age_group
ORDER BY SUM(profit) DESC;


---------------------------------

-- Top 10 customers 
SELECT TOP 10
	*
FROM #customers_profitability
ORDER BY profit DESC;

---------------------------------

SELECT TOP 10
	*
FROM #customers_profitability
ORDER BY profit ASC;

---------------------------------

-- Final complete customers analysis query.
SELECT
	*
FROM #customers_profitability;