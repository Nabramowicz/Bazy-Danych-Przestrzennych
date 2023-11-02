CREATE TABLE railroads_nodes AS
SELECT st_node(geom) AS geom
FROM railroads

SELECT COUNT(geom) FROM railroads_nodes 