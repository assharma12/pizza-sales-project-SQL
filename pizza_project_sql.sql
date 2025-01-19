 -- Basics
 -- Retrieve the total number of orders placed.
 
SELECT 
    COUNT(*) AS total_orders
FROM
    orders
 
 -- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
    
    -- Identify the highest-priced pizza.
 
SELECT 
    pt.name, MAX(p.price) AS highest_price
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY 2 DESC
LIMIT 1
 
 -- Identify the most common pizza size ordered.
select p.size,count(od.quantity) as no_of_count
from pizzas as p join order_details as od on p.pizza_id = od.pizza_id
group by p.size
order by 2 desc 
limit 1

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(od.quantity) AS total_quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY 2 DESC
LIMIT 5


-- intermediate
-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY 2 DESC
 
 -- Determine the distribution of orders by hour of the day

SELECT 
    HOUR(time) AS hours, COUNT(order_Id) AS order_count
FROM
    orders
GROUP BY HOUR(time)
 
-- Join relevant tables to find the category-wise distribution of pizzas
 
SELECT 
    category, COUNT(*) AS category_count
FROM
    pizza_types
GROUP BY category

-- Group the orders by date and calculate the average number of pizzas ordered per day
 
SELECT 
    ROUND(AVG(total_quantity), 0) AS avg_qnt_per_day
FROM
    (SELECT 
        o.date, SUM(od.quantity) AS total_quantity
    FROM
        orders AS o
    JOIN order_details AS od ON o.order_id = od.order_id
    GROUP BY o.date) AS order_quantity

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name AS name,
    ROUND(SUM(p.price * od.quantity), 0) AS revenue
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3


-- HARD
-- Calculate the percentage contribution of each pizza type to total revenue.
WITH CTE AS(
SELECT 
    pt.category AS category,
    SUM(od.quantity * p.price)   AS revenue 
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
) 
SELECT category,round(revenue/(select sum(od.quantity*p.price)
from pizzas p join order_details od on p.pizza_id = od.pizza_id)*100,2) as revenue_percentage
FROM CTE
 
 -- Analyze the cumulative revenue generated over time.

with cte as (
SELECT 
    o.date, SUM(od.quantity * p.price) AS revenue
FROM
    pizzas AS p
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
        JOIN
    orders AS o ON o.order_id = od.order_id
GROUP BY o.date)
select date,sum(revenue) over(order by date) as cum_revenue
from cte  


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
with revenue as (
SELECT 
    pt.category, pt.name, SUM(od.quantity * p.price) AS revenue
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY 1 , 2),
ranking_cte as (
select category,name, 
                 dense_rank() over(partition by category order by revenue desc) as rnking
                     from revenue)
select name,category
       from ranking_cte
                  where rnking <=3



































































































