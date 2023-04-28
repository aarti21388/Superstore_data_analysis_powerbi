-- #Write an SQL query to solve the given problem statement.
-- What percentage of total orders were shipped on the same date?

SELECT ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM superstore),1) AS Same_Day
FROM superstore
WHERE Order_date = Ship_date;

-- Write an SQL query to solve the given problem statement.
-- #Name top 3 customers with highest total value of orders.

SELECT Customer_Name,sum(Sales) as s FROM `superstore` GROUP by Customer_Name order by s desc limit 3

-- Write an SQL query to solve the given problem statement.
-- Find the top 5 items with the highest average sales per day.


SELECT Product_ID,avg(Sales) as 
avarage_sale FROM `superstore` GROUP by Product_ID order by avarage_sale desc limit 5

-- Write an SQL query to solve the given problem statement.
-- Write a query to find the average order value for each customer, 
-- and rank the customers by their average order value.

SELECT Customer_ID,Customer_Name, avg(Sales) as Avg_Order_Value, RANK() OVER(order by avg(Sales) desc) from superstore
GROUP by Customer_ID,Customer_Name
order by Avg_Order_Value desc

-- Write an SQL query to solve the given problem statement.
-- Give the name of customers who ordered highest and lowest orders from each city.

select city,
max(case when rank_highest_sales=1 then total_sales end) as higest_orders,
max(case when rank_lowest_sales=1 then total_sales end) as lowest_orders,
max(case when rank_highest_sales=1 then customer_Name end) as High_Customer_Name,
max(case when rank_lowest_sales=1 then customer_Name end) as low_customer_name 
from(
SELECT *,
RANK() OVER (PARTITION BY city ORDER BY total_sales DESC) AS rank_highest_sales,
RANK() OVER (PARTITION BY city ORDER BY total_sales ASC) AS rank_lowest_sales
FROM
(SELECT customer_name, city, SUM(sales) AS total_sales FROM superstore GROUP BY 1,2) AS rank_sales) as C GROUP by 1

-- Write an SQL query to solve the given problem statement.
-- What is the most demanded sub-category in the west region?

select Sub_Category,sum(Sales) as total_sales from superstore where Region='West' GROUP by Sub_Category order by total_sales desc limit 1

-- Write an SQL query to solve the given problem statement.
-- Which order has the highest number of items? And which order has the highest cumulative value?

select Order_ID,COUNT(Order_ID)as total_orders from superstore GROUP by Order_ID Order by total_orders desc limit 1 

-- Write an SQL query to solve the given problem statement.
-- Which order has the highest cumulative value?

select order_id, sum(sales) as total_sales from superstore group by order_id order by total_sales desc limit 1

-- Write an SQL query to solve the given problem statement.
-- Which segment’s order is more likely to be shipped via first class?

select Segment from superstore where Ship_Mode='First Class' GROUP by Segment ORDER by count(Order_ID) desc limit 1

-- Write an SQL query to solve the given problem statement.
-- Which city is least contributing to total revenue?

select sum(Sales), city from superstore GROUP by city order by sum(sales) limit 1

-- Write an SQL query to solve the given problem statement.
-- What is the average time for orders to get shipped after order is placed?

SELECT cast(avg(DATEDIFF(Ship_Date, Order_Date)) as decimal(10,8)) AS avg_ship_time FROM superstore;

-- Write an SQL query to solve the given problem statement.
-- Which segment places the highest number of orders from each state and which segment places the largest individual orders from each state?
with CTE1 as (
  select state, segment, count(distinct order_id) as cnt 
  from superstore 
  group by state, segment 
  order by state, segment, cnt desc
),
CTE2 as (
  select state, segment, order_id, sum(sales) as Totalsales 
  from superstore 
  group by state, segment, order_id 
  order by state, Totalsales desc
)
select aa.state, aa.segment as 'Highest Order Segment', bb.segment as 'Largest Order Segment' 
from 
  (select CTE1.state state, segment 
  from CTE1, 
    (select state, max(cnt) as cnt 
    from CTE1 
    group by state) as b 
  where CTE1.state = b.state and CTE1.cnt = b.cnt) as aa,
  
  (select CTE2.state state, CTE2.segment 
  from CTE2, 
    (select state, max(TotalSales) as MaxSale 
    from CTE2 
    group by state) as b
  where CTE2.state = b.state and CTE2.Totalsales = b.MaxSale) as bb
where aa.state = bb.state;

-- Write an SQL query to solve the given problem statement.
-- Find all the customers who individually ordered on 3 consecutive days where each day’s total order was more than 50 in value. **

select t1.customer_id, t1.t1_sales,t2.t2_sales,t3.t3_sales, 
t1.order_date,t2.order_date,t3.order_date FROM
(select customer_id,order_date,sum(sales) 
as t1_sales from superstore GROUP by customer_id,order_date order by customer_id)as t1 
join (select customer_id,order_date,sum(sales) as t2_sales from 
superstore GROUP by customer_id,order_date order by customer_id) t2 on
t2.order_date=date_add(t1.order_date,interval 1 DAY) and t1.customer_id=t2.customer_id 
join(select customer_id,order_date,sum(sales) as t3_sales from superstore GROUP by customer_id,order_date order by customer_id)as t3 
on t3.order_date=date_add(t1.order_date,interval 2 DAY) and t1.customer_id=t3.customer_id GROUP by t1.customer_id,t1.order_date,t2.order_date,t3.order_date 
having t1.t1_sales>50 and t2.t2_sales>50 and t3.t3_sales>50

-- Write an SQL query to solve the given problem statement.
-- Find all the customers who individually ordered on 3 consecutive days where each day’s total order was more than 50 in value. **

select count(*) as 'max_num'
FROM(select t1.order_date,t1.sum_sales,LAG(t1.sum_sales) over(order by t1.order_date) as
prev_sales from superstore t2, (select sum(sales) as sum_sales,order_date from superstore
GROUP BY order_date order by order_date)t1
where t1.order_date=t2.Order_Date group by t2.Order_Date) t3 where sum_sales>prev_sales