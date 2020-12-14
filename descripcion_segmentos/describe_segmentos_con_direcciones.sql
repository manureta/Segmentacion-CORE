/*
titulo: describe_segmentos_con_direcciones.sql
descripción:
crea la descripcion de un dado segmento, usando mzas, lados, y desde hasta por lados
para agregarse en el mapa del radio


autor: -h
fecha: 14/12/2020

*/

DROP FUNCTION indec.describe_segmentos_con_direcciones(text);
create or replace function indec.describe_segmentos_con_direcciones(esquema text)
 returns table (
 prov integer, dpto integer, codloc integer, frac integer, radio integer, 
 mza integer, lado integer, segmento bigint, descripcion text
)
 language plpgsql volatile
set client_min_messages = error
as $function$
begin

return query
execute '
with 
segmento_lado_desde_hasta as (
    select prov, dpto, codloc, frac, radio, mza, lado, segmento_id, 
    desde_id, hasta_id,
    indec.descripcion_calle_desde_hasta(''' || esquema || ''', desde_id, hasta_id)::text as descripcion
    from "' || esquema || '".segmentos_desde_hasta_ids)
select prov::integer, dpto::integer, codloc::integer, frac::integer, radio::integer,
    mza::integer, lado::integer,
    segmento_id::bigint, descripcion
from segmento_lado_desde_hasta
';
end;
$function$
;


