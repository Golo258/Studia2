

-- Zadanie 1
--  1. Nadaj unikalny numer dla każdego zamówienia w ramach klienta według daty zamówienia rosnąco. [orders]
USE nwnd;
GO

SELECT 
    OrderID,
    CustomerID,
    OrderDate,
    ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate ASC) AS OrderNumberPerCustomer
FROM dbo.Orders;

-- 2: Podziel produkty na 4 segmenty według ceny jednostkowej (Products)
USE nwnd;
GO

SELECT 
    ProductID,
    ProductName,
    UnitPrice,
    NTILE(4) OVER (ORDER BY UnitPrice ASC) AS PriceSegment
FROM dbo.Products;


-- 3: Dla każdego zamówienia pobierz poprzednią datę zamówienia dla danego klienta (Orders)
USE nwnd;
GO

SELECT 
    OrderID,
    CustomerID,
    OrderDate,
    LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate ASC) AS PreviousOrderDate
FROM dbo.Orders;

-- 4: Oblicz całkowitą wartość zamówień (UnitPrice * Quantity) dla każdego klienta (Order Details, Orders)
USE nwnd;
GO

SELECT 
    od.OrderID,
    o.CustomerID,
    od.ProductID,
    od.UnitPrice,
    od.Quantity,
    od.UnitPrice * od.Quantity AS LineTotal,
    SUM(od.UnitPrice * od.Quantity) OVER (PARTITION BY o.CustomerID) AS TotalOrderValuePerCustomer
FROM dbo.[Order Details] od
JOIN dbo.Orders o ON od.OrderID = o.OrderID;

--  5: Oblicz całkowitą ilość zamówionych jednostek (Quantity) dla każdego produktu (Order Details)
USE nwnd;
GO

SELECT 
    ProductID,
    OrderID,
    Quantity,
    SUM(Quantity) OVER (PARTITION BY ProductID) AS TotalUnitsOrdered
FROM dbo.[Order Details];



-- 6: Znajdź najwcześniejszą datę zamówienia dla każdego klienta (Orders)
USE nwnd;
GO

SELECT 
    OrderID,
    CustomerID,
    OrderDate,
    MIN(OrderDate) OVER (PARTITION BY CustomerID) AS FirstOrderDate
FROM dbo.Orders;