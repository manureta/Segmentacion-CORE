/*
titulo: describe_segmentos_con_direcciones_ffrr.sql
descripción:
crea la descripcion de un dado segmento, usando mzas, lados, y desde hasta por lados
para agregarse en el mapa del radio
SÓLO para un SOLO radio
no usa tabla intermedia esquema.segmendo_lado_desde_hasta_ids
decide si hay que usar muestreo o no
autor: -h
fecha: 2021-01-29

*/

DROP FUNCTION if exists indec.describe_segmentos_con_direcciones_ffrr(text, integer, integer);
create or replace function indec.describe_segmentos_con_direcciones_ffrr(esquema text, _frac integer, _radio integer)
 returns table (
 prov integer, dpto integer, codloc integer, frac integer, radio integer,
 segmento_id bigint, seg text, descripcion text, viviendas numeric
)
 language plpgsql volatile
set client_min_messages = error
as $function$

declare muestreado boolean;

begin
execute 'select ''muestra'' in (select table_name from information_schema.tables where table_schema=''' || esquema || ''');'
into muestreado;

if not muestreado then
  return query 
  execute '
  select * from indec.describe_sin_muestreo_ffrr(''' || esquema || ''', ' || _frac || ', ' ||  _radio || ');';
else  
  return query 
  execute '
  select * from indec.describe_despues_de_muestreo_ffrr(''' || esquema || ''', ' || _frac || ', ' ||  _radio || ');';

end if;

    
end;
$function$
;


