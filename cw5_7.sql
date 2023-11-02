SELECT ST_NumGeometries(ST_Intersection
						((SELECT ST_Union(geom) FROM majrivers),
						 (SELECT ST_Union(geom) FROM railroads)));
				