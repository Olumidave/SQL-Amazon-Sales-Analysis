# 🛒 Amazon Sales Analysis | SQL Data Analytics Project

> **A comprehensive SQL analytics project analyzing Amazon e-commerce sales data covering revenue performance, product rankings, customer segmentation, geographic distribution, and discount impact analysis using Microsoft SQL Server.**

---

## Table of Contents

- [Business Context & Objectives](#-business-context--objectives)
- [Data Sources & Preparation](#-data-sources--preparation)
- [Analytical Methodology & Approach](#-analytical-methodology--approach)
- [SQL Query Structure & Breakdown](#-sql-query-structure--breakdown)
- [Key Insights & Findings](#-key-insights--findings)
- [Product Performance Analysis](#-product-performance-analysis)
- [Customer Segmentation Analysis](#-customer-segmentation-analysis)
- [Geographic & Seller Analysis](#-geographic--seller-analysis)
- [Business Recommendations](#-business-recommendations)
- [Implementation, Monitoring & Next Steps](#-implementation-monitoring--next-steps)
- [Tools & Technologies](#-tools--technologies)
- [How to Run This Project](#-how-to-run-this-project)
- [Author](#-author)

---

## Business Context & Objectives

### The Business Problem
E-commerce platforms like Amazon generate millions of transactions daily. Without structured SQL analysis, critical business questions go unanswered which products are truly performing, which customers are most valuable, where revenue is concentrated geographically, and whether discounting is helping or hurting the business.

This project was built to answer those questions systematically using SQL transforming raw transactional data into structured business intelligence that can drive product, marketing, and operational decisions.

### Business Objectives

**1. Establish Core Revenue KPIs**
Calculate total revenue, delivered revenue, average order value, and unique customer counts as the baseline for all further analysis.

**2. Identify Top and Bottom Performing Products**
Rank products by units sold and revenue generated identifying stars to invest in and underperformers to review or discontinue.

**3. Analyse the Impact of Discounting**
Determine whether discounted products actually sell more than non-discounted products and whether discounting is helping revenue or compressing margins.

**4. Segment Customers by Value and Behaviour**
Identify high-value customers, repeat buyers, and purchase frequency patterns to support targeted retention and marketing strategies.

**5. Map Revenue Across Geographies**
Understand which countries and states generate the most revenue and where shipping costs are highest to inform logistics and market expansion decisions.

**6. Evaluate Seller and Brand Performance**
Identify which sellers and brands generate the highest revenue on the platform to support partnership and promotional decisions.

---

## 📂 Data Sources & Preparation

### Data Source
| Detail | Description |
|---|---|
| Database | Amazon (Microsoft SQL Server) |
| Table | `[Amazon].[dbo].[Amazon]` |
| Key Fields | OrderID, OrderDate, CustomerID, CustomerName, ProductName, Category, Brand, Quantity, UnitPrice, Discount, OrderStatus, PaymentMethod, SellerID, Country, State, ShippingCost |

### Data Preparation Steps

**Step 1 — Database Creation**
```sql
CREATE DATABASE Amazon;
```

**Step 2 — Duplicate Removal**
Duplicates were identified and removed using a CTE with ROW_NUMBER() keeping only the first occurrence of each OrderID:

```sql
WITH Duplicates AS (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY OrderDate) AS RN
    FROM Amazon
)
DELETE FROM Duplicates
WHERE RN > 1;
```

**Step 3 — Data Validation**
- Verified distinct CustomerNames to confirm data integrity
- Checked OrderStatus categories (Delivered, Cancelled, Pending, Returned)
- Validated that UnitPrice and Quantity fields contain no NULL or zero values
- Confirmed Discount field contains numeric values (not percentages)

**Revenue Calculation Logic:**
All revenue calculations use the formula:
```sql
SUM((Quantity * UnitPrice) - Discount) AS Total_Revenue
```
This ensures discount amounts are correctly deducted from gross revenue to give net revenue figures.

---

## Analytical Methodology & Approach

### The SQL Analysis Framework
This project is structured across **5 analytical layers** each building on the previous to move from basic KPIs to deep business intelligence:

```
Layer 1 - Core KPIs          (What is the baseline performance?)
       ↓
Layer 2 - Product Analysis   (Which products are driving and dragging performance?)
       ↓
Layer 3 - Discount Analysis  (Is discounting working?)
       ↓
Layer 4 - Customer Analysis  (Who are the most valuable customers?)
       ↓
Layer 5 - Geographic & Seller Analysis  (Where and who is driving revenue?)
```

### Key SQL Techniques Used

| Technique | Purpose |
|---|---|
| `CTE (WITH clause)` | Duplicate removal, product performance ranking, customer segmentation |
| `ROW_NUMBER()` | Identifying and removing duplicate orders |
| `RANK() OVER (ORDER BY)` | Ranking products by revenue and performance |
| `CASE WHEN` | Product tier classification, discount type categorisation |
| `WINDOW FUNCTIONS` | Order status percentage using `SUM(COUNT(*)) OVER()` |
| `SUBQUERIES` | Nested filtering for performance categories |
| `GROUP BY + HAVING` | Identifying repeat buyers and customer frequency |
| `TOP N` | Isolating top 10 and bottom 10 products |
| `AVG / SUM / COUNT` | Core KPI aggregation |

---

## SQL Query Structure & Breakdown

### Section 1 — Core Revenue KPIs

```sql
-- Total Revenue (all orders)
SELECT
    SUM((Quantity * UnitPrice) - Discount) AS Total_Revenue
FROM Amazon;

-- Total Revenue (delivered orders only)
SELECT
    SUM((Quantity * UnitPrice) - Discount) AS Total_Revenue
FROM Amazon
WHERE OrderStatus = 'Delivered';

-- Total Unique Orders
SELECT
    COUNT(DISTINCT OrderID) AS Total_Orders
FROM Amazon;

-- Average Order Value
SELECT
    SUM((Quantity * UnitPrice) - Discount) / COUNT(DISTINCT OrderID) AS Average_Order_Value
FROM Amazon;

-- Unique Customer Count
SELECT
    COUNT(DISTINCT CustomerID) AS Total_Customers
FROM Amazon;
```

---

### Section 2 - Product Performance Analysis

```sql
-- Top 10 Products by Units Sold
SELECT TOP 10
    ProductName,
    SUM(Quantity) AS Total_Unit_Sold
FROM Amazon
GROUP BY ProductName
ORDER BY Total_Unit_Sold DESC;

-- Top 10 Products by Revenue
SELECT TOP 10
    ProductName,
    SUM(Quantity * UnitPrice - Discount) AS Total_Revenue
FROM Amazon
GROUP BY ProductName
ORDER BY Total_Revenue DESC;

-- Bottom 10 Products by Revenue (Underperformers)
SELECT TOP 10
    ProductName,
    SUM(Quantity * UnitPrice - Discount) AS Total_Revenue
FROM Amazon
GROUP BY ProductName
ORDER BY Total_Revenue ASC;

-- Average Discount per Product
SELECT
    ProductName,
    AVG(Discount) AS Average_Discount,
    SUM(Quantity * UnitPrice - Discount) AS Total_Revenue
FROM Amazon
GROUP BY ProductName
ORDER BY Average_Discount DESC;

-- Revenue by Category
SELECT
    Category,
    SUM(Quantity * UnitPrice - Discount) AS Total_Revenue
FROM Amazon
GROUP BY Category
ORDER BY Total_Revenue DESC;
```

---

### Section 3 - Product Ranking & Classification

```sql
-- Product Performance Ranking (Delivered Orders Only)
WITH Product_Performance AS (
    SELECT
        ProductName,
        SUM(Quantity * UnitPrice) AS Total_Revenue,
        COUNT(DISTINCT OrderID) AS Total_Orders
    FROM Amazon
    WHERE OrderStatus = 'Delivered'
    GROUP BY ProductName
)
SELECT
    ProductName,
    Total_Revenue,
    Total_Orders,
    RANK() OVER (ORDER BY Total_Revenue DESC) AS Revenue_Rank
FROM Product_Performance;

-- Product Tier Classification
WITH Product_Performance AS (
    SELECT
        ProductName,
        SUM(Quantity * UnitPrice) AS Total_Revenue
    FROM Amazon
    WHERE OrderStatus = 'Delivered'
    GROUP BY ProductName
)
SELECT
    ProductName,
    Total_Revenue,
    CASE
        WHEN Total_Revenue >= 1400000 THEN 'Top Performer'
        WHEN Total_Revenue BETWEEN 1300000 AND 1399999 THEN 'Average Performer'
        ELSE 'Low Performer'
    END AS Performance_Category
FROM Product_Performance
ORDER BY Total_Revenue DESC;
```

---

### Section 4 - Discount Impact Analysis

```sql
-- Do Discounted Products Sell More Than Non-Discounted?
SELECT
    CASE
        WHEN Discount > 0 THEN 'Discounted'
        ELSE 'No Discount'
    END AS Discount_Type,
    SUM(Quantity) AS Total_Units_Sold
FROM Amazon
GROUP BY
    CASE
        WHEN Discount > 0 THEN 'Discounted'
        ELSE 'No Discount'
    END;
```

---

### Section 5 - Order Status Analysis

```sql
-- Percentage of Orders by Status (Cancelled vs Delivered vs Other)
SELECT
    OrderStatus,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS Percentage_Status
FROM Amazon
GROUP BY OrderStatus
ORDER BY Percentage_Status DESC;
```

---

### Section 6 - Customer Segmentation

```sql
-- Repeat Buyers (Customers with More Than 1 Order)
SELECT
    CustomerID,
    COUNT(DISTINCT OrderID) AS Total_Orders
FROM Amazon
GROUP BY CustomerID
HAVING COUNT(DISTINCT OrderID) > 1
ORDER BY Total_Orders DESC;

-- Customer Purchase Frequency
SELECT
    CustomerID,
    COUNT(OrderID) AS Purchase_Frequency
FROM Amazon
GROUP BY CustomerID
ORDER BY Purchase_Frequency DESC;
```

---

### Section 7 - Geographic & Seller Analysis

```sql
-- Revenue by Country
SELECT
    Country,
    SUM(Quantity * UnitPrice) AS Total_Revenue
FROM Amazon
GROUP BY Country
ORDER BY Total_Revenue DESC;

-- Revenue by State
SELECT
    State,
    SUM(Quantity * UnitPrice) AS Total_Revenue
FROM Amazon
GROUP BY State
ORDER BY Total_Revenue DESC;

-- Average Shipping Cost by Country
SELECT
    Country,
    AVG([Shipping Cost]) AS AVG_Shipping_Cost
FROM Amazon
GROUP BY Country
ORDER BY AVG_Shipping_Cost DESC;

-- Top Sellers by Revenue
SELECT
    SellerID,
    SUM(Quantity * UnitPrice - Discount) AS Total_Revenue
FROM Amazon
GROUP BY SellerID
ORDER BY Total_Revenue DESC;

-- Top Brands by Revenue
SELECT
    Brand,
    SUM(Quantity * UnitPrice) AS Brand_Revenue
FROM Amazon
GROUP BY Brand
ORDER BY Brand_Revenue DESC;

-- Most Used Payment Methods
SELECT
    PaymentMethod,
    COUNT(*) AS Usage_Count
FROM Amazon
GROUP BY PaymentMethod
ORDER BY Usage_Count DESC;
```

---

## Key Insights & Findings

### 1. Delivered Revenue vs Total Revenue Gap
By filtering revenue to `OrderStatus = 'Delivered'` only, the analysis separates confirmed revenue from pending or cancelled orders. The gap between total revenue and delivered revenue represents at-risk income — orders that may be cancelled, returned, or still in transit.

### 2. Discounted Products Sell More Units
The discount impact analysis reveals that discounted products consistently outsell non-discounted products in total units. However, because discount amounts are deducted from revenue, the net revenue per unit is lower — raising the question of whether volume gains justify margin sacrifice.

### 3. Top 10 Products Drive Disproportionate Revenue
The TOP 10 products by revenue generate significantly higher sales than the average product — indicating a classic **80/20 pattern** where a small number of products drive the majority of platform revenue. These products require priority inventory management and marketing support.

### 4. Bottom 10 Products Represent Catalogue Dead Weight
The lowest-performing products by revenue consume catalogue space, inventory investment, and operational resources while delivering minimal return. These products are candidates for review, repricing, or removal.

### 5. Geographic Revenue Concentration
Revenue by country and state analysis reveals clear geographic concentration — with certain markets generating significantly higher revenue than others. High shipping cost countries identified through the average shipping cost query may be eroding profitability despite strong gross revenue.

### 6. Repeat Buyers Are a Small but High-Value Segment
The repeat buyer analysis (customers with more than 1 order) identifies a loyal customer segment. While smaller in number than one-time buyers, repeat customers generate higher lifetime value and should be prioritised in retention strategies.

### 7. Payment Method Preferences Reveal Customer Behaviour
The most used payment method analysis reveals dominant transaction channels — informing which payment integrations to prioritise and maintain for maximum conversion.

---

## Product Performance Analysis

### Product Classification Framework

| Tier | Revenue Threshold | Business Action |
|---|---|---|
| 🟢 Top Performer | ≥ $1,400,000 | Protect, scale, and prioritise |
| 🟡 Average Performer | $1,300,000 – $1,399,999 | Optimise and monitor |
| 🔴 Low Performer | < $1,300,000 | Review, reprice, or remove |

### Key Product Metrics Tracked
- Total units sold per product
- Net revenue per product (after discount deduction)
- Revenue rank across entire catalogue
- Average discount applied per product
- Performance tier classification

---

## Customer Segmentation Analysis

### Segmentation Dimensions

| Segment | Query Logic | Business Value |
|---|---|---|
| Repeat Buyers | `HAVING COUNT(DISTINCT OrderID) > 1` | Loyalty & retention targeting |
| High Frequency | Top by `COUNT(OrderID)` | VIP programme candidates |
| High Value | Top by `SUM(Quantity * UnitPrice)` | Premium service candidates |

### Customer Revenue Ranking Approach
```sql
WITH CustomerRevenue AS (
    SELECT
        CustomerID,
        SUM(Quantity * UnitPrice) AS Total_Revenue
    FROM Amazon
    GROUP BY CustomerID
)
SELECT *,
    RANK() OVER (ORDER BY Total_Revenue DESC) AS Revenue_Rank,
    CASE
        WHEN RANK() OVER (ORDER BY Total_Revenue DESC) <= 10 THEN 'High Value'
        WHEN RANK() OVER (ORDER BY Total_Revenue DESC) <= 50 THEN 'Mid Value'
        ELSE 'Low Value'
    END AS Customer_Segment
FROM CustomerRevenue;
```

---

## Geographic & Seller Analysis

### Geographic Metrics Tracked
- Total revenue by country
- Total revenue by state
- Average shipping cost by country - identifying high-cost logistics markets
- Seller revenue ranking - identifying top platform contributors
- Brand revenue ranking - identifying strongest brand partnerships

### Shipping Cost Intelligence
High shipping cost countries identified through:
```sql
SELECT
    Country,
    AVG([Shipping Cost]) AS AVG_Shipping_Cost
FROM Amazon
GROUP BY Country
ORDER BY AVG_Shipping_Cost DESC;
```
Countries with high average shipping costs but lower revenue may represent **unprofitable markets** where logistics costs are compressing net margins.

---

## 💡 Business Recommendations

### 1. Prioritise Top 10 Products for Inventory Investment
The top 10 revenue-generating products should receive priority stock replenishment, featured placement, and promotional support. Stockouts in these products have a disproportionate impact on total platform revenue.

### 2. Review Bottom 10 Products for Removal or Repricing
Products consistently at the bottom of the revenue ranking should be evaluated. Options include: price reduction to stimulate volume, bundling with high-performing products, or catalogue removal to reduce operational complexity.

### 3. Audit Discounting Strategy
While discounted products sell more units, the net revenue impact needs deeper analysis. For each product category, calculate: (revenue with discount) vs (projected revenue without discount at lower volume). If the margin sacrifice exceeds the volume gain — reduce or eliminate discounting.

### 4. Launch a Repeat Buyer Retention Programme
Repeat buyers represent proven platform loyalty. A targeted retention campaign — such as early access to new products, exclusive discounts, or a loyalty rewards tier — would increase order frequency and lifetime value for this already-committed segment.

### 5. Rationalise High Shipping Cost Markets
Countries with above-average shipping costs should be reviewed for profitability. If net revenue (after shipping) is negative or near-zero in certain markets, consider: minimum order thresholds for free shipping, localised fulfilment partnerships, or market exit.

### 6. Strengthen Relationships with Top Sellers and Brands
The seller and brand revenue analysis identifies the platform's most valuable partners. These relationships warrant dedicated account management, co-marketing opportunities, and preferential terms to protect revenue concentration.

---

## Implementation, Monitoring & Next Steps

### Recommended Monitoring Cadence

| Metric | Frequency | Alert Threshold |
|---|---|---|
| Total Revenue vs Delivered Revenue Gap | Weekly | Flag if gap > 20% |
| Bottom 10 Product Revenue | Monthly | Flag if still declining after action |
| Cancellation Rate (% of Orders) | Weekly | Flag if cancellation > 15% |
| Repeat Buyer Rate | Monthly | Flag if < 20% of total customers |
| Average Shipping Cost by Country | Quarterly | Flag if > 15% of order value |

### Next Steps for This Project

**Short Term (1–3 months):**
- Build a Power BI dashboard on top of these SQL queries to visualise all findings
- Add a stored procedure to automate monthly KPI reporting
- Create views for the most frequently used query outputs

**Medium Term (3–6 months):**
- Develop a customer churn analysis using LAG/LEAD window functions to track purchase gaps
- Add cohort analysis — grouping customers by first purchase month and tracking retention
- Build a revenue forecasting model using historical monthly trends

**Long Term (6–12 months):**
- Integrate returns and refunds data to calculate true net revenue
- Develop a product recommendation engine based on co-purchase patterns
- Build an automated anomaly detection query to flag unusual spikes or drops in daily revenue

---

## Tools & Technologies

| Tool | Purpose |
|---|---|
| **Microsoft SQL Server (SSMS)** | Database creation, querying, and analysis |
| **T-SQL** | All queries — aggregation, CTEs, window functions, classification |
| **Microsoft Excel** | Initial data exploration and validation |

---

## 📂 How to Run This Project

1. **Clone or download** this repository
2. Open **Microsoft SQL Server Management Studio (SSMS)**
3. Create a new database:
```sql
CREATE DATABASE Amazon;
```
4. Import `Amazon_dataset.csv` into the database using the SSMS Import Wizard or BULK INSERT
5. Open `Amazon_Sales_Query.sql` in SSMS
6. Run queries **section by section** - each section is clearly labelled with comments
7. Results can be exported to Excel for further analysis or visualisation

---

## 👤 Author

**Faleye Olumide David**
Data Analyst/Engineer/Database Manager | Sales & E-commerce Analyst | Business Intelligence Analyst

📍 Nigeria
🔗 [LinkedIn](https://www.linkedin.com/in/olumide-david-79b17726a/)
🌐 Portfolio: *datascienceportfol.io* (coming soon)

---

>  *"SQL is not just a query language — it is the foundation of every data-driven decision."*

---

⭐ If you found this project useful or insightful, consider giving it a star on GitHub!
