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
  min(listado.orden_reco) as lado_desde, max(listado.orden_reco) as lado_hasta
from listado
group by prov, dpto, codloc, frac, radio, mza, lado
order by prov, dpto, codloc, frac, radio, mza, lado
--;
)
-- desde hasta lado por segmento
select prov, dpto, codloc, frac, radio, mza, lado, segmento_id,
  min(listado.orden_reco) as seg_lado_desde, max(listado.orden_reco) as seg_lado_hasta,
  (min(listado.orden_reco) = lado_desde and max(listado.orden_reco) = lado_hasta) as completo
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
