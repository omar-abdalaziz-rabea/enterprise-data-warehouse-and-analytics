/*
================================================================================
                       GOLD LAYER - ANALYTICAL DATA MODEL
================================================================================
Purpose:
    Create business-ready SQL Views in the Gold Layer by integrating
    and enriching transformed data from the Silver Layer.

Architecture:
    Star Schema (Dimensional Data Modeling).

Objects Created:
    1. Dimensions:
       - gold.dim_customers
       - gold.dim_products

    2. Fact:
       - gold.fact_sales

Data Transformation & Modeling:
    1. Data Integration:
       Combine related Silver Layer tables using appropriate JOIN operations.

    2. Data Enrichment:
       - Integrate customer demographic and geographic attributes.
       - Enrich product records with category and subcategory information.
       - Resolve missing gender values using COALESCE and NULLIF.

    3. Dimensional Modeling:
       - Build Customer and Product Dimension Views.
       - Build the Sales Fact View.
       - Integrate surrogate keys into the Fact View.
       - Exclude historical product records to retrieve current products.

    4. Schema Standardization:
       - Rename columns using business-friendly naming conventions.
       - Reorder columns according to logical data categories:
         Keys, Identifiers, Descriptive Attributes, Dates, and Measures.

    5. Historical Data Handling:
       Retain current product records in the Product Dimension while
       preserving the historical source records in the Silver Layer.

Usage:
    Query Gold Views directly for analytical reporting,
    business intelligence, and downstream data consumption.

Expected Outcome:
    Deliver an integrated, business-ready analytical data model
    that provides a consistent foundation for reporting,
    KPI development, and business decision-making.

Important Notes:
    - Gold Views are built on top of the Silver Layer.
    - Views provide a logical representation of the data
      without physically storing the resulting datasets.
    - The Sales Fact View connects transactional records
      to their corresponding Customer and Product Dimensions.
================================================================================
*/

-- Use  Datawarehouse database.
USE Datawarehouse;
GO

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

DROP VIEW IF EXISTS gold.dim_customers;
GO

CREATE VIEW gold.dim_customers     AS
SELECT
    ci.[key]                       AS [key],
    ci.cst_id                      AS id,
    ci.cst_firstname               AS first_name,
    ci.cst_lastname                AS last_name,
    COALESCE(
        NULLIF(ci.cst_gndr, ''),
        NULLIF(cm.gen, ''),
        'n/a')                     AS gender,
    ci.cst_marital_status          AS marital_status,
    cl.cntry                       AS country,
    cm.bdate                       AS birthdate,
    ci.cst_create_date             AS create_date
FROM      silver.cust_info     AS ci
LEFT JOIN silver.cust_metadata AS cm
ON        ci.cst_key = cm.cid
LEFT JOIN silver.cust_loc      AS cl
ON        ci.cst_key = cl.cid;
GO

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
DROP VIEW IF EXISTS gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    pri.[key]                 AS [key],
    pri.prd_key                AS id,
    pri.prd_nm                AS [name],
    pri.prd_line              AS line,
    cai.subcat                AS subcategory_name,
    cai.maintenance           AS subcategory_maintenance,
    cai.cat                   AS category_name,
    pri.prd_start_dt          AS [start_date],
    pri.prd_cost              AS cost
FROM      silver.prd_info AS pri
LEFT JOIN silver.cat_info AS cai
ON        cai.id = pri.cat_key
WHERE     pri.prd_end_dt IS NULL; -- Get rid off historical products.
GO

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
DROP VIEW IF EXISTS gold.fact_sales;
GO

CREATE VIEW gold.fact_sales  AS
SELECT 
    sd.sls_ord_num AS order_number,
    p.[key] AS product_key,
    c.[key] AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS ship_date,
    sd.sls_due_dt AS due_date,
    sd.sls_price AS price,
    sd.sls_quantity AS quantity,
    sd.sls_sales AS sales
FROM silver.sales_details AS sd
LEFT JOIN gold.dim_customers AS c
ON sd.sls_cust_id = c.id
LEFT JOIN gold.dim_products AS p
ON sd.sls_prd_key = p.id
