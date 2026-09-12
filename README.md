# Superstore Sales Analytics (MySQL + Power BI)

An end-to-end data analytics project on the classic Superstore retail
dataset. Raw sales data is cleaned and modeled in MySQL, business
questions are answered in SQL, and the results are visualized in an
interactive Power BI dashboard.

![Dashboard preview](https://github.com/user-attachments/assets/bad31109-cb06-4fa4-b604-8bc0535b91e7)

## Project overview

The goal: take a messy, flat CSV export and turn it into a normalized
relational database, then build a KPI dashboard that answers the
questions a retail stakeholder actually asks:

- What are total sales, profit, orders, and return rate at a glance?
- How does sales performance trend month over month?
- Which regions and states drive the most revenue?
- Which categories, sub-categories, and products are profitable —
  and which are causing losses?
- How much are returns cutting into profit?
- Who are the top customers, and how does revenue split by segment?

## Data pipeline

```
CSV → MySQL (staging table) → Data cleaning → Fact & dimension tables
    → KPI queries / views → Power BI → Dashboard
```

| Layer | Tool |
|---|---|
| Database | MySQL 8.0 |
| Data loading | `LOAD DATA INFILE` into a staging table |
| Analysis | SQL — joins, window functions, CTEs, views |
| Visualization | Power BI Desktop |
| Data connection | Power BI connected directly to MySQL (ODBC/SQL Server connector) |

## Data model

The raw CSV is a single flat, denormalized export — one row per order
line, with customer and product attributes repeated on every row. The
project's first job is turning that into a proper relational schema:

- All raw columns load as-is into `temp_superstore` via
  `LOAD DATA INFILE` — a disposable staging table, nothing is cleaned
  or split at this stage.
- From there, `customers`, `products`, `orders`, and `returns` are
  built as normalized fact/dimension tables, deduplicated with
  `GROUP BY` + `MAX()` since the source `customer_id`/`product_id`
  values repeat across rows.

## Setup — how to run this

1. Run the schema + data-load section of `main.sql` up through the
   `INSERT INTO orders ...` / `INSERT INTO returns ...` statements —
   this creates `superstore`, the staging table, and the four
   normalized tables, then populates them from the CSV.
2. Before running `LOAD DATA INFILE`, update the file path to point
   at your own copy of the dataset, and use forward slashes even on
   Windows (`C:/path/to/file.csv`) — MySQL treats `\` inside string
   literals as an escape character, so Windows-style backslash paths
   can silently break. Check `SHOW VARIABLES LIKE 'secure_file_priv'`
   first if you hit a permissions error — MySQL will only read files
   from that folder unless you're using `LOAD DATA LOCAL INFILE`
   (which needs `local_infile` enabled server-side *and* client-side).
3. Run the rest of `main.sql` for the KPI view and analysis queries.
4. Open `Superstore.pbix` in Power BI Desktop and point its data
   source at your MySQL instance (Get Data → MySQL database).

## SQL analysis performed

- **KPI view** — one view exposing total sales, profit, quantity,
  orders, customers, average order value, sales per customer, and
  profit margin, so Power BI (or any BI tool) pulls from a single
  clean summary source.
- **Top 10 customers by sales**
- **Loss-making products** — products with negative total profit
  despite non-zero sales
- **Return impact analysis** — joins orders, products, and returns to
  quantify how many returns each product had and whether returns
  correlate with reduced profit
- **Return rate per product** —
  `COUNT(DISTINCT returned orders) / COUNT(DISTINCT orders) * 100`
- **Monthly sales trend with running total** — `SUM() OVER` for
  cumulative sales by month
- **Month-over-month growth %** — `LAG()` comparing each month to the
  previous one
- **Top 3 products per category** —
  `DENSE_RANK() OVER (PARTITION BY category ...)`
- **Sales by category**

## Power BI dashboard

The dashboard ("Superstore Performance Overview") includes:

- KPI cards: Total Sales, Total Profit, Total Orders, Return Rate
- Region slicer (Central / East / South) filtering the whole page
- Monthly sales trend line chart
- Sales by Segment donut (Consumer / Corporate / Home Office)
- Sales and Profit by state map
- Top 10 Customers bar chart
- Top 3 products per Category bar chart
- Total Profit by Category bar chart

Relationships between customers, products, orders, and returns are
modeled in Power BI matching the MySQL foreign keys, with a dedicated
Date table for time intelligence.

## Key insights

- Overall business is profitable, but profit margin lags sales growth
  in some months — pointing to cost or discount pressure worth
  investigating further.
- A small set of sub-categories account for disproportionate losses
  despite healthy sales volume — the classic Superstore
  "profitable-looking category, unprofitable sub-category" pattern.
- Returns are concentrated in a handful of products, and those
  products also tend to have below-average profit — returns are a
  real, not just cosmetic, drag on profitability.

## Key learnings

- Data modeling using fact and dimension tables
- Writing optimized SQL queries and views
- Using SQL for KPI calculations instead of DAX
- Connecting MySQL with Power BI
- Designing interactive dashboards
