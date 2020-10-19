/*
segmentos.sql
descripcion:
propaga la segmentacion de lados_completos.py
a esquema.segmentacion
usando lados
autor: -h
2020-10-08
*/

create or replace function indec.v_segmentos_lados_completos(esquema text)
 returns integer
 language plpgsql volatile
set client_min_messages = error
as $function$

begin
execute 'drop view if exists "' || esquema || '".v_segmentos_lados_completos';
execute 'create view "' || esquema || '".v_segmentos_lados_completos as
with de_e00 as (
    select 
/*
      substr(mzai,1,2)::integer as prov, substr(mzai,3,3)::integer as dpto,
      substr(mzai,6,3)::integer as codloc,
      substr(mzai,9,2)::integer as frac, substr(mzai,11,2)::integer as radio,
      substr(mzai,13,3)::integer as mza, 
      ladoi::integer as lado,
*/    mzai || lpad(ladoi::text,2,''0'') as ppdddcccffrrmmmll,
      segi as nro_segmento_en_radio
    from "' || esquema || '".arc
    where segi is not Null 
    union
    select 
/*    substr(mzad,1,2)::integer as prov, substr(mzad,3,3)::integer as dpto,
      substr(mzad,6,3)::integer as codloc,
      substr(mzad,9,2)::integer as frac, substr(mzad,11,2)::integer as radio,
      substr(mzad,13,3)::integer as mza, 
      ladod::integer as lado,
*/    mzad || lpad(ladod::text,2,''0'') as ppdddcccffrrmmmll,
      segd as nro_segmento_en_radio
    from "' || esquema || '".arc
    where segd is not Null
  )
select ---lados_completos_id serial,
prov, dpto, codloc, frac, radio, 
substr(ppdddcccffrrmmmll,1,12) as ppdddcccffrr,
nro_segmento_en_radio,
--array_agg(substr(ppdddcccffrrmmmll,13,5)) as mmmll
substr(ppdddcccffrrmmmll,13,3)::integer as mza,
substr(ppdddcccffrrmmmll,16,2)::integer as lado,
conteo as vivs
from de_e00
join "' || esquema || '".conteos
on substr(ppdddcccffrrmmmll,1,2)::integer = prov
and substr(ppdddcccffrrmmmll,3,3)::integer = dpto
and substr(ppdddcccffrrmmmll,6,3)::integer = codloc
and substr(ppdddcccffrrmmmll,9,2)::integer = frac
and substr(ppdddcccffrrmmmll,11,2)::integer = radio
and substr(ppdddcccffrrmmmll,13,3)::integer = mza
and substr(ppdddcccffrrmmmll,16,2)::integer = lado
order by 
--prov, dpto, codloc, frac, radio, nro_segmento_en_radio
substr(ppdddcccffrrmmmll,1,12), nro_segmento_en_radio, mza, lado
;
'
;

return 1;
end;
$function$
;




