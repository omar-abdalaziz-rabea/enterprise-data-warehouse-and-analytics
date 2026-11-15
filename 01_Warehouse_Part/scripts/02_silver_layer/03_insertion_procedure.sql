//*
================================================================================
                    STORED PROCEDURE: LOAD SILVER LAYER
================================================================================

Procedure:
    silver.load_silver

Purpose:
    Execute the ETL process to transform, cleanse, standardize, and load
    raw data from the Bronze Layer into the Silver Layer.

Execution Workflow:
    1. Data Extraction:
       Retrieve raw records from the Bronze Layer source tables.

    2. Data Transformation:
       - Remove leading and trailing spaces.
       - Standardize categorical values and naming conventions.
       - Handle missing and invalid values.
       - Remove duplicate records using ROW_NUMBER().
       - Derive new attributes from existing columns.
       - Validate and convert date values.
       - Apply business rules and logical transformations.
       - Resolve historical product date ranges.

    3. Data Loading:
       - Truncate existing Silver Layer tables.
       - Insert transformed and cleansed records.
       - Reload the Silver Layer tables using a Full Load strategy.

    4. Execution Monitoring:
       - Track individual table loading durations.
       - Measure total batch execution time.
       - Display execution progress and error details.

Source Tables:
    - bronze.cust_info
    - bronze.prd_info
    - bronze.sales_details
    - bronze.cust_metadata
    - bronze.cust_loc
    - bronze.cat_info

Target Tables:
    - silver.cust_info
    - silver.prd_info
    - silver.sales_details
    - silver.cust_metadata
    - silver.cust_loc
    - silver.cat_info

Parameters:
    None.

Error Handling:
    Uses TRY...CATCH to capture execution errors and report
    error messages, numbers, and states.

Load Strategy:
    Full Load (TRUNCATE & INSERT).

Expected Outcome:
    Populate the Silver Layer with cleansed, standardized, and
    transformed data ready for downstream analytical processing
    and Gold Layer development.

Important Notes:
    - The Bronze Layer remains unchanged during the loading process.
    - All transformations are performed during the ETL process.
    - Execution time is tracked at both table and batch levels.
================================================================================
*/



CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '~~~~~~~~~~~~~~~~~~~~~~';
        PRINT 'Loading Silver Layer';
        PRINT '~~~~~~~~~~~~~~~~~~~~~~';

		-- Loading silver.cust_info
        SET @start_time = GETDATE();

		PRINT '-> Truncating Table: silver.cust_info';
		TRUNCATE TABLE silver.cust_info;

		PRINT '-> Inserting Data Into: silver.cust_info';
		INSERT INTO silver.cust_info (
			cst_id, 
			cst_key, 
			cst_firstname, 
			cst_lastname, 
			cst_marital_status, 
			cst_gndr,
			cst_create_date
		)
		SELECT
			-- These columns are clean.
			cst_id,
			cst_key,
			-- Trim leading and trailing spaces from first and last name columns.
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			-- Standardize marital_status and fill missing values with n/a.
			CASE 
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				ELSE 'n/a'
			END AS cst_marital_status,
			-- Standardize cst_gndr and fill missing values with n/a. 
			CASE 
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				ELSE 'n/a'
			END AS cst_gndr,
			cst_create_date
		FROM (
			SELECT
				*,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS ranking
			FROM bronze.cust_info
			WHERE cst_id IS NOT NULL -- Exclude nulls.
		) AS relation
		WHERE ranking = 1; -- Select the earliest record.

		SET @end_time = GETDATE();

        PRINT '-> Load Time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-> -------------';

		-- Loading silver.prd_info
        SET @start_time = GETDATE();

		PRINT '-> Truncating Table: silver.prd_info';
		TRUNCATE TABLE silver.prd_info;

		PRINT '-> Inserting Data Into: silver.prd_info';
		INSERT INTO silver.prd_info (
			prd_id,
			cat_key,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			-- This column is clean.
			prd_id,
			-- Derive cat_key column from prd_key column.
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_key,
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,  
			-- This column is clean.
			prd_nm, 
			-- Convert null values into 0
			ISNULL(prd_cost, 0) AS prd_cost,
			-- Standardize the prd_line column and fill missing values with n/a.
			CASE 
				WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
				WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
				WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
				WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line,

			prd_start_dt AS prd_start_dt,
			-- Calculate the end date as the day before the next start date.
			DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt))
			AS prd_end_dt 
		FROM bronze.prd_info;

        SET @end_time = GETDATE();

        PRINT '-> Load Time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-> -------------';

        -- Loading silver.sales_details.
        SET @start_time = GETDATE();

		PRINT '-> Truncating Table: silver.sales_details';
		TRUNCATE TABLE silver.sales_details;

		PRINT '-> Inserting Data Into: silver.sales_details';
		INSERT INTO silver.sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			-- These columns are clean.
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			-- If length of numbers could be a date it will be converted into date, otherwise, it will be null.
			-- Cast the column into string first, after then date.
			CASE 
				WHEN LEN(sls_order_dt) < 6 OR sls_order_dt IS NULL THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE 
				WHEN LEN(sls_ship_dt) < 6 OR sls_ship_dt IS NULL THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE 
				WHEN LEN(sls_due_dt) < 6 OR sls_due_dt IS NULL THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			-- If the sales column has a problem, it will be calculated by this equation sls_quantity * ABS(sls_price).
			CASE 
				WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != (sls_quantity * ABS(sls_price))
					THEN (sls_quantity * ABS(sls_price))
				ELSE sls_sales
			END AS sls_sales,
			-- This column is clean.
			sls_quantity,
			-- When the price is null or negative, derive the value by this equation (ABS(sls_sales) / NULLIF(sls_quantity, 0)).
			CASE 
				WHEN sls_price IS NULL OR sls_price <= 0 
					THEN ABS(sls_sales) / NULLIF(sls_quantity, 0)
				ELSE sls_price  -- Derive price if the original value is invalid
			END AS sls_price
		FROM bronze.sales_details;

        SET @end_time = GETDATE();

        PRINT '-> Load Time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-> -------------';

        -- silver.cust_metadata
        SET @start_time = GETDATE();

		PRINT '-> Truncating Table: silver.cust_metadata';
		TRUNCATE TABLE silver.cust_metadata;

		PRINT '-> Inserting Data Into: silver.cust_metadata';
		INSERT INTO silver.cust_metadata (
			cid,
			bdate,
			gen
		)
		SELECT
			--	Remove the prefix from the column
			CASE
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
				ELSE cid
			END AS cid, 
			 -- Turn any future bdate to null
			CASE
				WHEN YEAR(bdate) > 2025 THEN NULL
				ELSE bdate
			END AS bdate,
			-- Standardize gen column and fill missing values with n/a.
			CASE
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				ELSE 'n/a'
			END AS gen
		FROM bronze.cust_metadata;

	    SET @end_time = GETDATE();

        PRINT '-> Load Time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-> -------------';

        -- Loading silver.cust_loc
        SET @start_time = GETDATE();

		PRINT '-> Truncating Table: silver.cust_loc';
		TRUNCATE TABLE silver.cust_loc;

		PRINT '-> Inserting Data Into: silver.cust_loc';
		INSERT INTO silver.cust_loc (
			cid,
			cntry
		)
		SELECT
			-- Remove '-' from the column.
			REPLACE(cid, '-', '') AS cid, 
			-- Standardize cntry column.
			CASE
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM(cntry)
			END AS cntry
		FROM bronze.cust_loc;

	    SET @end_time = GETDATE();

        PRINT '-> Load Time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-> -------------';
		
		-- Loading cat_info
		SET @start_time = GETDATE();

		PRINT '-> Truncating Table: silver.cat_info';
		TRUNCATE TABLE silver.cat_info;

		PRINT '-> Inserting Data Into: silver.cat_info';
		INSERT INTO silver.cat_info (
			id,
			cat,
			subcat,
			maintenance
		) -- This table is clean
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.cat_info;

		SET @end_time = GETDATE();

		PRINT '-> Load Time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-> -------------';

		SET @batch_end_time = GETDATE();

		PRINT '~~~~~~~~~~~~~~~~~~~~~~'
		PRINT 'Loading Silver Layer Is Successfully Done!';
        PRINT 'The Entire Time: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '~~~~~~~~~~~~~~~~~~~~~~'
		
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message ->' + ERROR_MESSAGE();
		PRINT 'Error Number ->' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State ->' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END
