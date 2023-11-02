--srednia wysokosc (454.6363636363636)
SELECT AVG(elev) 
FROM airports
WHERE use ILIKE '%Military%';

 --ile lotnisk militarnych (11)
SELECT COUNT(id) 
FROM airports
WHERE use ILIKE '%Military%';

--Usuń z warstwy airports lotniska o charakterze militarnym, 
--które są dodatkowo położone powyżej 1400 m n.p.m.
--Ile było takich lotnisk? (1)
SELECT 	COUNT(id) FROM airports 
WHERE 
use ILIKE '%Military%'
AND 
elev>1400;

--usuwanie
DELETE FROM airports
WHERE 
use ILIKE '%Military%'
AND 
elev>1400;


