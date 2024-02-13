# OwczarkiHodowla Database Project

## Overview

This project was created for the needs of the Database Architecture and Database Administration and Maintenance classes.

The purpose of the OwczarkiHodowla database is to store information necessary for the functioning of a dog breeding business. The information includes details about the dogs, products, and the overall operation of the breeding business as a company.

## Database Schemas

### hodowla

- **Pieski**
  - Imię: Name given by the breeder.
  - Rasa: Breed of the dog (defaulted to German Shepherd).
  - Opis: General description of the dog.

- **Rodowód**
  - Relacje rodzic-dziecko dla każdego psa.

- **Notatki**
  - Notations from breeders about each dog.

- **WizytyWeterynaryjne**
  - Basic information about veterinary visits.

- **Adopcje**
  - Junction table between Owners and Dogs, storing data about dog adoptions.

- **Adresy**
  - Addresses of clients.

- **Zgony**
  - Information about dog deaths.

- **Jedzenie**
  - Information about potential dog food.

- **DietaPieska**
  - Junction table between Foods and Dogs.

- **Wystawy**
  - Information about dog shows.

- **Uczestnictwa**
  - Information about dog show participations and rankings.

- **Certyfikaty**
  - Represents certificates obtained by dogs.

- **CertyfikatyPieskow**
  - Junction table between certificates and dogs.

- **Treserzy**
  - Information about specialists involved in dog training.

- **Tresura**
  - Stores data about the course of dog training.

- **Weterynarze**
  - Information about veterinarians.

### klienci

- **Wlasiciele**
  - Stores information about clients who adopted dogs.

- **Opinie**
  - Stores information about opinions on the breeding business.

- **Klienci**
  - Stores information about regular customers buying products for their pets.

- **Dostawcy**
  - Represents information about suppliers of supplies to the store.

- **Produkty**
  - Products related to dogs available in the warehouse.

- **Magazyn**
  - Represents the current state of the warehouse.

- **Zakupy**
  - Describes a purchase made by a customer.

### firma

- **Pracownicy**
  - Stores basic information about employees.

- **DaneKontaktowe**
  - Stores contact information needed to communicate with employees.

- **DaneOsobowe**
  - Stores general information identifying the user.

- **Wypłaty**
  - Stores information about employee salaries.

- **Stanowiska**
  - Stores information about positions available in the company and their roles.

- **Zwolnieni**
  - Stores information about employees who no longer work in the company.

### dbo

- **Adresy**
  - Stores addresses of various legal and physical entities.

## Triggers

## Wyzwalacze kontrolujące integralność danych na poziomie funkcji insert, update

- **CheckParents:** Kontroluje integralność danych na poziomie tabeli rodowody. Sprawdza, czy id rodziców znajdują się w tabeli Pieski. Jeśli mają wartość null, oznacza to, że rodzice są spoza hodowli, i notatka zostaje dodana do atrybutu opis, jeśli hodowca nie uzupełni go ręcznie.

- **CheckPiesekAdopcja:** Indywidualnie sprawdza integralność dla tabeli Adopcje.

- **CheckMagazyn:** Wyrzuca błąd, jeżeli wartość produktId nie istnieje w tabeli Produkty w kolumnie id.

- **CheckWlasciciele:** Sprawdza, czy adres istnieje w bazie danych.

- **CheckOpinie:** Sprawdza, czy właściciel o podanym id istnieje w bazie Wlascicieli.

- **CheckNotatki:** Sprawdza, czy pies o podanym id istnieje w bazie.

- **CheckAdopcje:** Sprawdza, czy właściciel istnieje o podanym id, sprawdza, czy piesek istnieje, czy już jest zaadoptowany, oraz czy nie umarł (tabela zgony).

- **CheckDaneKontaktowe:** Sprawdza, czy istnieje adres o podanym id oraz pracownik.

- **CheckPracownicy:** Sprawdza, czy wynagrodzenieBrutto jest większe lub równe wynagrodzeniuNetto dla stanowiska, na którym się znajduje.

- **CheckCertyfikatyPieskow:** Sprawdza, czy dataWydania jest mniejsza od daty certyfikatu, czy jest większa od daty urodzin pieska oraz daty adopcji. Sprawdza również, czy nie występuje kolizja w tabeli zgony. Ponadto sprawdza, czy istnieje certyfikat oraz piesek o podanych id.

- **CheckDietaPieska:** Sprawdza id tabel Pieski oraz Pokarm.

- **CheckTresury:** Sprawdza, czy dataRozpoczecia jest mniejsza od datyZakonczenia, czy dataRozpoczęcia jest mniejsza od datyNarodzin w tabeli Pieskow. Sprawdza również, czy dataZakonczenia, dataAdopcji są mniejsze od datyRozpoczecia w tabeli. Sprawdza, czy treser i piesek istnieją w tabelach.

- **CheckWystawy:** Sprawdza, czy dataOdbycia nie koliduje z datą w tabelach Tresura oraz data Adopcji w tabeli adopcje.

- **CheckZgony:** Sprawdzamy, czy data śmierci nie jest mniejsza od daty narodzin.

- **CheckKlienci:** Sprawdzamy, czy podany adres istnieje w tabeli Adresy.

- **CheckDostawcy:** Sprawdzamy, czy podany adres istnieje.

- **CheckProdukty:** Sprawdzamy, czy podany dostawca istnieje w tabeli dostawcy.

- **CheckZamowienia:** Sprawdzamy, czy klient oraz produkt istnieje oraz czy znajduje się w takiej ilości na magazynie.

- **CheckPracownicy:** Sprawdzamy, czy stanowisko istnieje.

- **CheckDaneKontaktowe:** Sprawdzamy, czy adres istnieje w tabeli Adresy.

- **CheckWyplaty:** Sprawdzamy, czy pracownik istnieje oraz czy nie jest zwolniony.

## Wyzwalacze kontrolujące integralność danych na poziomie funkcji delete:

- **CheckDeletedProdukt:** Jeżeli produkt zostanie usunięty z tabeli Produkty, to ma również zostać usunięty z tabeli Magazyn.

## Views

### WidokPieskowHodowli

- Information from the Pieski table (dogs not in the Zgony table), includes the count of certificates and displays it as the `ilość_certyfikatow` field, as well as participations in shows as the `ilość_wystaw` field.

### WidokPoleRodowody

- For a specific dog, provides the names of the mother and father.

### WidokStanowiska (Materialized View)

- For a specific position, shows the `ilość_pracownikow` (employees holding that position), the name of the position to which the current position belongs, and data from the Stanowiska table.

### WidokMartwePieski

- Combines the Pieski and Zgony tables to present data about the death of each dog.

### WidokWlasciciele

- Provides the number of dogs owned by a specific owner in the `ilość_pieskow` field, the owner's address, and all their data.

### WidokPracownicy

- Combines the Pracownicy, DaneOsobowe, and DaneKontaktowe tables.

### WidokAdopcje

- Provides basic data from the Wlasciciele, Piesek, and all data from the Adopcje table. Summarizes all the expenses incurred by the breeding business when raising a dog and the resulting profit from the sale of the dog.

### WidokZyskHodowli

- Profit of the breeding business for a specific day.

### WidokPracownicyOdUmowy

- Displays information about employees with a specific type of contract.

### WidokProduktZamowienia

- Displays the profit from orders and the quantity sold.

## Indexes

W bazie danych zaimplementowano kilka indeksów, aby zoptymalizować szybkość zapytań i operacji na danych. Oto lista indeksów:

### Tabela `Notatki`

- `notatka, piesekId`: Indeks wierszowy umożliwiający szybkie wyszukiwanie psów na podstawie notatek.

### Tabela `WizytyWeterynaryjne`

- `koszt, piesekId`: Indeks kolumnowy do szybkiego sumowania kosztów weterynaryjnych dla danego psa.

### Tabela `Opinia`

- `opinia, id`: Indeks wierszowy umożliwiający szybkie wyszukiwanie opinii po identyfikatorze.

### Tabela `Pieski`

- `opis, id`: Indeks wierszowy ułatwiający szybkie wyszukiwanie psów na podstawie opisu.

### Tabela `Produkty`

- `nazwa, ilość, cena`: Indeks wierszowy umożliwiający liczenie sumarycznej ilości i wartości produktów w magazynie.

### Tabela `Stanowiska`

- `nazwa`: Indeks wierszowy ułatwiający szybkie wyszukiwanie stanowisk po nazwie.