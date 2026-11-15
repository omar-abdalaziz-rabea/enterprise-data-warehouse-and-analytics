/*
======================================================
Stored Procedure: bronze.load_bronze
=======================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external 
    CSV files. It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the 'BULK INSERT' command to load data from CSV Files to 
      bronze tables.
    - Tracks load duration for each table and for the entire batch.

Design Decision - Dynamic SQL:
    Dynamic SQL (sp_executesql) is used to centralize the dataset folder 
    path in a single variable @abs_path.
    
    Why? 
    - Maintainability (DRY Principle): If the user clones the project to a 
      different drive/folder, they only need to change the path in ONE place
      at the top of the procedure, instead of changing it in 6 different 
      BULK INSERT statements.

Parameters:
    None. This procedure does not accept any parameters or return any values.
    Configuration is done via the @abs_path variable inside the procedure.

Configuration:
    >>> IMPORTANT: Change the @abs_path variable below to match your local
    dataset folder location before execution. <<<
    Example: SET @abs_path = N'''C:\Users\YourName\dataset\';
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	DECLARE @abs_path NVARCHAR(MAX), @sql NVARCHAR(MAX);

	--================================================================
	-- The absolute path of the datasets on my local machine.
	SET @abs_path = N'''D:\data_warehouse_project\dataset\';
	--=================================================================

	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '~~~~~~~~~~~~~~~~~~~~~';
		PRINT 'Loading Bronze Layer';
		PRINT '~~~~~~~~~~~~~~~~~~~~~';

		SET @start_time = GETDATE();

		PRINT '-> Truncating Table: bronze.cust_info';
		TRUNCATE TABLE bronze.cust_info;

		PRINT '-> Inserting Data Into: bronze.cust_info';
		-------------------------------------------------------------------
		SET @sql = 'BULK INSERT bronze.cust_info
					FROM ' + @abs_path + 'cust_info.csv''
					WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK)';
		EXEC sp_executesql @sql;
		-------------------------------------------------------------------
		SET @end_time = GETDATE();

		PRINT '-> Load Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-> -------------';

        SET @start_time = GETDATE();

		PRINT '-> Truncating Table: bronze.prd_info';
		TRUNCATE TABLE bronze.prd_info;

		PRINT '-> Inserting Data Into: bronze.prd_info';
		-------------------------------------------------------------------
		SET @sql = 'BULK INSERT bronze.prd_info
					FROM ' + @abs_path + 'prd_info.csv''
					WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK)';
		EXEC sp_executesql @sql;
		-------------------------------------------------------------------

		SET @end_time = GETDATE();

		PRINT '-> Load Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-> -------------';

        SET @start_time = GETDATE();

		PRINT '-> Truncating Table: bronze.sales_details';
		TRUNCATE TABLE bronze.sales_details;

		PRINT '-> Inserting Data Into: bronze.sales_details';
		-------------------------------------------------------------------
		SET @sql = 'BULK INSERT bronze.sales_details
					FROM ' + @abs_path + 'sales_details.csv''
					WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK)';
		EXEC sp_executesql @sql;
		-------------------------------------------------------------------

		SET @end_time = GETDATE();

		PRINT '-> Load Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-> -------------';

		--**************************************************************************************************************************************.
	
		SET @start_time = GETDATE();

		PRINT '-> Truncating Table: bronze.cust_loc';
		TRUNCATE TABLE bronze.cust_loc;

		PRINT '-> Inserting Data Into: bronze.cust_loc';
		-------------------------------------------------------------------
		SET @sql = 'BULK INSERT bronze.cust_loc
					FROM ' + @abs_path + 'cust_loc.csv''
					WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK)';
		EXEC sp_executesql @sql;
		-------------------------------------------------------------------

		SET @end_time = GETDATE();

		PRINT '-> Load Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-> -------------';

		SET @start_time = GETDATE();

		PRINT '-> Truncating Table: bronze.cust_metadata';
		TRUNCATE TABLE bronze.cust_metadata;

		PRINT '-> Inserting Data Into: bronze.cust_metadata';
		-------------------------------------------------------------------
		SET @sql = 'BULK INSERT bronze.cust_metadata
					FROM ' + @abs_path + 'cust_metadata.csv''
					WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK)';
		EXEC sp_executesql @sql;
		-------------------------------------------------------------------

		SET @end_time = GETDATE();

		PRINT '-> Load Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-> -------------';

		SET @start_time = GETDATE();

		PRINT '-> Truncating Table: bronze.cat_info';
		TRUNCATE TABLE bronze.cat_info;

		PRINT'-> Inserting Data Into: bronze.cat_info';
		-------------------------------------------------------------------
		SET @sql = 'BULK INSERT bronze.cat_info
					FROM ' + @abs_path + 'cat_info.csv''
					WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK)';
		EXEC sp_executesql @sql;
		-------------------------------------------------------------------

		SET @end_time = GETDATE();

		PRINT '-> Load Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-> -------------';

		SET @batch_end_time = GETDATE();

		PRINT '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
		PRINT 'Loading Bronze Layer Is Done!';
        PRINT '- The Entire Time: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR DETECTED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message ->' + ERROR_MESSAGE();
		PRINT 'Error Number ->' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State ->' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END
