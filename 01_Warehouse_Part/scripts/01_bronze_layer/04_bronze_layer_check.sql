/*
=================================================
Validation Script: Bronze Layer - Row Count Check
=================================================
Script Purpose:
    This script validates the data load in the Bronze Layer by checking the
    row counts of all bronze tables against the expected counts from the
    source CSV files.

    It ensures that BULK INSERT completed successfully without missing rows
    or truncation issues.

Expected Results:
    The row counts below are the source of truth. If any count differs,
    the load_bronze procedure must be re-executed after checking the file path
    and file integrity.

Layer: Bronze (Source -> Bronze)
*/


-- Activate DataWarehouse database
USE Datawarehouse;
GO

-- One-shot validation

SELECT 'cust_info' AS table_name, 18493 AS expected_rows, COUNT(*) AS loaded_rows,
       CASE WHEN COUNT(*) = 18493 THEN 'OK' ELSE 'FAIL' END AS [check]
FROM bronze.cust_info
UNION ALL
SELECT 'prd_info', 397, COUNT(*), CASE WHEN COUNT(*) = 397 THEN 'OK' ELSE 'FAIL' END
FROM bronze.prd_info
UNION ALL
SELECT 'sales_details', 60384, COUNT(*), CASE WHEN COUNT(*) = 60384 THEN 'OK' ELSE 'FAIL' END
FROM bronze.sales_details
UNION ALL
SELECT 'cust_metadata', 18483, COUNT(*), CASE WHEN COUNT(*) = 18483 THEN 'OK' ELSE 'FAIL' END
FROM bronze.cust_metadata
UNION ALL
SELECT 'cust_loc', 18484, COUNT(*), CASE WHEN COUNT(*) = 18484 THEN 'OK' ELSE 'FAIL' END
FROM bronze.cust_loc
UNION ALL
SELECT 'cat_info', 37, COUNT(*), CASE WHEN COUNT(*) = 37 THEN 'OK' ELSE 'FAIL' END
FROM bronze.cat_info;