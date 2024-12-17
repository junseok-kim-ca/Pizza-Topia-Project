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

```sql
SELECT
    COUNT(*) AS total_rows
FROM 
    pizza_sales; -- There are 48620 rows in this dataset
    
SELECT
    COUNT(*) AS total_columns
FROM 
    INFORMATION_SCHEMA.COLUMNS 
WHERE
    TABLE_SCHEMA = 'pizza_db'
    AND TABLE_NAME = 'pizza_sales'; -- There are 12 columns in the dataset

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



# Analysis 
For this project, each query was designed to explore specific requirements of Pizza Topia. Here's the approach I took for addressing each question:

### 1. Total Revenue from pizza sales
To measure the financial performance of the pizza business, I calculated the total revenue by summing up the sales figures across all orders. This query is essential for understanding the overall income generated, providing a baseline for evaluating business success.

*** 왜 total revenue를 했는지 이해해보자 *** 

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


