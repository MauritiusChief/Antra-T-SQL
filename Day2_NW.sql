--  Using Northwnd Database: (Use aliases for all the Joins)

-- 14.  List all Products that has been sold at least once in last 27 years.
SELECT DISTINCT p.ProductName, p.ProductID
FROM dbo.Orders AS o
JOIN dbo.[Order Details] AS od ON o.OrderID = od.OrderID
JOIN dbo.Products AS p ON od.ProductID = p.ProductID
WHERE DATEDIFF(year, OrderDate, GETDATE()) > 27

-- 15.  List top 5 locations (Zip Code) where the products sold most.
SELECT TOP 5 o.ShipPostalCode, SUM(od.Quantity) AS SoldQuantity
FROM dbo.Orders AS o
JOIN dbo.[Order Details] AS od ON o.OrderID = od.OrderID
WHERE o.ShipPostalCode IS NOT NULL
GROUP BY o.ShipPostalCode
ORDER BY SUM(od.Quantity) DESC

-- 16.  List top 5 locations (Zip Code) where the products sold most in last 27 years.
SELECT TOP 5 o.ShipPostalCode, SUM(od.Quantity) AS SoldQuantity
FROM dbo.Orders AS o
JOIN dbo.[Order Details] AS od ON o.OrderID = od.OrderID
WHERE o.ShipPostalCode IS NOT NULL AND DATEDIFF(year, o.OrderDate, GETDATE()) > 27
GROUP BY o.ShipPostalCode
ORDER BY SUM(od.Quantity) DESC

-- 17.   List all city names and number of customers in that city.     
SELECT City, COUNT(CustomerID) AS NumOfCustomers
FROM dbo.Customers
GROUP BY City

-- 18.  List city names which have more than 2 customers, and number of customers in that city
SELECT City, COUNT(CustomerID) AS NumOfCustomers
FROM dbo.Customers
GROUP BY City
HAVING COUNT(CustomerID) > 2

-- 19.  List the names of customers who placed orders after 1/1/98 with order date.
SELECT c.CompanyName, o.OrderDate 
FROM dbo.Customers AS c
JOIN dbo.Orders AS o ON c.CustomerID = o.CustomerID
WHERE o.OrderDate > '1998-01-01'

-- 20.  List the names of all customers with most recent order dates
SELECT TOP 1 c.CompanyName, o.OrderDate 
FROM dbo.Customers AS c
JOIN dbo.Orders AS o ON c.CustomerID = o.CustomerID
ORDER BY o.OrderDate DESC

-- 21.  Display the names of all customers  along with the  count of products they bought
SELECT c.CompanyName, SUM(od.Quantity) AS CountOfProductsBought
FROM dbo.Customers AS c
JOIN dbo.Orders AS o ON c.CustomerID = o.CustomerID
JOIN dbo.[Order Details] AS od ON o.OrderID = od.OrderID
GROUP BY c.CompanyName

-- 22.  Display the customer ids who bought more than 100 Products with count of products.
SELECT o.CustomerID, SUM(od.Quantity) AS CountOfProductsBought
FROM dbo.Orders AS o
JOIN dbo.[Order Details] AS od ON o.OrderID = od.OrderID
GROUP BY o.CustomerID
HAVING SUM(od.Quantity) > 100

-- 23.  List all of the possible ways that suppliers can ship their products. Display the results as below
--     Supplier Company Name                Shipping Company Name
--     ---------------------------------            ----------------------------------
SELECT su.CompanyName AS 'Supplier Company Name', sh.CompanyName AS 'Shipping Company Name'
FROM dbo.Shippers AS sh
CROSS JOIN dbo.Suppliers AS su

-- 24.  Display the products order each day. Show Order date and Product Name. 
SELECT DISTINCT o.OrderDate, p.ProductName
FROM dbo.Products AS p
JOIN dbo.[Order Details] AS od ON p.ProductID = od.ProductID
JOIN dbo.Orders AS o ON o.OrderID = od.OrderID 

-- 25.  Displays pairs of employees who have the same job title.
SELECT e1.EmployeeID, e2.EmployeeID, e2.Title
FROM dbo.Employees AS e1
JOIN dbo.Employees AS e2 ON e1.Title = e2.Title
WHERE e1.EmployeeID != e2.EmployeeID 

-- 26.  Display all the Managers who have more than 2 employees reporting to them.
SELECT m.EmployeeID, COUNT(m.EmployeeID) AS CountReportToThis
FROM dbo.Employees AS m
JOIN dbo.Employees AS e ON e.ReportsTo = m.EmployeeID
GROUP BY m.EmployeeID
HAVING COUNT(m.EmployeeID) > 2

-- 27.  Display the customers and suppliers by city. The results should have the following columns
-- City
-- Name
-- Contact Name,
-- Type (Customer or Supplier)
SELECT City, CompanyName AS "Name", ContactName AS "Contact Name", 'Customer' AS "Type"
FROM dbo.Customers
UNION
SELECT City, CompanyName AS "Name", ContactName AS "Contact Name", 'Supplier' AS "Type"
FROM dbo.Suppliers