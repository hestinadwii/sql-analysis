SELECT * FROM coffee_shop_sales;


-- Questions to Answer

-- 1. How much the total sales?
SELECT CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1), 'k') AS total_sales
FROM coffee_shop_sales;

-- if you want to specify the month
SELECT CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1), 'k') AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 3; -- March 

-- total sales for each store
SELECT CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1), 'k') AS total_sales
FROM coffee_shop_sales
GROUP BY store_id;

-- 2. What's the average transaction amount for each product category?
SELECT product_category, CONCAT(ROUND(AVG(unit_price * transaction_qty), 1), 'k') AS avg_transaction_amount
FROM coffee_shop_sales
GROUP BY product_category;

-- 3. Which product generated the highest revenue?
SELECT product_category, CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1), 'k') AS total_revenue
FROM coffee_shop_sales
GROUP BY product_category
ORDER BY total_revenue DESC;

-- 4. What is the total sales amount for each month of the year?
SELECT DATEPART(YEAR, transaction_date) AS year, DATEPART(MONTH, transaction_date) AS month, CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1), 'k') AS total_sales
FROM coffee_shop_sales
GROUP BY DATEPART(YEAR, transaction_date), DATEPART(MONTH, transaction_date)
ORDER BY year, month;

-- 5. How many transactions were made in each store location?
SELECT store_location, COUNT(transaction_id) AS transaction_count
FROM coffee_shop_sales
GROUP BY store_location;


