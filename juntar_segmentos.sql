/*
titulo: juntar_segmentos.sql
descripción:
junta segmentos de cero viviendas con el segmento contiguo de menor cantidad de viviendas
cambia el código
autor: -h
fecha: 2021-04-11 Do
*/


create or replace function
indec.juntar_segmentos(esquema text)
    returns integer
    language plpgsql volatile
    set client_min_messages = error
as $function$

begin
/*
execute '
with
  lados_segmentos_excedidos as (
  select prov, dpto, codloc, frac, radio, mza, lado, segmento_id
  from "' || esquema || '".segmentacion
  join "' || esquema || '".listado
  on listado_id = listado.id
  group by segmento_id
  having count(*) > umbral
  )
update "' || esquema || '".segmentacion
set segmento_id = Null -- (?) y acá? agregar un campo en segmentación?
where
segmento_id in (select segmento_id from lados_segmentos_excedidos)
';
*/

return 1;
end;
$function$
;


