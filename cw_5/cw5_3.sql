WITH
matanuska_trails_plus AS 
(
SELECT *
FROM trails t
WHERE ST_intersects(t.geom, (SELECT geom FROM regions WHERE name_2='Matanuska-Susitna'))
)
SELECT SUM(ST_Length(ST_Intersection))
FROM ST_Intersection((SELECT ST_Union(geom) FROM matanuska_trails_plus), 
					 (SELECT geom FROM regions WHERE name_2='Matanuska-Susitna'))