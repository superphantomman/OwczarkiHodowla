USE master
GO
-- Tworzenie użytkowników na poziomie serwera
CREATE LOGIN hodowca123 WITH
    PASSWORD = N'hodowca123',
    CHECK_EXPIRATION = OFF,
    CHECK_POLICY = OFF;
GO

CREATE LOGIN zaopatrzeniowiec456 WITH
    PASSWORD = N'zaopatrzeniowiec456',
    CHECK_EXPIRATION = OFF,
    CHECK_POLICY = OFF;
GO

CREATE LOGIN mediamedia789 WITH
    PASSWORD = N'mediamedia789',
    CHECK_EXPIRATION = OFF,
    CHECK_POLICY = OFF;
GO

CREATE LOGIN kierownik123 WITH
    PASSWORD = N'kierownik123',
    CHECK_EXPIRATION = OFF,
    CHECK_POLICY = OFF;
GO

CREATE LOGIN Wlasciciel WITH
    PASSWORD = N'Wlasciciel123',
    CHECK_EXPIRATION = OFF,
    CHECK_POLICY = OFF;
GO

USE OwczarkiHodowla
GO

-- Ustawienie domyślnej bazy danych dla logins
ALTER LOGIN hodowca123 WITH DEFAULT_DATABASE = [OwczarkiHodowla];
ALTER LOGIN zaopatrzeniowiec456 WITH DEFAULT_DATABASE = [OwczarkiHodowla];
ALTER LOGIN kierownik123 WITH DEFAULT_DATABASE = [OwczarkiHodowla];
ALTER LOGIN Wlasciciel WITH DEFAULT_DATABASE = [OwczarkiHodowla];

-- Tworzenie roli Wlasciciel dla bazy danych, dodanie db_owner roli
CREATE USER Wlasciciel FOR LOGIN Wlasciciel;
EXEC sp_addrolemember 'db_owner', 'Wlasciciel';

-- Tworzenie ról
CREATE ROLE Hodowca AUTHORIZATION dbo;
CREATE ROLE Zaopatrzeniowiec AUTHORIZATION dbo;
CREATE ROLE SpecjalistaMediow AUTHORIZATION dbo;
CREATE ROLE Kierownik AUTHORIZATION dbo;

-- Nadanie uprawnień

-- Hodowca
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::hodowla TO Hodowca;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::klienci TO Hodowca;
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::magazyn TO Hodowca;

-- Zaopatrzeniowiec
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::magazyn TO Zaopatrzeniowiec;

-- SpecjalistaMediow
GRANT SELECT ON SCHEMA::klienci TO SpecjalistaMediow;

-- Kierownik
GRANT SELECT ON SCHEMA::dbo TO Kierownik;
DENY INSERT, UPDATE, DELETE ON SCHEMA::dbo TO Kierownik;

-- Tworzenie przykładowych użytkowników
CREATE USER hodowca123 FOR LOGIN hodowca123;
CREATE USER zaopatrzeniowiec456 FOR LOGIN zaopatrzeniowiec456;
CREATE USER mediamedia789 FOR LOGIN mediamedia789;
CREATE USER kierownik123 FOR LOGIN kierownik123;

-- Przypisanie użytkowników do ich ról

ALTER ROLE Hodowca ADD MEMBER hodowca123;
ALTER ROLE Zaopatrzeniowiec ADD MEMBER zaopatrzeniowiec456;
ALTER ROLE SpecjalistaMediow ADD MEMBER mediamedia789;
ALTER ROLE Kierownik ADD MEMBER kierownik123;


-- Hodowca
EXECUTE AS LOGIN = 'hodowca123';
-- Przykład modyfikacji (UPDATE) w tabeli, która jest dozwolona dla Hodowcy
UPDATE hodowla.Pieski SET opis = 'Nowy opis' WHERE id = 1;
-- Przykład niepowodzenia modyfikacji w tabeli, do której nie ma dostępu
UPDATE magazyn.Magazyn SET ilosc = ilosc + 1 WHERE id = 1; -- To powinno zakończyć się błędem
REVERT;

-- Zaopatrzeniowiec
EXECUTE AS LOGIN = 'zaopatrzeniowiec456';
-- Przykład modyfikacji (INSERT) w tabeli, która jest dozwolona dla Zaopatrzeniowca
INSERT INTO magazyn.Magazyn (nazwa, ilosc, cena) VALUES ('Nowy produkt', 10, 29.99);
-- Przykład niepowodzenia modyfikacji w tabeli, do której nie ma dostępu
UPDATE hodowla.Pieski SET opis = 'Nowy opis' WHERE id = 1; -- To powinno zakończyć się błędem
REVERT;

-- SpecjalistaMediow
EXECUTE AS LOGIN = 'mediamedia789';
-- Przykład modyfikacji (DELETE) w tabeli, która jest dozwolona dla Specjalisty Mediów
DELETE FROM klienci.Opinie WHERE id = 1;
-- Przykład niepowodzenia modyfikacji w tabeli, do której nie ma dostępu
UPDATE magazyn.Magazyn SET ilosc = ilosc - 1 WHERE id = 1; -- To powinno zakończyć się błędem
REVERT;

-- Kierownik
EXECUTE AS LOGIN = 'kierownik123';
-- Przykład modyfikacji (INSERT) w tabeli, która jest dozwolona dla Kierownika
INSERT INTO klienci.Wlasciciele (imie, nazwisko, adresId) VALUES ('Jan', 'Kowalski', 1);
-- Przykład niepowodzenia modyfikacji w tabeli, do której nie ma dostępu
UPDATE hodowla.Pieski SET opis = 'Nowy opis' WHERE id = 1; -- To powinno zakończyć się błędem
REVERT;
