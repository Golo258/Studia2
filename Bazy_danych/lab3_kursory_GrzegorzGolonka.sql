USE nwnd;
GO

-- Kursor – Zadanie 1
-- Wypisz za pomocą funkcji PRINT wszystkie zamówienia dla klienta ALFKI wraz z datą zamówienia

DECLARE @OrderID INT;
DECLARE @OrderDate DATETIME;

DECLARE OrderCursor CURSOR FOR
SELECT OrderID, OrderDate
FROM Orders
WHERE CustomerID = 'ALFKI';

OPEN OrderCursor;

FETCH NEXT FROM OrderCursor INTO @OrderID, @OrderDate;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'OrderID: ' + CAST(@OrderID AS NVARCHAR) + ', OrderDate: ' + CONVERT(NVARCHAR, @OrderDate, 120);
    FETCH NEXT FROM OrderCursor INTO @OrderID, @OrderDate;
END

CLOSE OrderCursor;
DEALLOCATE OrderCursor;



-- Punkt 1: tabela docelowa
IF OBJECT_ID('dbo.EmployeeSummary', 'U') IS NOT NULL
    DROP TABLE dbo.EmployeeSummary;

CREATE TABLE dbo.EmployeeSummary (
    EmployeeID INT PRIMARY KEY,
    Data NVARCHAR(MAX)
);
GO

-- Punkt 2: procedura
IF OBJECT_ID('dbo.UpsertEmployeeSummary', 'P') IS NOT NULL
    DROP PROCEDURE dbo.UpsertEmployeeSummary;
GO

CREATE PROCEDURE dbo.UpsertEmployeeSummary
    @EmployeeID INT,
    @FirstName NVARCHAR(10),
    @LastName NVARCHAR(20),
    @Title NVARCHAR(30),
    @Address NVARCHAR(60),
    @City NVARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Data NVARCHAR(MAX) = 
        'Name: ' + @FirstName + ' ' + @LastName +
        ', Title: ' + @Title +
        ', Address: ' + @Address +
        ', City: ' + @City;

    IF EXISTS (SELECT 1 FROM dbo.EmployeeSummary WHERE EmployeeID = @EmployeeID)
        UPDATE dbo.EmployeeSummary
        SET Data = @Data
        WHERE EmployeeID = @EmployeeID;
    ELSE
        INSERT INTO dbo.EmployeeSummary (EmployeeID, Data)
        VALUES (@EmployeeID, @Data);
END;
GO

-- Punkt 3: kursor
DECLARE @EmployeeID INT,
        @FirstName NVARCHAR(10),
        @LastName NVARCHAR(20),
        @Title NVARCHAR(30),
        @Address NVARCHAR(60),
        @City NVARCHAR(15),
        @Country NVARCHAR(15);

DECLARE EmployeeCursor CURSOR FOR
SELECT EmployeeID, FirstName, LastName, Title, Address, City, Country
FROM Employees;

OPEN EmployeeCursor;

FETCH NEXT FROM EmployeeCursor INTO
    @EmployeeID, @FirstName, @LastName, @Title, @Address, @City, @Country;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @Country = 'USA'
        SET @Title = 'unknown';

    EXEC dbo.UpsertEmployeeSummary
        @EmployeeID = @EmployeeID,
        @FirstName = @FirstName,
        @LastName = @LastName,
        @Title = @Title,
        @Address = @Address,
        @City = @City;

    FETCH NEXT FROM EmployeeCursor INTO
        @EmployeeID, @FirstName, @LastName, @Title, @Address, @City, @Country;
END

CLOSE EmployeeCursor;
DEALLOCATE EmployeeCursor;

-- Sprawdzenie wyniku
SELECT * FROM dbo.EmployeeSummary;


