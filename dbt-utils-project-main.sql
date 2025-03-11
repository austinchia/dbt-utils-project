
// dbt-utils package

// dbt-utils Installation and Setup
// Let’s have a look at how the dbt-utils package can be introduced into your data workflow below.

// Step 1: Install dbt
// First, ensure that dbt is installed in your environment. You can install dbt via pip:

pip install dbt

// Step 2: Add dbt-utils to your dbt project
// Create this file in your dbt project root if it doesn't exist, and add the following:


packages:
- package: dbt-labs/dbt_utils
version: "1.1.1" # Use the latest version compatible with your dbt version

// In this yaml file, you’ll be specifying the necessary package version as well. Make sure to use the latest version that is compatible with your installed dbt version.

// Step 3: Install the package
// After modifying, the installation is a simple command away.

// The successful execution of this command will fetch and install dbt-utils, preparing you for enhanced functionality.

// Run the following command in your terminal within your dbt project directory:

dbt deps

// This command installs all the packages listed in your packages.yml.

// These functions help developers avoid redundancies and concentrate on their unique business logic.

Here are some functions in dbt-utils:

// 1. SQL generators
// SQL generators in dbt-utils are useful for creating modular SQL code.

// 2. Generic tests
// Generic tests are used to validate data in a table or view. They can be easily customized to fit specific requirements and provide valuable insights into the quality of data being processed.

// 3. Jinja helpers
// Jinja helpers are useful for creating dynamic SQL queries that can be easily customized based on user input or variable data. They allow for conditional logic and looping within SQL statements.

// 4. Web macros
// Web macros are similar to Jinja helpers, but they are specifically designed for web-based projects. 

// Here’s how the syntax looks:

{{ dbt_utils.get_url_path(field='page_url') }}


// Practical Use Cases of dbt utils
// Use case 1: Simplifying complex queries
// Example scenario: A company has a large dataset containing customer information, transaction data, and product data. They need to create a report that shows the total sales for each product category in the past quarter.

// Instead of writing complex SQL queries to join multiple tables and calculate the sales for each category, they can use dbt utils to easily extract relevant data and manipulate it within their macros or models.

// For example, they can use get_filtered_columns_in_relation to filter out only the necessary columns related to product data and then use sum macro to calculate the total sales for each category.

// This simplifies the process and makes it more efficient, saving time and reducing errors.


-- models/product_data_filtered.sql
with product_data as (
select
{{ dbt_utils.get_filtered_columns_in_relation(
relation=ref('products'),
include=['product_id', 'category']
) }}
from {{ ref('products') }}
)
select * from product_data

// Next, create a model to join the product, transaction, and customer data. Then use the sum function to calculate the total sales for each product category in the past quarter.


-- models/total_sales_by_category.sql
with product_data as (
select
{{ dbt_utils.get_filtered_columns_in_relation(
relation=ref('products'),
include=['product_id', 'category']
) }}
from {{ ref('products') }}
),
transaction_data as (
select
product_id,
sale_amount,
transaction_date
from {{ ref('transactions') }}
where transaction_date >= date_trunc('quarter', current_date) - interval '1 quarter'
),
joined_data as (
select
p.category,
t.sale_amount
from product_data p
join transaction_data t
on p.product_id = t.product_id
)
select
category,
sum(sale_amount) as total_sales
from joined_data
group by category

// After defining the models, run the dbt models to execute the transformations and generate the report.


dbt run

// Here’s an explanation of the code above:

// The get_filtered_columns_in_relation macro helps in selecting only the necessary columns (product_id and category) from the products table, simplifying the dataset.

// Next, the filtered product data is joined with the transaction data using SQL to get the sales amounts for each product. It then calculates the total sales for each product category within the last quarter using the sum aggregation function.

// Use case 2: Ensuring data quality with generic tests
// Example scenario:

// In this use case, we will continue working with the same mock dataset from Use Case 1. However, instead of creating a report, our goal is to ensure data quality by running generic tests on the data.

// Below are examples of how to implement these tests for your dataset:

// 1. Testing for proportion of nulls
// In this generic test, we will assert only values that fit the non-null proportion that we specify. We will do this using the not_null_proportion test.


# models/products.yml
version: 2
models:
- name: products
columns:
- name: product_id
tests:
- dbt_utils.not_null_proportion:
at_least: 0.95
// In this example, we included an additional optional argument at_least to set the non-null proportion to have a maximum of 0.95.

// 2. Testing for empty fields
// In this example, we’ll use the not_empty_string test to check for empty strings in the product_id field.


# models/products.yml
version: 2
models:
- name: products
columns:
- name: product_id
tests:
- dbt_utils.not_empty_string
// 3. Testing referential integrity
// Using the relationships_where function will ensure that every product_id in the transactions table exists in the products table.


# models/transactions.yml
version: 2
models:
- name: transactions
columns:
- name: product_id
tests:
- dbt_utils.relationships_where:
to: ref('products')
field: product_id
