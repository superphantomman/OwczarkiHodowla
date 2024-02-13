--test procedury WyliczKosztWizytPieska

DECLARE @startTime DATETIME;
DECLARE @endTime DATETIME;
DECLARE @elapsedTime INT;

CREATE TABLE #TempPieskiId (Id INT PRIMARY KEY);
INSERT INTO #TempPieskiId (Id) SELECT id FROM Pieski;

SET @startTime = GETDATE();
DECLARE @currentPiesekId INT;

WHILE (SELECT COUNT(*) FROM #TempPieskiId) > 0
BEGIN
    SELECT TOP 1 @currentPiesekId = Id FROM #TempPieskiId;

    -- Wywołaj procedurę
    EXEC WyliczKosztWizytPieska @currentPiesekId;

    DELETE FROM #TempPieskiId WHERE Id = @currentPiesekId;
END

SET @endTime = GETDATE();
SET @elapsedTime = DATEDIFF(SECOND, @startTime, @endTime);

-- Wyświetl czas wykonania
PRINT 'Czas wykonania całości (sekundy): ' + CAST(@elapsedTime AS NVARCHAR(10));

DROP TABLE #TempPieskiId;

--test SzukajPieskaPoOpisie 
EXEC SzukajPieskaPoOpisie @szukane = 'playful';

--test SzukajPsaPoNotatce
EXEC SzukajPsaPoNotatce @szukane = 'friendly and playful';

-- test ObliczOgolnaSredniaOcen
EXEC ObliczOgolnaSredniaOcen;

-- test PrzeszukajOpinie
EXEC PrzeszukajOpinie @szukaneSlowo = 'caring';

-- Wywołanie procedury dla konkretnego psa
EXEC WyliczKosztWizytPieska @piesekId = 1;

-- Wyszukiwanie psa po opisie
EXEC SzukajPieskaPoOpisie @szukane = 'friendly and playful';

-- Wyszukiwanie psa po notatce
EXEC SzukajPsaPoNotatce @szukane = 'vet visit';

-- Obliczanie ogólnej średniej oceny
EXEC ObliczOgolnaSredniaOcen;

-- Wyszukiwanie opinii
EXEC SzukajOpinie @szukane = 'recommend';

-- Wstawianie adopcji z istniejącym pieskiem
INSERT INTO hodowla.Adopcje (wlascicielId, piesekId, dataAdopcji, cena) VALUES (1, 1, '2023-01-06', 100.00);

-- Wstawianie do tabeli rodowod z równymi ojcem, matką i potomkiem
INSERT INTO hodowla.Rodowody (piesekId, ojciecId, matkaId) VALUES (1, 1, 1);

-- Szukanie informacji na temat psa własciciela, który jest w bazie danyc 
EXEC SzukajDaneOPsachWlasciciela @wlascicielId = 1;

-- Szukanie informacji na temat psa wlasciciela ktorego nie ma w bazie danych
EXEC SzukajDaneOPsachWlasciciela @wlascicielId = 10000;

-- Dodanie adopcji psa dla nie istniejącego w bazie właściciela
EXEC DodajAdopcjeNowegoWlasciciela 
    @imieWlasciciela = 'Jan',
    @nazwiskoWlasciciela = 'Kowalski',
    @kodPocztowy = '00-001',
    @miasto = 'Warszawa',
    @ulica = 'Uliczna',
    @numerDomu = '1',
    @piesekId = 1, -- Podaj istniejące ID psa
    @cenaAdopcji = 100.00;

--Dodanie ad
EXEC DodajAdopcjeWlasciciela 
    @wlascicielId = 1
    @piesekId = 2
