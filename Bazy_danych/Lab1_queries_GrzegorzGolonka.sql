USE pubs;
GO;

-- 1) ZnajdŸ autorów, których imiê zaczyna siê na 'M' a koñczy na 'R'
SELECT * 
FROM authors 
WHERE au_fname LIKE 'M%R';




-- Zadanie 2: ZnajdŸ tytu³y, które koñcz¹ siê znakiem zapytania
SELECT * 
FROM titles 
WHERE title LIKE '%?';

-- Zadanie 3: ZnajdŸ sprzeda¿e, których data zamówienia jest pomiêdzy 06.1993 a 10.1994
SELECT * 
FROM sales 
WHERE ord_date BETWEEN '1993-06-01' AND '1994-10-31';

-- Zadanie 4: ZnajdŸ sklepy, których kod pocztowy znajduje siê w przedziale 80000 a 95000
SELECT * 
FROM stores 
WHERE CAST(zip AS INT) BETWEEN 80000 AND 95000;

-- Zadanie 5: Zwróæ inicja³y wszystkich autorów
SELECT CONCAT(LEFT(au_lname, 1), '.', LEFT(au_fname, 1), '.') AS initials
FROM authors;

-- 6) Wyœwietl numery telefonów autorów jako numeryczne (bez spacji oraz myœlnika)
SELECT au_id, au_fname, au_lname, 
       REPLACE(REPLACE(phone, ' ', ''), '-', '') AS phone_clean
FROM authors;

-- 7) Wyœwietl w jednym wyniku imiê oraz nazwisko autorów i pracowników
SELECT au_fname AS first_name, au_lname AS last_name, 'Author' AS role
FROM authors
UNION ALL
SELECT fname AS first_name, lname AS last_name, 'Employee' AS role
FROM employee;

-- 8) Zwróæ iloœæ publikacji z podzia³em na lata
SELECT YEAR(pubdate) AS publication_year, COUNT(*) AS publication_count
FROM titles
GROUP BY YEAR(pubdate)
ORDER BY publication_year;

-- 9) ZnajdŸ kategorie ksi¹¿ek, które posiadaj¹ œredni¹ cenê powy¿ej 15
SELECT type, AVG(price) AS avg_price
FROM titles
GROUP BY type
HAVING AVG(price) > 15;

-- 10) Zwróæ imiê, nazwisko, stanowisko pracownika oraz stan wydawnictwa dla pracowników zatrudnionych przed 1994 rokiem
SELECT e.fname, e.lname, j.job_desc, 
       COALESCE(p.state, 'NA') AS publisher_state
FROM employee e
JOIN jobs j ON e.job_id = j.job_id
JOIN publishers p ON e.pub_id = p.pub_id
WHERE e.hire_date < '1994-01-01'
ORDER BY p.pub_name, j.job_desc;

-- 11) W bazie danych [pubs] jest tabela z list¹ ksi¹¿ek [titles].
-- Nale¿y utworzyæ now¹ tabelê z referencj¹ (do titles) w której bêdzie mo¿liwoœæ przechowywania recenzji od u¿ytkowników.
-- Tabela powinna zawieraæ takie informacje jak:
-- tekst recenzji
-- datê dodania recenzji - gdy nie podana powinna byæ "teraz"
-- imiê oraz nazwisko recenzenta - mo¿e nie byæ podane
-- ocene u¿ytkownika w skali 1 do 5
-- powinna byæ mo¿liwoœæ dodania wielu recenzji do jednej ksi¹¿ki

CREATE TABLE reviews (
    review_id INT IDENTITY(1,1) PRIMARY KEY,
    title_id tid NOT NULL REFERENCES titles(title_id),
    review_text TEXT NOT NULL,
    review_date DATETIME DEFAULT GETDATE(),
    reviewer_fname VARCHAR(50) NULL,
    reviewer_lname VARCHAR(50) NULL,
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5)
);

-- uzupe³nij tabele o przynajmniej 5 rekordów.
INSERT INTO reviews (title_id, review_text, reviewer_fname, reviewer_lname, rating)
VALUES 
    ('PC1035', 'Œwietna ksi¹¿ka, bardzo wci¹gaj¹ca!', 'Jan', 'Kowalski', 5),
    ('PS1372', 'Nieco nudna, ale dobrze napisana.', 'Anna', NULL, 3),
    ('BU1111', 'Dobra lektura na wieczór.', 'Micha³', 'Nowak', 4),
    ('PS7777', 'Nie polecam, za du¿o d³u¿yzn.', NULL, NULL, 2),
    ('TC4203', 'Klasyka gatunku, ka¿dy powinien przeczytaæ.', 'Ewa', 'Wiœniewska', 5);


-- 12)  widok podsumowania przychodów poszczególnych autorów[authors, titleauthor, titles, sales]
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


-- 13)   przychody wydawców z podzia³em na miesi¹ce[publishers, titles, sales]

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
-- 14)   Napisz funkcje skalarn¹ która oblicza ca³kowit¹ sprzeda¿ ksi¹¿ki na podstawie title_id.[sales.qty]
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

-- Przykladowe U¿ycie
SELECT dbo.GetTotalSales('PC1035') AS total_sales;


-- 15)   Napisz funkcje skalarn¹ która oblicza œredni¹ cenê ksi¹¿ek wydawcy[publisher] na podstawie pub_id [titles.price].

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


-- 16)   Napisz procedurê która dodaje nowego autora do bazy danych, sprawdzaj¹c najpierw, 
-- czy autor o podanym imieniu oraz nazwisku ju¿ istnieje. Jeœli tak, zwraca b³¹d. 
-- Zwróæ uwagê ¿e id nie jest autoinkrementowalne i nale¿y zapewniæ w jakiœ sposób unikatowy ci¹g np czas

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
        RAISERROR('Autor o podanym imieniu i nazwisku ju¿ istnieje.', 16, 1);
        RETURN;
    END

    DECLARE @new_au_id VARCHAR(11);
    SET @new_au_id = 
        RIGHT('000' + CAST(DATEPART(ms, GETDATE()) % 1000 AS VARCHAR), 3) + '-' + 
        RIGHT('00' + CAST(DATEPART(ss, GETDATE()) AS VARCHAR), 2) + '-' + 
        RIGHT('0000' + CAST(DATEPART(mi, GETDATE()) AS VARCHAR), 4);

    INSERT INTO authors (au_id, au_fname, au_lname, phone, address, city, state, zip, contract)
    VALUES (@new_au_id, @first_name, @last_name, @phone, @address, @city, @state, @zip, @contract);

    PRINT 'Autor dodany pomyœlnie. ID: ' + @new_au_id;
END;
GO

-- wywo³anie
EXEC AddNewAuthor 
    @first_name = 'John', 
    @last_name = 'Doe', 
    @phone = '123-456-7890', 
    @address = '123 Main St', 
    @city = 'New York', 
    @state = 'NY', 
    @zip = '10001', 
    @contract = 1;


--  17)   Napisz procedure która usuwa ksi¹¿kê dla przekazanego w parametrze id [titles.title_id]
--  (prawdopodobnie trzeba wiêcej delete ni¿ jedna tabela). 
-- Jeœli rekord o danym id nie istnieje nale¿y zwróciæ b³¹d z odpowiednim komunikatem. 
--  Spróbowaæ dla title_id = 'BU1032', jeœli potrafisz u¿yj transakcji.

CREATE PROCEDURE DeleteBook
    @title_id CHAR(6)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM titles WHERE title_id = @title_id)
    BEGIN
        RAISERROR('Ksi¹¿ka o podanym title_id nie istnieje.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;

    BEGIN TRY
        DELETE FROM sales WHERE title_id = @title_id;
        DELETE FROM titleauthor WHERE title_id = @title_id;
        DELETE FROM roysched WHERE title_id = @title_id;
        DELETE FROM reviews WHERE title_id = @title_id; -- Jeœli masz recenzje

        DELETE FROM titles WHERE title_id = @title_id;

        COMMIT TRANSACTION;

        PRINT 'Ksi¹¿ka oraz powi¹zane dane zosta³y usuniête.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH;
END;
GO

--- wywo³anie
EXEC DeleteBook @title_id = 'BU1032';



-- 18)   Napisz procedure która wyœwietli podsumowanie sprzeda¿y(sume z sales.qty) 
-- ksi¹¿ek danego autora na podstawie przekazanego id [titleauthor.au_id]. 
-- jeœli autor nie istnieje lub nie ma ¿adnych tytu³ów nalezy zwróciæ b³¹d z odpowiednim komunikatem.

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

    -- Sprawdzenie, czy autor ma przypisane ksi¹¿ki
    IF NOT EXISTS (SELECT 1 FROM titleauthor WHERE au_id = @au_id)
    BEGIN
        RAISERROR('Autor nie ma przypisanych ¿adnych ksi¹¿ek.', 16, 1);
        RETURN;
    END

    -- Sprawdzenie, czy autor ma jakiekolwiek sprzeda¿e
    IF NOT EXISTS (
        SELECT 1 
        FROM titleauthor ta
        JOIN sales s ON ta.title_id = s.title_id
        WHERE ta.au_id = @au_id
    )
    BEGIN
        RAISERROR('Autor ma przypisane ksi¹¿ki, ale nie ma ¿adnej sprzeda¿y.', 16, 1);
        RETURN;
    END

    -- Zwrócenie podsumowania sprzeda¿y ksi¹¿ek autora
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