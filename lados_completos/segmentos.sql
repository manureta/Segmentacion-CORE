/*
segmentos.sql
descripcion:
propaga la segmentacion de lados_completos.py
a esquema.segmentacion
usando lados
autor: -h
2020-10-08
*/

create or replace function a_entero(text) returns integer
as $function$
select case
  when $1 is Null then 0
  when $1 = '' then 0
  else $1::integer
end
$function$
language sql immutable
;


drop view e0359.v_segmentos_lados_completos;
create view e0359.v_segmentos_lados_completos as
with de_e00 as (
    select 
/*
      substr(mzai,1,2)::integer as prov, substr(mzai,3,3)::integer as dpto,
      substr(mzai,6,3)::integer as codloc,
      substr(mzai,9,2)::integer as frac, substr(mzai,11,2)::integer as radio,
      substr(mzai,13,3)::integer as mza, 
      ladoi::integer as lado,
*/    mzai || lpad(ladoi::text,2,'0') as ppdddcccffrrmmmll,
      segi as nro_segmento_en_radio
    from e0359.arc
    where segi is not Null 
    union
    select 
/*    substr(mzad,1,2)::integer as prov, substr(mzad,3,3)::integer as dpto,
      substr(mzad,6,3)::integer as codloc,
      substr(mzad,9,2)::integer as frac, substr(mzad,11,2)::integer as radio,
      substr(mzad,13,3)::integer as mza, 
      ladod::integer as lado,
*/    mzad || lpad(ladod::text,2,'0') as ppdddcccffrrmmmll,
      segd as nro_segmento_en_radio
    from e0359.arc
    where segd is not Null
  )
select ---lados_completos_id serial,
--prov, dpto, codloc, frac, radio, 
substr(ppdddcccffrrmmmll,1,12) as ppdddcccffrr,
nro_segmento_en_radio,
--array_agg(substr(ppdddcccffrrmmmll,13,5)) as mmmll
substr(ppdddcccffrrmmmll,13,3)::integer as mza,
substr(ppdddcccffrrmmmll,16,2)::integer as lado
from de_e00
order by 
--prov, dpto, codloc, frac, radio, nro_segmento_en_radio
substr(ppdddcccffrrmmmll,1,12), nro_segmento_en_radio, mza, lado
;


select * 
from e0359.v_segmentos_lados_completos
;

