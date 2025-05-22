-- Zadanie 1
SELECT title
FROM titles
WHERE pub_id IN (
    SELECT pub_id
    FROM publishers
    WHERE state = 'CA'
);

-- Zadanie 2
SELECT 
    title,
    ISNULL(price, 0) AS price,
    (SELECT AVG(ISNULL(price, 0)) FROM titles) AS average_price
FROM titles;

-- Zadanie 3
SELECT au_lname, au_fname
FROM authors
WHERE au_id IN (
    SELECT au_id
    FROM titleauthor
    WHERE title_id IN (
        SELECT title_id
        FROM titles
        WHERE ISNULL(price, 0) > (
            SELECT AVG(ISNULL(price, 0)) FROM titles
        )
    )
);

-- Zadanie 4
SELECT 
    p.pub_name,
    ISNULL(CAST(avg_prices.avg_price AS VARCHAR(20)), 'NO DATA') AS average_price
FROM (
    SELECT pub_id, AVG(ISNULL(price, 0)) AS avg_price
    FROM titles
    GROUP BY pub_id
) AS avg_prices
JOIN publishers p ON p.pub_id = avg_prices.pub_id;

-- Zadanie 5
SELECT pub_name
FROM publishers
WHERE pub_id IN (
    SELECT pub_id
    FROM titles
    GROUP BY pub_id
    HAVING COUNT(*) > 5
);

-- Zadanie 6
UPDATE titles
SET price = price * 1.1
WHERE ISNULL(price, 0) < (
    SELECT AVG(ISNULL(price, 0)) FROM titles
);

-- Zadanie 7
SELECT 
    au_lname, 
    au_fname, 
    (SELECT COUNT(*) FROM titleauthor t WHERE t.au_id = a.au_id) AS books_written
FROM authors a;

-- Zadanie 8.1 – dodanie sklepu fikcyjnego
IF NOT EXISTS (SELECT * FROM stores WHERE stor_id = 0)
BEGIN
    INSERT INTO stores (stor_id, stor_name, stor_address, city, state, zip)
    VALUES (0, 'Withdrawn', 'n/a', 'n/a', 'NA', '00000');
END

-- Zadanie 8.2 – dodanie niesprzedanych książek do sales
INSERT INTO sales (stor_id, ord_num, ord_date, qty, payterms, title_id)
SELECT 
    0, 
    -1, 
    GETDATE(), 
    0, 
    'n/a',
    title_id
FROM titles
WHERE title_id NOT IN (SELECT title_id FROM sales);