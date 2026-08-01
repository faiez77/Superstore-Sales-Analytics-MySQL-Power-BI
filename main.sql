create database superstore;
USE superstore;

CREATE TABLE customers (
customer_id varchar(20) primary key,
customer_name varchar(100),
segment varchar(50),
country varchar(50),
city varchar(50),
state varchar(50),
region varchar(50)
);

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255)
);

CREATE TABLE orders (
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    sales DECIMAL(10,2),
    quantity INT,
    profit DECIMAL(10,2),

    PRIMARY KEY (order_id, product_id),

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
ALTER TABLE superstore.orders
ADD Payment_Mode varchar(20);
 

CREATE TABLE returns (
    order_id VARCHAR(50) PRIMARY KEY,
    returned VARCHAR(10)
);

select database();
show tables;
describe orders;

CREATE TABLE temp_superstore (
    order_id VARCHAR(20),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(20),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    region VARCHAR(50),
    product_id VARCHAR(20),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255),
    sales DECIMAL(10,2),
    quantity INT,
    profit DECIMAL(10,2),
    returned VARCHAR(10),
    Payment_Mode varchar(20)
);

show variables like "secure_file_priv";
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/SuperStore_Sales_Dataset - Copy.csv'
INTO TABLE temp_superstore
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

INSERT INTO customers (
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    region
)
SELECT DISTINCT
    customer_id,
    Max(customer_name),
    Max(segment),
    Max(country),
   Max(city),
    Max(state),
   Max(region)
FROM temp_superstore
group by customer_id;

-- we used group by and max - because customer id is primary key but duplicated are present and max used for other like city 

INSERT INTO products (
    product_id,
     category,
    sub_category,
    product_name
)
SELECT 
    product_id,
    MAX(category),
    MAX(sub_category),
    MAX(product_name)
FROM temp_superstore
GROUP BY product_id;


INSERT INTO orders (
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    product_id,
    sales,
    quantity,
    profit,
    Payment_Mode
)
SELECT 
    order_id,
    max(order_date),    
    max(ship_date),      
   max(ship_mode),
    max(customer_id),
    product_id,
    sum(sales),
	sum(quantity),
    sum(profit),
    max(Payment_Mode)
FROM temp_superstore
group by order_id , product_id;


INSERT INTO  returns(order_id , returned)
SELECT DISTINCT 
              order_id,
			CASE 
            WHEN returned ='1' THEN 1
            END
FROM temp_superstore 
WHERE returned ='1' ;



-- top customers by sale

SELECT 
    c.customer_id,
    c.customer_name,
    SUM(o.sales) AS total_sales
FROM orders o
JOIN customers c 
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_sales DESC
LIMIT 10;

-- product causing loss
SELECT 
   p.product_id,
   p.product_name,
   SUM(o.sales) AS Total_Sales,
   SUM(o.profit) AS Total_Profit
 FROM orders o
 join products p
  ON o.product_id = p.product_id
  GROUP BY p.product_id , p.product_name
  HAVING total_Profit < 0
  ORDER BY Total_Profit ASC;

-- return  analysis (are return impacting profit)

SELECT 
    p.product_name,
    COUNT(r.order_id) AS return_count,
    SUM(o.sales) AS total_sales,
    SUM(o.profit) AS total_profit
FROM orders o
JOIN products p 
    ON o.product_id = p.product_id
LEFT JOIN returns r 
    ON o.order_id = r.order_id
WHERE r.returned = '1'
GROUP BY p.product_name
ORDER BY return_count DESC;

-- return rate
SELECT 
    p.product_name,
    COUNT(DISTINCT r.order_id) * 100.0 / COUNT(DISTINCT o.order_id) AS return_rate
FROM orders o
JOIN products p 
    ON o.product_id = p.product_id
LEFT JOIN returns r 
    ON o.order_id = r.order_id
    GROUP BY p.product_name
ORDER BY return_rate DESC;


-- Monthly sales trend
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(sales) AS monthly_sales,
    SUM(SUM(sales)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) AS running_sales
FROM orders
GROUP BY month;

-- MOM
WITH monthly AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY month
)
SELECT 
    month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY month) AS prev_month_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (ORDER BY month)) 
        / LAG(total_sales) OVER (ORDER BY month) * 100, 
    2) AS growth_percentage
FROM monthly;

-- top 3 products in each category

WITH product_sales AS (
    SELECT 
        p.category,
        p.product_name,
        SUM(o.sales) AS total_sales
    FROM orders o
    JOIN products p 
        ON o.product_id = p.product_id
    GROUP BY p.category, p.product_name
)
SELECT *
FROM (
    SELECT 
        category,
        product_name,
        total_sales,
        DENSE_RANK() OVER (
            PARTITION BY category 
            ORDER BY total_sales DESC
        ) AS rnk
    FROM product_sales
) ranked
WHERE rnk <= 3;

-- KPI 
CREATE ViEW KPI AS 
SELECT 
   ROUND(SUM(sales),2) AS Total_Sales,
   ROUND(SUM(profit),2) AS Total_Profit,
    SUM(quantity) AS Total_Quantity,
   COUNT(DISTINCT order_id) AS Total_orders,
   COUNT(DISTINCT customer_id) AS Total_customers,
   ROUND(SUM(sales)/COUNT(DISTINCT order_id) , 2) AS Avg_Order_Value,
   ROUND(SUM(sales)/COUNT(DISTINCT customer_id) , 2) AS Sales_Per_Customer,
  ROUND(SUM(profit) * 100.0/SUM(sales) , 2) AS Profit_Margin
FROM orders;

-- sales by category
SELECT 
    p.category,
    SUM(sales) AS Total_Sales
FROM orders o 
JOIN products p
    ON o.product_id = p.product_id
GROUP BY p.category;



