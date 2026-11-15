/*
==========================================================================
MAIN SALES PERFORMANCE KPIs
==========================================================================

Purpose:
Evaluate the company's overall sales performance by calculating key business
metrics at both the unit and order levels. The analysis measures total sales,
average selling price, order value distribution, and purchasing volume.

Business Questions:

1. What is the total sales revenue generated throughout the entire period?
2. What is the average selling price per unit sold?
3. How many orders were placed throughout the analysis period?
4. What is the average order value (AOV)?
5. What is the average number of units purchased per order?
6. What are the minimum and maximum order values?
7. How do total sales revenue and order volume vary across different years?
8. How does the average order value change year over year?
9. How does the average purchasing quantity per order change across years?
10. How does the distribution of order values vary between years?

Key Metrics:

- Total Sales Revenue
- Average Selling Price per Unit
- Total Number of Orders
- Average Order Value (AOV)
- Average Quantity per Order
- Minimum Order Value
- Maximum Order Value
- Annual Sales Revenue
- Annual Order Volume
- Annual Order Value Statistics

Technical Notes:

- Order-level metrics are calculated by first aggregating sales and quantities
  at the order level to ensure accurate calculations.
- Annual metrics are calculated through separate queries for each year.
- The CTE or derived result set is scoped to a single SQL statement in SQL
  Server. Therefore, separate queries require repeating the aggregation logic
  unless a temporary table or another reusable database object is introduced.
- This approach keeps each annual analysis independent and straightforward.

Business Value:
Provide a comprehensive overview of sales performance, purchasing volume,
and order value patterns. These metrics establish a baseline for evaluating
business performance and support further investigation into sales trends,
customer purchasing behavior, and revenue drivers.

==============================================================================================================================
*/

SELECT 
	SUM(sales) / NULLIF(SUM(quantity), 0) AS avg_selling_price_per_unit
FROM gold.fact_sales;

-----------------------

-- Calculate KPIs for all periods.
SELECT 
	SUM(sales) AS total_sales,
	AVG(sales) AS avg_order_value,
	AVG(quantity) AS avg_quantity_per_order,
	MIN(sales) AS min_order_value,
	MAX(sales) AS max_order_value,
	COUNT(*) AS total_orders
FROM
(
SELECT
	SUM(sales) AS sales,
	SUM(quantity) AS quantity
FROM gold.fact_sales
GROUP BY order_number
) AS relation;

-----------------------

-- Calculate KPIs for each period independently.

SELECT 
	SUM(sales) AS total_sales_2011,
	AVG(sales) AS avg_order_value_2011,
	AVG(quantity) AS avg_quantity_per_order_2011,
	MIN(sales) AS min_order_value_2011,
	MAX(sales) AS max_order_value_2011,
	COUNT(*) AS total_orders
FROM
(
SELECT
	order_number AS order_number,
	SUM(sales) AS sales,
	SUM(quantity) AS quantity
FROM gold.fact_sales
WHERE YEAR(order_date) = 2011
GROUP BY order_number
) AS relation;

-----------------------

SELECT 
	SUM(sales) AS total_sales_2012,
	AVG(sales) AS avg_order_value_2012,
	AVG(quantity) AS avg_quantity_per_order_2012,
	MIN(sales) AS min_order_value_2012,
	MAX(sales) AS max_order_value_2012,
	COUNT(*) AS total_orders
FROM
(
SELECT
	order_number AS order_number,
	SUM(sales) AS sales,
	SUM(quantity) AS quantity
FROM gold.fact_sales
WHERE YEAR(order_date) = 2012
GROUP BY order_number
) AS relation;

-----------------------

SELECT 
	SUM(sales) AS total_sales_2013,
	AVG(sales) AS avg_order_value_2013,
	AVG(quantity) AS avg_quantity_per_order_2013,
	MIN(sales) AS min_order_value_2013,
	MAX(sales) AS max_order_value_2013,
	COUNT(*) AS total_orders
FROM
(
SELECT
	order_number AS order_number,
	SUM(sales) AS sales,
	SUM(quantity) AS quantity
FROM gold.fact_sales
WHERE YEAR(order_date) = 2013
GROUP BY order_number
) AS relation;

--============================================================================================================================
