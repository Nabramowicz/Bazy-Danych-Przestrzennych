--1. 2.
--Zainstaluj rozszerzenie PosGIS dla bazy danych PostgreSQL (sprawdź, czy najnowsza
--dostępna wersja oprogramowania wspiera PostGIS). Utwórz pustą bazę danych.


--3. Dodaj funkcjonalności PostGIS’a do bazy poleceniem CREATE EXTENSION postgis;

CREATE EXTENSION postgis;


--4. Na podstawie poniższej mapy utwórz trzy tabele: budynki (id, geometria, nazwa), 
--drogi(id, geometria, nazwa), punkty_informacyjne (id, geometria, nazwa).

CREATE SCHEMA mapa;
CREATE TABLE mapa.budynki(id INT PRIMARY KEY, geometria GEOMETRY NOT NULL, nazwa VARCHAR(10) NOT NULL);
CREATE TABLE mapa.drogi(id INT PRIMARY KEY, geometria GEOMETRY NOT NULL, nazwa VARCHAR(10) NOT NULL);
CREATE TABLE mapa.punkty_informacyjne(id INT PRIMARY KEY, geometria GEOMETRY NOT NULL, nazwa VARCHAR(10) NOT NULL);


--5.Współrzędne obiektów oraz nazwy (np. BuildingA) należy odczytać z mapki umieszczonej
--poniżej. Układ współrzędnych ustaw jako niezdefiniowany.

INSERT INTO mapa.budynki VALUES
(1, ST_GeomFromText('POLYGON((8 1.5, 10.5 1.5, 10.5 4, 8 4, 8 1.5))'), 'BuildingA'),
(2, ST_GeomFromText('POLYGON((4 5, 6 5, 6 7, 4 7, 4 5))'), 'BuildingB'),
(3, ST_GeomFromText('POLYGON((3 6, 5 6, 5 8, 3 8, 3 6))'), 'BuildingC'),
(4, ST_GeomFromText('POLYGON((9 8, 10 8, 10 9, 9 9, 9 8))'), 'BuildingD'),
(5, ST_GeomFromText('POLYGON((1 1, 2 1, 2 2, 1 2, 1 1))'), 'BuildingF');

INSERT INTO mapa.drogi VALUES
(1, ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)'), 'RoadX'),
(2, ST_GeomFromText('LINESTRING(7.5 0, 7.5 10.5)'), 'RoadY');

INSERT INTO mapa.punkty_informacyjne VALUES
(1, ST_GeomFromText('POINT(6 9.5)'), 'K'),
(2, ST_GeomFromText('POINT(6.5 6)'), 'J'),
(3, ST_GeomFromText('POINT(9.5 6)'), 'I'),
(4, ST_GeomFromText('POINT(1 3.5)'), 'G'),
(5, ST_GeomFromText('POINT(5.5 1.5)'), 'H');


--6. Na bazie przygotowanych tabel wykonaj poniższe polecenia:
--a) Wyznacz całkowitą długość dróg w analizowanym mieście.
SELECT SUM(ST_Length(geometria)) 
FROM mapa.drogi;

--b) Wypisz geometrię (WKT), pole powierzchni oraz obwód poligonu reprezentującego
--budynek o nazwie BuildingA.
SELECT ST_AsEWKT(geometria) AS Geometria, ST_Area(geometria) AS Pole_powierzchni, ST_Perimeter(geometria) AS Obwod 
FROM mapa.budynki
WHERE nazwa='BuildingA';

--c) Wypisz nazwy i pola powierzchni wszystkich poligonów w warstwie budynki. Wyniki
--posortuj alfabetycznie.
SELECT nazwa, ST_Area(geometria) AS Pole_powierzchni 
FROM mapa.budynki
ORDER BY nazwa;

--d) Wypisz nazwy i obwody 2 budynków o największej powierzchni.
SELECT nazwa, ST_Perimeter(geometria) AS Obwod 
FROM mapa.budynki
ORDER BY ST_Area(geometria) DESC LIMIT 2;

--e) Wyznacz najkrótszą odległość między budynkiem BuildingC a punktem G.
SELECT ST_Distance(b.geometria, pkt.geometria) AS Odleglosc 
FROM mapa.budynki b, mapa.punkty_informacyjne pkt
WHERE b.nazwa='BuildingC' AND pkt.nazwa='G';

--f) Wypisz pole powierzchni tej części budynku BuildingC, która znajduje się w
--odległości większej niż 0.5 od budynku BuildingB.
SELECT ST_Area(ST_Difference(bc.geometria, ST_Buffer(bb.geometria, 0.5))) AS pole_powierzchni
FROM mapa.budynki bb, mapa.budynki bc
WHERE bb.nazwa='BuildingB' AND bc.nazwa='BuildingC';

--g) Wybierz te budynki, których centroid (ST_Centroid) znajduje się powyżej drogi
--o nazwie RoadX.
SELECT b.nazwa, b.geometria FROM mapa.budynki b, mapa.drogi d
WHERE ST_Y(ST_Centroid(b.geometria)) > ST_Y(ST_Centroid(d.geometria))
AND d.nazwa = 'RoadX';

--8. Oblicz pole powierzchni tych części budynku BuildingC i poligonu
--o współrzędnych (4 7, 6 7, 6 8, 4 8, 4 7), które nie są wspólne dla tych dwóch
--obiektów.
SELECT ST_Area(ST_SymDifference(geometria, ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')))
FROM mapa.budynki
WHERE nazwa='BuildingC';
