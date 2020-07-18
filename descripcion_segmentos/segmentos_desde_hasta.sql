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
...
 02   | 014  | 010    | 02   | 03    | 0023 | 001  |          67 |              1 |             35 | f
 02   | 014  | 010    | 02   | 03    | 0023 | 001  |          68 |             36 |             70 | f
 02   | 014  | 010    | 02   | 03    | 0023 | 001  |          69 |             71 |             72 | f
 02   | 014  | 010    | 02   | 03    | 0023 | 002  |          69 |             73 |             73 | t
 02   | 014  | 010    | 02   | 03    | 0023 | 003  |          69 |             74 |            104 | f
 02   | 014  | 010    | 02   | 03    | 0023 | 003  |          70 |            105 |            139 | f
 02   | 014  | 010    | 02   | 03    | 0023 | 003  |          71 |            140 |            173 | f
 02   | 014  | 010    | 02   | 03    | 0023 | 003  |          72 |            174 |            208 | f
 02   | 014  | 010    | 02   | 03    | 0023 | 003  |          73 |            209 |            210 | f
 02   | 014  | 010    | 02   | 03    | 0023 | 004  |          73 |            211 |            211 | t
 02   | 014  | 010    | 02   | 03    | 0023 | 005  |          73 |            212 |            242 | t
 02   | 014  | 010    | 02   | 03    | 0024 | 001  |          74 |              1 |              1 | t
 02   | 014  | 010    | 02   | 03    | 0024 | 002  |          74 |              2 |             20 | t
 02   | 014  | 010    | 02   | 03    | 0024 | 003  |          74 |             21 |             28 | f
 02   | 014  | 010    | 02   | 03    | 0024 | 003  |          75 |             29 |             45 | f
 02   | 014  | 010    | 02   | 03    | 0024 | 004  |          75 |             46 |             55 | t
 02   | 014  | 010    | 02   | 03    | 0024 | 005  |          75 |             56 |             56 | t
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
  min(listado.orden_reco::integer) as lado_desde, max(listado.orden_reco::integer) as lado_hasta
from listado
group by prov, dpto, codloc, frac, radio, mza, lado
order by prov, dpto, codloc, frac, radio, mza, lado
--;
)
-- desde hasta lado por segmento
select prov, dpto, codloc, frac, radio, mza, lado, segmento_id,
  min(listado.orden_reco::integer) as seg_lado_desde, max(listado.orden_reco::integer) as seg_lado_hasta,
  (min(listado.orden_reco::integer) = lado_desde and max(listado.orden_reco::integer) = lado_hasta) as completo
from listado
join segmentacion
on listado.id = listado_id
join lados_desde_hasta
using (prov, dpto, codloc, frac, radio, mza, lado)
group by prov, dpto, codloc, frac, radio, mza, lado, segmento_id, lado_desde, lado_hasta
order by prov, dpto, codloc, frac, radio, mza, lado, segmento_id
;
';

return 1;
end;
$function$
;
