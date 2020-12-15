/*
titulo: describe_segmentos_con_direcciones.sql
descripción:
crea la descripcion de un dado segmento, usando mzas, lados, y desde hasta por lados
para agregarse en el mapa del radio


autor: -h
fecha: 14/12/2020

*/

DROP FUNCTION if exists indec.describe_segmentos_con_direcciones(text,bigint);
create or replace function indec.describe_segmentos_con_direcciones(esquema text, s_id bigint)
 returns table (
 prov integer, dpto integer, codloc integer, frac integer, radio integer,
 segmento_id bigint, descripcion text, viviendas numeric
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
    desde_id, hasta_id, completo,
    indec.descripcion_calle_desde_hasta(''' || esquema || ''', desde_id, hasta_id)::text as descripcion,
    viviendas
  from "' || esquema || '".segmentos_desde_hasta_ids
  where segmento_id::bigint = ' || s_id || '
  order by prov::integer, dpto::integer, codloc::integer, frac::integer, radio::integer,
    mza::integer, lado::integer
  ),
segmento_lados as (
  select prov::integer, dpto::integer, codloc::integer, frac::integer, radio::integer,
    mza::integer, segmento_id::bigint, 
    string_agg('' Lado '' || lado::text || 
      case when completo then '' completo '' else '''' end ||
        '', '' || descripcion, ''; '') as descripcion,
    sum(viviendas) as viviendas
  from segmento_lado_desde_hasta
  group by prov::integer, dpto::integer, codloc::integer, frac::integer, radio::integer,
    mza::integer, segmento_id::bigint
  )
select prov::integer, dpto::integer, codloc::integer, frac::integer, radio::integer,
  segmento_id::bigint, 
  string_agg('' Manzana '' || mza::text || '', '' || descripcion, ''. '') as descripcion,
  sum(viviendas) as viviendas
from segmento_lados
group by prov::integer, dpto::integer, codloc::integer, frac::integer, radio::integer,
  segmento_id::bigint
';
end;
$function$
;


DROP FUNCTION if exists indec.describe_segmentos_con_direcciones(text);
create or replace function indec.describe_segmentos_con_direcciones(esquema text)
 returns table (
 prov integer, dpto integer, codloc integer, frac integer, radio integer,
 segmento_id bigint, descripcion text, viviendas numeric
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
    indec.descripcion_calle_desde_hasta(''' || esquema || ''', desde_id, hasta_id)::text as descripcion,
    viviendas
  from "' || esquema || '".segmentos_desde_hasta_ids
  order by prov::integer, dpto::integer, codloc::integer, frac::integer, radio::integer,
    mza::integer, lado::integer
  ),
segmento_lados as (
  select prov::integer, dpto::integer, codloc::integer, frac::integer, radio::integer,
    mza::integer, segmento_id::bigint, 
    string_agg('' Lado '' || lado::text || '', '' || descripcion, ''; '') as descripcion,
    sum(viviendas) as viviendas
  from segmento_lado_desde_hasta
  group by prov::integer, dpto::integer, codloc::integer, frac::integer, radio::integer,
    mza::integer, segmento_id::bigint
  )
select prov::integer, dpto::integer, codloc::integer, frac::integer, radio::integer,
  segmento_id::bigint, 
  string_agg('' Manzana '' || mza::text || '', '' || descripcion, ''. '') as descripcion,
  sum(viviendas) as viviendas
from segmento_lados
group by prov::integer, dpto::integer, codloc::integer, frac::integer, radio::integer,
  segmento_id::bigint
';
end;
$function$
;

