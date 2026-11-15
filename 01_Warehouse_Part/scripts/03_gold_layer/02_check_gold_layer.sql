/*
=================================================
Quality Checks: Referential Integrity Validation
=================================================
Script Purpose:
This script validates referential integrity across the Gold Layer
by ensuring that all foreign key values in fact_sales have matching
primary key values in their corresponding dimension tables.

Validation Checks:
1. Customer Referential Integrity:
Ensure every customer_key in gold.fact_sales exists in
gold.dim_customers.

2. Product Referential Integrity:
   Ensure every product_key in gold.fact_sales exists in
   gold.dim_products.

Expected Results:
- Both validation queries should return empty result sets.
- Any returned rows indicate orphaned foreign key references
that violate referential integrity.

Conclusion:
If all validation queries return empty result sets, referential
integrity is successfully maintained across the Gold Layer.
--=====================================================
*/
USE Datawarehouse;
GO

--=====================================================
-- Each customer in fact_sales must be in dim_customers
--=====================================================
SELECT
	*
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c
ON s.customer_key = c.[key]
WHERE c.[key] IS NULL

--=====================================================
-- Each product in fact_sales must be in dim_products
--=====================================================

SELECT
	*
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
ON s.product_key = p.[key]
WHERE p.[key] IS NULL
-------------------------------------------------------
-- The referential integrity IS GREAT.
-------------------------------------------------------