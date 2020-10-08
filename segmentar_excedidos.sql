/*
titulo: segmentar_excedidos.sql
descripción: 
segmenta en forma equilibrada sin cortar piso, balanceando la
cantidad deseada con la proporcional de viviendas por segmento 
usando la cantidad de viviendas en la manzana.
El objetivo es que los segmentos se aparten lo mínimo de la cantidad deseada
y que la carga de los censistas esté lo más balanceado

segmenta las manzanas que tienen radios excedidos de una cantidad umbral
autor: -h+M
fecha: 2019-06-05 Mi
*/



create or replace function 
indec.segmentar_excedidos(esquema text, umbral integer)
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

        
