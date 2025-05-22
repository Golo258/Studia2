
1) Używając kursora, wypisz za pomocą funkcji print wszystkie zamówienia dla klienta o identyfikatorze ALFKI wraz z datą zamówienia

2) Wykonaj poniższe punkty
-stwórz tabele która będzie przechowywać skonsolidowane dane pracownika w jednej kolumnie (EmployeeID, data).
-procedurę która przyjmie w parametrze id, Imię, nazwisko, stanowisko, adres oraz miasto i doda rekord do nowo stworzonej tabeli a jeśli pracownik o takim id już istnieje nadpiszę dane.
-wywołaj nowo napisaną funkcję w kursorze dla każdego pracownika zamieniając stanowisko na 'unknown' jeśli pracownik jest z USA


##--------------
-- Zadanie 1
-- Stwórz zmienną tabelaryczną przechowującą identyfikatory i nazwy produktów z kategorii "Beverages" oraz wyświetl te dane

USE nwnd;
GO

DECLARE @BeveragesProducts TABLE (
    ProductID INT,
    ProductName NVARCHAR(40)
);

INSERT INTO @BeveragesProducts (ProductID, ProductName)
SELECT p.ProductID, p.ProductName
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE c.CategoryName = 'Beverages';

SELECT * FROM @BeveragesProducts;


-- Zadanie 2
-- Stwórz zmienną tabelaryczną przechowującą zamówienia złożone przez klienta "VINET" oraz wyświetl te dane

DECLARE @VinetOrders TABLE (
    OrderID INT,
    CustomerID NCHAR(5),
    EmployeeID INT,
    OrderDate DATETIME,
    RequiredDate DATETIME,
    ShippedDate DATETIME,
    ShipVia INT,
    Freight MONEY,
    ShipName NVARCHAR(40),
    ShipAddress NVARCHAR(60),
    ShipCity NVARCHAR(15),
    ShipRegion NVARCHAR(15),
    ShipPostalCode NVARCHAR(10),
    ShipCountry NVARCHAR(15)
);

INSERT INTO @VinetOrders
SELECT *
FROM Orders
WHERE CustomerID = 'VINET';

SELECT * FROM @VinetOrders;



-- Zadanie 3
-- Stwórz zmienną tabelaryczną przechowującą pracowników, którzy są menedżerami (czyli mają podwładnych) i wyświetl te dane

DECLARE @Managers TABLE (
    EmployeeID INT,
    LastName NVARCHAR(20),
    FirstName NVARCHAR(10),
    Title NVARCHAR(30)
);

INSERT INTO @Managers
SELECT DISTINCT e.EmployeeID, e.LastName, e.FirstName, e.Title
FROM Employees e
WHERE e.EmployeeID IN (
    SELECT DISTINCT ReportsTo
    FROM Employees
    WHERE ReportsTo IS NOT NULL
);

SELECT * FROM @Managers;



-- Zadanie 4
-- Stwórz lokalną tabelę tymczasową przechowującą produkty z ceną jednostkową powyżej 30 oraz wyświetl te dane

IF OBJECT_ID('tempdb..#ExpensiveProducts') IS NOT NULL
    DROP TABLE #ExpensiveProducts;

CREATE TABLE #ExpensiveProducts (
    ProductID INT,
    ProductName NVARCHAR(40),
    UnitPrice MONEY
);

INSERT INTO #ExpensiveProducts
SELECT ProductID, ProductName, UnitPrice
FROM Products
WHERE UnitPrice > 30;

SELECT * FROM #ExpensiveProducts;


-- Zadanie 5
-- Stwórz lokalną tabelę tymczasową przechowującą zamówienia z 1997 roku oraz wyświetl te dane

IF OBJECT_ID('tempdb..#Orders1997') IS NOT NULL
    DROP TABLE #Orders1997;

CREATE TABLE #Orders1997 (
    OrderID INT,
    CustomerID NCHAR(5),
    EmployeeID INT,
    OrderDate DATETIME,
    RequiredDate DATETIME,
    ShippedDate DATETIME,
    ShipVia INT,
    Freight MONEY,
    ShipName NVARCHAR(40),
    ShipAddress NVARCHAR(60),
    ShipCity NVARCHAR(15),
    ShipRegion NVARCHAR(15),
    ShipPostalCode NVARCHAR(10),
    ShipCountry NVARCHAR(15)
);

INSERT INTO #Orders1997
SELECT *
FROM Orders
WHERE OrderDate >= '19970101' AND OrderDate < '19980101';

SELECT * FROM #Orders1997;



-- Zadanie 6
-- Stwórz globalną tabelę tymczasową przechowującą klientów z Francji oraz wyświetl te dane

IF OBJECT_ID('tempdb..##FrenchCustomers') IS NOT NULL
    DROP TABLE ##FrenchCustomers;

CREATE TABLE ##FrenchCustomers (
    CustomerID NCHAR(5),
    CompanyName NVARCHAR(40),
    ContactName NVARCHAR(30),
    ContactTitle NVARCHAR(30),
    Address NVARCHAR(60),
    City NVARCHAR(15),
    Region NVARCHAR(15),
    PostalCode NVARCHAR(10),
    Country NVARCHAR(15),
    Phone NVARCHAR(24),
    Fax NVARCHAR(24)
);

INSERT INTO ##FrenchCustomers
SELECT *
FROM Customers
WHERE Country = 'France';

SELECT * FROM ##FrenchCustomers;

