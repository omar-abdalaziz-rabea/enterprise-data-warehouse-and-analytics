/*
===============================================================================
Database & Schema Initialization
===============================================================================
Script Purpose:
    This script initializes the Data Warehouse environment by creating a new
    database named 'Datawarehouse' and establishing the required schemas.

    The script performs the following operations:
        1. Checks whether the 'Datawarehouse' database already exists.
        2. Drops the existing database, if present, and recreates it.
        3. Creates the following schemas:
            - bronze: Raw data layer.
            - silver: Cleansed and transformed data layer.
            - gold: Business-ready data layer.

WARNING:
    This script performs a destructive operation by dropping the existing
    'Datawarehouse' database, including all its objects and stored data.

    Ensure that valid backups are available before execution.
===============================================================================
*/

USE master;
GO

-- Drop and recreate the 'Datawarehouse' database
IF EXISTS (SELECT 1 FROM SYS.DATABASES WHERE NAME = 'Datawarehouse')
BEGIN
    --  Ensure no active connections, and rollback any open transaction immediately.
    ALTER DATABASE Datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Datawarehouse;                                          
END;
GO

-- Create the 'Datawarehouse' database
CREATE DATABASE Datawarehouse;
GO

-- Use DataWarehouse.
USE Datawarehouse;
GO

-- Create Schemas.
--------------------
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
---------------------

-- Ensure existing of the schemas.
SELECT
    [name]
FROM SYS.SCHEMAS

