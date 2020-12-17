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
 prov | dpto | codloc | frac | radio | mza  | lado | segmento_id | seg_lado_desde | seg_lado_hasta | completo
------+------+--------+------+-------+------+------+-------------+----------------+----------------+----------
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

create or replace function indec.segmentos_desde_hasta(esquema text)
 returns integer
 language plpgsql volatile
set client_min_messages = error
as $function$

begin
execute 'drop table if exists "' || esquema || '".segmentos_desde_hasta cascade;';

execute '
create table "' || esquema || '".segmentos_desde_hasta as 
with 
listado as ( select id, prov, dpto, codloc, frac, radio, mza, lado,
coalesce(CASE WHEN orden_reco='''' THEN NULL ELSE orden_reco END,''0'')::integer orden_reco,
tipoviv
from "' || esquema || '".listado),
segmentacion as ( select * from "' || esquema || '".segmentacion),

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
  (min(listado.orden_reco::integer) = lado_desde and max(listado.orden_reco::integer) = lado_hasta) as completo,
  count(indec.contar_vivienda(tipoviv)) as viviendas
from listado
join segmentacion
on listado.id = listado_id
join lados_desde_hasta
using (prov, dpto, codloc, frac, radio, mza, lado)
group by prov, dpto, codloc, frac, radio, mza, lado, segmento_id, lado_desde, lado_hasta
order by prov, dpto, codloc, frac, radio, mza, lado, segmento_id
;
';

execute 'CREATE INDEX idx_segmentos_desde_hasta ON
"' || esquema || '".segmentos_desde_hasta (prov, dpto, codloc, frac, radio, mza, lado,
segmento_id)';

execute 'drop table if exists "' || esquema || '".segmentos_desde_hasta_ids cascade;';
execute '
create table "' || esquema || '".segmentos_desde_hasta_ids as
with 
listado as ( select id, prov, dpto, codloc, frac, radio, mza, lado,
orden_reco
from "' || esquema || '".listado
WHERE trim(orden_reco)!='''')
select * from
(
  select l.prov, l.dpto, l.codloc, l.frac, l.radio, l.mza, l.lado, s.segmento_id, l.id as desde_id,
  viviendas, completo
  from "' || esquema || '".segmentos_desde_hasta s
  join listado l on s.prov = l.prov and s.dpto = l.dpto and s.codloc = l.codloc
  and s.frac = l.frac and s.radio = l.radio and s.mza = l.mza and s.lado = l.lado
  and seg_lado_desde = orden_reco::integer
) as desdes
natural join (
  select l.prov, l.dpto, l.codloc, l.frac, l.radio, l.mza, l.lado, s.segmento_id, l.id as hasta_id,
  viviendas, completo
  from "' || esquema || '".segmentos_desde_hasta s
  join listado l on s.prov = l.prov and s.dpto = l.dpto and s.codloc = l.codloc
  and s.frac = l.frac and s.radio = l.radio and s.mza = l.mza and s.lado = l.lado
  and seg_lado_hasta = orden_reco::integer
) as hastas
order by prov, dpto, codloc, frac, radio, mza, lado
;
';

execute 'CREATE INDEX idx_segmentos_desde_hasta_ids ON
"' || esquema || '".segmentos_desde_hasta_ids (prov, dpto, codloc, frac, radio, mza, lado)';

return 1;
end;
$function$
;
