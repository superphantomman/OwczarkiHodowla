-- Test for CheckMagazyn Trigger
-- This should fail, as the product with ID 100 does not exist in the Produkty table.
INSERT INTO magazyn.Magazyn (ilosc, cena, produktId)
VALUES (10, 25.50, 100);

-- Test for CheckWlasciciele Trigger
-- This should fail, as the address with ID 200 does not exist in the Adresy table.
INSERT INTO klienci.Wlasciciele (imie, nazwisko, adresId)
VALUES ('John', 'Doe', 200);

-- Test for CheckOpinie Trigger
-- This should fail, as the owner with ID 300 does not exist in the Wlasciciele table.
INSERT INTO klienci.Opinie (tresc, wlascicielId)
VALUES ('Great service!', 300);

-- Test for CheckNotatki Trigger
-- This should fail, as the dog with ID 400 does not exist in the Pieski table.
INSERT INTO hodowla.Notatki (tresc, piesekId)
VALUES ('Regular checkup', 400);

-- Test for CheckAdopcje Trigger
-- This should fail, as either the owner, dog, or both do not exist, or the dog has been adopted or is deceased.
INSERT INTO hodowla.Adopcje (wlasicielId, piesekId)
VALUES (500, 600);

-- Test for CheckDaneKontaktowe Trigger
-- This should fail, as the address with ID 700 does not exist in the Adresy table.
INSERT INTO firma.DaneKontaktowe (telefon, email, adresId)
VALUES ('123-456-789', 'john.doe@example.com', 700);

-- Test for CheckPracownicy Trigger
-- This should fail, as the gross salary is less than the net salary for the specified position.
INSERT INTO firma.Pracownicy (imie, nazwisko, stanowiskoId, wynagrodzenieBrutto)
VALUES ('Alice', 'Smith', 800, 3000);

-- Test for CheckCertyfikatyPieskow Trigger
-- This should fail, as the certificate or dog ID is invalid, or the certificate issue date is in the future.
INSERT INTO hodowla.CertyfikatyPieskow (certyfikatId, piesekId, dataZdobycia)
VALUES (900, 1000, '2025-01-01');

-- Test for CheckDietaPieska Trigger
-- This should fail, as either the dog or food ID does not exist in the respective tables.
INSERT INTO hodowla.DietaPieska (piesekId, jedzenieId)
VALUES (1100, 1200);

-- Test for CheckTresury Trigger
-- This should fail, as the start date is greater than the end date, or the start date is before the dog's birth, or the end date is in the future.
INSERT INTO hodowla.Tresury (piesekId, treserId, dataRozpoczecia, dataZakonczenia)
VALUES (1300, 1400, '2023-01-01', '2022-01-01');

-- Test for CheckWystawy Trigger
-- This should fail, as the exhibition date is in the past or the exhibition already has participants.
INSERT INTO hodowla.Wystawy (dataOdbycia)
VALUES ('2022-01-01');

-- Test for CheckZgony Trigger
-- This should fail, as the death date is before the dog's birth.
INSERT INTO hodowla.Zgony (piesekId, dataZgonu)
VALUES (1500, '2022-01-01');

-- Test for CheckKlienci Trigger
-- This should fail, as the address with ID 1600 does not exist in the Adresy table.
INSERT INTO klienci.Klienci (imie, nazwisko, adresId)
VALUES ('Bob', 'Johnson', 1600);

-- Test for CheckDostawcy Trigger
-- This should fail, as the address with ID 1700 does not exist in the Adresy table.
INSERT INTO magazyn.Dostawcy (nazwa, adresId)
VALUES ('ABC Suppliers', 1700);

-- Test for CheckProdukty Trigger
-- This should fail, as the supplier with ID 1800 does not exist in the Dostawcy table.
INSERT INTO magazyn.Produkty (nazwa, cena, dostawcaId)
VALUES ('Widget A', 10.99, 1800);

-- Test for CheckZamowienia Trigger
-- This should fail, as either the client, product, or both do not exist, or the requested quantity is not available in the warehouse.
INSERT INTO klienci.Zamowienia (klientId, produktId, ilosc)
VALUES (1900, 2000, 100);

-- Test for CheckPracownicy Trigger
-- This should fail, as the gross salary is less than the net salary for the specified position.
INSERT INTO firma.Pracownicy (imie, nazwisko, stanowiskoId, wynagrodzenieBrutto)
VALUES ('Charlie', 'Brown', 800, 2500);

-- Test for CheckDaneKontaktowe Trigger
-- This should fail, as the address with ID 2100 does not exist in the Adresy table.
INSERT INTO firma.DaneKontaktowe (telefon, email, adresId)
VALUES ('987-654-321', 'charlie.brown@example.com', 2100);
