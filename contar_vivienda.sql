/*
titulo: contar_vivienda.sql
descripción: 
define por tipoviv cual registro se contabiliza como vivenda
devuelve 1 si se cuenta, 0 si no
es usada por generar_conteos

autor: -h
fecha: 2020-05
*/

create or replace function indec.contar_vivienda(in tipoviv character varying(5))
 returns boolean
 language sql immutable
as $function$
select 
  case
    when $1 is Null then False 
    when trim($1) not in ('', 'co', 'n', 'ca/', 'lo') then True
    else False
  end;
$function$
;

