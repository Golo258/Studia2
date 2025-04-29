USE pubs;
GO;

-- 1) Znajd� autor�w, kt�rych imi� zaczyna si� na 'M' a ko�czy na 'R'
SELECT * 
FROM authors 
WHERE au_fname LIKE 'M%R';




-- Zadanie 2: Znajd� tytu�y, kt�re ko�cz� si� znakiem zapytania
SELECT * 
FROM titles 
WHERE title LIKE '%?';

-- Zadanie 3: Znajd� sprzeda�e, kt�rych data zam�wienia jest pomi�dzy 06.1993 a 10.1994
SELECT * 
FROM sales 
WHERE ord_date BETWEEN '1993-06-01' AND '1994-10-31';

-- Zadanie 4: Znajd� sklepy, kt�rych kod pocztowy znajduje si� w przedziale 80000 a 95000
SELECT * 
FROM stores 
WHERE CAST(zip AS INT) BETWEEN 80000 AND 95000;

-- Zadanie 5: Zwr�� inicja�y wszystkich autor�w
SELECT CONCAT(LEFT(au_lname, 1), '.', LEFT(au_fname, 1), '.') AS initials
FROM authors;

-- 6) Wy�wietl numery telefon�w autor�w jako numeryczne (bez spacji oraz my�lnika)
SELECT au_id, au_fname, au_lname, 
       REPLACE(REPLACE(phone, ' ', ''), '-', '') AS phone_clean
FROM authors;

-- 7) Wy�wietl w jednym wyniku imi� oraz nazwisko autor�w i pracownik�w
SELECT au_fname AS first_name, au_lname AS last_name, 'Author' AS role
FROM authors
UNION ALL
SELECT fname AS first_name, lname AS last_name, 'Employee' AS role
FROM employee;

-- 8) Zwr�� ilo�� publikacji z podzia�em na lata
SELECT YEAR(pubdate) AS publication_year, COUNT(*) AS publication_count
FROM titles
GROUP BY YEAR(pubdate)
ORDER BY publication_year;

-- 9) Znajd� kategorie ksi��ek, kt�re posiadaj� �redni� cen� powy�ej 15
SELECT type, AVG(price) AS avg_price
FROM titles
GROUP BY type
HAVING AVG(price) > 15;

-- 10) Zwr�� imi�, nazwisko, stanowisko pracownika oraz stan wydawnictwa dla pracownik�w zatrudnionych przed 1994 rokiem
SELECT e.fname, e.lname, j.job_desc, 
       COALESCE(p.state, 'NA') AS publisher_state
FROM employee e
JOIN jobs j ON e.job_id = j.job_id
JOIN publishers p ON e.pub_id = p.pub_id
WHERE e.hire_date < '1994-01-01'
ORDER BY p.pub_name, j.job_desc;

-- 11) W bazie danych [pubs] jest tabela z list� ksi��ek [titles].
-- Nale�y utworzy� now� tabel� z referencj� (do titles) w kt�rej b�dzie mo�liwo�� przechowywania recenzji od u�ytkownik�w.
-- Tabela powinna zawiera� takie informacje jak:
-- tekst recenzji
-- dat� dodania recenzji - gdy nie podana powinna by� "teraz"
-- imi� oraz nazwisko recenzenta - mo�e nie by� podane
-- ocene u�ytkownika w skali 1 do 5
-- powinna by� mo�liwo�� dodania wielu recenzji do jednej ksi��ki

CREATE TABLE reviews (
    review_id INT IDENTITY(1,1) PRIMARY KEY,
    title_id tid NOT NULL REFERENCES titles(title_id),
    review_text TEXT NOT NULL,
    review_date DATETIME DEFAULT GETDATE(),
    reviewer_fname VARCHAR(50) NULL,
    reviewer_lname VARCHAR(50) NULL,
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5)
);

-- uzupe�nij tabele o przynajmniej 5 rekord�w.
INSERT INTO reviews (title_id, review_text, reviewer_fname, reviewer_lname, rating)
VALUES 
    ('PC1035', '�wietna ksi��ka, bardzo wci�gaj�ca!', 'Jan', 'Kowalski', 5),
    ('PS1372', 'Nieco nudna, ale dobrze napisana.', 'Anna', NULL, 3),
    ('BU1111', 'Dobra lektura na wiecz�r.', 'Micha�', 'Nowak', 4),
    ('PS7777', 'Nie polecam, za du�o d�u�yzn.', NULL, NULL, 2),
    ('TC4203', 'Klasyka gatunku, ka�dy powinien przeczyta�.', 'Ewa', 'Wi�niewska', 5);


-- 12)  widok podsumowania przychod�w poszczeg�lnych autor�w[authors, titleauthor, titles, sales]
CREATE VIEW AuthorRevenue AS
SELECT 
    a.au_id,
    a.au_fname,
    a.au_lname,
    SUM(s.qty * t.price) AS total_revenue
FROM authors a
JOIN titleauthor ta ON a.au_id = ta.au_id
JOIN titles t ON ta.title_id = t.title_id
JOIN sales s ON t.title_id = s.title_id
GROUP BY a.au_id, a.au_fname, a.au_lname;

-- wynik widoku AuthorRevenue
SELECT * FROM AuthorRevenue;


-- 13)   przychody wydawc�w z podzia�em na miesi�ce[publishers, titles, sales]

CREATE VIEW PublisherRevenueByMonth AS
SELECT 
    p.pub_id,
    p.pub_name,
    YEAR(s.ord_date) AS sale_year,
    MONTH(s.ord_date) AS sale_month,
    SUM(s.qty * t.price) AS total_revenue
FROM publishers p
JOIN titles t ON p.pub_id = t.pub_id
JOIN sales s ON t.title_id = s.title_id
GROUP BY p.pub_id, p.pub_name, YEAR(s.ord_date), MONTH(s.ord_date);

-- Posortowane wyniki widoku
SELECT * FROM PublisherRevenueByMonth
ORDER BY pub_name, sale_year, sale_month;


--stored procedures
-- 14)   Napisz funkcje skalarn� kt�ra oblicza ca�kowit� sprzeda� ksi��ki na podstawie title_id.[sales.qty]
CREATE FUNCTION GetTotalSales (@title_id CHAR(6))
RETURNS INT
AS
BEGIN
    DECLARE @total_sales INT;
    
    SELECT @total_sales = COALESCE(SUM(qty), 0) 
    FROM sales 
    WHERE title_id = @title_id;
    
    RETURN @total_sales;
END;
GO

-- Przykladowe U�ycie
SELECT dbo.GetTotalSales('PC1035') AS total_sales;


-- 15)   Napisz funkcje skalarn� kt�ra oblicza �redni� cen� ksi��ek wydawcy[publisher] na podstawie pub_id [titles.price].

CREATE FUNCTION GetAverageBookPrice (@pub_id CHAR(4))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @avg_price DECIMAL(10,2);
    
    SELECT @avg_price = COALESCE(AVG(price), 0)
    FROM titles
    WHERE pub_id = @pub_id;
    
    RETURN @avg_price;
END;
GO

-- Przykladowe uzycie
SELECT dbo.GetAverageBookPrice('0736') AS avg_price;


-- 16)   Napisz procedur� kt�ra dodaje nowego autora do bazy danych, sprawdzaj�c najpierw, 
-- czy autor o podanym imieniu oraz nazwisku ju� istnieje. Je�li tak, zwraca b��d. 
-- Zwr�� uwag� �e id nie jest autoinkrementowalne i nale�y zapewni� w jaki� spos�b unikatowy ci�g np czas

CREATE PROCEDURE AddNewAuthor
    @first_name VARCHAR(20),
    @last_name VARCHAR(40),
    @phone CHAR(12) = 'UNKNOWN',
    @address VARCHAR(40) = NULL,
    @city VARCHAR(20) = NULL,
    @state CHAR(2) = NULL,
    @zip CHAR(5) = NULL,
    @contract BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM authors 
        WHERE au_fname = @first_name AND au_lname = @last_name
    )
    BEGIN
        RAISERROR('Autor o podanym imieniu i nazwisku ju� istnieje.', 16, 1);
        RETURN;
    END

    DECLARE @new_au_id VARCHAR(11);
    SET @new_au_id = 
        RIGHT('000' + CAST(DATEPART(ms, GETDATE()) % 1000 AS VARCHAR), 3) + '-' + 
        RIGHT('00' + CAST(DATEPART(ss, GETDATE()) AS VARCHAR), 2) + '-' + 
        RIGHT('0000' + CAST(DATEPART(mi, GETDATE()) AS VARCHAR), 4);

    INSERT INTO authors (au_id, au_fname, au_lname, phone, address, city, state, zip, contract)
    VALUES (@new_au_id, @first_name, @last_name, @phone, @address, @city, @state, @zip, @contract);

    PRINT 'Autor dodany pomy�lnie. ID: ' + @new_au_id;
END;
GO

-- wywo�anie
EXEC AddNewAuthor 
    @first_name = 'John', 
    @last_name = 'Doe', 
    @phone = '123-456-7890', 
    @address = '123 Main St', 
    @city = 'New York', 
    @state = 'NY', 
    @zip = '10001', 
    @contract = 1;


--  17)   Napisz procedure kt�ra usuwa ksi��k� dla przekazanego w parametrze id [titles.title_id]
--  (prawdopodobnie trzeba wi�cej delete ni� jedna tabela). 
-- Je�li rekord o danym id nie istnieje nale�y zwr�ci� b��d z odpowiednim komunikatem. 
--  Spr�bowa� dla title_id = 'BU1032', je�li potrafisz u�yj transakcji.

CREATE PROCEDURE DeleteBook
    @title_id CHAR(6)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM titles WHERE title_id = @title_id)
    BEGIN
        RAISERROR('Ksi��ka o podanym title_id nie istnieje.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;

    BEGIN TRY
        DELETE FROM sales WHERE title_id = @title_id;
        DELETE FROM titleauthor WHERE title_id = @title_id;
        DELETE FROM roysched WHERE title_id = @title_id;
        DELETE FROM reviews WHERE title_id = @title_id; -- Je�li masz recenzje

        DELETE FROM titles WHERE title_id = @title_id;

        COMMIT TRANSACTION;

        PRINT 'Ksi��ka oraz powi�zane dane zosta�y usuni�te.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH;
END;
GO

--- wywo�anie
EXEC DeleteBook @title_id = 'BU1032';



-- 18)   Napisz procedure kt�ra wy�wietli podsumowanie sprzeda�y(sume z sales.qty) 
-- ksi��ek danego autora na podstawie przekazanego id [titleauthor.au_id]. 
-- je�li autor nie istnieje lub nie ma �adnych tytu��w nalezy zwr�ci� b��d z odpowiednim komunikatem.

CREATE PROCEDURE GetAuthorSalesSummary
    @au_id VARCHAR(11)
AS
BEGIN
    SET NOCOUNT ON;

    -- Sprawdzenie, czy autor istnieje
    IF NOT EXISTS (SELECT 1 FROM authors WHERE au_id = @au_id)
    BEGIN
        RAISERROR('Autor o podanym au_id nie istnieje.', 16, 1);
        RETURN;
    END

    -- Sprawdzenie, czy autor ma przypisane ksi��ki
    IF NOT EXISTS (SELECT 1 FROM titleauthor WHERE au_id = @au_id)
    BEGIN
        RAISERROR('Autor nie ma przypisanych �adnych ksi��ek.', 16, 1);
        RETURN;
    END

    -- Sprawdzenie, czy autor ma jakiekolwiek sprzeda�e
    IF NOT EXISTS (
        SELECT 1 
        FROM titleauthor ta
        JOIN sales s ON ta.title_id = s.title_id
        WHERE ta.au_id = @au_id
    )
    BEGIN
        RAISERROR('Autor ma przypisane ksi��ki, ale nie ma �adnej sprzeda�y.', 16, 1);
        RETURN;
    END

    -- Zwr�cenie podsumowania sprzeda�y ksi��ek autora
    SELECT 
        a.au_id,
        a.au_fname,
        a.au_lname,
        t.title,
        SUM(s.qty) AS total_sales
    FROM authors a
    JOIN titleauthor ta ON a.au_id = ta.au_id
    JOIN titles t ON ta.title_id = t.title_id
    JOIN sales s ON t.title_id = s.title_id
    WHERE a.au_id = @au_id
    GROUP BY a.au_id, a.au_fname, a.au_lname, t.title
    ORDER BY total_sales DESC;
END;
GO


EXEC GetAuthorSalesSummary @au_id = '409-56-7008';