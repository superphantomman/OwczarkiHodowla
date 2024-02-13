CREATE PROCEDURE SprawdzCzyRekordIstnieje
    @tabela NVARCHAR(255),
    @klucz INT
AS
BEGIN
    IF @klucz IS NULL
    BEGIN
        DECLARE @errorMsg NVARCHAR(255);
        SET @errorMsg = CONCAT('Null is not acceptable for key from table ',  @tabela);
        RAISEERROR (@errorMsg, 16, 1);
        RETURN;
    END

    DECLARE @query NVARCHAR(1000);
    SET @query = 'IF NOT EXISTS (SELECT 1 FROM ' + @tabela + ' WHERE id = ' + CAST(@klucz AS NVARCHAR(10)) + ')
                    BEGIN
                        DECLARE @errorMsg NVARCHAR(255);
                        SET @errorMsg = ''Rekord o id '' + CAST(' + CAST(@klucz AS NVARCHAR(10)) + ' AS NVARCHAR(10)) + '' nie istnieje w tabeli ' + @tabela + '.'';
                        RAISEERROR (@errorMsg, 16, 1);
                    END';
    EXEC sp_executesql @query;
END;


-- Procedura do wyliczenia kosztu dla psa o podanym id
CREATE PROCEDURE WyliczKosztWizytPieska
    @piesekId INT
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.SprawdzCzyRekordIstnieje 'hodowla.Pieski', @piesekId;

    DECLARE @TotalCost SMALLMONEY;

    SELECT @TotalCost = SUM(koszt)
    FROM hodowla.WizytyWeterynaryjne WITH(INDEX(IX_WizytyWeterynaryjne_Koszt_PiesekId))
    WHERE piesekId = @piesekId;

    SELECT @TotalCost AS TotalCost;
END

-- Procedura do pełnotekstowego wyszukiwania piesków po opisie
CREATE PROCEDURE SzukajPieskaPoOpisie
    @szukane NVARCHAR(255)
AS
BEGIN
    SELECT *
    FROM hodowla.Pieski
    WHERE CONTAINS(opis, @szukane);
END;

-- Procedura do pełnotekstowego wyszukiwania piesków po notatce
CREATE PROCEDURE SzukajPsaPoNotatce
    @szukane NVARCHAR(400)
AS
BEGIN
    SELECT P.id AS PiesId, P.imie AS ImiePsa, P.rasa AS RasaPsa, N.id AS NotatkaId, N.notatka AS Notatka, N.dataPublikacji
    FROM hodowla.Pieski P
    INNER JOIN hodowla.Notatki N ON P.id = N.piesekId
    WHERE CONTAINS(N.notatka, @szukane);
END;

-- Procedura obliczająca średnią ocen
CREATE PROCEDURE ObliczSredniaOcen
AS
BEGIN
    SELECT
        AVG(CAST(ocena AS FLOAT)) AS ogolnaSredniaOcena
    FROM klienci.Opinie;
END;

-- Procedura do przeszukiwania opinii wg określonych słów lub fraz
CREATE PROCEDURE SzukajOpinie
    @szukane NVARCHAR(400)
AS
BEGIN
    SELECT
        id,
        wlascicielId,
        ocena,
        opinia
    FROM klienci.Opinie
    WHERE CONTAINS(opinia, @szukane);
END;

-- Procedura szukająca dane o psach danego właściciela
CREATE PROCEDURE SzukajDaneOPsachWlasciciela
    @wlascicielId INT
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.SprawdzCzyRekordIstnieje 'hodowla.Wlasciciele', @wlascicielId;

    SELECT P.id AS PiesekId, P.imie AS ImiePsa, P.rasa AS RasaPsa, A.dataAdopcji, A.cena
    FROM hodowla.Pieski P
    INNER JOIN hodowla.Adopcje A ON P.id = A.piesekId
    WHERE A.wlascicielId = @wlascicielId;
END;

-- Procedura dodająca adopcję na psa przez nowego właściciela
CREATE PROCEDURE DodajAdopcjeNowegoWlasciciela
    @imieWlasciciela NVARCHAR(255),
    @nazwiskoWlasciciela NVARCHAR(255),
    @kodPocztowy NVARCHAR(50),
    @miasto NVARCHAR(255),
    @ulica NVARCHAR(255),
    @numerDomu NVARCHAR(30),
    @piesekId INT,
    @cenaAdopcji SMALLMONEY
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    DECLARE @adresId INT;

    INSERT INTO klienci.Adresy (kodPocztowy, miasto, ulica, numerDomu)
    VALUES (@kodPocztowy, @miasto, @ulica, @numerDomu);
    SET @adresId = SCOPE_IDENTITY();

    DECLARE @wlascicielId INT;

    INSERT INTO hodowla.Wlasciciele (imie, nazwisko, adresId)
    VALUES (@imieWlasciciela, @nazwiskoWlasciciela, @adresId);
    SET @wlascicielId = SCOPE_IDENTITY();

    -- Dodaj adopcję do tabeli Adopcje
    INSERT INTO hodowla.Adopcje (wlascicielId, piesekId, dataAdopcji, cena)
    VALUES (@wlascicielId, @piesekId, GETDATE(), @cenaAdopcji);

    COMMIT;
END;

-- Procedura dodająca adopcję do istniejącego właściciela
CREATE PROCEDURE DodaAdopcjeIniejacegoWlasciciela
    @wlascicielId INT,
    @piesekId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Sprawdź, czy podane ID właściciela istnieje
    EXEC dbo.SprawdzCzyRekordIstnieje 'klienci.Wlasciciele', @wlascicielId;

    -- Sprawdź, czy podane ID psa istnieje
    EXEC dbo.SprawdzCzyRekordIstnieje 'hodowla.Pieski', @piesekId;

    BEGIN TRANSACTION;

    -- Wstawienie adopcji do tabeli Adopcje
    INSERT INTO hodowla.Adopcje (wlascicielId, piesekId, dataAdopcji, cena)
    VALUES (@wlascicielId, @piesekId, GETDATE(), 0.0);  -- Załóżmy, że cena adopcji wynosi 0.0, można dostosować

    -- Wstawienie właściciela do tabeli Wlasciciele (jeśli nie istnieje)
    EXEC dbo.SprawdzCzyRekordIstnieje 'klienci.Wlasciciele', @wlascicielId;

    COMMIT;
END;

--Procedura zaznaczająca śmierć danego pieska, przyjmuje się jej wykonanie na dzień tragedii
CREATE PROCEDURE OznaczSmiercPieska
    @piesekId INT, 
    @przyczyna NVARCHAR(60) = 'brak przyczyny'
AS
BEGIN
    -- Sprawdzenie czy piesek istnieje
    EXEC dbo.SprawdzCzyRekordIstnieje 'hodowla.Pieski', @piesekId;

    INSERT INTO hodowla.Zgony (piesekId, dataZgonu, przyczyna)
    VALUES (@piesekId, GETDATE(), @przyczyna);
END;

--Procedura dodająca tresure do bazy danych. Przyjmuje się, że bazowy stan jest taki, że pies uczestniczy w tresurze.
CREATE PROCEDURE RozpoczetaTresura
    @piesekId INT,
    @dataRozpoczecia DATE,
    @typ NVARCHAR(50),
    @opis NVARCHAR(255),
    @koszt SMALLMONEY,
    @treserId INT
AS
BEGIN
    -- Sprawdzenie czy piesek istnieje
    EXEC dbo.SprawdzCzyRekordIstnieje 'hodowla.Pieski', @piesekId;

    INSERT INTO hodowla.Tresury (dataRozpoczecia, piesekId, typ, opis, koszt, treserId)
    VALUES (COALESCE(@dataZakonczenia, GETDATE()), @piesekId, @typ, @opis, @koszt, @treserId);
END;

--Procedura zmieniająca stan tresury danego pieska na zakończony
CREATE PROCEDURE ZakonczenieTresury
    @piesekId INT,
    @dataZakonczenia DATE = NULL
AS
BEGIN
    -- Sprawdzenie czy piesek istnieje
    EXEC dbo.SprawdzCzyRekordIstnieje 'hodowla.Pieski', @piesekId;

    UPDATE hodowla.Tresury
    SET dataZakonczenia = COALESCE(@dataZakonczenia, GETDATE())
    WHERE piesekId = @piesekId AND dataZakonczenia IS NULL;
END;

--Procedura przypisująca danemu pieskowi certyfikat
CREATE PROCEDURE DodajCertyfikatPsowi
    @piesekId INT,
    @certyfikatId INT,
    @data DATE = NULL,
    @koszt SMALLMONEY
AS
BEGIN
    -- Sprawdzenie czy piesek istnieje
    EXEC dbo.SprawdzCzyRekordIstnieje 'hodowla.Pieski', @piesekId;

    INSERT INTO hodowla.CertyfikatyPieskow (piesekId, certyfikatId, dataZdobycia)
    VALUES (@piesekId, @certyfikatId, COALESCE(@data, GETDATE()));
END;

--Procedura dodająca zapis z uczestnictwa Pieska w wystawie
CREATE PROCEDURE UczestnictwoPieska
    @piesekId INT,
    @wystawaId INT,
    @wpisowe SMALLMONEY, 
    @dataOdbycia DATE,
    @pozycja INT
AS
BEGIN
    -- Sprawdzenie czy piesek istnieje
    EXEC dbo.SprawdzCzyRekordIstnieje 'hodowla.Pieski', @piesekId;

    INSERT INTO hodowla.Uczestnictwa (piesekId, wystawaId, pozycja, wpisowe, dataOdbycia)
    VALUES (@piesekId, @wystawaId, @pozycja, @wpisowe, @dataOdbycia);
END;

CREATE PROCEDURE DodajZalecenieDoDiety
    @piesekId INT,
    @jedzenieId INT,
    @czyLubi BIT,
    @ileMoze VARCHAR(10)
AS
BEGIN
    -- Sprawdzenie czy piesek istnieje
    EXEC dbo.SprawdzCzyRekordIstnieje 'hodowla.Pieski', @piesekId;

    INSERT INTO hodowla.DietaPieska (piesekId, jedzenieId, czyLubi, ileMoze)
    VALUES (@piesekId, @jedzenieId, @czyLubi, @ileMoze);
END;

CREATE PROCEDURE UtworzOpinie
    @wlascicielId INT,
    @opinia NVARCHAR(400),
    @ocena SMALLINT
AS
BEGIN
    -- Sprawdzenie czy właściciel istnieje
    EXEC dbo.SprawdzCzyRekordIstnieje 'klienci.Wlasciciele', @wlascicielId;

    INSERT INTO klienci.Opinie (wlascicielId, opinia, ocena)
    VALUES (@wlascicielId, @opinia, @ocena);
END;

-- Procedura dodająca pracownika
CREATE PROCEDURE DodajPracownika
    @nrTelefonu VARCHAR(11),
    @email VARCHAR(50),
    @adresId INT,
    @imie NVARCHAR(35),
    @nazwisko NVARCHAR(35),
    @pesel VARCHAR(11),
    @dataUrodzenia DATE,
    @stanowiskoId hierarchyid
AS
BEGIN
    BEGIN TRANSACTION;

    -- Dodaj pracownika do tabeli Pracownicy
    INSERT INTO firma.Pracownicy (dataZatrudnienia, wynagrodzenieBrutto, rodzajUmowy, stanowiskoId)
    VALUES (GETDATE(), 0, 'brak umowy', @stanowiskoId);

    -- Pobierz nowo utworzone pracownikId
    DECLARE @pracownikId INT = SCOPE_IDENTITY();

    -- Dodaj dane kontaktowe do tabeli DaneKontaktowe
    INSERT INTO firma.DaneKontaktowe (nrTelefonu, email, adresId, pracownikId)
    VALUES (@nrTelefonu, @email, @adresId, @pracownikId);

    -- Dodaj dane osobowe do tabeli DaneOsobowe
    INSERT INTO firma.DaneOsobowe (pracownikId, imie, nazwisko, pesel, dataUrodzenia)
    VALUES (@pracownikId, @imie, @nazwisko, @pesel, @dataUrodzenia);

    COMMIT;
END;


-- Procedura dodająca produkt do magazynu
CREATE PROCEDURE DodajProduktDoMagazynu
    @produktId INT,
    @ilosc INT,
    @cena SMALLMONEY
AS
BEGIN
    -- Sprawdzenie czy produkt o podanym ID istnieje
    EXEC dbo.SprawdzCzyRekordIstnieje 'magazyn.Produkty', @produktId;

    -- Dodaj produkt do tabeli Magazyn
    INSERT INTO magazyn.Magazyn (ilosc, cena, produktId)
    VALUES (@ilosc, @cena, @produktId);
END;

-- Procedura dodająca zamówienie
CREATE PROCEDURE DodajZamowienie
    @klientId INT,
    @produktId INT,
    @dataSprzedazy DATE,
    @rabat SMALLINT,
    @ilosc INT
AS
BEGIN
    -- Sprawdzenie czy klient o podanym ID istnieje
    EXEC dbo.SprawdzCzyRekordIstnieje 'klienci.Klienci', @klientId;

    -- Sprawdzenie czy produkt o podanym ID istnieje
    EXEC dbo.SprawdzCzyRekordIstnieje 'magazyn.Produkty', @produktId;

    -- Dodaj zamówienie do tabeli Zamowienia
    INSERT INTO klienci.Zamowienia (id, produktId, klientId, dataSprzedazy, rabat, ilosc)
    VALUES (IDENT_CURRENT('klienci.Zamowienia') + 1, @produktId, @klientId, @dataSprzedazy, @rabat, @ilosc);
END;

-- Procedura tworząca klienta
CREATE PROCEDURE UtworzKlienta
    @imie NVARCHAR(35),
    @nazwisko NVARCHAR(35),
    @adresId INT
AS
BEGIN
    -- Sprawdzenie czy adres o podanym ID istnieje
    EXEC dbo.SprawdzCzyRekordIstnieje 'klienci.Adresy', @adresId;

    -- Dodaj klienta do tabeli Klienci
    INSERT INTO klienci.Klienci (imie, nazwisko, adresId)
    VALUES (@imie, @nazwisko, @adresId);
END;

CREATE PROCEDURE UtworzStanowisko
    @podlega HIERARCHYID = NULL,
    @nazwa NVARCHAR(35),
    @opis NVARCHAR(max),
    @wynagrodzenieNetto SMALLMONEY,
    @pensja INT
AS
BEGIN
    -- Sprawdzenie czy stanowisko o podanym ID istnieje
    IF NOT EXISTS (SELECT 1 FROM firma.Stanowiska WHERE id = @podlega)
    BEGIN
        RAISEERROR('Podane stanowisko nadrzędne nie istnieje.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;
    IF @podlega IS NULL
    BEGIN
         -- Utworz stanowisko, ktore nikomu nie podlega
        INSERT INTO firma.Stanowiska (id, nazwa, opis, wynagrodzenieNetto)
        VALUES (hierarchyid::GetRoot() , @nazwa, @opis, @wynagrodzenieNetto);
        RETURN
    END

    -- Dodaj stanowisko do tabeli Stanowiska
    INSERT INTO firma.Stanowiska (id, nazwa, opis, wynagrodzenieNetto)
    VALUES (@podlega.GetDescendant(NULL, NULL), @nazwa, @opis, @wynagrodzenieNetto);

    COMMIT;
END;


-- Procedura tworząca zamówienie od producenta
CREATE PROCEDURE UtworzZamowienieProducent
    @produktId INT,
    @ilosc INT,
    @cena SMALLMONEY  -- Dodanie parametru cena
AS
BEGIN
    -- Sprawdzenie czy producent o podanym ID istnieje
    EXEC dbo.SprawdzCzyRekordIstnieje 'klienci.Producenci', @producentId;

    -- Sprawdzenie czy produkt o podanym ID istnieje
    EXEC dbo.SprawdzCzyRekordIstnieje 'magazyn.Produkty', @produktId;
    
    -- Dodanie rekordu do tabeli Magazyn
    INSERT INTO magazyn.Magazyn (ilosc, cena, produktId)
    VALUES (@ilosc, @cena, @produktId);
END;


-- Procedura wycofująca produkt
CREATE PROCEDURE WycofajProdukt
    @produktId INT
AS
BEGIN
    -- Sprawdzenie czy produkt o podanym ID istnieje
    EXEC dbo.SprawdzCzyRekordIstnieje 'magazyn.Produkty', @produktId;

    BEGIN TRANSACTION;
    -- Usuń produkt z tabeli Magazyn
    DELETE FROM magazyn.Magazyn
    WHERE produktId = @produktId;

    -- Usuń produkt z tabeli Produkty
    DELETE FROM magazyn.Produkty
    WHERE id = @produktId;

    COMMIT;
END;

-- Procedura tworząca zamówienie od producenta z dodaniem nowych produktów do magazynu
CREATE PROCEDURE UtworzZamowienieProducentaNoweProdukty
    @nazwa NVARCHAR(255),
    @ilosc INT,
    @cena SMALLMONEY,
    @producentId INT
AS
BEGIN
    DECLARE @produktId INT;

    BEGIN TRANSACTION;

    -- Dodaj nowy produkt do tabeli Produkty
    INSERT INTO magazyn.Produkty (nazwa, cena, dostawcaId)
    VALUES (@nazwa, @cena, @producentId);

    -- Pobierz ID dodanego produktu
    SET @produktId = SCOPE_IDENTITY();

    -- Dodaj nowy produkt do tabeli Magazyn
    INSERT INTO magazyn.Magazyn (ilosc, cena, produktId)
    VALUES (@ilosc, @cena, @produktId);

    COMMIT;
END;

-- Procedura zwalniająca pracownika
CREATE PROCEDURE ZwolnijPracownika
    @pracownikId INT,
    dataZwolnienia DATE NOT NULL,
    powod NVARCHAR(100) = 'Brak powodu'
AS
BEGIN
    -- Sprawdzenie czy pracownik o podanym ID istnieje
    EXEC dbo.SprawdzCzyRekordIstnieje 'firma.Pracownicy', @pracownikId;

    -- Dodaj zwolnionego pracownika do tabeli Zwolnieni
    INSERT INTO firma.Zwolnieni (pracownikId, dataZwolnienia, powod)
    VALUES (@pracownikId, COALESCE(@dataZwolnienia, GETDATE()), 'Brak powodu');

END;
