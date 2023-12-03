SELECT * FROM dane.uk_250k;

--3. Połącz te dane (wszystkie kafle) w mozaikę, 
--a następnie wyeksportuj jako GeoTIFF.
--NIEWYKONALNE :)

CREATE TABLE public.uk_250k_union AS
SELECT ST_Union(d.rast) as uk_250k_mosaic
FROM dane.uk_250k d;

SELECT ST_AsTiff(uk_250k_mosaic)
FROM public.uk_250k_union;


--5. Załaduj do bazy danych tabelę reprezentującą granice 
-- parków narodowych.
--Dane wczytałam do bd przez qgis'a

SELECT * FROM dane.national_parks;


--6. Utwórz nową tabelę o nazwie uk_lake_district, 
--gdzie zaimportujesz mapy rastrowe z punktu 1., 
--które zostaną przycięte do granic parku narodowego Lake District.

CREATE TABLE public.uk_lake_district AS
SELECT ST_Clip(r.rast, v.geom, true)
FROM dane.uk_250k r, dane.national_parks v
WHERE ST_Intersects(r.rast, v.geom) AND v.id=1;

SELECT * FROM uk_lake_district;


--7. Wyeksportuj wyniki do pliku GeoTIFF.

CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,ST_AsGDALRaster(ST_Union(ST_Clip), 'GTiff', 
									   ARRAY['COMPRESS=DEFLATE','PREDICTOR=2', 'PZLEVEL=9'])) 
									   AS loid
FROM uk_lake_district;

SELECT lo_export(loid, 'D:\uk_lake_district.tiff')
FROM tmp_out;

SELECT lo_unlink(loid)
FROM tmp_out;

DROP TABLE tmp_out;



--10. Policz indeks NDWI (to inny indeks niż NDVI) 
--oraz przytnij wyniki do granic Lake District.

--NDWI = (Green – NIR)/(Green + NIR)
--For Sentinel 2 data:
--NDWI= (Band 3 – Band 8)/(Band 3 + Band 8)

CREATE TABLE ndwi AS
WITH 
band3 AS 
(
SELECT ST_Clip(a.rast, ST_Transform(b.geom, 32630), true) rast
FROM dane.sentinel2_band3_1 a, dane.national_parks b
WHERE ST_Intersects(a.rast, ST_Transform(b.geom, 32630)) AND b.id=1
UNION ALL
SELECT ST_Clip(a.rast, ST_Transform(b.geom, 32630), true) rast
FROM dane.sentinel2_band3_2 a, dane.national_parks b
WHERE ST_Intersects(a.rast, ST_Transform(b.geom, 32630)) AND b.id=1

),
band8 AS 
(
SELECT ST_Clip(a.rast, ST_Transform(b.geom, 32630), true) rast
FROM dane.sentinel2_band8_1 a, dane.national_parks b
WHERE ST_Intersects(a.rast, ST_Transform(b.geom, 32630)) AND b.id=1
UNION ALL
SELECT ST_Clip(a.rast, ST_Transform(b.geom, 32630), true) rast
FROM dane.sentinel2_band8_2 a, dane.national_parks b
WHERE ST_Intersects(a.rast, ST_Transform(b.geom, 32630)) AND b.id=1
)
SELECT ST_MapAlgebra(b3.rast,b8.rast,
					 '([rast1.val] - [rast2.val]) / ([rast1.val] + [rast2.val])::float','32BF') rast
FROM band3 b3, band8 b8


CREATE INDEX idx_ld_ndwi_rast_gist ON ndwi_lake_district
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('public'::name,
'ndwi_lake_district'::name,'rast'::name);


--11. Wyeksportuj obliczony i przycięty wskaźnik NDWI do GeoTIFF.

CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,ST_AsGDALRaster(ST_Union(rast), 'GTiff', 
									   ARRAY['COMPRESS=DEFLATE','PREDICTOR=2', 'PZLEVEL=9'])) 
									   AS loid
FROM ndwi_lake_district;

SELECT lo_export(loid, 'D:\ndwi.tiff')
FROM tmp_out;

SELECT lo_unlink(loid)
FROM tmp_out;

DROP TABLE tmp_out;




---------------------------------------------------------
-- TABELE DO SPRAWDZENIA CZY WARSTWY DOBRZE SIĘ PRZYCIEŁY
---------------------------------------------------------
-- CREATE TABLE clip_band3 AS
-- (
-- SELECT ST_Clip(a.rast, ST_Transform(b.geom, 32630), true)
-- FROM dane.sentinel2_band3_1 AS a, dane.national_parks AS b
-- WHERE ST_Intersects(a.rast, ST_Transform(b.geom, 32630)) AND b.id=1
-- 	UNION ALL
-- SELECT ST_Clip(a.rast, ST_Transform(b.geom, 32630), true)
-- FROM dane.sentinel2_band3_2 AS a, dane.national_parks AS b
-- WHERE ST_Intersects(a.rast, ST_Transform(b.geom, 32630)) AND b.id=1
-- );

-- CREATE TABLE clip_band8 AS
-- (
-- SELECT ST_Clip(a.rast, ST_Transform(b.geom, 32630), true)
-- FROM dane.sentinel2_band8_1 AS a, dane.national_parks AS b
-- WHERE ST_Intersects(a.rast, ST_Transform(b.geom, 32630)) AND b.id=1
-- 	UNION ALL
-- SELECT ST_Clip(a.rast, ST_Transform(b.geom, 32630), true)
-- FROM dane.sentinel2_band8_2 AS a, dane.national_parks AS b
-- WHERE ST_Intersects(a.rast, ST_Transform(b.geom, 32630)) AND b.id=1
-- );
