-- All scenarios are based on Database NORTHWIND.

-- 1.      List all cities that have both Employees and Customers.
SELECT DISTINCT e.City
FROM dbo.Employees AS e
    JOIN dbo.Customers AS c ON e.City = c.City

-- 2.      List all cities that have Customers but no Employee.
-- a.      Use sub-query
SELECT DISTINCT c.City
FROM dbo.Customers AS c
WHERE c.City NOT IN (
    SELECT e.City
    FROM dbo.Employees AS e
)
-- b.      Do not use sub-query
SELECT DISTINCT c.City
FROM dbo.Employees AS e
    RIGHT JOIN dbo.Customers AS c ON e.City = c.City
WHERE e.EmployeeID IS NULL

-- 3.      List all products and their total order quantities throughout all orders.
SELECT p.ProductName,
    (
        SELECT SUM(od.Quantity)
        FROM dbo.[Order Details] AS od
        WHERE od.ProductID = p.ProductID
    ) AS TotalQuantity
FROM dbo.Products AS p

SELECT p.ProductName, SUM(od.Quantity) AS TotalQuantity
FROM dbo.Products AS p
    JOIN dbo.[Order Details] AS od ON od.ProductID = p.ProductID
GROUP BY p.ProductName

-- 4.      List all Customer Cities and total products ordered by that city.
SELECT DISTINCT c.City,
    (
        SELECT ISNULL(SUM(od.Quantity), 0)
        FROM dbo.[Order Details] AS od
            JOIN dbo.Orders AS o ON od.OrderID = o.OrderID
        WHERE o.ShipCity = c.City
    ) AS TotalQuantity
FROM dbo.Customers AS c

SELECT c.City, ISNULL(SUM(od.Quantity), 0) AS TotalQuantity
FROM dbo.[Order Details] AS od
    JOIN dbo.Orders AS o ON od.OrderID = o.OrderID
    RIGHT JOIN dbo.Customers AS c ON o.ShipCity = c.City -- Show all City even has null Quantity
GROUP BY c.City

-- 5.      List all Customer Cities that have at least two customers.
SELECT c.City, COUNT(c.CustomerID) AS NumOfCustomers
FROM dbo.Customers AS c
GROUP BY c.City
HAVING COUNT(c.CustomerID) > 2

-- 6.      List all Customer Cities that have ordered at least two different kinds of products.
SELECT c.City, COUNT(DISTINCT od.ProductID) AS ProductCount
FROM dbo.Customers AS c
    JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
    JOIN dbo.[Order Details] AS od ON od.OrderID = o.OrderID
GROUP BY c.City
HAVING COUNT(od.ProductID) > 2

-- 7.      List all Customers who have ordered products, but have the ‘ship city’ on the order different from their own customer cities.
SELECT DISTINCT c.City AS CustomerCity, o.ShipCity
FROM dbo.Orders AS o
    JOIN dbo.Customers AS c ON o.ShipCity != c.City AND o.CustomerID = c.CustomerID

-- 8.      List 5 most popular products, their average price, and the customer city that ordered most quantity of it.
WITH product_totals AS (
    SELECT
        od.ProductID,
        SUM(od.Quantity) AS total_qty,
        AVG(od.UnitPrice) AS avg_price
    FROM dbo.[Order Details] AS od
    GROUP BY od.ProductID
),
product_city AS (
    SELECT
        od.ProductID,
        c.City,
        SUM(od.Quantity) AS qty_city,
        RANK() OVER (
            PARTITION BY od.ProductID
            ORDER BY SUM(od.Quantity) DESC
        ) AS RNK
    FROM dbo.[Order Details] AS od
        JOIN dbo.Orders AS o ON o.OrderID = od.OrderID
        LEFT JOIN dbo.Customers AS c ON c.CustomerID = o.CustomerID
    GROUP BY od.ProductID, c.City
),
top_city AS (
    SELECT ProductID, City, qty_city
    FROM product_city
    WHERE RNK = 1
)
SELECT TOP (5)
    pt.ProductID,
    pt.avg_price,
    pt.total_qty,
    tc.City AS TopCity,
    tc.qty_city AS QtyInTopCity
FROM product_totals AS pt
JOIN top_city AS tc ON tc.ProductID = pt.ProductID
ORDER BY pt.total_qty DESC, pt.ProductID

-- 9.      List all cities that have never ordered something but we have employees there.
-- a.      Use sub-query
SELECT DISTINCT e.City
FROM dbo.Employees AS e
WHERE e.City NOT IN (
    SELECT c.City
    FROM dbo.Customers AS c
        JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
)
-- b.      Do not use sub-query
SELECT DISTINCT e.City
FROM dbo.Customers AS c
    JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID 
    RIGHT JOIN dbo.Employees AS e ON e.City = c.City
WHERE c.CustomerID IS NULL

-- 10.  List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, and also the city of most total quantity of products ordered from. (tip: join  sub-query)
WITH order_city AS ( -- Order count of each city
    SELECT TOP 1 e.City, COUNT(o.OrderID) AS CountOfOrder
    FROM dbo.Orders AS o
        JOIN dbo.Employees AS e ON e.EmployeeID = o.EmployeeID
    GROUP BY e.City
    ORDER BY COUNT(o.OrderID) DESC
),
quantity_city AS ( -- Sum of quantity of each city
    SELECT TOP 1 c.City, SUM(od.Quantity) AS QuantityOfCityOrder
    FROM dbo.Orders AS o
        JOIN dbo.Customers AS c ON c.CustomerID = o.CustomerID
        JOIN dbo.[Order Details] AS od ON od.OrderID = o.OrderID
    GROUP BY c.City
    ORDER BY SUM(od.Quantity) DESC
)
SELECT oc.City
FROM order_city AS oc
    JOIN quantity_city AS qc ON oc.City = qc.City

-- 11. How do you remove the duplicates record of a table?
-- Use PARTITION BY on every column, and ROW_NUMBER() to find duplicate rows (identical on every column). If RowNumber is greater than 1, then delete this row.
-- For example
WITH cte AS (
    SELECT 
        OrderID,
        ProductID,
        UnitPrice,
        Quantity,
        Discount,
        ROW_NUMBER() OVER (
            PARTITION BY OrderID, ProductID, UnitPrice, Quantity, Discount 
            ORDER BY OrderID
        ) AS RowNum
    FROM dbo.[Order Details]
)
DELETE
FROM cte
WHERE RowNum > 1