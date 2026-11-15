/*
===============================================================================
    SCRIPT: Bronze Layer - Data Quality Assessment & Data Profiling
    DESCRIPTION: Performs comprehensive data quality checks and exploratory
                 data profiling on the Bronze Layer source tables.
===============================================================================
    OBJECTIVE:
        Identify data quality issues and assess source data consistency,
        completeness, validity, and uniqueness before transformation.

    VALIDATION DIMENSIONS:
        - Uniqueness: Identify duplicate records and key violations.
        - Completeness: Detect NULL and missing values.
        - Consistency: Examine formatting and standardization issues.
        - Validity: Validate data formats, ranges, and logical rules.
        - Accuracy: Investigate suspicious and potentially invalid values.
        - Referential Integrity: Examine key relationships across source tables.

    APPROACH:
        Execute SQL-based profiling queries to identify anomalies, document
        findings, and establish data quality requirements for downstream
        transformation and loading processes.

    LAYER: Bronze
    DATABASE: Datawarehouse
===============================================================================
*/

USE Datawarehouse;
GO


-- 1) cust_info table.
SELECT
	cst_id,
	COUNT(*) AS cst_id_count
FROM bronze.cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 -- There are duplicates, we will pick the latest one according the date registeration.
---------------
SELECT
	cst_key
FROM bronze.cust_info
WHERE cst_key != TRIM(cst_key) -- There is no leading or trailing spaces in the cst_key column.
---------------
SELECT
	cst_firstname
FROM bronze.cust_info
WHERE cst_firstname != TRIM(cst_firstname)
OR cst_firstname IS NULL -- There are leading or/and trailing spaces and null in cst_firstname column.
---------------
SELECT
	cst_firstname
FROM bronze.cust_info
WHERE UPPER(LEFT(TRIM(cst_firstname), 1)) != LEFT(TRIM(cst_firstname), 1) -- All names are in title case.
---------------
SELECT
	cst_lastname
FROM bronze.cust_info
WHERE cst_lastname != TRIM(cst_lastname)
OR cst_lastname IS NULL -- There are leading or/and trailing spaces and nulls in cst_lastname column.
---------------
SELECT
	cst_lastname
FROM bronze.cust_info
WHERE UPPER(LEFT(TRIM(cst_lastname), 1)) != LEFT(TRIM(cst_lastname), 1) -- All names are in title case.
---------------
SELECT DISTINCT
	cst_marital_status
FROM bronze.cust_info -- (S, M, NULL) are the distinct values.
---------------
SELECT 
	cst_marital_status
FROM bronze.cust_info
WHERE TRIM(cst_marital_status) != cst_marital_status  -- There is no leading or trailing spaces.
---------------
SELECT DISTINCT
	cst_gndr
FROM bronze.cust_info -- (M, F, NULL) are the distinct values.
---------------
SELECT
	cst_gndr
FROM bronze.cust_info
WHERE TRIM(cst_gndr) != cst_gndr -- There is no leading or trailing spaces.
---------------
SELECT
	MAX(cst_create_date) AS earliest_date,
	MIN(cst_create_date) AS oldest_date
FROM bronze.cust_info -- (2025-10-06, 2026-01-27) There is no invalid boundry.
/*
----------------------------------------------------------------------------------------------------------
*/
-- 2) prd_info table.
SELECT
	prd_id,
	COUNT(*) AS prd_id_count
FROM bronze.prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 -- There is no duplicates or nulls.
---------------
SELECT
	prd_key
FROM bronze.prd_info
WHERE TRIM(prd_key) != prd_key 
OR prd_key  IS NULL -- There is no null or leading and trailing spaces.
---------------
SELECT
	prd_nm
FROM bronze.prd_info
WHERE TRIM(prd_nm) != prd_nm
OR prd_nm IS NULL -- There is no null or leading and trailing spaces.
---------------
SELECT
	prd_cost
FROM bronze.prd_info
WHERE prd_cost IS NULL
OR prd_cost <= 0 -- There is no negative or zero values, but there are nulls.
---------------
SELECT 
	prd_line
FROM bronze.prd_info
WHERE prd_line != TRIM(prd_line)
OR prd_line IS NULL -- There is no leading or trailing spaces.
---------------
SELECT 
	prd_start_dt,
	prd_end_dt
FROM bronze.prd_info
WHERE prd_start_dt > prd_end_dt -- There is an unlogical date operations.
---------------
SELECT
	*
FROM 
(SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY prd_key ORDER by prd_start_dt) AS ranking
FROM bronze.prd_info) AS r
WHERE ranking > 1
/*
----------------------------------------------------------------------------------------------------------
*/
-- 3) sales_details.
SELECT
	sls_ord_num,
	sls_prd_key,
	COUNT(*)
FROM bronze.sales_details
GROUP BY sls_ord_num,
		 sls_prd_key
HAVING COUNT(*) > 1 -- There is no duplicates.
---------------
SELECT
	sls_ord_num,
	sls_prd_key
FROM bronze.sales_details
WHERE sls_ord_num IS NULL
OR sls_prd_key IS NULL
OR TRIM(sls_ord_num) != sls_ord_num
OR TRIM(sls_prd_key) != sls_prd_key -- There is any nulls or leading or trailing spaces.
---------------
SELECT
	sls_ord_num,
	sls_prd_key
FROM bronze.sales_details
WHERE TRIM(sls_ord_num) != sls_ord_num OR
	  TRIM(sls_prd_key) != sls_prd_key -- There is no leading or trailing spaces.
---------------
SELECT
	sls_cust_id
FROM bronze.sales_details
WHERE sls_cust_id IS NULL -- There is no any nulls.
---------------
SELECT
	sls_order_dt
FROM bronze.sales_details
WHERE LEN(sls_order_dt) NOT BETWEEN 6 AND 8 -- There are some issues in the date length.
---------------
SELECT 
	sls_price
FROM bronze.sales_details
WHERE sls_price <= 0 OR sls_price IS NULL -- There are some negitave and null values.
---------------
SELECT 
	sls_quantity
FROM bronze.sales_details
WHERE sls_quantity <= 0 OR sls_quantity IS NULL -- There is no negitave or zero values.
---------------
SELECT
	sls_sales
FROM bronze.sales_details
WHERE sls_sales <= 0 OR sls_sales IS NULL -- There are zeros, nulls and negitave values.
/*
----------------------------------------------------------------------------------------------------------
*/
-- 4) cat_info
SELECT
	id,
	COUNT(*) AS id_count
FROM bronze.cat_info
GROUP BY id
HAVING COUNT(*) > 1 OR TRIM(id) != id -- There is no duplicates or leading and trailing spaces.
---------------
SELECT DISTINCT
	cat
FROM bronze.cat_info
WHERE TRIM(cat) != cat -- There is no leading or trailing spaces.
---------------
SELECT
	subcat
FROM bronze.cat_info
WHERE TRIM(subcat) != subcat -- There is no leading or trailing spaces.
---------------
SELECT
	maintenance
FROM bronze.cat_info
WHERE TRIM(maintenance) != maintenance -- There is no leadig or trailing apaces.
---------------
SELECT DISTINCT
	maintenance
FROM bronze.cat_info -- The distinct values (Yes, No).
/*
----------------------------------------------------------------------------------------------------------
*/
-- 5) cust_loc.
SELECT
	cid,
	COUNT(*) AS id_count
FROM bronze.cust_loc
GROUP BY cid
HAVING COUNT(*) > 1 OR TRIM(cid) != cid  -- There is duplicates or leading and trailing spaces.
---------------
SELECT DISTINCT
	cntry
FROM bronze.cust_loc -- There is no standardized country names.
---------------
SELECT
	cntry
FROM bronze.cust_loc
WHERE TRIM(cntry) != cntry -- There are leading and trailind spaces.
/*
----------------------------------------------------------------------------------------------------------
*/
-- 6) cust_metadata.
SELECT
	cid
FROM bronze.cust_metadata
WHERE TRIM(cid) != cid -- There is no leading or tailing spaces.
---------------
SELECT
	MAX(bdate) AS latest_bdate,
	MIN(bdate) AS oldest_bdate
FROM bronze.cust_metadata -- There is invalid dates.
---------------
SELECT
	bdate
FROM bronze.cust_metadata
WHERE bdate IS NULL -- There is no null.
---------------
SELECT DISTINCT
	gen
FROM bronze.cust_metadata -- The column is not standardized.
--====================================================================================================================================