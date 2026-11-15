/*
===============================================================================
DDL Script: Create Silver Layer Tables (OLTP Design).
===============================================================================
Script Purpose:
    This script creates tables in the 'Silver' layer after dropping existing tables 
    if they already exist.

    This layer stores clean, consistent, standardize and transformed data.

	Run this script to re-create the DDL structure of 'Silver' layer.
===============================================================================
*/

-- Use Datawarehouse database
USE Datawarehouse;
GO


DROP TABLE IF EXISTS silver.cust_info;
GO

CREATE TABLE silver.cust_info (
    [key]               INT IDENTITY(1, 1),
    cst_id              INT,
    cst_key             NVARCHAR(20),
    cst_firstname       NVARCHAR(20),
    cst_lastname        NVARCHAR(20),
    cst_marital_status  NVARCHAR(10),
    cst_gndr            NVARCHAR(10),
    cst_create_date     DATE,
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);
GO

DROP TABLE IF EXISTS silver.prd_info;
GO

CREATE TABLE silver.prd_info (
    [key]           INT IDENTITY(1, 1),
    prd_id          INT,
    cat_key         NVARCHAR(10),
    prd_key         NVARCHAR(20),
    prd_nm          NVARCHAR(50),
    prd_cost        INT,
    prd_line        NVARCHAR(20),
    prd_start_dt    DATE,
    prd_end_dt      DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

DROP TABLE IF EXISTS silver.sales_details;
GO

CREATE TABLE silver.sales_details (
    sls_ord_num     NVARCHAR(10),
    sls_prd_key     NVARCHAR(20),
    sls_cust_id     INT,
    sls_order_dt    DATE,
    sls_ship_dt     DATE,
    sls_due_dt      DATE,
    sls_sales       INT,
    sls_quantity    SMALLINT,
    sls_price       INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

DROP TABLE IF EXISTS silver.cust_loc;
GO

CREATE TABLE silver.cust_loc (
    cid             NVARCHAR(20),
    cntry           NVARCHAR(20),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

DROP TABLE IF EXISTS silver.cust_metadata;
GO

CREATE TABLE silver.cust_metadata (
    cid             NVARCHAR(20),
    bdate           DATE,
    gen             NVARCHAR(10),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

DROP TABLE IF EXISTS silver.cat_info;
GO

CREATE TABLE silver.cat_info (
    id              NVARCHAR(10),
    cat             NVARCHAR(20),
    subcat          NVARCHAR(20),
    maintenance     NVARCHAR(10),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


