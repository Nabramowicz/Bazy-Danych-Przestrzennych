CREATE TABLE buildings_in_bristol_bay as
SELECT * FROM popp p
WHERE 
p.f_codedesc='Building'
and
st_within(p.geom, (SELECT geom FROM regions WHERE name_2='Bristol Bay'));

SELECT COUNT(gid) FROM buildings_in_bristol_bay;