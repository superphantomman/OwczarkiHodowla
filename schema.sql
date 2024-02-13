USE master
GO
DROP DATABASE IF EXISTS OwczarkiHodowla;
GO
CREATE DATABASE OwczarkiHodowla;
GO
USE OwczarkiHodowla
GO

-- Schema: magazyn
CREATE SCHEMA magazyn;
GO
-- Schema: klienci
CREATE SCHEMA klienci;
GO
-- Schema: hodowla
CREATE SCHEMA hodowla;
GO
-- Schema: firma
CREATE SCHEMA firma;
GO

-- Table: Adresy
CREATE TABLE Adresy (
    id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    kodPocztowy VARCHAR(6) NOT NULL,
    miasto NVARCHAR(35) NOT NULL,
    ulica NVARCHAR(255) NOT NULL,
    numerBudynku VARCHAR(30) NOT NULL,
    numerBloku VARCHAR(30),
);

-- Table: Dostawcy
CREATE TABLE magazyn.Dostawcy (
    id INT NOT NULL PRIMARY KEY,
    nazwa NVARCHAR(255) NOT NULL,
    adresId INT NOT NULL,
    FOREIGN KEY (adresId) REFERENCES Adresy (id)
);

-- Table: Produkty
CREATE TABLE magazyn.Produkty (
    id INT NOT NULL PRIMARY KEY,
    nazwa NVARCHAR(255) NOT NULL,
    cena SMALLMONEY NOT NULL,
    dostawcaId INT NOT NULL,
    FOREIGN KEY (dostawcaId) REFERENCES magazyn.Dostawcy (id)
);

-- Table: Magazyn
CREATE TABLE magazyn.Magazyn (
    id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ilosc INT NOT NULL CHECK ( ilosc > 0 ),
    cena SMALLMONEY NOT NULL CHECK ( cena > 0 ),
    produktId INT NOT NULL UNIQUE,
    FOREIGN KEY (produktId) REFERENCES  magazyn.Produkty(id)
);

-- Table: Wlasciciele
CREATE TABLE klienci.Wlasciciele (
    id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    imie NVARCHAR(35) NOT NULL,
    nazwisko NVARCHAR(35) NOT NULL,
    adresId INT NOT NULL,
    FOREIGN KEY (adresId) REFERENCES Adresy (id)
);

-- Table: Opinie
CREATE TABLE klienci.Opinie (
    id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    wlascicielId INT NOT NULL,
    ocena SMALLINT NOT NULL CHECK (ocena >= 1 AND ocena <= 5),
    opinia NVARCHAR(400) NOT NULL UNIQUE,
    FOREIGN KEY (wlascicielId) REFERENCES klienci.Wlasciciele (id)
);

-- Table: Pieski
CREATE TABLE hodowla.Pieski (
    id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    imie NVARCHAR(255) NOT NULL,
    rasa NVARCHAR(255) NOT NULL DEFAULT 'German Shepherd',
    dataUrodzenia DATE NOT NULL DEFAULT GETDATE(),
    opis NVARCHAR(400) NOT NULL UNIQUE, 
    plec varchar(2) CHECK ( plec IN ('M', 'K') )
);

-- Table: Rodowody
CREATE TABLE hodowla.Rodowody (
    piesekId INT PRIMARY KEY,
    ojciecId INT,
    matkaId INT,
    opis NVARCHAR(200),
    FOREIGN KEY (piesekId) REFERENCES hodowla.Pieski (id),
    FOREIGN KEY (ojciecId) REFERENCES hodowla.Pieski (id),
    FOREIGN KEY (matkaId) REFERENCES hodowla.Pieski (id)
); -- 

-- Table: Weterynarze
CREATE TABLE hodowla.Weterynarze (
    id INT NOT NULL PRIMARY KEY,
    imie NVARCHAR(35) NOT NULL,
    nazwisko NVARCHAR(35) NOT NULL,
    specjalizacja NVARCHAR(100) NOT NULL,
    email NVARCHAR(50) NOT NULL
);

CREATE TABLE hodowla.WizytyWeterynaryjne (
   id INT  NOT NULL PRIMARY KEY,
   koszt SMALLMONEY  NOT NULL,
   zabieg NVARCHAR(100)  NOT NULL,
   dataWykonania DATE  NOT NULL,
   piesekId INT  NOT NULL,
   weterynarzId INT  NOT NULL,
   FOREIGN KEY (piesekId) REFERENCES hodowla.Pieski (id),
   FOREIGN KEY (weterynarzId) REFERENCES hodowla.Weterynarze (id)
);

-- Table: Notatki
CREATE TABLE hodowla.Notatki (
    id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    notatka NVARCHAR(400) NOT NULL,
    dataPublikacji DATE NOT NULL DEFAULT GETDATE(),
    piesekId INT NOT NULL,
    FOREIGN KEY (piesekId) REFERENCES hodowla.Pieski (id)
);

-- Table: Adopcje
CREATE TABLE hodowla.Adopcje (
    wlascicielId INT NOT NULL,
    piesekId INT NOT NULL,
    dataAdopcji DATE NOT NULL DEFAULT GETDATE(),
    cena SMALLMONEY NOT NULL CHECK ( cena > 0),
    CONSTRAINT Adopcje_pk PRIMARY KEY (wlascicielId, piesekId),
    FOREIGN KEY (piesekId) REFERENCES hodowla.Pieski (id),
    FOREIGN KEY (wlascicielId) REFERENCES klienci.Wlasciciele (id)
);

-- Table: Stanowiska
CREATE TABLE firma.Stanowiska (
    id hierarchyid PRIMARY KEY CLUSTERED,
    pozycja AS id.GetLevel(),
    nazwa NVARCHAR(35) NOT NULL,
    opis NVARCHAR(max) NOT NULL,
    wynagrodzenieNetto SMALLMONEY NOT NULL CHECK ( wynagrodzenieNetto >= 0)
);

-- Table: Pracownicy
CREATE TABLE firma.Pracownicy (
    id INT NOT NULL PRIMARY KEY,
    dataZatrudnienia DATE NOT NULL,
    wynagrodzenieBrutto SMALLMONEY NOT NULL CHECK (wynagrodzenieBrutto >= 0),
    rodzajUmowy NVARCHAR(20) NOT NULL 
    CHECK ( 
            rodzajUmowy IN 
            ('czas_nieokreslony', 'czas_nieokreslony', 'czas_probny', 'zlecenie', 'dzielo', 'b2b' )
        ),
    stanowiskoId hierarchyid NOT NULL,
    FOREIGN KEY (stanowiskoId) REFERENCES firma.Stanowiska (id)
);

-- Table: DaneKontaktowe
CREATE TABLE firma.DaneKontaktowe (
    nrTelefonu VARCHAR(11) NOT NULL,
    email VARCHAR(50) NOT NULL,
    adresId INT NOT NULL,
    pracownikId INT NOT NULL,
    CONSTRAINT DaneKontaktowe_pk PRIMARY KEY (pracownikId),
    FOREIGN KEY (adresId) REFERENCES Adresy (id)
);

CREATE TABLE firma.DaneOsobowe (
    pracownikId INT NOT NULL,
    imie NVARCHAR(35) NOT NULL,
    nazwisko NVARCHAR(35) NOT NULL,
    pesel VARCHAR(11) NOT NULL,
    dataUrodzenia DATE NOT NULL,
    CONSTRAINT DaneOsobowe_pk PRIMARY KEY (pracownikId),
    FOREIGN KEY (pracownikId) REFERENCES firma.Pracownicy(id)

);

-- Table: Wyplaty
CREATE TABLE firma.Wyplaty (
    id INT NOT NULL PRIMARY KEY,
    dataPrzelewu DATE NOT NULL,
    wartoscPrzelewu SMALLMONEY NOT NULL CHECK (wartoscPrzelewu > 0),
    pracownikId INT NOT NULL,
    FOREIGN KEY (pracownikId) REFERENCES firma.Pracownicy (id)
);

-- Table: Certyfikaty
CREATE TABLE hodowla.Certyfikaty (
    id INT NOT NULL PRIMARY KEY,
    instytucja NVARCHAR(50) NOT NULL,
    nazwa NVARCHAR(40) NOT NULL,
);

-- Table: CertyfikatyPieskow
CREATE TABLE hodowla.CertyfikatyPieskow (
    piesekId INT NOT NULL,
    certyfikatId INT NOT NULL,
    dataZdobycia DATE NOT NULL,
    koszt SMALLMONEY NOT NULL CHECK (koszt >= 0),
    CONSTRAINT CertyfikatyPieskow_pk PRIMARY KEY (piesekId, certyfikatId),
    FOREIGN KEY (piesekId) REFERENCES hodowla.Pieski (id),
    FOREIGN KEY (certyfikatId) REFERENCES hodowla.Certyfikaty (id)
);

-- Table: Pokarm
CREATE TABLE hodowla.Pokarm (
    id INT NOT NULL PRIMARY KEY,
    typ VARCHAR(30) NOT NULL 
    CHECK ( typ in ( 'WARZYWO', 'OWOC', 'ZBOZE', 'KASZA', 'NABIAL', 'MIESO', 'WYROBY CUKIERNICZE', 'KARMA') ),
    nazwa NVARCHAR(35) NOT NULL UNIQUE,
    marka NVARCHAR(35),
);

-- Table: DietaPieska
CREATE TABLE hodowla.DietaPieska (
    piesekId INT NOT NULL,
    jedzenieId INT NOT NULL,
    ileMoze VARCHAR(12) NOT NULL
    CHECK (ileMoze in ('zadna', 'ograniczona' ,'dowolna')),
    czyLubi BIT NOT NULL,
    CONSTRAINT DietaPieska_pk PRIMARY KEY (piesekId, jedzenieId),
    FOREIGN KEY (piesekId) REFERENCES hodowla.Pieski (id),
    FOREIGN KEY (jedzenieId) REFERENCES hodowla.Pokarm (id)
);

-- Table: Treserzy
CREATE TABLE hodowla.Treserzy (
    id INT NOT NULL PRIMARY KEY,
    imie NVARCHAR(35) NOT NULL,
    nazwisko NVARCHAR(35) NOT NULL,
    email VARCHAR(50) NOT NULL
);

-- Table: Tresury
CREATE TABLE hodowla.Tresury (
    id INT NOT NULL PRIMARY KEY,
    dataRozpoczecia DATE NOT NULL,
    dataZakonczenia DATE,
    typ NVARCHAR(50) NOT NULL,
    opis NVARCHAR(255) NOT NULL,
    koszt SMALLMONEY NOT NULL CHECK ( koszt >= 0),
    piesekId INT NOT NULL,
    treserId INT NOT NULL,
    FOREIGN KEY (piesekId) REFERENCES hodowla.Pieski (id),
    FOREIGN KEY (treserId) REFERENCES hodowla.Treserzy (id)
);

-- Table: Wystawy
CREATE TABLE hodowla.Wystawy (
    id INT NOT NULL PRIMARY KEY,
    nazwa NVARCHAR(50) NOT NULL,
    dataOdbycia DATE NOT NULL
);

-- Table: Uczestnictwa
CREATE TABLE hodowla.Uczestnictwa (
    piesekId INT NOT NULL,
    wystawaId INT NOT NULL,
    pozycja INT, 
    wpisowe SMALLMONEY NOT NULL CHECK ( wpisowe >= 0)
    CONSTRAINT Uczestnictwa_pk PRIMARY KEY (piesekId, wystawaId),
    FOREIGN KEY (piesekId) REFERENCES hodowla.Pieski (id),
    FOREIGN KEY (wystawaId) REFERENCES hodowla.Wystawy (id)
);

-- Table: Zgony
CREATE TABLE hodowla.Zgony (
    id INT NOT NULL PRIMARY KEY,
    dataZgonu DATE NOT NULL,
    przyczyna NVARCHAR(60) NOT NULL,
    piesekId INT NOT NULL,
    FOREIGN KEY (piesekId) REFERENCES hodowla.Pieski (id)
);

-- Table: Klienci
CREATE TABLE klienci.Klienci (
    id INT NOT NULL PRIMARY KEY,
    imie NVARCHAR(35) NOT NULL,
    nazwisko NVARCHAR(35) NOT NULL,
    adresId INT NOT NULL,
    FOREIGN KEY (adresId) REFERENCES Adresy (id)
);

-- Table: Zamowienia
CREATE TABLE klienci.Zamowienia (
    id INT NOT NULL PRIMARY KEY,
    produktId INT NOT NULL,
    klientId INT NOT NULL,
    dataSprzedazy DATE NOT NULL,
    rabat SMALLINT NOT NULL,
    ilosc INT NOT NULL
    FOREIGN KEY (klientId) REFERENCES klienci.Klienci (id),
    FOREIGN KEY (produktId) REFERENCES magazyn.Produkty (id)
);

-- Table: Zwolnieni
CREATE TABLE firma.Zwolnieni (
   pracownikId INT NOT NULL,
   dataZwolnienia DATE NOT NULL,
   powod NVARCHAR(100) NOT NULL,
   CONSTRAINT Zwolnieni_pk PRIMARY KEY (pracownikId),
   FOREIGN KEY (pracownikId) REFERENCES firma.Pracownicy (id)
);


-- Full-text catalog for Notatki table
CREATE FULLTEXT CATALOG ft AS DEFAULT;

-- Unique index for Notatki table
CREATE UNIQUE INDEX IX_Notatki_Notatka ON hodowla.Notatki(notatka);

-- Full-text index for Notatki table
CREATE FULLTEXT INDEX ON hodowla.Notatki(notatka) KEY INDEX IX_Notatki_Notatka;

-- Unique index for Opinie table
CREATE UNIQUE INDEX IX_Opinie_Opinia ON klienci.Opinie(opinia);

-- Full-text index for Opinie table
CREATE FULLTEXT INDEX ON klienci.Opinie(opinia) KEY INDEX IX_Opinie_Opinia;

-- Unique index for Pieski table
CREATE UNIQUE INDEX IX_Pieski_Opis ON hodowla.Pieski(opis);

-- Full-text index for Pieski table
CREATE FULLTEXT INDEX ON hodowla.Pieski(opis) KEY INDEX IX_Pieski_Opis;

-- Index for Stanowiska table
CREATE INDEX IX_Stanowiska_Nazwa ON firma.Stanowiska(nazwa);

-- Index for Pracownicy table
CREATE INDEX IX_Pracownicy_RodzajUmowy ON firma.Pracownicy(rodzajUmowy);

-- Index for Pokarm table
CREATE INDEX IX_Pokarm_Nazwa ON hodowla.Pokarm(nazwa);

-- Indexes for summarizing costs and revenues related to dog maintenance:
-- Tresury (cost, piesekId)
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_Tresury_Koszt_PiesekId ON hodowla.Tresury (koszt, piesekId);

-- CertyfikatyPieskow (cost, piesekId)
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_CertyfikatyPieskow_Koszt_PiesekId ON hodowla.CertyfikatyPieskow (koszt, piesekId);

-- Adopcje (price, piesekId)
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_Adopcje_Cena_PiesekId ON hodowla.Adopcje (cena, piesekId);

-- WizytyWeterynaryjne (cost, piesekId)
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_WizytyWeterynaryjne_Koszt_PiesekId ON hodowla.WizytyWeterynaryjne (koszt, piesekId);

-- Uczestnictwa (entry fee, piesekId)
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_Uczestnictwa_Wpisowe_PiesekId ON hodowla.Uczestnictwa (wpisowe, piesekId);

-- Zamówienia: Column index (quantity, produktId) and column produktId (price, margin, produktId) -> Quick sum of a given product
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_Zamowienia_Ilosc_ProduktId ON klienci.Zamowienia (ilosc, produktId);

CREATE NONCLUSTERED COLUMNSTORE INDEX IX_Zamowienia_Cena_Marza_ProduktId ON magazyn.Produkty (cena, id);

