# Introduction 



# Problem Statement


# Tools 


# Analysis 
For this project, each query was designed to explore specific requirements of Pizza Topia. Here's the approach I took for addressing each question:

### 1. Find a total revenue of Pizza Topia

```sql
SELECT
	ROUND(SUM(total_price), 0) AS total_revenue
FROM 
	pizza_sales;
```
| total_revenue |
|---------------|
| 817860        |





