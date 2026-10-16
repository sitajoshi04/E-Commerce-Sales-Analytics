CREATE DATABASE ecommerce_sales;

-- 1. Which payment method is used most frequently
SELECT payment_method, COUNT(order_id) as frequency
FROM orders
GROUP BY payment_method
ORDER BY frequency DESC limit 1;

-- 2. Whcih product have price higher than the average product price
SELECT product_name,price
FROM products
WHERE price>
(SELECT AVG(price)
FROM products)
ORDER BY price DESC;

-- 3. What are the top 10 products by total revenue
SELECT p.product_name, ROUND(SUM(o.quantity*p.price),2) as total_revenue
FROM orders o JOIN products p
ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC LIMIT 10;

-- 4. How many orders and how much revenue were generated each month
SELECT MONTH(order_date) as month , COUNT(o.order_id), ROUND(SUM(o.quantity*p.price),2) as revenue
FROM orders o JOIN products p
ON o.product_id = p.product_id
GROUP BY month(order_date)
ORDER BY month;

-- 5. What are the top 10 customers by total spending
SELECT c.customer_id, SUM(o.quantity*p.price) as total_spending
FROM customers c JOIN orders o
ON c.customer_id = o.customer_id
JOIN products p ON p.product_id = o.product_id
GROUP BY c.customer_id
ORDER BY total_spending DESC LIMIT 10;

-- 6. Which city generated the highest revenue
SELECT c.city, ROUND(SUM(o.quantity*p.price),2) as total_revenue
FROM customers c JOIN orders o
ON c.customer_id = o.customer_id
JOIN products p ON p.product_id = o.product_id
GROUP BY city
ORDER BY total_revenue DESC LIMIT 1;

-- 7. How does revenue compare between loyalty members and non-loyalty members
SELECT
CASE
 WHEN c.loyalty_member = 1 THEN 'loyalty_member'
 ELSE 'non_loyalty_member' END AS customer_type,
ROUND(SUM(o.quantity*p.price),2) as total_revenue
FROM customers c JOIN orders o
ON c.customer_id = o.customer_id
JOIN products p ON p.product_id = o.product_id
GROUP BY CASE
 WHEN c.loyalty_member = 1 THEN 'loyalty_member'
 ELSE 'non_loyalty_member' END;
 
 -- 8 .Which customer have spending above the average customer spending
WITH consumer_spending as 
(SELECT o.customer_id, SUM(o.quantity*p.price) as total_spending
FROM orders o JOIN products p
ON o.product_id = p.product_id
GROUP BY o.customer_id)
SELECT customer_id, total_spending
FROM consumer_spending
WHERE total_spending> (SELECT AVG(total_spending) FROM consumer_spending)
ORDER BY total_spending DESC;

-- 9. What is the running total revenue over time
SELECT order_date, 
SUM(revenue) over(ORDER BY order_date) as cum_revenue
FROM
(SELECT o.order_date, SUM(o.quantity*p.price) as revenue
FROM orders o JOIN products p
ON o.product_id = p.product_id
GROUP BY o.order_date) as a;

-- 10. What are the top 3 products within each category by revenue
SELECT category, product_name, revenue
FROM
(SELECT category, product_name, revenue,
RANK() OVER (PARTITION BY category ORDER BY revenue DESC) as rn
FROM
(SELECT p.category, p.product_name, ROUND(SUM(o.quantity*p.price),2) as revenue
FROM orders o JOIN products p
ON o.product_id = p.product_id
GROUP BY p.category, p.product_name) as a) as b
WHERE rn<= 3;

-- End of Project