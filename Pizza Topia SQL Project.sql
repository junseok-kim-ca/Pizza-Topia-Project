/* ------------------------------------------Queries------------------------------------------------------------ */


/* Data Import */

-- CREATE database and pizza_sales table
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



/*
Before importing a large datasets, we need to execute below queries:

SHOW VARIABLES LIKE 'local_infile'; -- To check LOAD DATA LOCAL INFILE command is enabled or disabled for the MySQL server.
SET GLOBAL local_infile = 1; -- Allow the use of LOAD DATA LOCAL INFILE command
SHOW VARIABLES LIKE 'secure_file_priv'; -- To find a restricted directory from which MySQL can read or write files for operations like LOAD DATA INFILE
*/

SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'secure_file_priv';
SELECT @@secure_file_priv; -- If it's NULL, then you can import the dataset from any locations 


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

SELECT
	*
FROM 
	pizza_sales;

/* Data Exploration */
DESCRIBE pizza_sales; -- Quick overview of table structure

SELECT
	COUNT(*) AS total_rows
FROM 
	pizza_sales; -- There are 48620 rows in this dataset
    
SELECT
	COUNT(*) AS total_columns
FROM 
	INFORMATION_SCHEMA.COLUMNS -- A metadata table that contains information about all columns in all tables.
WHERE
	TABLE_SCHEMA = 'pizza_db'
    AND TABLE_NAME = 'pizza_sales'; -- There are 12 columns in the dataset

-- How many unique pizza menus are there? 
SELECT 
    COUNT(DISTINCT pizza_name) AS unique_pizza_items
FROM 
	pizza_sales; -- there are 32 unique pizza items in Pizza Topia

-- What sizes does the Pizza Topia offer? 
SELECT DISTINCT 
	pizza_size
FROM 
	pizza_sales; -- They offer M, L, S, XL, and XXL

-- Let's check the period during which the data was collected.
SELECT 
	MIN(order_date) AS earliest_order_date,
    MAX(order_date) AS latest_order_date
FROM 
	pizza_sales; -- The data was collected from Jan 1, 2015 until Dec 31, 2015

-- Let's check the order time 
SELECT
	MIN(order_time) AS earliest_order_time,
	MAX(order_time) AS latest_order_time
FROM 
	pizza_sales; 

/*
Based on the data, we can assume that the store starts taking orders around 09:30 AM and stops accepting orders around 11:30 PM. 
However, these times may not precisely reflect the official store opening and closing hours, as they depend on the recorded order times.
*/
    

/* Data Cleaning */
	
-- Let's Change the date format from DD-MM-YYYY to YYYY-MM-DD to set the date datatype.
SET SQL_SAFE_UPDATES = 0; -- Disable Safe Update Mode

UPDATE pizza_sales
SET
	order_date = STR_TO_DATE(order_date, '%d-%m-%Y')
WHERE
	order_date IS NOT NULL;
    
ALTER TABLE pizza_sales
MODIFY order_date DATE;

DESCRIBE pizza_sales;

SELECT
	*
FROM 
	pizza_sales
LIMIT 5;

-- Let's check if the text data columns: pizza_name_id, pizza_category, pizza_ingredients, pizza_name 
-- To see the columns might have inconsistencies such as Non-printable characters, unusual characters, or unexpected punctuation. 

SELECT DISTINCT
	pizza_name_id
FROM 
	pizza_sales;
    
SELECT DISTINCT
	pizza_category
FROM 
	pizza_sales;

SELECT DISTINCT
	pizza_name
FROM 
	pizza_sales; -- 'The Vegetables + Vegetables Pizza' seems redundant and may cause confusion.

SELECT DISTINCT
	pizza_ingredients
FROM 
	pizza_sales; -- There is a wrong value, ?duja Salami in pizza_ingredients

-- Let's change the name, 'The Vegetables + Vegetables Pizza' to 'The Vegetables Pizza'
UPDATE pizza_sales
SET
	pizza_name = 'The Vegetables Pizza'
WHERE
	pizza_name = 'The Vegetables + Vegetables Pizza';
    
-- In order to detect more inappropriate punctuations such as ?duja Salami, let's use Regular expression operator, REGEXP

SELECT DISTINCT
    pizza_ingredients
FROM 
    pizza_sales
WHERE 
    pizza_ingredients REGEXP '[!@#$%^&*()_+=\\[\\]{}|;:"<>?/\\`~]'; -- No other punctuation issus without ?duja Salami.


/* Code Explanation 
1. REGEXP - is a regular expression operator in MySQL 

2. Regualr Expression - a sequence of characters used to define a search pattern 
for matching complex string data within a database

3. [!@#$%^&*()_+=\\[\\]{}|;:"<>?/\\`~] - Match any single character that is a punctuation symbol from the list provided.
*/

-- According to internet information, ?duja Salami might be 'Nduja Salami (Italian spicy sausage). 
-- Let's change ?duja Salami to 'Nduja Salami
UPDATE pizza_sales
SET
	pizza_ingredients = REPLACE(pizza_ingredients, '?duja Salami', '''Nduja Salami')
WHERE
	pizza_ingredients LIKE '%?duja Salami%'; 


SELECT DISTINCT
	pizza_ingredients
FROM 
	pizza_sales
WHERE
	pizza_ingredients LIKE '%''Nduja%';


-- Missing values & Duplicates

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

/* Data Analysis */

-- 1. What is the total revenue of Pizza Topia?
SELECT
	ROUND(SUM(total_price), 0) AS total_revenue
FROM 
	pizza_sales; -- 817860
	
-- 2. What is average order value (AOV) of Pizza Topia?

SELECT
	ROUND(SUM(total_price) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM 
	pizza_sales; -- 38.31
    
/* 
AOV (Average Order Value) - the average amount of revenue generated per customer order. 
It is a key metric used in business to understand customer spending habits and evaluate sales performance.

AOV = total revenue / Number of Unique Orders
*/


-- 3. What is average pizzas per order?  
SELECT
	ROUND(SUM(quantity) / COUNT(DISTINCT order_id), 0) AS avg_pizza_per_order
FROM 
	pizza_sales; -- 2


-- 4. How many repeat orders does each pizza have, ranked from the highest to the lowest?  
WITH repeat_orders AS (
	SELECT 
		pizza_name,
        pizza_category,
		order_id,
		COUNT(order_id) AS total_order
	FROM 
		pizza_sales
	GROUP BY 
		pizza_name,
        pizza_category,
        order_id
	HAVING 
		COUNT(order_id) > 1 
)
SELECT
	pizza_name,
    pizza_category,
    COUNT(DISTINCT order_id) AS total_repeat_order -- Use the DISTINCT operator to ensure the count is accurate and to prevent duplicate entries from inflating the results
FROM 
	repeat_orders
GROUP BY 
	pizza_name,
    pizza_category
ORDER BY
	total_repeat_order DESC;
    
-- 5. What is each pizza category's revenue and its percentage of total revenue?
WITH total_pizza_revenue AS (
	SELECT
		SUM(total_price) AS total_revenue
	FROM 
		pizza_sales
)
SELECT
	pizza_category,
    ROUND(SUM(total_price), 0) AS category_total_revenue,
    ROUND(SUM(total_price) / (SELECT tpr.total_revenue FROM total_pizza_revenue tpr) * 100, 0) AS category_revenue_pct
FROM 
	pizza_sales
GROUP BY 
	pizza_category
ORDER BY 
	category_total_revenue DESC;

-- 6. Which are the top 3 best-selling pizzas, and what percentage of total revenue does each contribute?
WITH pizza_total_revenue AS (
	SELECT 
		SUM(total_price) AS total_revenue
	FROM 
		pizza_sales
),
revenue_rank AS (
	SELECT
		pizza_name,
        pizza_category,
		SUM(total_price) AS pizza_revenue,
		ROW_NUMBER() OVER (
			ORDER BY SUM(total_price) DESC
		) AS row_num
	FROM 
		pizza_sales
	GROUP BY 
		pizza_name,
        pizza_category
)
SELECT
	rr.pizza_name,
    rr.pizza_category,
    ROUND(rr.pizza_revenue, 0) AS pizza_revenue,
    ROUND((rr.pizza_revenue / ptr.total_revenue * 100), 1) AS pizza_revenue_pct
FROM 
	revenue_rank rr
CROSS JOIN
    pizza_total_revenue ptr
WHERE
	rr.row_num <= 3
ORDER BY 
	rr.pizza_revenue DESC;
    
SELECT
	*
FROM 
	pizza_sales
WHERE
	pizza_name_id = 'big_meat_s';

/* Another query

WITH total_revenue_by_pizza_name AS (
	SELECT 
		pizza_name,
        pizza_category,
        SUM(total_price) AS pizza_revenue 
	FROM 
		pizza_sales
	GROUP BY 
		pizza_name,
        pizza_category
),
pizza_total_revenue AS (
	SELECT
		SUM(total_price) AS total_revenue
	FROM 
		pizza_sales
)
SELECT
	tp.pizza_name,
    tp.pizza_category,
    ROUND(tp.pizza_revenue, 0) AS pizza_revenue,
	ROUND((tp.pizza_revenue / tr.total_revenue * 100), 1) AS pizza_revenue_pct
FROM 
	total_revenue_by_pizza_name tp
CROSS JOIN 
    pizza_total_revenue tr
ORDER BY 
	tp.pizza_revenue DESC
LIMIT 3;

*/

-- 7. Which pizza and size combination is ordered most frequently on weekdays compared to weekends? 
WITH day_summary AS (
	SELECT
		pizza_name_id,
        pizza_category,
        CASE
			WHEN DAYOFWEEK(order_date) IN (1, 7) THEN 'Weekend' -- Sunday (1) and Saturday (7)
            ELSE 'Weekday'
		END AS day_type,
        COUNT(*) AS total_order
	FROM
		pizza_sales 
	GROUP BY 
		day_type,
		pizza_name_id,
        pizza_category
),
top_pizza AS (
	SELECT
		pizza_name_id,
        day_type,
        total_order,
        pizza_category,
        ROW_NUMBER() OVER (
			PARTITION BY day_type
            ORDER BY total_order DESC 
		) AS row_num
	FROM 
		day_summary
)
SELECT
	pizza_name_id,
    pizza_category,
	day_type,
	total_order
FROM 
	top_pizza
WHERE
	row_num = 1;

-- 8. Hourly trend for total pizza sold & total_order
SELECT
	HOUR(order_time) AS hour_of_order,
    COUNT(order_id) AS total_order,
    SUM(total_price) AS total_revenue
FROM 
	pizza_sales
GROUP BY 
	hour_of_order
ORDER BY 
	-- hour_of_order;
	total_revenue DESC;  

-- 9. Day-of-week trend for total orders 
SELECT
	DAYNAME(order_date) AS day_of_week,
    COUNT(order_id) AS total_order,
    SUM(total_price) AS total_revenue
FROM 
	pizza_sales
GROUP BY 
	day_of_week
ORDER BY
	-- FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');
	total_revenue DESC;

-- 10. Weekend vs Weekday Analysis
SELECT
	CASE 
		WHEN DAYOFWEEK(order_date) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
	END AS day_name,
    COUNT(order_id) AS total_orders,
    SUM(total_price) AS total_revenue
FROM 
	pizza_sales
GROUP BY 
	day_name
ORDER BY 
	total_revenue DESC;

-- 11. Monthly trend Analysis 
SELECT
	CASE
		WHEN MONTH(order_date) = 1 THEN 'Jan'
        WHEN MONTH(order_date) = 2 THEN 'Feb'
        WHEN MONTH(order_date) = 3 THEN 'Mar'
        WHEN MONTH(order_date) = 4 THEN 'Apr'
        WHEN MONTH(order_date) = 5 THEN 'May'
        WHEN MONTH(order_date) = 6 THEN 'Jun'
        WHEN MONTH(order_date) = 7 THEN 'Jul'
        WHEN MONTH(order_date) = 8 THEN 'Aug'
        WHEN MONTH(order_date) = 9 THEN 'Sep'
        WHEN MONTH(order_date) = 10 THEN 'Oct'
        WHEN MONTH(order_date) = 11 THEN 'Nov'
        WHEN MONTH(order_date) = 12 THEN 'Dec'
	END AS order_month,
    COUNT(order_id) AS total_orders,
    SUM(total_price) AS total_revenue
FROM 
	pizza_sales
GROUP BY 
	order_month
ORDER BY 
	-- FIELD(order_month, 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
    total_revenue DESC;