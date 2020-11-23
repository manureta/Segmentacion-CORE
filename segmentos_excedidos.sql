/*
titulo: segmentos_excedidos.sql
descripción: función que devuelve una lista de los segmentos excedidos en el radio

autor: -h
fecha:2020-11
*/

create or replace function
indec.segmentos_excedidos(esquema text, umbral integer)
    returns table (segmento_id bigint)
    language plpgsql volatile
    set client_min_messages = error
as $function$

begin

return query
execute '
select segmento_id
from "' || esquema || '".listado
join "' || esquema || '".segmentacion
on listado_id = listado.id
group by segmento_id
having count(*) > ' || umbral || '
;';
end;
$function$
;


