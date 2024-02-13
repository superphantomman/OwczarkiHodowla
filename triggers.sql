USE OwczarkiHodowla
GO

--Wiadomosc do sprawdzajacego trigger powinny byc tworzone osobno inaczej blad jest wyrzucony
--Pozdrawiam

--Trigger sprawdzający poprawność danych rodziców względem innych tabel
CREATE TRIGGER CheckParents
ON hodowla.Rodowody
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @piesekId INT, @matkaId INT, @ojciecId INT, @opis NVARCHAR(400), @opis_kopia NVARCHAR(400)

    SELECT @piesekId = i.piesekId, @matkaId = i.matkaId, @ojciecId = i.ojciecId, @opis = i.opis, @opis_kopia = i.opis FROM inserted i;

    IF @matkaId IS NULL AND @opis_kopia IS NULL
    BEGIN
        SET @opis = 'Matka z poza hodowli';
    END

    IF @ojciecId IS NULL AND @opis_kopia IS NULL
    BEGIN
        SET @opis = CONCAT(@opis, CHAR(13), CHAR(10), 'Ojciec z poza hodowli');
    END

    IF NOT EXISTS (SELECT 1 FROM hodowla.Pieski p WHERE p.id = @piesekId)
    BEGIN
        RAISERROR('Błąd piesek o podanym id nie istnieje w bazie.', 16, 1);
        
    END

    IF NOT EXISTS (SELECT 1 FROM hodowla.Pieski p WHERE p.id = @matkaId)
    BEGIN
        RAISERROR('Błąd matka pieska o podanym id nie istnieje w bazie.', 16, 1);
        
    END

    IF NOT EXISTS (SELECT 1 FROM hodowla.Pieski p WHERE p.id = @ojciecId)
    BEGIN
        RAISERROR('Błąd ojciec o podanym id nie istnieje w bazie.', 16, 1);
        
    END

	DECLARE @dataUrodzenia DATE = (SELECT dataUrodzenia FROM hodowla.Pieski p WHERE p.id = @piesekId );
    -- Check birthdate condition
    IF EXISTS (
        SELECT 1
        FROM hodowla.Pieski p
        WHERE p.id IN (@matkaId, @ojciecId)
            AND @dataUrodzenia > p.dataUrodzenia
    )
    BEGIN
        RAISERROR('Błąd: Ani matka ani ojciec nie mogą być młodsi od dziecka', 16, 1);
        
    END

    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.ojciecId = i.matkaId
            OR i.ojciecId = i.piesekId
            OR i.matkaId = i.piesekId
    )
    BEGIN
        RAISERROR('Błąd: Żaden z kluczy nie powinien być sobie równy.', 16, 1);
        
    END

    INSERT INTO hodowla.Rodowody (piesekId, ojciecId, matkaId, opis) VALUES (@piesekId, @ojciecId, @matkaId, @opis);
END;
;

-- Trigger blokujący ponowną adopcje pieska, jeśli znajduje się w tabeli adopcje
-- sprawdza również unikalność pieska w tabeli Adopcje
CREATE TRIGGER CheckPiesekAdopcja
ON hodowla.Adopcje
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (
        SELECT p.id
        FROM hodowla.Pieski p
        WHERE p.id = (SELECT i.piesekId FROM inserted i)
    )
    BEGIN
        RAISERROR('Piesek o podanym id nie istnieje w bazie.', 16, 1);
    END;
    IF NOT EXISTS (
        SELECT w.id
        FROM klienci.Wlasciciele w
        WHERE w.id = (SELECT i.wlascicielId FROM inserted i)
    )
    BEGIN
        RAISERROR('Wlasciciel o podanym id nie istnieje', 16, 1);
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.piesekId IN (SELECT piesekId FROM hodowla.Adopcje)
    )
    BEGIN
        RAISERROR('Piesek o podanym id już jest adoptowany.', 16, 1);
    END
    ELSE
    BEGIN
        -- Jeśli nie ma konfliktu, wykonaj normalnie INSERT
        INSERT INTO hodowla.Adopcje (wlascicielId, piesekId, dataAdopcji, cena)
        SELECT wlascicielId, piesekId, dataAdopcji, cena FROM inserted;
    END;
END;
;

-- CheckMagazyn Trigger
CREATE TRIGGER CheckMagazyn
ON magazyn.Magazyn
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted i LEFT JOIN magazyn.Produkty p ON i.produktId = p.id WHERE p.id IS NULL)
    BEGIN
        RAISERROR('Product ID does not exist in the Produkty table.', 16, 1);
        
        RETURN;
    END;
    
    INSERT INTO magazyn.Magazyn (ilosc, cena, produktId)
    SELECT ilosc, cena, produktId
    FROM inserted;
END;


-- CheckWlasciciele Trigger
CREATE TRIGGER CheckWlasciciele
ON klienci.Wlasciciele
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted i LEFT JOIN Adresy a ON i.adresId = a.id WHERE a.id IS NULL)
    BEGIN
        RAISERROR('Address ID does not exist in the Adresy table.', 16, 1);
        
        RETURN;
    END;
END;


-- CheckOpinie Trigger
CREATE TRIGGER CheckOpinie
ON klienci.Opinie
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted i LEFT JOIN klienci.Wlasciciele w ON i.wlascicielId = w.id WHERE w.id IS NULL)
    BEGIN
        RAISERROR('Owner ID does not exist in the Wlasciciele table.', 16, 1);
        
        RETURN;
    END;
END;


-- CheckNotatki Trigger
CREATE TRIGGER CheckNotatki
ON hodowla.Notatki
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted i LEFT JOIN hodowla.Pieski p ON i.piesekId = p.id WHERE p.id IS NULL)
    BEGIN
        RAISERROR('Dog ID does not exist in the Pieski table.', 16, 1);
        
        RETURN;
    END;
END;


-- CheckAdopcje Trigger
CREATE TRIGGER CheckAdopcje
ON hodowla.Adopcje
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i 
        LEFT JOIN klienci.Wlasciciele w ON i.wlascicielId = w.id 
        LEFT JOIN hodowla.Pieski p ON i.piesekId = p.id
        LEFT JOIN hodowla.Zgony z ON i.piesekId = z.piesekId
        WHERE w.id IS NULL OR p.id IS NULL OR z.id IS NOT NULL
    )
    BEGIN
        RAISERROR('Owner ID, Dog ID, or Dog has already been adopted or is deceased.', 16, 1);
        
        RETURN;
    END;
END;


-- CheckDaneKontaktowe Trigger
CREATE TRIGGER CheckDaneKontaktowe
ON firma.DaneKontaktowe
AFTER INSERT, UPDATE
AS
BEGIN
    -- Sprawdzenie, czy pracownik o podanym ID istnieje
    IF NOT EXISTS (SELECT 1 FROM inserted i
               LEFT JOIN firma.Pracownicy p ON i.pracownikId = p.id)
    BEGIN
        RAISERROR('Employee with the given ID does not exist in the Pracownicy table.', 16, 1);
        
        RETURN;
    END;

    -- Sprawdzenie, czy adres o podanym ID istnieje
    IF NOT EXISTS (SELECT 1 FROM inserted i
               LEFT JOIN Adresy a ON i.adresId = a.id
               WHERE a.id IS NULL)
    BEGIN
        RAISERROR('Address ID does not exist in the Adresy table.', 16, 1);
        
        RETURN;
    END;
END;


-- CheckPracownicy Trigger
CREATE TRIGGER CheckPracownicy
ON firma.Pracownicy
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i 
        LEFT JOIN firma.Stanowiska s ON i.stanowiskoId = s.id 
        WHERE i.wynagrodzenieBrutto < s.wynagrodzenieNetto
    )
    BEGIN
        RAISERROR('Gross salary is less than net salary for the specified position.', 16, 1);
        
        RETURN;
    END;
END;


-- CheckCertyfikatyPieskow Trigger
CREATE TRIGGER [hodowla].[CheckCertyfikatyPieskow]
ON [hodowla].[CertyfikatyPieskow]
AFTER INSERT, UPDATE
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM inserted i 
        LEFT JOIN hodowla.Certyfikaty c ON i.certyfikatId = c.id
        LEFT JOIN hodowla.Pieski p ON i.piesekId = p.id
        LEFT JOIN hodowla.Zgony z ON i.piesekId = z.piesekId AND i.dataZdobycia > z.dataZgonu
        WHERE i.dataZdobycia >= p.dataUrodzenia OR i.dataZdobycia >= GETDATE() OR z.id IS NOT NULL
    )
    BEGIN
        RAISERROR('Invalid certificate or dog ID, or certificate issue date.', 16, 1);
        
        RETURN;
    END;
END;

--CheckDietaPieska
ALTER TRIGGER [hodowla].[CheckDietaPieska]
ON [hodowla].[DietaPieska]
AFTER INSERT, UPDATE
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM inserted i INNER JOIN hodowla.Pieski p ON i.piesekId = p.id INNER JOIN hodowla.Pokarm pk ON i.jedzenieId = pk.id)
    BEGIN
        RAISERROR('Dog ID or Food ID does not exist in the respective tables.', 16, 1);
        
        RETURN;
    END;
END;
-- CheckTresury Trigger
CREATE TRIGGER CheckTresury
ON hodowla.Tresury
AFTER INSERT, UPDATE
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM inserted i 
        LEFT JOIN hodowla.Pieski p ON i.piesekId = p.id 
        LEFT JOIN hodowla.Treserzy t ON i.treserId = t.id 
        WHERE i.dataRozpoczecia >= i.dataZakonczenia OR i.dataRozpoczecia < p.dataUrodzenia OR i.dataZakonczenia >= GETDATE() OR p.id IS NULL OR t.id IS NULL
    )
    BEGIN
        RAISERROR('Invalid start or end date, dog ID, or trainer ID.', 16, 1);
        
        RETURN;
    END;
END;


-- CheckWystawy Trigger
CREATE TRIGGER CheckWystawy
ON hodowla.Wystawy
AFTER INSERT, UPDATE
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM inserted i 
        LEFT JOIN hodowla.Uczestnictwa u ON i.id = u.wystawaId 
        WHERE i.dataOdbycia < GETDATE() OR u.piesekId IS NOT NULL
    )
    BEGIN
        RAISERROR('Invalid exhibition date or exhibition already has participants.', 16, 1);
        
        RETURN;
    END;
END;


-- CheckZny Trigger
CREATE TRIGGER CheckZgony
ON hodowla.Zgony
AFTER INSERT, UPDATE
AS
BEGIN
    -- Sprawdzenie, czy pies o podanym ID istnieje
    IF NOT EXISTS (
        SELECT 1 FROM inserted i
        LEFT JOIN hodowla.Pieski p ON i.piesekId = p.id
        WHERE p.id IS NULL
    )
    BEGIN
        RAISERROR('Dog with the given ID does not exist in the Pieski table.', 16, 1);
        
        RETURN;
    END;


    IF EXISTS (
        SELECT 1 FROM inserted i 
        LEFT JOIN hodowla.Pieski p ON i.piesekId = p.id 
        WHERE i.dataZgonu < p.dataUrodzenia
    )
    BEGIN
        RAISERROR('Invalid death date, dog ID, or dog is not born yet.', 16, 1);
        
        RETURN;
    END;
END;


-- CheckKlienci Trigger
CREATE TRIGGER CheckKlienci
ON klienci.Klienci
AFTER INSERT, UPDATE
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM inserted i LEFT JOIN Adresy a ON i.adresId = a.id WHERE a.id IS NULL)
    BEGIN
        RAISERROR('Address ID does not exist in the Adresy table.', 16, 1);
        
        RETURN;
    END;
END;


-- CheckDostawcy Trigger
CREATE TRIGGER CheckDostawcy
ON magazyn.Dostawcy
AFTER INSERT, UPDATE
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM inserted i LEFT JOIN Adresy a ON i.adresId = a.id WHERE a.id IS NULL)
    BEGIN
        RAISERROR('Address ID does not exist in the Adresy table.', 16, 1);
        
        RETURN;
    END;
END;


-- CheckProdukty Trigger
CREATE TRIGGER CheckProdukty
ON magazyn.Produkty
AFTER INSERT, UPDATE
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM inserted i LEFT JOIN magazyn.Dostawcy d ON i.dostawcaId = d.id WHERE d.id IS NULL)
    BEGIN
        RAISERROR('Supplier ID does not exist in the Dostawcy table.', 16, 1);
        
        RETURN;
    END;
END;


-- CheckZamowienia Trigger
CREATE TRIGGER CheckZamowienia
ON klienci.Zamowienia
AFTER INSERT, UPDATE
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM inserted i 
        LEFT JOIN klienci.Klienci k ON i.klientId = k.id 
        LEFT JOIN magazyn.Produkty p ON i.produktId = p.id 
        LEFT JOIN magazyn.Magazyn m ON i.produktId = m.produktId 
        WHERE k.id IS NULL OR p.id IS NULL OR m.ilosc < i.ilosc
    )
    BEGIN
        RAISERROR('Invalid client ID, product ID, or insufficient product quantity in the warehouse.', 16, 1);
        
        RETURN;
    END;
END;


-- CheckPracownicy Trigger
CREATE TRIGGER CheckPracownicy
ON firma.Pracownicy
AFTER INSERT, UPDATE
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM inserted i 
        LEFT JOIN firma.Stanowiska s ON i.stanowiskoId = s.id 
        WHERE i.wynagrodzenieBrutto < s.wynagrodzenieNetto
    )
    BEGIN
        RAISERROR('Gross salary is less than net salary for the specified position.', 16, 1);
        
        RETURN;
    END;
END;


-- CheckDaneKontaktowe Trigger
CREATE TRIGGER CheckDaneKontaktowe
ON firma.DaneKontaktowe
AFTER INSERT, UPDATE
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM inserted i LEFT JOIN Adresy a ON i.adresId = a.id WHERE a.id IS NULL)
    BEGIN
        RAISERROR('Address ID does not exist in the Adresy table.', 16, 1);
        
        RETURN;
    END;
END;


CREATE TRIGGER CheckWyplaty
ON firma.Wyplaty
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN firma.Pracownicy p ON i.pracownikId = p.id
        LEFT JOIN firma.Zwolnieni z ON i.pracownikId = z.pracownikId
        WHERE p.id IS NULL OR z.pracownikId IS NOT NULL
    )
    BEGIN
        RAISERROR('Employee does not exist or is already dismissed.', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO firma.Wyplaty (id, dataPrzelewu, wartoscPrzelewu, pracownikId)
        SELECT id, dataPrzelewu, wartoscPrzelewu, pracownikId
        FROM inserted;
    END
END;


CREATE TRIGGER CheckDeletedProdukt
ON magazyn.Produkty
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM magazyn.Magazyn
    WHERE produktId IN (SELECT id FROM deleted);
    
    DELETE FROM magazyn.Produkty
    WHERE id IN (SELECT id FROM deleted);
END;


