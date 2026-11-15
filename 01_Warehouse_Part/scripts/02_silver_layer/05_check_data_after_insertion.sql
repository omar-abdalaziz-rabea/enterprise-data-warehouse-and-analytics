/*
================================================================================
                    SILVER LAYER - DATA QUALITY VALIDATION
================================================================================

Purpose:
    Validate the quality and integrity of transformed data loaded into
    the Silver Layer after applying data cleansing and standardization
    operations.

Scope:
    Perform post-transformation validation across all Silver tables
    to ensure that data meets the required quality standards before
    being consumed by the Gold Layer.

Validation Dimensions:
    1. Uniqueness:
       Verify primary key uniqueness and detect duplicate records.

    2. Completeness:
       Ensure mandatory attributes do not contain unexpected NULL values.

    3. Standardization:
       Validate consistent formatting, naming conventions,
       and standardized categorical values.

    4. Validity:
       Verify valid data ranges, date formats, and logical constraints.

    5. Consistency:
       Ensure data consistency across related attributes and datasets.

    6. Historical & Business Logic:
       Validate historical records, date boundaries, and
       business-related rules.


Expected Outcome:
    Confirm that cleansing and transformation processes have
    successfully addressed the identified data quality issues
    and that Silver Layer data is reliable.

Important Notes:
    - Validation queries are diagnostic and do not modify source data.
    - Empty result sets indicate that no records violated the
      specific validation rule being tested.
================================================================================
*/


-- Use DataWarehouse database
USE DataWarehouse;
GO

-- 1) cust_info.

SELECT
	cst_id,
	COUNT(*) AS id_count
FROM silver.cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
---------------------------
SELECT
	cst_key,
	COUNT(*) AS id_count
FROM silver.cust_info
GROUP BY cst_key
HAVING COUNT(*) > 1
---------------------------
SELECT
	*
FROM silver.cust_info
WHERE cst_firstname IS NULL
OR cst_lastname IS NULL
OR cst_marital_status IS NULL
OR cst_gndr IS NULL 
OR cst_gndr NOT IN ('Male', 'Female', 'n/a')
OR cst_marital_status NOT IN ('single', 'married')
OR TRIM(cst_firstname) != cst_firstname
OR TRIM(cst_lastname) != cst_lastname
--*********************************************************************************************************
-- 2) prd_info table.
SELECT
	*
FROM silver.prd_info
WHERE prd_nm IS NULL
OR prd_line IS NULL
OR TRIM(prd_nm) != prd_nm
OR prd_line NOT IN ('Road', 'Mountain', 'Other Sales', 'Touring', 'n/a')
OR prd_start_dt > prd_end_dt
-- ********************************************************************************************************
-- 3) sales_details table
SELECT
	*
FROM silver.sales_details
WHERE sls_order_dt > sls_ship_dt
OR sls_prd_key IS NULL 
OR sls_prd_key IS NULL
OR sls_price <= 0
OR sls_quantity <= 0
OR sls_sales <= 0
-----------------------------
-- Each customer in crm_sales_details must be in crm_cust_info according  to solid inferential constraints.
SELECT
	*
FROM silver.sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.cust_info)

-- 4) cat_info table.
SELECT
	*
FROM silver.cat_info
WHERE id IS NULL 
OR TRIM(id) != id
OR cat IS NULL 
OR TRIM(cat) != cat
OR subcat IS NULL
OR TRIM(subcat) != subcat
OR TRIM(maintenance) != maintenance
OR maintenance IS NULL
------------------------------
SELECT
	*
FROM silver.cat_info
WHERE maintenance NOT IN ('Yes', 'No')
------------------------------
SELECT
	sls_prd_key
FROM silver.sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.prd_info) 
--*********************************************************************************************************
-- 5) cust_loc table.
SELECT
	*
FROM silver.cust_loc
WHERE TRIM(cid) != cid
OR cid IS NULL
OR TRIM(cntry) != cntry
OR cntry IS NULL
--*********************************************************************************************************
-- 6) cust_metadate table.
SELECT
	*
FROM silver.cust_metadata
WHERE bdate NOT BETWEEN '1915-01-01' AND '2025-01-01'
OR gen NOT IN ('Male', 'Female', 'n/a')
--*********************************************************************************************************
