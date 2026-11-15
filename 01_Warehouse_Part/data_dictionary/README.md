📖 Gold Layer – Data Dictionary

The Gold Layer follows a Star Schema design, consisting of two dimension tables and one fact table. Each table is structured to support efficient analytical queries and business intelligence reporting.

1. dim_customers

Stores customer-level descriptive attributes used for customer segmentation and analysis.
*** Table source *** ->(cust_info.csv, cust_loc.csv, cust_metadata.csv)

*** Table information ***

Column| Data Type| Description
customer_key| INT| Surrogate Primary Key uniquely identifying each customer in the dimension table.
id| INT| Original customer identifier from the source system.
first_name| NVARCHAR| Customer's first name.
last_name| NVARCHAR| Customer's last name.
gender| NVARCHAR| Customer's gender.
marital_status| NVARCHAR| Customer's marital status.
country| NVARCHAR| Customer's country of residence.
birthdate| DATE| Customer's date of birth.
create_date| DATE| Date the customer record was originally created.

2. dim_products

Stores product-level descriptive attributes, including product hierarchy and cost information.
*** Table source *** ->(prd_info.csv, cat_info.csv)

*** Table information ***

Column| Data Type| Description
product_key| INT| Surrogate Primary Key uniquely identifying each product in the dimension table.
id| NVARCHAR| Original product identifier from the source system.
name| NVARCHAR| Product name.
line| NVARCHAR| Product line to which the product belongs.
subcategory_name| NVARCHAR| Name of the product's subcategory.
subcategory_maintenance| NVARCHAR| Indicates whether the product subcategory requires maintenance (Yes/No).
category_name| NVARCHAR| Name of the product's category.
start_date| DATE| Date associated with the product's start or effective date.
cost| INT| Unit cost of the product.

3. fact_sales

Stores transactional sales data at the item level, capturing individual product sales within customer orders.
*** Table source *** ->(sales_details.csv)

*** Table information ***

Column| Data Type| Description
order_number| NVARCHAR| Identifier of the customer order. Multiple rows may share the same order number because each row represents an individual order item.
product_key| INT| Foreign Key referencing "dim_products", used to associate sales transactions with product attributes.
customer_key| INT| Foreign Key referencing "dim_customers", used to associate sales transactions with customer attributes.
order_date| DATE| Date the customer placed the order.
ship_date| DATE| Date the order was shipped.
due_date| DATE| Expected delivery date of the order.
price| INT| Selling price per unit of the product.
quantity| INT| Number of units sold in the transaction row.
sales| INT| Total sales amount for the transaction row, calculated as unit price multiplied by quantity.

🔑 Surrogate Keys & Relationships

Surrogate keys were introduced in both dimension tables ("dim_customers" and "dim_products") to provide unique integer-based identifiers.

These keys are used to establish relationships with the fact table instead of relying on original source identifiers or text-based attributes.

Key Benefits:

- Improved JOIN efficiency through integer-based relationships.
- Reduced index storage requirements compared to wider text-based keys.
- Simplified relationships between fact and dimension tables.
- Improved query performance and supported efficient analytical reporting.

⭐ Star Schema Relationships

Dimension Table| Fact Table| Relationship| Join Columns
dim_customers| fact_sales| One-to-Many (1:M)| customer_key
dim_products| fact_sales| One-to-Many (1:M)| product_key

Relationship Direction: One-to-Many (1:M), from Dimension Tables to the Fact Table.

📊 Data Grain

Table| Grain
fact_sales| Item-level: Each row represents an individual product within a customer order.
dim_customers| Customer-level: Each row represents a unique customer.
dim_products| Product-level: Each row represents a unique product.

Important: "order_number" is not unique in "fact_sales", as a single order can contain multiple products. The fact table's grain is therefore defined at the individual order-item level.