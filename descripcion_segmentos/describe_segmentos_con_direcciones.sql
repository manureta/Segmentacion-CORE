/*
titulo: describe_segmentos_con_direcciones.sql
descripción:
crea la descripcion de un dado segmento, usando mzas, lados, y desde hasta por lados
para agregarse en el mapa del radio


autor: -h
fecha: 14/12/2020

*/


DROP FUNCTION if exists indec.describe_segmentos_con_direcciones(text);
create or replace function indec.describe_segmentos_con_direcciones(esquema text)
 returns table (
 prov integer, dpto integer, codloc integer, frac integer, radio integer,
 segmento_id bigint, seg text, descripcion text, viviendas numeric
)
 language plpgsql volatile
set client_min_messages = error
as $function$
begin

return query
execute '
with minimos as (
  select prov, dpto, codloc, frac, radio, segmento_id, 
    min(mza::integer) as minmza, min(lado::integer) as minlado, min(orden_reco::integer) as minreco, 
    min(sector) as minsector, min(edificio) as minedificio, min(entrada) as minentrada,
    max(REGEXP_REPLACE(COALESCE(piso::character varying, ''0''), ''[^0-9]*'' ,''0'')::integer) as maxpiso
  from "' || esquema || '".listado
  join "' || esquema || '".segmentacion
  on listado_id = listado.id
  group by prov, dpto, codloc, frac, radio, segmento_id
  ),
etiquetas as (
  select segmento_id, rank() over w as seg
  from minimos
  window w as (
    partition by prov, dpto, codloc, frac, radio
    order by minmza, minlado, minreco, minsector, minedificio, minentrada, maxpiso desc
    )
  ),
segmento_lado_desde_hasta as (
  select prov, dpto, codloc, frac, radio, mza, lado, segmento_id,
    desde_id, hasta_id, completo,
    ''Lado '' || lpad(lado::integer::text, 2, ''0'') ||
      case when completo then '' completo ''
           else '' ''
      end ||
    indec.descripcion_calle_desde_hasta(''' || esquema || ''', desde_id, hasta_id, completo)::text as descripcion,
    viviendas
  from "' || esquema || '".segmentos_desde_hasta_ids
  order by prov::integer, dpto::integer, codloc::integer, frac::integer, radio::integer,
    mza::integer, lado::integer
  ),
segmento_lados as (
  select prov::integer, dpto::integer, codloc::integer, frac::integer, radio::integer,
    mza::integer, segmento_id::bigint, 
    string_agg(descripcion, '', '') as descripcion,
    sum(viviendas) as viviendas
  from segmento_lado_desde_hasta
  group by prov::integer, dpto::integer, codloc::integer, frac::integer, radio::integer,
    mza::integer, segmento_id::bigint
  )
select prov::integer, dpto::integer, codloc::integer, frac::integer, radio::integer,
  segmento_id::bigint, seg::text, 
  string_agg(''Manzana '' || lpad(mza::integer::text, 3, ''0'') || '': '' || descripcion, ''. '') as descripcion,
  sum(viviendas) as viviendas
from segmento_lados
join etiquetas
using (segmento_id)
group by prov::integer, dpto::integer, codloc::integer, frac::integer, radio::integer,
  segmento_id::bigint, seg::text
';
end;
$function$
;



