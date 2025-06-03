-- Zadanie 2:

-- 1a. Tworzenie tabeli productsJson
USE nwnd;
GO

IF OBJECT_ID('dbo.productsJson', 'U') IS NOT NULL
    DROP TABLE dbo.productsJson;
GO

CREATE TABLE dbo.productsJson (
    ProductID INT PRIMARY KEY,
    JsonData NVARCHAR(MAX)
);
GO

-- 1a: Ręczne tworzenie JSON z CONCAT i wstawianie do tabeli
INSERT INTO dbo.productsJson (ProductID, JsonData)
SELECT 
    ProductID,
    CONCAT(
        '{',
        '"ProductID":', ProductID, ',',
        '"ProductName":"', ProductName, '",',
        '"SupplierID":', ISNULL(CAST(SupplierID AS NVARCHAR), 'null'), ',',
        '"CategoryID":', ISNULL(CAST(CategoryID AS NVARCHAR), 'null'), ',',
        '"QuantityPerUnit":"', ISNULL(QuantityPerUnit, ''), '",',
        '"UnitPrice":', ISNULL(CAST(UnitPrice AS NVARCHAR), 'null'), ',',
        '"UnitsInStock":', ISNULL(CAST(UnitsInStock AS NVARCHAR), 'null'), ',',
        '"UnitsOnOrder":', ISNULL(CAST(UnitsOnOrder AS NVARCHAR), 'null'), ',',
        '"ReorderLevel":', ISNULL(CAST(ReorderLevel AS NVARCHAR), 'null'), ',',
        '"Discontinued":', Discontinued,
        '}'
    )
FROM dbo.Products;


-- 1b: Czyszczenie tabeli przed ponownym wypełnieniem
USE nwnd;
GO

TRUNCATE TABLE dbo.productsJson;

-- 1b: Tworzenie JSON za pomocą FOR JSON PATH
INSERT INTO dbo.productsJson (ProductID, JsonData)
SELECT 
    ProductID,
    (
        SELECT 
            ProductID,
            ProductName,
            SupplierID,
            CategoryID,
            QuantityPerUnit,
            UnitPrice,
            UnitsInStock,
            UnitsOnOrder,
            ReorderLevel,
            Discontinued
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    )
FROM dbo.Products;

-- 2: Podniesienie ceny o 10% w JSON jeśli dostawca z USA
USE nwnd;
GO

UPDATE pj
SET JsonData = JSON_MODIFY(JsonData, '$.UnitPrice',
    CAST(ROUND(JSON_VALUE(JsonData, '$.UnitPrice') * 1.1, 2) AS NVARCHAR)
)
FROM dbo.productsJson pj
WHERE EXISTS (
    SELECT 1
    FROM dbo.Suppliers s
    WHERE s.SupplierID = JSON_VALUE(pj.JsonData, '$.SupplierID')
      AND s.Country = 'USA'
);


-- 3: Dodanie tablicy "Orders" do JSON-a na podstawie wystąpień produktu w zamówieniach
USE nwnd;
GO

UPDATE pj
SET JsonData = JSON_MODIFY(
    pj.JsonData,
    '$.Orders',
    '[' + ISNULL((
        SELECT STRING_AGG(CAST(OrderID AS NVARCHAR), ',')
        FROM dbo.[Order Details] od
        WHERE od.ProductID = pj.ProductID
    ), '') + ']'
)
FROM dbo.productsJson pj;