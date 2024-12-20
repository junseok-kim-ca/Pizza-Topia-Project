# Overview

**How to figure out if there are text encoding issues? Please show the MySQL queries to find them 

# Problem Statement


# Tools 

# Data Preparation & Cleanup 
This section describes the steps involved in preparing the data for analysis, ensuring its accuracy and reliability for use.

## Data Import 
I created a database and table, and since the dataset contains over 48,000 rows, I used the `LOAD DATA INFILE` query. This method is widely recognized as one of the fastest and most efficient ways to load large volumes of data into a database table.

```sql
CREATE DATABASE IF NOT EXISTS pizza_db;
USE pizza_db;

CREATE TABLE pizza_sales (
    pizza_id INT NOT NULL PRIMARY KEY,
    order_id INT,
    pizza_name_id VARCHAR(50),
    quantity INT,
    order_date VARCHAR(50), -- We will change the database format, YYYY-MM-DD and change DATE datatype later
    order_time TIME,
    unit_price DECIMAL(10, 2),
    total_price DECIMAL(10, 2),
    pizza_size CHAR(3),
    pizza_category VARCHAR(50),
    pizza_ingredients TEXT,
    pizza_name VARCHAR(255) 
);

LOAD DATA INFILE 'C:\\Project 2\\pizza_sales.csv'
INTO TABLE pizza_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES 
(
    pizza_id,
    order_id,
    pizza_name_id,
    quantity,
    order_date,
    order_time,
    unit_price,
    total_price,
    pizza_size,
    pizza_category,
    pizza_ingredients,
    pizza_name
);
```

## Data Exploration
I begin by running a series of SQL queries to gain an initial understanding of the pizza_sales dataset, focusing on its size, uniqueness of key features, and the time range of data collection. This helps establish the foundational structure and scope of the data before further analysis.

```sql
SELECT
    COUNT(*) AS total_rows
FROM 
    pizza_sales; -- There are 48620 rows in this dataset

SELECT 
    COUNT(DISTINCT pizza_name) AS unique_pizza_items
FROM 
    pizza_sales; -- there are 32 unique pizza items in Pizza Topia

SELECT 
    MIN(order_date) AS earliest_order_date,
    MAX(order_date) AS latest_order_date
FROM 
    pizza_sales; -- The data was collected from Jan 1, 2015 until Dec 31, 2015
```

## Data Cleaning 
In this stage, I corrected data types and standardized text data to ensure more accurate analysis in the future. Additionally, I addressed missing and duplicate data to enhance overall data integrity.

### Fixing Data Types & Text Data 

```sql
UPDATE pizza_sales
SET
    order_date = STR_TO_DATE(order_date, '%d-%m-%Y')
WHERE
    order_date IS NOT NULL; -- modify date format DD-MM-YYYY to YYYY-MM-DD

ALTER TABLE pizza_sales
MODIFY order_date DATE; -- change VARCHAR to DATE data type 

SELECT 
    pizza_name
FROM 
    pizza_sales
WHERE
    pizza_name REGEXP '[!@#$%^&*()_+=\\[\\]{}|;:"<>?/\\`~]'; -- Match any single character that is a punctuation symbol from the list provided.

UPDATE pizza_sales
SET
    pizza_ingredients = REPLACE(pizza_ingredients, '?duja Salami', '''Nduja Salami')
WHERE
    pizza_ingredients LIKE '%?duja Salami%'; -- Update '?duja Salami' to 'Nduja Salami'
```

### Handling Missing & Duplicate data

```sql
SELECT 
    * 
FROM 
    pizza_sales
WHERE 
    pizza_id IS NULL 
    OR order_id IS NULL
    OR pizza_name_id IS NULL
    OR quantity IS NULL
    OR order_date IS NULL
    OR order_time IS NULL
    OR unit_price IS NULL
    OR total_price IS NULL
    OR pizza_size IS NULL
    OR pizza_category IS NULL
    OR pizza_ingredients IS NULL
    OR pizza_name IS NULL; -- There is no NULL values in all columns

SELECT 
    *,
    COUNT(*) AS duplicate_count
FROM 
    pizza_sales
GROUP BY 
    pizza_id,
    order_id,
    pizza_name_id,
    quantity,
    order_date,
    order_time,
    unit_price,
    total_price,
    pizza_size,
    pizza_category,
    pizza_ingredients,
    pizza_name
HAVING 
    COUNT(*) > 1; -- There are no duplicate rows 
```


# Analysis 
For this project, each query was designed to explore specific requirements of Pizza Topia. Here's the approach I took for addressing each question:

### 1. Total Revenue from pizza sales
To measure the financial performance of the pizza business, I calculated the total revenue by summing up the sales figures across all orders. This query is essential for understanding the overall income generated, providing a baseline for evaluating business success.

```sql
SELECT
    ROUND(SUM(total_price), 0) AS total_revenue
FROM 
    pizza_sales;
```
| total_revenue |
|---------------|
| 817860        |



### 2. Average order value (AOV) of Pizza Topia
To assess customer spending patterns, I calculated the average order value by dividing the total revenue by the number of unique orders. This query calculates the average revenue per order, offering insights into customer spending habits. 

```sql
SELECT
    ROUND(SUM(total_price) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM 
    pizza_sales;
```
| avg_order_value  |        
|------------------|
| 38.31  |  

### 3. Average pizzas per order from Pizza Topia
To understand customer purchasing habits, this query calculates the average number of pizzas per order by dividing total pizzas sold by unique orders, revealing typical order sizes.

```sql
SELECT
    ROUND(SUM(quantity) / COUNT(DISTINCT order_id), 0) AS avg_pizza_per_order
FROM 
    pizza_sales; -- 2

```
| avg_pizza_per_order  |        
|------------------|
| 2 |  

### 4. Repeat orders by each pizzas (ordered by highest to lowest) 
I calculated the number of unique repeat orders for each pizza in order to identify customer loyalty and preferences. This query highlightes the most frequently reordered pizzas. 

```sql
WITH repeat_orders AS (
    SELECT
        pizza_name,
        order_id,
        COUNT(order_id) AS total_order
    FROM 
        pizza_sales
    GROUP BY 
        pizza_name,
        order_id
    HAVING 
        COUNT(order_id) > 1 
)
SELECT
    pizza_name,
    COUNT(DISTINCT order_id) AS total_repeat_order -- Use the DISTINCT operator to ensure the count is accurate and to prevent duplicate entries from inflating the results
FROM 
    repeat_orders
GROUP BY 
    pizza_name
ORDER BY
    total_repeat_order DESC;

```
| Pizza Name                       | Pizza Category | Total Repeat Orders |
|----------------------------------|----------------|---------------------|
| The California Chicken Pizza     | Chicken        | 102                 |
| The Barbecue Chicken Pizza       | Chicken        | 98                  |
| The Pepperoni Pizza              | Classic        | 89                  |
| ...                              | ...            | ...                 |
| The Green Garden Pizza           | Veggie         | 11                  |
| The Mediterranean Pizza          | Veggie         | 11                  |
| The Calabrese Pizza              | Supreme        | 9                   |

***Key Findings***
1. The California Chicken Pizza leads significantly with 102 repeat orders, making it the most popular pizza among returning customers.
2. Pizzas like The Calabrese Pizza (9 orders), The Mediterranean Pizza (11 orders), and The Green Garden Pizza (11 orders) have fewer repeat orders.
3. Vegetarian pizzas such as The Vegetables Pizza (44 orders) and The Green Garden Pizza (11 orders) show lower repeat rates compared to chicken-based pizzas.  

### 5. 
