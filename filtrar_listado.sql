/*
titulo: filtrar_listado.sql
descripción: 
function indec.filtrar_listado(aglomerado, cant_vivs, metodo_de_separar, filtro)

cant_vivs crítica para decidir tipo de metodo de segmentacion

autor: -h
fecha: 2020-06
https://github.com/hernan-alperin/Segmentacion-CORE/issues/8
*/

create or replace function indec.filtrar_listado(aglomerado text, cant_vivs integer, metodo_de_separar text, filtro text)
 returns table (
 id integer,
 metodo_de_segmentar text -- puede ser 'lado completo' o 'recorrido'
)  
 language plpgsql volatile
set client_min_messages = error
as $function$

begin

return query
execute '
with
listado as (
    select * from "' || aglomerado || '".listado
    ),
conteos as (
    select * from "' || aglomerado || '".conteos
    ), 
marcados as (
    select listado.id, 
        case 
        when conteo > ' || cant_vivs || ' then ''recorrido''
        else ''lado completo''
        end as metodo_de_segmentar
    from listado
    join conteos
    on listado.prov::integer = conteos.prov 
    and listado.dpto::integer = conteos.dpto
    and listado.codloc::integer = conteos.codloc
    and listado.frac::integer = conteos.frac
    and listado.radio::integer = conteos.radio
    and listado.mza::integer = conteos.mza
    and listado.lado::integer = conteos.lado
)
select * 
from marcados
;';
end;
$function$
;


-- ejemplo select indec.filtrar_listado('e0029', 40, '', '');
-- el parámetro metodo_de_separar se va a usar para excluir más adelante 
-- manzanas enteras
-- que contengan esos lados y balancear mejor la sobrecarga
-- por ejemplo si un lado supera la cantidad crítica
-- 
-- el parámetro filtro se usa para elegir si devuelve filtrado o todo con el campo
-- metodo_de_segmentar


