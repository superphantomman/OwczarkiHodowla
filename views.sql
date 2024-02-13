CREATE VIEW hodowla.WidokPieskowHodowli AS
SELECT
    P.id AS piesekId,
    P.imie,
    P.rasa,
    P.dataUrodzenia,
    P.opis,
    P.plec,
    COUNT(CP.certyfikatId) AS ilosc_certyfikatow,
    COUNT(U.wpisowe) AS ilosc_wystaw
FROM
    hodowla.Pieski P
LEFT JOIN
    hodowla.CertyfikatyPieskow CP ON P.id = CP.piesekId
LEFT JOIN
    hodowla.Uczestnictwa U ON P.id = U.piesekId
WHERE
    P.id NOT IN (SELECT piesekId FROM hodowla.Zgony)
GROUP BY
    P.id, P.imie, P.rasa, P.dataUrodzenia, P.opis, P.plec;


CREATE VIEW klienci.WidokWlasciciele AS
SELECT
    W.id AS wlascicielId,
    W.imie AS imie_wlasciciela,
    W.nazwisko AS nazwisko_wlasciciela,
    A.miasto + ' ' + A.ulica + ' ' + A.numerBudynku AS adres_wlasciciela,
    COUNT(A.id) AS ilosc_pieskow
FROM
    klienci.Wlasciciele W
JOIN
    klienci.Klienci K ON W.id = K.id
JOIN
    Adresy A ON W.adresId = A.id
JOIN
    hodowla.Adopcje AD ON W.id = AD.wlascicielId
GROUP BY
    W.id, W.imie, W.nazwisko, A.miasto, A.ulica, A.numerBudynku;

CREATE VIEW hodowla.WidokMartwePieski AS
SELECT
    Z.id AS zgonyId,
    Z.dataZgonu,
    P.id AS piesekId,
    P.imie,
    P.rasa,
    P.dataUrodzenia,
    P.opis,
    P.plec
FROM
    hodowla.Zgony Z
JOIN
    hodowla.Pieski P ON Z.piesekId = P.id;

CREATE VIEW firma.WidokStanowiska AS
SELECT
    S.id,
    S.nazwa AS stanowisko,
    S.opis AS opis_stanowiska,
    COUNT(P.id) AS ilosc_pracownikow,
    P2.nazwa AS stanowisko_nadrzedne
FROM
    firma.Stanowiska S
LEFT JOIN
    firma.Pracownicy P ON S.id = P.stanowiskoId.GetAncestor(1)
LEFT JOIN
    firma.Stanowiska P2 ON S.id.GetAncestor(1) = P2.id
GROUP BY
    S.id, S.nazwa, S.opis, P2.nazwa;

CREATE VIEW hodowla.WidokPoleRodowody AS
SELECT
    R.piesekId,
    O.imie AS ojciec,
    M.imie AS matka
FROM
    hodowla.Rodowody R
LEFT JOIN
    hodowla.Pieski O ON R.ojciecId = O.id
LEFT JOIN
    hodowla.Pieski M ON R.matkaId = M.id;

