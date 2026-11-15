/*
================================================================================
                 CUSTOMER PURCHASE FREQUENCY DISTRIBUTION
                  ONE-TIME VS. REPEAT CUSTOMER ANALYSIS
================================================================================
Purpose:
Analyze the distribution of purchasing customers based on their purchase
frequency by distinguishing between one-time buyers and repeat customers.

The analysis measures the proportion of customers who completed only one
purchase compared to those who made multiple purchases, providing insight
into customer purchasing continuity and repeat purchase behavior.

Business Questions:

1. What percentage of customers made only one purchase?
2. What percentage of customers made multiple purchases?
3. How is the customer base distributed between one-time and repeat buyers?
4. To what extent do customers demonstrate repeat purchasing behavior?
5. What does the distribution reveal about customer purchasing continuity
   and potential retention opportunities?

Business Value:
Evaluate the prevalence of repeat purchasing behavior, identify potential
customer retention challenges, and provide insights that support customer
retention strategies, re-engagement campaigns, and initiatives aimed at
increasing repeat purchases and long-term customer value.

================================================================================
*/
SELECT 
	'One-Time Customer percent' AS customer_type,
	ROUND(CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM gold.customer_report) * 100, 2) AS [percent]
FROM gold.customer_report
WHERE total_orders = 1

UNION ALL

SELECT 
	'Repeated Customer percent',
	ROUND(CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM gold.customer_report) * 100, 2)
FROM gold.customer_report
WHERE total_orders > 1