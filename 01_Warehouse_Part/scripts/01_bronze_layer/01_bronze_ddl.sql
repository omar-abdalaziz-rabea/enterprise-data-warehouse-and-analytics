/*
===============================================================================
DDL Script: Create Bronze Layer Tables (OLTP Design).
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' layer after dropping existing tables 
    if they already exist.

    This layer stores row data as-is from source system with no transformations and
    constraints.

	Run this script to re-create the DDL structure of 'bronze' layer.
===============================================================================
*/

-- Use Datawarehouse database
USE Datawarehouse;
GO

DROP TABLE IF EXISTS bronze.cust_info;
GO

CREATE TABLE bronze.cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(20),
    cst_firstname       NVARCHAR(20),
    cst_lastname        NVARCHAR(20),
    cst_marital_status  NVARCHAR(10),
    cst_gndr            NVARCHAR(10),
    cst_create_date     DATE
);
GO

DROP TABLE IF EXISTS bronze.prd_info;
GO

CREATE TABLE bronze.prd_info (
    prd_id       INT,
    prd_key      NVARCHAR(20),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(10),
    prd_start_dt DATE,
    prd_end_dt   DATE
);
GO

DROP TABLE IF EXISTS bronze.sales_details;
GO

CREATE TABLE bronze.sales_details (
    sls_ord_num  NVARCHAR(10),
    sls_prd_key  NVARCHAR(20),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity SMALLINT,
    sls_price    INT
);
GO

DROP TABLE IF EXISTS bronze.cust_loc;
GO

CREATE TABLE bronze.cust_loc (
    cid    NVARCHAR(20),
    cntry  NVARCHAR(20)
);
GO

DROP TABLE IF EXISTS bronze.cust_metadata;
GO

CREATE TABLE bronze.cust_metadata (
    cid    NVARCHAR(20),
    bdate  DATE,
    gen    NVARCHAR(10)
);
GO

DROP TABLE IF EXISTS bronze.cat_info;

GO

CREATE TABLE bronze.cat_info (
    id           NVARCHAR(10),
    cat          NVARCHAR(20),
    subcat       NVARCHAR(20),
    maintenance  NVARCHAR(10)
);
GO
