/*
titulo: segmentos_desde_hasta.sql
descripción: 
desde y hasta qué registro del listado spanea el segmento por lado de manzana
ademas de informar si el lado está completamente incluido en el segmento
proceso posterior a la segmentación por manzana completa
necesario para generar la descripcion de cada segmento
indec.segmentar_equilibrado(esquema, carga)
autor: -h
fecha: 18/7/2020

ejemplo:
 prov | dpto | codloc | frac | radio | segmento_id | mza  | lado | seg_lado_desde | seg_lado_hasta | completo
------+------+--------+------+-------+-------------+------+------+----------------+----------------+----------
 02   | 014  | 010    | 01   | 01    |           1 | 0001 | 001  |              1 |              1 | t
 02   | 014  | 010    | 01   | 01    |           1 | 0001 | 002  |              2 |              2 | t
 02   | 014  | 010    | 01   | 01    |           1 | 0001 | 003  |              3 |              3 | t
 02   | 014  | 010    | 01   | 01    |           1 | 0001 | 004  |              4 |              4 | t
 02   | 014  | 010    | 01   | 01    |           2 | 0003 | 001  |              5 |              5 | t
...
 02   | 014  | 010    | 02   | 03    |         103 | 0023 | 001  |           1345 |           1410 | f
 02   | 014  | 010    | 02   | 03    |         103 | 0023 | 002  |           1411 |           1411 | t
 02   | 014  | 010    | 02   | 03    |         103 | 0023 | 003  |           1412 |           1418 | f
 02   | 014  | 010    | 02   | 03    |         104 | 0023 | 001  |           1347 |           1347 | f
 02   | 014  | 010    | 02   | 03    |         104 | 0023 | 003  |           1419 |           1437 | f
 02   | 014  | 010    | 02   | 03    |         105 | 0024 | 001  |           1581 |           1581 | t
 02   | 014  | 010    | 02   | 03    |         105 | 0024 | 002  |           1582 |           1600 | t
 02   | 014  | 010    | 02   | 03    |         105 | 0024 | 003  |           1601 |           1606 | f
 02   | 014  | 010    | 02   | 03    |         106 | 0024 | 002  |           1583 |           1584 | f
 02   | 014  | 010    | 02   | 03    |         106 | 0024 | 003  |           1607 |           1623 | f
 02   | 014  |: 010    | 02   | 03    |         107 | 0024 | 002  |           1585 |           1589 | f
 02   | 014  | 010    | 02   | 03    |         107 | 0024 | 003  |           1624 |           1625 | f
 02   | 014  | 010    | 02   | 03    |         107 | 0024 | 004  |           1626 |           1635 | t
 02   | 014  | 010    | 02   | 03    |         107 | 0024 | 005  |           1636 |           1636 | t
 02   | 014  | 010    | 02   | 03    |         108 | 0026 | 001  |           1637 |           1637 | t
 02   | 014  | 010    | 02   | 03    |         108 | 0026 | 002  |           1638 |           1638 | t
 02   | 014  | 010    | 02   | 03    |         108 | 0026 | 003  |           1639 |           1639 | t
 02   | 014  | 010    | 02   | 03    |         108 | 0026 | 004  |           1640 |           1640 | t
...

*/

create or replace function indec.segmentos_desde_hasta(aglomerado text)
 returns integer
 language plpgsql volatile
set client_min_messages = error
as $function$

begin
execute 'drop table if exists "' || aglomerado || '".segmentos_desde_hasta;';

execute '
create table "' || aglomerado || '".segmentos_desde_hasta as 
with 
listado as ( select * from "' || aglomerado || '".listado),
segmentacion as ( select * from "' || aglomerado || '".segmentacion),

lados_desde_hasta as (
-- desde hasta por lado
select prov, dpto, codloc, frac, radio, mza, lado,
  min(listado.id) as lado_desde, max(listado.id) as lado_hasta
from listado                                                                                                                                                      group by prov, dpto, codloc, frac, radio, mza, lado
order by prov, dpto, codloc, frac, radio, mza, lado
--;
)
-- desde hasta lado por segmento
select prov, dpto, codloc, frac, radio, segmento_id, mza, lado,
  min(listado.id) as seg_lado_desde, max(listado.id) as seg_lado_hasta,
  (min(listado.id) = lado_desde and max(listado.id) = lado_hasta) as completo
from listado
join segmentacion
on listado.id = listado_id
join lados_desde_hasta
using (prov, dpto, codloc, frac, radio, mza, lado)
group by prov, dpto, codloc, frac, radio, segmento_id, mza, lado, lado_desde, lado_hasta
order by prov, dpto, codloc, frac, radio, segmento_id, mza, lado
;
';

return 1;
end;
$function$
;
