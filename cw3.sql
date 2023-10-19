create extension postgis;

--4) Wyznacz liczbę budynków (tabela: popp, atrybut: f_codedesc, reprezentowane, jako punkty)
-- położonych w odległości mniejszej niż 1000 jednostek od głównych rzek. Budynki spełniające to
-- kryterium zapisz do osobnej tabeli tableB.

SELECT p.* INTO TableB
FROM popp p
JOIN majrivers r
ON ST_Intersects(ST_Buffer(r.geom, 1000), p.geom)
WHERE p.f_codedesc='Building';

SELECT COUNT(f_codedesc) FROM tableb;


--5) Utwórz tabelę o nazwie airportsNew. Z tabeli airports do zaimportuj nazwy lotnisk, ich
-- geometrię, a także atrybut elev, reprezentujący wysokość n.p.m.

SELECT name, geom, elev INTO airportsNew
FROM airports;

--a) Znajdź lotnisko, które położone jest najbardziej na zachód 
-- i najbardziej na wschód.

SELECT name, ST_X(geom) AS min_x
FROM airportsNew 
ORDER BY min_x LIMIT 1

SELECT name, ST_X(geom) AS max_x
FROM airportsNew 
ORDER BY max_x DESC LIMIT 1

--b) Do tabeli airportsNew dodaj nowy obiekt - lotnisko, które położone jest w punkcie
-- środkowym drogi pomiędzy lotniskami znalezionymi w punkcie a. Lotnisko nazwij airportB.
-- Wysokość n.p.m. przyjmij dowolną.

INSERT INTO airportsNew VALUES
('airportB',
 (SELECT ST_Centroid(ST_MakeLine((SELECT geom FROM airportsNew ORDER BY ST_X(geom) LIMIT 1), 
								 (SELECT geom FROM airportsNew ORDER BY ST_X(geom) DESC LIMIT 1)))),
0);
--sprawdzenie
SELECT * FROM airportsNew
WHERE name='airportB'


--6) Wyznacz pole powierzchni obszaru, który oddalony jest mniej niż 1000 jednostek od najkrótszej
-- linii łączącej jezoro o nazwie ‘Iliamna Lake’ i lotnisko o nazwie „AMBLER”

SELECT ST_Area(ST_Buffer((ST_ShortestLine((SELECT geom FROM lakes WHERE names='Iliamna Lake'),
										 (SELECT geom FROM airports WHERE name='AMBLER'))), 1000))
										 									
																			
--7)Napisz zapytanie, które zwróci sumaryczne pole powierzchni poligonów reprezentujących
-- poszczególne typy drzew znajdujących się na obszarze tundry i bagien (swamps).

SELECT vegdesc, SUM(ST_Area(tr.geom)) AS area
FROM trees tr, tundra tu, swamp s
WHERE
ST_Within(tr.geom, tu.geom)
OR
St_Within(tr.geom, s.geom)
GROUP BY tr.vegdesc




















