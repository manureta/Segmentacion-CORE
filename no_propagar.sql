/*
titulo: no_propagar.sql
descripción:
funciones que devuelven 
las mnzas o lados que no
se pueden propagar de lados completos a tabla segmentacion 
por tener cantidad excedida
autor: -h
fecha: 2020-10
*/

create or replace function indec.lados_excedidos(esquema text, umbral integer)
 returns table (
 prov integer, dpto integer, codloc integer, frac integer, radio integer, mza integer, lado integer
)
 language plpgsql volatile
set client_min_messages = error
as $function$
begin

return query
execute '
select prov, dpto, codloc, frac, radio, mza, lado 
from "' || esquema || '".v_segmentos_lados_completos
where vivs > ' || umbral || '
;';
end;
$function$
;


create or replace function indec.mzas_con_lado_excedido(esquema text, umbral integer)
 returns table (
 prov integer, dpto integer, codloc integer, frac integer, radio integer, mza integer, lado integer
)
 language plpgsql volatile
set client_min_messages = error
as $function$
begin

return query
execute '
select distinct prov, dpto, codloc, frac, radio, mza
from indec.lados_excedidos(esquema, umbral)
;';
end;
$function$
;



