/*
titulo: excluye_colectivas.sql
descripción:
devuelve el text para excluir las viviendas colectivas el segmento_lado
autor: -h
fecha: 2021-04-26

*/

DROP FUNCTION if exists indec.excluye_colectivas_ffrrmmmllss(text, _frac integer, _radio integer, 
  _mza integer, _lado integer, _seg_id integer);
create or replace function indec.excluye_colectivas_ffrrmmmllss(esquema text, _frac integer, _radio integer,
  _mza integer, _lado integer, _seg_id integer)
 returns table (descripcion text)
 language plpgsql volatile
set client_min_messages = error
as $function$

declare a_excluir text;

begin
 
execute '
with
  listado as (select * 
    from "' || esquema || '".listado 
    where frac::integer = ' || _frac || ' and radio::integer = ' || _radio || '
    and mza::integer = ' || _mza || ' and lado::integer = ' || _lado || '
    and tipoviv = ''CO''
  ),
  segmentacion as (select * from "' || esquema || '".segmentacion where segmento_id = ' || _seg_id || '),
  casos as (select * from listado join segmentacion on listado.id = listado_id)

select string_agg(indec.descripcion_domicilio(''' || esquema || ''', id), '', '')::text as descripcion
from casos
;' into a_excluir;

if a_excluir != '' then 
  return query 
  select '. Se excluyen la(s) vivienda(s) colectiva(s): ' || a_excluir;
else
  return query 
  select '';  
end if;

end;
$function$
;


