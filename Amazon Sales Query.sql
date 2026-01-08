Create Database Amazon;

SELECT DISTINCT
CustomerName
FROM [Amazon].[dbo].[Amazon]

--Remove Duplicate
WITH Duplicates AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY OrderID
               ORDER BY OrderDate
           ) AS RN
FROM Amazon
)
DELETE FROM Duplicates
WHERE RN > 1;

SELECT *
FROM Amazon

--Total Revenue--
SELECT
SUM((Quantity * UnitPrice) - Discount) AS Total_Revenue
FROM Amazon

--Total Revenue Delivered--
SELECT 
SUM((Quantity * UnitPrice) - Discount) AS Total_Revenue
FROM Amazon
WHERE OrderStatus = 'Delivered'

--Total_Orders  
SELECT 
COUNT(DISTINCT OrderID) AS Total_Orders
FROM Amazon

--Average Order Value
SELECT
SUM((Quantity * UnitPrice) - Discount)/COUNT(DISTINCT OrderID)
FROM Amazon

--Average Order Value
SELECT
SUM((Quantity * UnitPrice) - Discount)/COUNT(DISTINCT OrderID)
FROM Amazon
WHERE OrderStatus = 'Delivered'

--Unique Customers--
SELECT
COUNT(DISTINCT CustomerID) AS Total_Customer
FROM Amazon

--PRODUCT PERFORMANCE--
--This is the top 10 product sold--
SELECT TOP 10
ProductName,
SUM(Quantity) AS Total_Unit_Sold
FROM Amazon
GROUP BY ProductName
ORDER BY Total_Unit_Sold DESC

--Best Selling Product--
SELECT
ProductName,
SUM(Quantity) AS Total_Unit_Sold
FROM Amazon
GROUP BY ProductName
ORDER BY Total_Unit_Sold DESC

--Product By Revenue--
SELECT
ProductName,
SUM(Quantity * UnitPrice - Discount) AS Total_Revenue
FROM Amazon
GROUP BY ProductName
ORDER BY Total_Revenue DESC

--Top 10 Product--
SELECT TOP 10
ProductName,
SUM(Quantity * UnitPrice - Discount) AS Total_Revenue
FROM Amazon
GROUP BY ProductName
ORDER BY Total_Revenue DESC

--Product Lagging in performance
SELECT
ProductName,
SUM(Quantity * UnitPrice - Discount) AS Total_Revenue
FROM Amazon
GROUP BY ProductName
ORDER BY Total_Revenue ASC

--Bottom 10 Product Lagging in performance
SELECT TOP 10
ProductName,
SUM(Quantity * UnitPrice - Discount) AS Total_Revenue
FROM Amazon
GROUP BY ProductName
ORDER BY Total_Revenue ASC

--Discount on Product--
SELECT
ProductName,
AVG(Discount) AS Average_Discount,
SUM(Quantity * UnitPrice - Discount) AS Total_Revenue
FROM Amazon
GROUP BY ProductName
ORDER BY Average_Discount DESC

--Revenue By Category--
SELECT
Category,
SUM(Quantity * UnitPrice - Discount) AS Total_Revenue
FROM Amazon
GROUP BY Category
ORDER BY Total_Revenue DESC

--Most used Payment Method--
SELECT
PaymentMethod,
COUNT(*) AS Usage_Count
FROM Amazon
GROUP BY PaymentMethod
ORDER BY Usage_Count DESC

--Brand Revenue--
SELECT
Brand,
SUM(Quantity * UnitPrice) AS Brand_Revenue
FROM Amazon
GROUP BY Brand
ORDER BY Brand_Revenue DESC

--percentage of orders were cancelled vs delivered--
SELECT
OrderStatus,
COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS Percentage_Status
FROM Amazon
GROUP BY OrderStatus
ORDER BY Percentage_Status DESC


--Do Discount Product sell more than none discount Product--
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


--Product Performance in Rank--
WITH Product_Performance AS (
SELECT ProductName,
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
FROM Product_Performance


--Classify Product-- 
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

--CUSTOMER SEGMENTATION--
--High Valued Customer--

WITH CustomerRevenue AS (
SELECT
CustomerID,
SUM(Quantity * UnitPrice) AS Total_Revenue
FROM Amazon
GROUP BY CustomerID
),
RankedCustomers AS (
SELECT *,
RANK() OVER (PARTITION BY CustomerID ORDER BY Total_Revenue DESC) AS Revenue_Group
FROM CustomerRevenue
)
SELECT *
FROM RankedCustomers

--Repeated Buyers--
SELECT
CustomerID,
COUNT(DISTINCT OrderID) AS Total_Orders
FROM Amazon
GROUP BY CustomerID
HAVING COUNT(DISTINCT OrderID) > 1
ORDER BY Total_Orders

--Customer Purchase Frequency--
SELECT
CustomerID,
COUNT(OrderID) AS Purchase_Frequency
FROM Amazon
GROUP BY CustomerID
ORDER BY Purchase_Frequency DESC;

--GEOGRAPHIC INSIGHT--
--Revenue by Country
SELECT
Country,
SUM(Quantity * UnitPrice) AS Total_Revenue
FROM Amazon
GROUP BY Country
ORDER BY Total_Revenue

--Revenue by State
SELECT
State,
SUM(Quantity * UnitPrice) AS Total_Revenue
FROM Amazon
GROUP BY State
ORDER BY Total_Revenue

--Average shipping Cost by Country--
SELECT
Country,
AVG(Shipping Cost) AS AVG_Shipping_Cost
FROM Amazon
GROUP BY Country
ORDER BY AVG_Shipping_Cost

--Seller with the highest Revenue--
SELECT
SellerID,
SUM(Quantity * UnitPrice - Discount) AS Total_Revenue
FROM Amazon
GROUP BY SellerID
ORDER BY Total_Revenue