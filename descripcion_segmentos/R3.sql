/*
nombre: R3.sql
descripción:
genera function que devuelve
descripción de llistados
por segmentos por radio 
se usa para
-> R3 y box descripción del mapa en manzanas_independientes

https://github.com/hernan-alperin/Segmentacion-CORE/issues/11

autor: -h
fecha: 2020-07-14
*/


-- datos de segmento x listado 
-- en aglo.segmentacion
-- generado por segmentar_equilibrado.sql

-- drop function indec.r3(aglomerado text);
create or replace function indec.r3(aglomerado text)
 returns table (
 segmento_id bigint,
 mza text,
 lado text,
 descripcion text
)  

language plpgsql volatile
set client_min_messages = error
as $function$

begin

return query
execute 
'
with 
  listado as (select * from "' || aglomerado || '".listado),
  segmentacion as (select * from "' || aglomerado || '".segmentacion),
  listado_segmento_id as (
  select *
  from listado
  join segmentacion
  on listado.id = listado_id
  ),
  desde_ids as (
  select segmento_id, lado, min(id) as desde_id
  from listado_segmento_id
  group by segmento_id, lado
  order by segmento_id, lado
  ),
  hasta_ids as (
  select segmento_id, lado, max(id) as hasta_id
  from listado_segmento_id
  group by segmento_id, lado
  order by segmento_id, lado
  ), 
  desde as (select dpto, frac, radio, mza, segmento_id, lado, desde_id,
--
-- ver códigos específicos dado por DPE para identicar y describir un domicilio
--   numero || '' '' || piso || ''° '' || apt as desde

  nrocatastr ||
  case when sector is Null or sector = '''' then '''' else sector end || 
  case when edificio is Null or edificio = ''''  then '''' else edificio end || 
  case when entrada is Null or entrada = ''''  then '''' else entrada end || 
  case when descripcio is Null or descripcio = ''''  then '''' else descripcio end || 
  case when descripci2 is Null or descripci2 = ''''  then '''' else descripci2 end || 

  '' '' || piso || ''° '' || dpto_habit as desde
--
  from listado_segmento_id as listado
  natural join desde_ids
  where id = desde_id
  ),
  hasta as (select dpto, frac, radio, mza, segmento_id, lado, hasta_id,
--  numero || '' '' || piso || ''° '' || apt as hasta
                                                                                                                                                                          nrocatastr ||
  case when sector is Null or sector = '''' then '''' else sector end || 
  case when edificio is Null or edificio = ''''  then '''' else edificio end ||
  case when entrada is Null or entrada = ''''  then '''' else entrada end ||
  case when descripcio is Null or descripcio = ''''  then '''' else descripcio end ||
  case when descripci2 is Null or descripci2 = ''''  then '''' else descripci2 end ||                                                                     
  '' '' || piso || ''° '' || dpto_habit as hasta

  from listado_segmento_id as listado
  natural join hasta_ids
  where id = hasta_id
  ),
  segmentos_en_manzana as (select *
  from desde
  natural join hasta
  )
select distinct segmento_id::bigint as segmento, 
  mza::text as manzana, lado::text, 
  ccalle || '' - '' || ncalle || '' desde '' || desde || '' hasta '' || hasta as descripcion
from segmentos_en_manzana as s
join listado as l
using (frac, radio, mza, lado)
order by segmento_id, manzana, lado, descripcion
;
';
end;
$function$
;


-- ejemplo select indec.r3('e0002');



/*

*/
