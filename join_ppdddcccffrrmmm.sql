/*
nombre: join_ppdddcccffrrmmm.sql
descripcion:
function indec.join_ppdddcccffrrmmm.sql(text, integer*6)
para juntar bases cartográficas y de listados
usando text [0-9]^15 PPDDDCCCFFRRMMM <---> prov,dpto,codloc,frac,radio,mza
autor: -h
2020-11
*/

create or replace function indec.join_ppdddcccffrrmmm(PPDDDCCCFFRRMMM text, 
  prov integer, dpto integer, codloc integer, frac integer, radio integer, mza integer)
  returns boolean
  language sql immutable
as $function$
select
$1 is not Null 
and $1 != ''
and $1 ~ '^[0-9]' -- es numérico
and length($1) = 15
and substr($1,1,2)::integer = $2 -- PP = prov
and substr($1,3,3)::integer = $3 -- DDD = dpto
and substr($1,6,3)::integer = $4 -- CCC = codloc
and substr($1,9,2)::integer = $5 -- FF = frac
and substr($1,11,2)::integer = $6 -- RR = radio
and substr($1,13,3)::integer = $7 -- MMM = mza
$function$
;


-- Unit tests
with 
  test_no_null as (select indec.join_ppdddcccffrrmmm(Null,1,2,3,4,5,6) = False as no_null),
  test_no_empty as (select indec.join_ppdddcccffrrmmm('',1,2,3,4,5,6) = False as no_empty),
  test_numeric as (select indec.join_ppdddcccffrrmmm('a',1,2,3,4,5,6) = False as is_numeric), -- safe
  test_no_match as (select indec.join_ppdddcccffrrmmm('123456789012345',1,2,3,4,5,6) = False as no_match),
  test_match_garbage_anyway as (select indec.join_ppdddcccffrrmmm('123456789012345',12,345,678,90,12,345) = True as match_garbage_anyway),
  test_match as (select indec.join_ppdddcccffrrmmm('112223334455666',11,222,333,44,55,666) = True as match)
select *
from test_no_null
natural join test_no_empty
natural join test_numeric
natural join test_no_match
natural join test_match_garbage_anyway
natural join test_match
;

-- (?) definir qué deben hacer los siguientes tests
select indec.join_ppdddcccffrrmmm('123456789012',12,345,678,90,12,345) = False as test_no_match_shorter;  
select indec.join_ppdddcccffrrmmm('12345678901234567',12,345,678,90,12,345) = False as test_no_match_longer;

