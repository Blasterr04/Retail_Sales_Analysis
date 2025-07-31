-- Create TABLE
CREATE TABLE retail_sales
  (
	transactions_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,	
	gender VARCHAR(15),
	age	INT,
	category VARCHAR(25),	
	quantiy	INT,
	price_per_unit FLOAT,	
	cogs FLOAT,
	total_sale FLOAT
  );

--data cleaning--
select * from retail_sales
LIMIT 10

select COUNT(*) from retail_sales

select * from retail_sales
WHERE transactions_id IS NULL

select * from retail_sales
WHERE sale_date IS NULL

ALTER TABLE retail_sales
RENAME COLUMN quantiy TO quantity;

select * from retail_sales
where 
	transactions_id is null
	or
	sale_date is null
	or
	sale_time is null
	or
	gender is null
	or
	category is null
	or
	quantity is null
	or 
	price_per_unit is null
	or
	cogs is null
	or
	total_sale is null
--
delete from retail_sales
where 
	transactions_id is null
	or
	sale_date is null
	or
	sale_time is null
	or
	gender is null
	or
	category is null
	or
	quantity is null
	or 
	price_per_unit is null
	or
	cogs is null
	or
	total_sale is null

--data exploration--

--how many sales we have?
select count(*) as total_sales from retail_sales

--how many unique customers we have?
select count(distinct customer_id) as total_sales from retail_sales

--how many unique category we have ?
select distinct category from retail_sales

--DATA ANALYSIS & BUSINESS KEY PROBLEMS & ANSWERS
-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022
select * from retail_sales
where category = 'Clothing' AND TO_CHAR(sale_date,'YYYY-MM') = '2022-11' AND quantity >=3

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
select category,sum(total_sale) as net_sale,
count(*) as total_orders
from retail_sales
group  by 1

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
select round(avg(age),2) as avg_age from retail_sales
where category = 'Beauty'

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
select * from retail_sales
where total_sale>1000

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
select category,gender,count(*) as total_tran from retail_sales
group by category,gender
order by 1

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
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

--2nd method
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

--3rd method
SELECT DISTINCT ON (EXTRACT(YEAR FROM sale_date)) 
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    AVG(total_sale) AS avg_sales
FROM retail_sales
GROUP BY 1, 2
ORDER BY EXTRACT(YEAR FROM sale_date), AVG(total_sale) DESC;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
select customer_id,sum(total_sale) as total_sales from retail_sales
group by 1
order by 2 desc

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
select category,count(distinct customer_id) from retail_sales
group by category

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
--Create a CTE (Common Table Expression) with shift classification
with hourly_sales as (
    select *,
        case
            when extract(hour from sale_time) < 12 then 'morning'       -- before 12 pm
            when extract(hour from sale_time) between 12 and 17 then 'afternoon'  -- 12 pm to 5 pm
            else 'evening'                                              -- after 5 pm
        end as shift                                                    -- label each row with time-of-day shift
    from retail_sales
)
select 
    shift,
    count(*) as total_orders
from hourly_sales
group by shift;