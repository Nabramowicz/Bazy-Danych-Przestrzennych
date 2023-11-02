--'uproszczone' bagna
--wierzchołki (6661)
SELECT sum(st_npoints(st_simplify(geom, 100))) as geom
FROM swamp
--pole (266082466575.26416)
SELECT sum(st_area(st_simplify(geom, 100))) as geom
FROM swamp

--zwykłe bagna
--wierzchołki (7469)
SELECT sum(st_npoints(geom)) as geom
FROM swamp
--pole (266080392628.23563)
SELECT sum(st_area(geom)) as geom
FROM swamp

--WNIOSKI: Po uproszczeniu geometrii bagien z tolerancją równą 100, 
--liczba wierzchołków się zmniejszyła a pole powierzchni się
--zwiększyło (nieznacznie) względem nieuproszczonej geometrii.
