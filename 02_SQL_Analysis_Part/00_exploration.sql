-- This script is designed to explore the data.

-- Use Datawarehouse
USE Datawarehouse;
GO

-- Range of the data from the first transaction to the last transaction.
SELECT
	MIN(order_date) AS first_date,
	MAX(order_date) AS last_date
FROM gold.fact_sales

-- The youngest and oldest customer of the data.
SELECT
	MIN(DATEDIFF(YEAR, birthdate, GETDATE())) AS youngest,
	MAX(DATEDIFF(YEAR, birthdate, GETDATE())) AS oldest
FROM gold.dim_customers

