/*
nombre: join_ppdddcccffrrmmm.sql
descripcion:
function indec.join_ppdddcccffrrmmm.sql(text, integer*6)
para juntar bases cartográficas y de listados
usando text [0-9]^15 PPDDDCCCFFRRMMM <---> prov,dpto,codloc,frac,radio,mza
autor: -h
2020-11
*/

create or replace function indec.join_ppdddcccffrrmmm.sql(PPDDDCCCFFRRMMM text, 
  prov integer, dpto integer, codloc integer, frac integer. radio integer, mza integer)
  returns text
  language sql immutable
as $function$
select
$1 is not Null 
and $1 != ''
and substr($1,1,2)::integer = $2 -- PP = prov
and substr($1,3,3)::integer = $3 -- DDD = dpto
and substr($1,6,3)::integer = $4 -- CCC = codloc
and substr($1,9,3)::integer = $5 -- FF = frac
and substr($1,11,2)::integer = $6 -- RR = radio
and substr($1,13,3)::integer = $7 -- MMM = mza
$function$
;

