/*
titulo: dividir_listado.sql
descripción: 
function indec.dividir_listado(aglomerado, cant_vivs)

genera 2 sublistados
uno para cada algoritmo
aglomerado.listado_recorrido
aglomerado.listado_lados_completos

cant_viviendas usa cargar_conteos
que usa contar_vivienda donde están definidos los códigos que cuentan

autor: -h
fecha: 2020-05
https://github.com/hernan-alperin/Segmentacion-CORE/issues/8
*/

create or replace function indec.dividir_listado(aglomerado text, cant_vivs integer, metodo text)
 returns integer
 language plpgsql volatile
set client_min_messages = error
as $function$

begin
execute 'drop table if exists "' || aglomerado || '".listado_recorrido;';
execute 'drop table if exists "' || aglomerado || '".listado_lados_completos;';

execute '
create table "' || aglomerado || '".listado_recorrido as
with
listado as (
    select * from "' || aglomerado || '".listado
    ),
conteos as (
    select * from "' || aglomerado || '".conteos
    ), 
lados_excedidos as (
    select *
    from conteos
    where conteo > ' || cant_vivs || '
    )
select * 
from listado
where (prov::integer, dpto::integer, codloc::integer, 
       frac::integer, radio::integer, 
       mza::integer, lado::integer) not in
    (select prov, dpto, codloc, frac, radio, mza, lado 
    from lados_excedidos)
;
create table "' || aglomerado || '".listado_lados_completos as
select * from "' || aglomerado || '".listado
except
select * from "' || aglomerado || '".listado_recorrido
;'
;

return 1;
end;
$function$
;


-- ejemplo select indec.dividir_listado('e0029', 40, '');
-- el parámetro metodo se va a usar para excluir las manzanas enteras
-- que contengan esos lados y balancear mejor la sobrecarga



