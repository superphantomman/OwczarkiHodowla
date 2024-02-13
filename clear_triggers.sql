USE master;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckParents')
    DROP TRIGGER CheckParents;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckPiesekAdopcja')
    DROP TRIGGER CheckPiesekAdopcja;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckMagazyn')
    DROP TRIGGER CheckMagazyn;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckWlasciciele')
    DROP TRIGGER CheckWlasciciele;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckOpinie')
    DROP TRIGGER CheckOpinie;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckNotatki')
    DROP TRIGGER CheckNotatki;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckAdopcje')
    DROP TRIGGER CheckAdopcje;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckDaneKontaktowe')
    DROP TRIGGER CheckDaneKontaktowe;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckPracownicy')
    DROP TRIGGER CheckPracownicy;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckCertyfikatyPieskow')
    DROP TRIGGER CheckCertyfikatyPieskow;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckDietaPieska')
    DROP TRIGGER CheckDietaPieska;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckTresury')
    DROP TRIGGER CheckTresury;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckWystawy')
    DROP TRIGGER CheckWystawy;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckZgony')
    DROP TRIGGER CheckZgony;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckKlienci')
    DROP TRIGGER CheckKlienci;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckDostawcy')
    DROP TRIGGER CheckDostawcy;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckProdukty')
    DROP TRIGGER CheckProdukty;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckZamowienia')
    DROP TRIGGER CheckZamowienia;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckPracownicy')
    DROP TRIGGER CheckPracownicy;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckDaneKontaktowe')
    DROP TRIGGER CheckDaneKontaktowe;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckWyplaty')
    DROP TRIGGER CheckWyplaty;

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'CheckDeletedProdukt')
    DROP TRIGGER CheckDeletedProdukt;
