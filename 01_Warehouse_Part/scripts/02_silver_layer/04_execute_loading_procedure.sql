/*
=====================================
Execution Script: Load Silver Layer
=====================================
Script Purpose:
    This script executes the stored procedure silver.load_silver to load 
    transformed, clean and standardized data into the silver layer.

Workflow:
    - Truncates existing silver tables.
    - Insert the data from the query into the tables.
    - Prints load time for each table and total loading time.

Output:
    - Messages in the Messages tab showing progress and load duration.
    - In case
*/

-- Use Datawarehouse database.
USE Datawarehouse;
GO

-- Exexcute the procedure.
EXEC silver.load_silver;