🏗️ End-to-End SQL Data Warehouse | Medallion Architecture

📌 Project Overview:

Designed and implemented an end-to-end SQL Server Data Warehouse using a Medallion Architecture (Bronze, Silver, and Gold) to transform raw CSV sources into clean, integrated, and analytics-ready datasets.

The project emphasizes reusable ETL procedures, data quality validation, business rule enforcement, surrogate key management, and dimensional modeling to support reliable analytical reporting.

---

🎯 Key Objectives:

- 📥 Build a layered Data Warehouse architecture using Bronze, Silver, and Gold schemas.
- 🔄 Develop reusable stored procedures for automated data ingestion and transformation.
- 🧹 Identify and resolve data quality issues while preserving raw source data.
- 🔗 Integrate multiple sources and validate data consistency across related tables.
- 🔑 Implement surrogate key management for efficient data integration and historical tracking.
- ⭐ Build business-ready Fact and Dimension views using a Star Schema.

---

🔄 ETL & Data Transformation (T-SQL)

1️⃣ Bronze Layer — Raw Data Ingestion:

- Created six staging tables to ingest raw data from CSV source files.
- Implemented "BULK INSERT" with "TABLOCK" for bulk data loading.
- Used Dynamic SQL with "sp_executesql" to centralize file-path configuration and simplify deployment across environments.
- Developed "bronze.load_bronze" to orchestrate full-refresh loading, monitor execution time, and report errors.
- Implemented source-to-target row-count validation to verify ingestion completeness.

2️⃣ Silver Layer — Data Cleaning & Standardization:

- Developed "silver.load_silver" to orchestrate transformations across six tables using standard T-SQL INSERT statements.
- Used "ROW_NUMBER()" to identify duplicate customer records and retain the latest record based on creation date.
- Standardized categorical values, text fields, country names, and customer identifiers.
- Applied business rules to handle missing or invalid values, correct inconsistent sales and pricing data, and derive product validity end dates using "LEAD()" and "DATEADD()".
- Added "dwh_create_date" columns to track record creation timestamps within the Silver tables.
- Implemented "IDENTITY(1,1)" surrogate keys in both customer and product tables to generate unique, system-managed identifiers and Initialize the dimensions for SCD.
- Retained original business keys to support source record identification, data integration, and change detection.
- Used integer-based surrogate keys instead of lengthy text-based identifiers for key matching, improving JOIN efficiency and simplifying downstream data integration.
- Established surrogate key management as a foundation for implementing Slowly Changing Dimensions (SCD) and maintaining historical dimension records.
- Created dedicated validation queries to check uniqueness, data quality, and referential integrity after loading.

---

🏗️ Data Modeling & Gold Layer:

1️⃣ Dimensional Modeling

- Created business-ready views: "gold.dim_customers", "gold.dim_products", and "gold.fact_sales".
- Designed a Star Schema with customer and product dimensions supporting sales analysis.
- Integrated customer attributes from multiple Silver tables using "LEFT JOIN" and "COALESCE".
- Enriched product data with category and subcategory attributes.
- Filtered historical product records to expose currently active product versions in the product dimension.

2️⃣ Fact & Dimension Integration

- Established the sales fact view at the item-line level.
- Integrated customer and product identifiers into the Fact view using surrogate-key-based relationships to improve join efficiency and support dimensional integration.
- Implemented referential integrity checks to identify unmatched customer and product keys across the Gold layer.

---

✅ Data Quality & Validation

- 🔍 Performed source-level profiling to investigate duplicates, nulls, invalid values, and inconsistent formats before transformation.
- 🧪 Validated Silver-layer outputs against defined business rules.
- 🔗 Checked key uniqueness and relationships between customer, product, and sales datasets.
- 📊 Reconciled expected source row counts against loaded Bronze records.
- 🛡️ Preserved raw source data in Bronze to maintain traceability and support reproducible transformations.

---

🛠️ Tools & Technologies

- SQL Server — Data Warehouse development and storage.
- T-SQL — Stored procedures, window functions, CTEs, joins, and data transformations.
- Dynamic SQL — Flexible execution and centralized file-path configuration in the Bronze layer.
- BULK INSERT — High-volume CSV ingestion.
- IDENTITY Surrogate Keys — System-generated identifiers for efficient data integration and historical dimension management.
- Medallion Architecture — Bronze, Silver, and Gold data layers.
- Dimensional Modeling — Star Schema, Fact and Dimension views.
- Data Quality Assurance — Row-count reconciliation, data validation, and referential integrity checks.

---
Images:
![Modeling](images\star_schema_model.png)
![Architecture](images\medallion_architecture.png)