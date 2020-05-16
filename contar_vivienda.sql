/*
titulo: contar_vivienda.sql
descripción: 
define por tipoviv cual registro se contabiliza como vivenda
devuelve tipoviv si se cuenta, Null si no
para usar el count(tipoviv)
es usada por generar_conteos

autor: -h
fecha: 2020-05
*/

create or replace function indec.contar_vivienda(in tipoviv text)
 returns text
 language sql immutable
as $function$
select 
  case 
    when trim($1) in ('', 'co', 'n', 'ca/', 'lo') then Null
    else $1
  end;
$function$
;

