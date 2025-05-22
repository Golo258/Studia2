-- Utworzenie tabeli logów
IF OBJECT_ID('authors_log', 'U') IS NOT NULL
    DROP TABLE authors_log;
GO

CREATE TABLE authors_log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    au_id VARCHAR(11),
    action VARCHAR(100),
    event_time DATETIME
);
GO

-- 1. Trigger: logowanie dodania autora
CREATE TRIGGER trg_authors_insert_log
ON authors
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO authors_log (au_id, action, event_time)
    SELECT au_id, 'INSERT', GETDATE()
    FROM inserted;
END;
GO

-- 2. Trigger: logowanie usunięcia autora
CREATE TRIGGER trg_authors_delete_log
ON authors
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO authors_log (au_id, action, event_time)
    SELECT au_id, 'DELETE', GETDATE()
    FROM deleted;
END;
GO

-- 3. Trigger: logowanie aktualizacji nazwiska autora
CREATE TRIGGER trg_authors_update_log
ON authors
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO authors_log (au_id, action, event_time)
    SELECT 
        i.au_id,
        'UPDATE last name from "' + d.au_lname + '" to "' + i.au_lname + '"',
        GETDATE()
    FROM inserted i
    JOIN deleted d ON i.au_id = d.au_id
    WHERE i.au_lname <> d.au_lname;
END;
GO

-- 4. Trigger: walidacja numeru telefonu (12 znaków) przed dodaniem
CREATE TRIGGER trg_authors_phone_check_insert
ON authors
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM inserted WHERE LEN(phone) <> 12
    )
    BEGIN
        RAISERROR('Phone number must be exactly 12 characters.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    INSERT INTO authors (au_id, au_lname, au_fname, phone, address, city, state, zip, contract)
    SELECT au_id, au_lname, au_fname, phone, address, city, state, zip, contract
    FROM inserted;
END;
GO

-- 5. Trigger: blokada usuwania autora mającego książki
CREATE TRIGGER trg_authors_block_delete_with_books
ON authors
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 
        FROM deleted d
        JOIN titleauthor ta ON ta.au_id = d.au_id
    )
    BEGIN
        RAISERROR('Cannot delete author with assigned books.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    DELETE FROM authors WHERE au_id IN (SELECT au_id FROM deleted);
END;
GO

-- 6. Trigger: walidacja formatu numeru telefonu przy UPDATE
CREATE TRIGGER trg_authors_phone_check_update
ON authors
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE LEN(phone) <> 12 OR phone IS NULL
    )
    BEGIN
        RAISERROR('Phone number must be exactly 12 characters and not null.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    UPDATE authors
    SET 
        au_lname = i.au_lname,
        au_fname = i.au_fname,
        phone = i.phone,
        address = i.address,
        city = i.city,
        state = i.state,
        zip = i.zip,
        contract = i.contract
    FROM authors a
    JOIN inserted i ON a.au_id = i.au_id;
END;
GO
