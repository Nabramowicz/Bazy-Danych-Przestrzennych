create extension postgis;


--1. Znajdź budynki, które zostały wybudowane lub wyremontowane na przestrzeni roku 
--(zmiana pomiędzy 2018 a 2019).

WITH 
NewBuildings
AS (
	SELECT t19.* 
	FROM t2019_kar_buildings t19
	LEFT JOIN t2018_kar_buildings t18 
	USING (polygon_id)
	WHERE t18.polygon_id IS NULL
),
RenovatedBuildings
AS (
	SELECT t19.*
	FROM t2018_kar_buildings t18, t2019_kar_buildings t19
	WHERE t18.polygon_id = t19.polygon_id
	AND (NOT ST_Equals(t18.geom, t19.geom) OR t18.height <> t19.height)
)
SELECT * INTO tnew_buildings 
FROM NewBuildings
UNION
SELECT * FROM RenovatedBuildings;

SELECT * FROM tnew_buildings;



--2. Znajdź ile nowych POI pojawiło się w promieniu 500 m od wyremontowanych 
--lub wybudowanych budynków, które znalezione zostały w zadaniu 1. 
--Policz je wg ich kategorii.

WITH
NewPoi
AS (
	SELECT p19.* 
	FROM t2019_kar_poi_table p19
	LEFT JOIN t2018_kar_poi_table p18
	USING (poi_id)
	WHERE p18.poi_id IS NULL
)
SELECT np.type, COUNT(ST_DWithin(np.geom, (SELECT ST_Union(geom) FROM tnew_buildings), 500.0))
INTO new_poi_in_buffer
FROM NewPoi np
GROUP BY np.type;

--ile
SELECT SUM(count) FROM new_poi_in_buffer;
--pogrupowane
SELECT * FROM new_poi_in_buffer;



-- 3. Utwórz nową tabelę o nazwie ‘streets_reprojected’, która zawierać będzie dane z tabeli 
-- T2019_KAR_STREETS przetransformowane do układu współrzędnych DHDN.Berlin/Cassini.
----------------------------------
--sprawdzam jaki to SRID 
SELECT * FROM spatial_ref_sys
WHERE srtext ILIKE '%DHDN%'
AND srtext ILIKE '%Berlin%';
----------------------------------

CREATE TABLE streets_reprojected AS
SELECT * FROM t2019_kar_streets;

ALTER TABLE streets_reprojected
ALTER COLUMN geom
TYPE GEOMETRY(MULTILINESTRING, 3068)
USING ST_Transform(geom, 3068);

--sprawdzenie
SELECT ST_SRID(geom) FROM streets_reprojected;



-- 4. Stwórz tabelę o nazwie ‘input_points’ i dodaj do niej dwa rekordy o geometrii punktowej.
-- Przyjmij układ współrzędnych GPS.

CREATE TABLE input_points (
point_id INT PRIMARY KEY,
geom GEOMETRY NOT NULL);

INSERT INTO input_points VALUES 
(1, ST_GeomFromText('POINT(8.36093 49.03174)', 4326)),
(2, ST_GeomFromText('POINT(8.39876 49.00644)', 4326));

--sprawdzenie
SELECT * FROM input_points;



-- 5. Zaktualizuj dane w tabeli ‘input_points’ tak, aby punkty te były w układzie współrzędnych 
-- DHDN.Berlin/Cassini. Wyświetl współrzędne za pomocą funkcji ST_AsText().

ALTER TABLE input_points
ALTER COLUMN geom
TYPE GEOMETRY(POINT, 3068)
USING ST_Transform(geom, 3068);

SELECT ST_AsText(geom) FROM input_points;



-- 6. Znajdź wszystkie skrzyżowania, które znajdują się w odległości 200 m od linii zbudowanej 
-- z punktów w tabeli ‘input_points’. Wykorzystaj tabelę T2019_STREET_NODE. 
-- Dokonaj reprojekcji geometrii, aby była zgodna z resztą tabel.

SELECT * FROM t2019_kar_street_node
WHERE ST_DWithin(geom,
				 (SELECT ST_Transform((ST_MakeLine(geom)), 4326) FROM input_points),
				 200.0, 
				 true); --200m mierzone na elipsoidzie; false - mierzone na sferze (wychodzi tutaj wiecej o 3 rows)
				 
				 
				 
-- 7. Policz jak wiele sklepów sportowych (‘Sporting Goods Store’ - tabela POIs) znajduje się 
-- w odległości 300 m od parków (LAND_USE_A).

--2018
SELECT COUNT(type)
FROM t2018_kar_poi_table
WHERE type='Sporting Goods Store'
AND ST_DWithin(geom,
			   (SELECT ST_Union(geom) FROM t2018_kar_land_use_a WHERE type ILIKE 'Park %'),
			   300.0);
				 
--2019
SELECT COUNT(type)
FROM t2019_kar_poi_table
WHERE type='Sporting Goods Store'
AND ST_DWithin(geom,
			   (SELECT ST_Union(geom) FROM t2019_kar_land_use_a WHERE type ILIKE 'Park %'),
			   300.0);



-- 8. Znajdź punkty przecięcia torów kolejowych (RAILWAYS) z ciekami (WATER_LINES). 
-- Zapisz znalezioną geometrię do osobnej tabeli o nazwie ‘T2019_KAR_BRIDGES’.

CREATE TABLE t2019_kar_bridges
AS (SELECT DISTINCT(ST_Intersection(r.geom, w.geom))
	FROM t2019_kar_railways r, t2019_kar_water_lines w);
	
ALTER TABLE t2019_kar_bridges 
ADD COLUMN bridge_id SERIAL PRIMARY KEY;

SELECT * FROM t2019_kar_bridges;


