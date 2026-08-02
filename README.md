# Superstore-Sales-Analytics-MySQL-Power-BI

An end-to-end data analytics project on the classic Superstore retail dataset. Raw sales data is cleaned and modeled in MySQL, business-analysis queries are written in SQL, and the results are visualized in an interactive Power BI dashboard.

Dashboard preview

<img width="1135" height="743" alt="Screenshot 2026-08-01 182431" src="https://github.com/user-attachments/assets/bad31109-cb06-4fa4-b604-8bc0535b91e7" />

Project overview:

The goal of this project was to take a messy flat CSV (SuperStore_Sales_Dataset) export and turn it into a normalized relational database, then build a KPI dashboard that answers core retail questions:

What are total sales,
profit, 
orders,
return rate at a glance?
How does sales performance trend month over month?
Which regions and states drive the most revenue?
Which categories, sub-categories, and products are profitable — and which are causing losses?
How much are returns cutting into profit?
Who are the top customers, and how does revenue split by segment?


## 🔄 Data Pipeline

CSV → MySQL (temp table) → Data Cleaning → Fact & Dimension Tables → KPI Queries / Views → Power BI → Dashboard

Tech stack:

Layer                 	Tool
Database         	      MySQL 8.0
Data loading          	LOAD DATA INFILE from a staging table
Analysis	              SQL (joins, window functions, CTEs, views)
Visualization           Power BI Desktop
Data connection	        Power BI connected directly to MySQL via SQL Server/ODBC connector

Data model:

The raw CSV (SuperStore_Sales_Dataset) is a single flat, denormalized export — one row per order line, with customer, product, and order attributes all repeated on every row. The project's first job was turning that into a proper relational schema.

Staging table:
All raw columns are loaded as-is into table temp_superstore via LOAD DATA INFILE. Nothing is cleaned or split at this stage — it exists purely so the normalization queries  have a single, disposable source .


#SQL analysis performed:

KPI view — a single KPI view exposing total sales, profit, quantity, orders, customers, average order value, sales per customer, and profit margin, so Power BI (or any BI tool) can pull one clean summary source.

Top 10 customers by sales.

Loss-making products — products with negative total profit despite non-zero sales.

Return impact analysis — joins orders, products, and returns to quantify how many returns each product had and whether returns correlate with reduced profit.

Return rate per product — COUNT(DISTINCT returned orders) / COUNT(DISTINCT orders) * 100.

Monthly sales trend with running total — window function (SUM() OVER) for cumulative sales by month.

Month-over-month growth % — LAG() window function comparing each month to the previous one.

Top 3 products per category — DENSE_RANK() OVER (PARTITION BY category ...).

Sales by category.



#Power BI dashboard:

The dashboard ("Superstore Performance Overview") includes:

KPI cards: Total Sales, Total Profit, Total Orders, Return Rate
Region slicer (Central / East / South) to filter the whole page
Monthly Sales trend line chart
Sales by Segment donut (Consumer / Corporate / Home Office)
Sales and Profit by state map
Top 10 Customers bar chart
Top 3 products per Category bar chart
Total Profit by Category bar chart

Relationships between customers, products, orders, and returns are modeled in Power BI matching the MySQL foreign keys, with a dedicated Date table for time intelligence.


Key insights surfaced:

Overall business is profitable, but profit margin lags sales growth in some months, pointing to cost or discount pressure worth investigating further.

A small set of sub-categories account for disproportionate losses despite healthy sales volume — the classic Superstore "profitable-looking category, unprofitable sub-category" pattern.

Returns are concentrated in a handful of products, and those products also tend to have below-average profit — suggesting returns are a real (not just cosmetic) drag on profitability.


##  Key Learnings

- Data modeling using fact and dimension tables
- Writing optimized SQL queries and views
- Using SQL for KPI calculations instead of DAX
- Connecting MySQL with Power BI
- Designing interactive dashboards




