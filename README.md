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

### Insert/Update Triggers

- **CheckParents**
  - Ensures the integrity of data in the Rodowód table, checking if parent IDs are present in the Pieski table.

... (and so on)

### Delete Triggers

- **CheckDeletedProdukt**
  - If a product is deleted from the Produkty table, it should also be deleted from the Magazyn table.

## Views

... (same structure as above)

## Indexes

... (same structure as above)
