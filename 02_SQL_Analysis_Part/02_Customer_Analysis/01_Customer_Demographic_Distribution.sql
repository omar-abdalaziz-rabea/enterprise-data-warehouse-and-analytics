/*
================================================================================
CUSTOMER DEMOGRAPHIC DISTRIBUTION ANALYSIS
================================================================================

Purpose:
Analyze the demographic composition of the customer base across four
key dimensions: geographical distribution, gender, marital status,
and age groups.

The analysis evaluates the relative representation of each customer
segment within the overall customer base, highlighting the most
prominent demographic groups and geographical markets.

Business Questions:
    1. Which countries account for the largest proportion of the
       company's customer base?

    2. What is the gender composition of the customer base, and
       which gender represents the largest share?

    3. How are customers distributed according to marital status?

    4. Which age groups represent the largest proportion of customers?

    5. What is the relative distribution of customers across
       different demographic segments?

================================================================================
*/


SELECT
	country,
	ROUND(
		CAST(
			COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM gold.dim_customers) * 100, 2) AS [percent]
FROM gold.dim_customers
GROUP BY country
ORDER BY ROUND(
			CAST(
				COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM gold.dim_customers) * 100, 2) DESC;

---------------------------------------

SELECT
	gender,
	ROUND(
		CAST(
			COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM gold.dim_customers) * 100, 2) AS [percent]
FROM gold.dim_customers
GROUP BY gender
ORDER BY ROUND(
			CAST(
				COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM gold.dim_customers) * 100, 2) DESC;

---------------------------------------

SELECT
	marital_status,
	ROUND(
		CAST(
			COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM gold.dim_customers) * 100, 2) AS [percent]
FROM gold.dim_customers
GROUP BY marital_status
ORDER BY ROUND(
			CAST(
				COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM gold.dim_customers) * 100, 2) DESC;

---------------------------------------

WITH ages_cte AS
(
SELECT
	CASE
		WHEN DATEDIFF(YEAR, birthdate, GETDATE()) <= 20 THEN 'age<=20'
		WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 21 AND 30 THEN '21-30'
		WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 31 AND 40 THEN '31-40'
		WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 41 AND 50 THEN '41-50'
		WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 51 AND 60 THEN '51-60'
		WHEN DATEDIFF(YEAR, birthdate, GETDATE()) > 60 THEN 'age>60'
		ELSE 'Unknown'
	END AS age
FROM gold.dim_customers
)

---------------------------------------

SELECT 
	age,
	ROUND(
		CAST(
			COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM gold.dim_customers) * 100, 2) AS [percent]
FROM ages_cte
GROUP BY age
ORDER BY ROUND(
			CAST(
				COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM gold.dim_customers) * 100, 2) DESC;

--==============================================================================