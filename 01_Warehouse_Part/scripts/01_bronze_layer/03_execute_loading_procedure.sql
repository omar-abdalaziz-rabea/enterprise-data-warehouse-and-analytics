/*
=====================================
Execution Script: Load Bronze Layer
=====================================
Script Purpose:
    This script executes the stored procedure bronze.load_bronze to load 
    all source files (CSV) into the Bronze Layer.

    It is the entry point for the first layer (Bronze) of the Data Warehouse.

Prerequisites:
    1. The procedure [bronze].[load_bronze] must be created.
    2. The @abs_path variable inside the procedure must be updated to match
       your local dataset folder path.
    3. Bronze tables must exist in the Datawarehouse database.

Workflow:
    - Truncates existing bronze tables.
    - Bulk loads fresh data from CSV files using Dynamic SQL.
    - Prints load time for each table and total batch time.

Output:
    - Messages in the Messages tab showing progress and load duration.
    - In case
*/

-- Use Datawarehouse database.
USE Datawarehouse;
GO

-- Exexcute the procedure.
EXEC bronze.load_bronze
