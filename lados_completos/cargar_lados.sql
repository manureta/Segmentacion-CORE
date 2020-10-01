/*
titulo: cargar_lados.sql
descripción: 
asigna un id a cada lado 
autor: -h
fecha: 2020-10
*/

create or replace function indec.cargar_lados(esquema text)
 returns integer
 language plpgsql volatile
set client_min_messages = error
as $function$

begin
execute 'drop table if exists "' || esquema || '".lados cascade;';
execute 'drop sequence if exists "' || esquema || '".lados_seq cascade;';
execute 'create sequence "' || esquema || '".lados_seq;';

execute '
create table "' || esquema || '".lados as 
with 
  listado as (select * from "' || esquema || '".listado),
  e00 as (select * from "' || esquema || '".arc),
  lados_ppdddcccffrrmmmll as (
    select prov::integer as prov, dpto::integer as dpto, codloc::integer as codloc,
      frac::integer as frac, radio::integer as radio, 
      mza::integer as mza, lado::integer as lado
    from listado
    union
    select substr(mzai,1,2)::integer as prov, substr(mzai,3,3)::integer as dpto, 
      substr(mzai,6,3)::integer as codloc,
      substr(mzai,9,2)::integer as frac, substr(mzai,11,2)::integer as radio, 
      substr(mzai,13,2)::integer as mza, ladoi::integer as lado
    from e00
    union
    select substr(mzad,1,2)::integer as prov, substr(mzad,3,3)::integer as dpto, 
      substr(mzad,6,3)::integer as codloc,
      substr(mzad,9,2)::integer as frac, substr(mzad,11,2)::integer as radio, 
      substr(mzad,13,2)::integer as mza, ladod::integer as lado
    from e00
  )
select *, nextval(''"' || esquema || '".lados_seq'') as id
from lados_ppdddcccffrrmmmll
order by prov, dpto, codloc, frac, radio, mza, lado
';

return 1;
end;
$function$
;



