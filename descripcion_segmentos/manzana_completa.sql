/*
titulo: manzana_completa.sql
descripción:
devuelve boolean si la manzana está completa en el segmento
autor: -h
fecha: 2021-06-12
*/

DROP FUNCTION if exists indec.manzana_completa_ffrr(text, integer, integer, integer);
create or replace function indec.manzana_completa_ffrr(esquema text, _frac integer, _radio integer, _mza integer)
 returns boolean
 language plpgsql volatile
set client_min_messages = error
as $function$

declare mza_completa boolean;

begin

execute '
with listado as (select *
    from "' || esquema || '".listado
    where -- indec.contar_vivienda(tipoviv) and --debe considerar LSV también (ver qué pasa con colectiva)
    frac::integer = ' || _frac || ' and radio::integer = ' || _radio || '
  ),
  segmentacion as (select * from listado join "' || esquema || '".segmentacion on listado.id = listado_id),
  segmentos_que_tienen_mza as (
    select distinct segmento_id as segs
    from segmentacion
    where mza::integer = ' || _mza || '
  )
select count(segs) = 1
from segmentos_que_tienen_mza 
;' into mza_completa;

return mza_completa;

end;
$function$
;



