WITH 
airports_buffer AS 
(
SELECT st_buffer(geom, 328083) as geom --u mnie układ Alaska Albers, dlstego zamieniłam 100km na stopy
FROM airports
),
railroads_buffer AS 
(
SELECT st_buffer(geom, 164041) as geom --to samo co wyżej (50km)
FROM railroads
),
trails_buffer AS 
(
SELECT st_buffer(geom, 3280) as geom --to samo co wyżej (1km)
FROM trails
)
SELECT st_intersection((st_intersection
						((st_intersection((SELECT st_union(geom) FROM airports_buffer), r.geom)),
						 (st_intersection((SELECT st_union(geom) FROM railroads_buffer), r.geom)))),
					  (SELECT st_union(geom) FROM trails_buffer))
					  as geom
FROM regions r