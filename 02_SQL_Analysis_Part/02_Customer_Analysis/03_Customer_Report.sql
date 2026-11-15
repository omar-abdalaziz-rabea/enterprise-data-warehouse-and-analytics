/*
================================================================================
                    END-TO-END CUSTOMER ANALYTICS REPORT
             CUSTOMER BEHAVIOR, FINANCIAL VALUE & PROFITABILITY
================================================================================
Purpose:
Develop a comprehensive customer-level analytical report that integrates
demographic attributes, purchasing behavior, customer engagement, and
financial performance into a unified customer reporting view.

The analysis evaluates customer purchasing frequency, recency, order
characteristics, average transaction values, revenue generation, cost,
profitability, and profit margins.

Additionally, customers are ranked according to their financial
contributions and profitability, while profitability-based segmentation
classifies customers into distinct value groups.

The resulting report provides a consolidated view of individual customer
performance, enabling the business to understand customer behavior, assess
financial contributions, identify profitable customer groups, and support
data-driven customer management strategies.

Business Questions:

1. Customer Demographics:
   - What are the demographic characteristics of the customer base across
     age, gender, marital status, and geographical distribution?

2. Purchasing Behavior:
   - How frequently does each customer purchase from the business?
   - How many orders and total product quantities does each customer generate?
   - What are the average quantities purchased per order?
   - What are the average unit values and average order values?

3. Customer Engagement:
   - How recently did each customer make a purchase?
   - How long has each customer maintained a purchasing relationship
     with the business?

4. Financial Performance:
   - How much revenue, cost, and profit does each customer generate?
   - What is the profit margin associated with each customer?
   - Which customers generate the highest absolute profit?
   - Which customers achieve the highest profit margins?

5. Customer Profitability Ranking:
   - How do customers rank based on their total profit contributions?
   - Which customers demonstrate the highest profitability efficiency
     based on profit margins?

6. Customer Segmentation:
   - How can customers be classified into profitability-based segments?
   - Which customers qualify as VIP, Golden, or Normal based on their
     profit margin contribution?
   - How does customer profitability differ across these segments?

Business Value:
Provide a unified customer-level reporting foundation that supports
customer profiling, purchasing behavior analysis, financial performance
evaluation, and profitability-based segmentation.

The insights enable management to identify valuable customers, prioritize
profitable customer relationships, evaluate customer engagement, and develop
more effective customer retention and relationship management strategies.

================================================================================
*/

DROP VIEW IF EXISTS gold.customer_report;
GO

CREATE VIEW gold.customer_report AS
SELECT
	c.[key],
	c.first_name +' '+ c.last_name AS full_name,
	DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age,
	c.gender,
	c.marital_status,
	c.country,
	ROUND(
		CAST(
			COUNT(DISTINCT s.order_number) AS FLOAT) /
				NULLIF(DATEDIFF(MONTH, MIN(s.order_date), MAX(s.order_date)), 0), 2)
					AS purchase_frequency_per_month,
	DATEDIFF(MONTH, MAX(order_date), GETDATE()) AS customer_recency_by_month,
	COUNT(DISTINCT s.order_number) AS total_orders,
	SUM(s.quantity) AS total_quantity,
	CAST(SUM(s.quantity) AS FLOAT) / NULLIF(COUNT(DISTINCT s.order_number), 0) AS avg_quantity_per_order,
	CAST(SUM(s.sales) AS FLOAT) / NULLIF(SUM(s.quantity), 0) AS avg_unit_value,
	CAST(SUM(s.sales) AS FLOAT) / NULLIF(COUNT(DISTINCT s.order_number), 0) AS avg_order_value,
	SUM(s.sales) AS revenue,
	SUM(s.quantity * p.cost) AS cost,
	SUM(s.sales) - SUM(s.quantity * p.cost) AS profit,
	ROUND(
		CAST(
			SUM(s.sales) - SUM(s.quantity * p.cost) AS FLOAT) / NULLIF(SUM(s.sales), 0) * 100, 3) AS profit_margin,
	DENSE_RANK() OVER(ORDER BY ROUND(CAST(SUM(s.sales) - SUM(s.quantity * p.cost) AS FLOAT) /
	NULLIF(SUM(s.sales), 0) * 100, 3) DESC) AS customer_profit_margin_rank,
	DENSE_RANK() OVER(ORDER BY SUM(s.sales) - SUM(s.quantity * p.cost) DESC) AS customer_profit_rank,
	DATEDIFF(DAY, MIN(s.order_date), MAX(s.order_date)) / 30.0 AS lifespan,
	CASE 
		WHEN ROUND(CAST(SUM(s.sales) - SUM(s.quantity * p.cost) AS FLOAT) / NULLIF(SUM(s.sales), 0) * 100, 3) > 60 THEN 'VIP'
		WHEN ROUND(CAST(SUM(s.sales) - SUM(s.quantity * p.cost) AS FLOAT) / NULLIF(SUM(s.sales), 0) * 100, 3) > 50 THEN 'Golden'
		ELSE 'Normal'
	END AS customer_segment
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c
ON s.customer_key = c.[key]
LEFT JOIN gold.dim_products AS p
ON s.product_key = p.[key]
GROUP BY c.[key],
		 c.first_name,
		 c.last_name,
		 c.country,
		 c.gender,
		 c.marital_status,
		 c.birthdate;

GO

SELECT * FROM gold.customer_report