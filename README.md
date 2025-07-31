# Retail Sales Analysis SQL Project

**Project Title**: Retail Sales Analysis  

## Project Structure

## 1. Database Configuration

- **Database Initialization**: Created a database named `Retail-Sales-Analysis` to support comprehensive sales analytics
- **Table Schema**: Established `retail_sales` table with optimized structure for transaction analysis

```sql
CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records present in the dataset.
- **Customer Count**: Calculate the number of unique customers.
- **Category Count**: List all unique product categories available.
- **Null Handling**: Inspect the dataset for missing or null entries and eliminate incomplete records to ensure data quality.


```sql
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

DELETE FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05**:
```sql
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';
```

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022**:
```sql
select * from retail_sales
where category = 'Clothing' AND TO_CHAR(sale_date,'YYYY-MM') = '2022-11' AND quantity >=3
```

3. **Write a SQL query to calculate the total sales (total_sale) for each category.**:
```sql
select category,sum(total_sale) as net_sale,
count(*) as total_orders
from retail_sales
group  by 1
```

4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.**:
```sql
select round(avg(age),2) as avg_age from retail_sales
where category = 'Beauty'
```

5. **Write a SQL query to find all transactions where the total_sale is greater than 1000.**:
```sql
select * from retail_sales
where total_sale>1000
```

6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
select category,gender,count(*) as total_tran from retail_sales
group by category,gender
order by 1
```

7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
```sql
-- Ranking Method
SELECT year,month,avg_sale FROM
(
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM sale_date) 
            ORDER BY AVG(total_sale) DESC
        ) AS month_rank
    FROM retail_sales
    GROUP BY 1, 2
) AS t1
WHERE month_rank = 1;

-- CTE Approach
WITH monthly_avg_sales AS (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,             
        EXTRACT(MONTH FROM sale_date) AS month,           
        AVG(total_sale) AS avg_sales,                     
        ROW_NUMBER() OVER (
            PARTITION BY EXTRACT(YEAR FROM sale_date)     
            ORDER BY AVG(total_sale) DESC                 
        ) AS rank
    FROM retail_sales
    GROUP BY 1, 2                                         
)
SELECT * FROM monthly_avg_sales
WHERE rank = 1;   

-- DISTINCT ON Technique
SELECT DISTINCT ON (EXTRACT(YEAR FROM sale_date)) 
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    AVG(total_sale) AS avg_sales
FROM retail_sales
GROUP BY 1, 2
ORDER BY EXTRACT(YEAR FROM sale_date), AVG(total_sale) DESC;
```

8. **Write a SQL query to find the top 5 customers based on the highest total sales **:
```sql
select customer_id,sum(total_sale) as total_sales from retail_sales
group by 1
order by 2 desc
limit 5
```

9. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql
SELECT 
    category,    
    COUNT(DISTINCT customer_id) as cnt_unique_cs
FROM retail_sales
GROUP BY category
```

10. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
with hourly_sales as (
    select *,
        case
            when extract(hour from sale_time) < 12 then 'Morning'
            when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
            else 'Evening'
        end as shift
    from retail_sales
)
select 
    shift,
    count(*) as total_orders
from hourly_sales
group by shift;
```

## Findings

- **Shopping Habits**: We discovered that different age groups and genders shop differently
- **Big Spenders**: Found purchases where people spent over $1000 in a single transaction
- **Busy Times**: Noticed that sales go up and down throughout the year, with certain months being busier
- **Best Customers**: Identified our top-spending customers and which products people like most


## Reports

- **Sales Scorecards**: Easy-to-read reports showing total sales, who's buying (age/gender), and which products sell best
- **Sales Patterns**: Charts showing busy months and times of day when people shop most
- **Customer Reports**: Lists of our most valuable customers and counts of unique shoppers for each product type
  
## Conclusion

This project shows how we can use sales data to understand customer behavior and improve business decisions. By analyzing shopping patterns, we can:
- Stock the right products at the right time
- Create better marketing to target different customer groups
- Reward our most loyal customers
- Ultimately increase sales and customer satisfaction.
