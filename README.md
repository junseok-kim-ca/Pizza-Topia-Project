# Introduction 



# Problem Statement


# Tools 


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


