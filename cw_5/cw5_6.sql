SELECT bbb.* 
FROM buildings_in_bristol_bay bbb
WHERE ST_DWithin((SELECT ST_Union(geom) FROM rivers),
				 bbb.geom,
				 100000,
				 true);