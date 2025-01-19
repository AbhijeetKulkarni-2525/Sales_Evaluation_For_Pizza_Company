--Checking dataset
SELECT 
  * 
FROM 
  pizzas 
SELECT 
  * 
FROM 
  pizza_types 
SELECT 
  * 
FROM 
  orders 
SELECT 
  * 
FROM 
  order_details

--Calculate the total revenue from pizza sales

SELECT 
  ROUND(
    SUM(od.quantity * p.price), 
    2
  ) AS total_sales 
FROM 
  pizzas AS p 
  LEFT JOIN order_details AS od ON p.pizza_id = od.pizza_id


--Identify the highest priced pizza
SELECT 
  TOP 1 p.pizza_type_id, 
  p.price, 
  pt.name 
FROM 
  pizzas AS p 
  LEFT JOIN pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id 
ORDER BY 
  p.price DESC

--Identify the most common pizza size ordered
SELECT 
  TOP 1 pizzas.size AS pizza_size, 
  COUNT(order_details.order_details_id) AS most_common_size_ordered
FROM 
  pizzas 
  LEFT JOIN order_details ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY 
  pizzas.size

--List the 5 top pizza types along with their quantities
SELECT 
  TOP 5 pizza_types.name AS pizza_type, 
  COUNT(order_details.quantity) AS quantities_ordered 
FROM 
  pizzas 
  JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id 
  JOIN order_details ON order_details.pizza_id = pizzas.pizza_id 
GROUP BY 
  pizza_types.name 
ORDER BY 
  quantities_ordered DESC

--Find the total quantity of each pizza category ordered
SELECT 
  pt.category, 
  SUM(od.quantity) AS quantities_ordered 
FROM 
  pizzas AS p 
  JOIN pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id 
  JOIN order_details as od ON p.pizza_id = od.pizza_id 
GROUP BY 
  pt.category 
ORDER BY 
  quantities_ordered DESC

--Determine the distribution of orders by hour of the day

SELECT 
  DATEPART(HOUR, time) AS hour_of_the_day, 
  COUNT(order_id) AS count_of_total_orders 
FROM 
  orders 
GROUP BY 
  DATEPART(HOUR, time) 
ORDER BY 
  DATEPART(HOUR, time) ASC

--Find number of pizzas types in each category
SELECT 
  category, 
  COUNT(pizza_type_id) AS num_pizzas
FROm 
  pizza_types 
GROUP BY 
  category 
ORDER BY 
  category DESC

--Calculate average number of pizzas ordered per day 
SELECT 
  AVG(quantity_ordered) AS average_quantity_ordered 
FROM 
  (
    SELECT 
      orders.date, 
      SUM(quantity) AS quantity_ordered 
    FROM 
      orders 
      JOIN order_details ON orders.order_id = order_details.order_id 
    GROUP BY 
      orders.date
  ) AS order_quantity;


--Determine top 3 pizzas based on the revenue

SELECT 
  TOP 3 pizza_types.name, 
  SUM(
    pizzas.price * order_details.quantity
  ) AS revenue 
FROM 
  pizzas 
  JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id 
  JOIN order_details ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY 
  pizza_types.name 
ORDER BY 
  revenue DESC

--Calculate the % contribution of each pizza category to the total revenue
WITH sum_of_total_revenue AS (
  SELECT 
    SUM(
      pizzas.price * order_details.quantity
    ) AS total_revenue 
  FROM 
    pizzas 
    JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
) 
SELECT 
  pizza_types.category, 
  (
    SUM(
      pizzas.price * order_details.quantity
    )* 1.0 / (
      SELECT 
        total_revenue 
      FROM 
        sum_of_total_revenue
    )
  )* 100 AS revenue 
FROM 
  pizzas 
  JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id 
  JOIN order_details ON pizzas.pizza_id = order_details.pizza_id CROSS 
  JOIN sum_of_total_revenue 
GROUP BY 
  pizza_types.category 
ORDER BY 
  revenue DESC


--Calculate cumulative revenue generated over time
SELECT 
  date, 
  SUM(revenue) OVER (
    ORDER BY 
      date
  ) as cumulative_revenue 
FROM 
  (
    SELECT 
      date, 
      SUM(
        pizzas.price * order_details.quantity
      ) AS revenue 
    FROM 
      pizzas 
      JOIN order_details ON order_details.pizza_id = pizzas.pizza_id 
      JOIN orders ON orders.order_id = order_details.order_id 
    GROUP BY 
      date
  ) AS sales


--Determine top 3 pizzas based on revenue from each category 
SELECT 
  name, 
  revenue 
FROM 
  (
    SELECT 
      category, 
      name, 
      revenue, 
      RANK() OVER (
        PARTITION BY category 
        ORDER BY 
          revenue DESC
      ) AS top_selling_pizzas 
    FROM 
      (
        SELECT 
          category, 
          name, 
          SUM(
            pizzas.price * order_details.quantity
          ) AS revenue 
        FROM 
          pizzas 
          JOIN order_details ON order_details.pizza_id = pizzas.pizza_id 
          JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
        GROUP BY 
          category, 
          name
      ) AS total_revenue
  ) AS top_pizzas_by_each_category 
WHERE 
  top_selling_pizzas <= 3

     




