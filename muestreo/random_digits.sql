/*
genera numeros aleatorios del 1 a 10
para cada localidad
verificar varianza (?)

autor: -h
2020-08-10
*/

create or replace function indec.randint(integer)
returns integer as
$$
select trunc(random()*$1 + 1)::integer;
$$
language sql stable
;

select prov, dpto, codloc, indec.randint(10)
from generate_series(1,3) as prov, generate_series(1,3) as dpto, generate_series(1,3) as codloc
group by prov, dpto, codloc
order by prov, dpto, codloc
;


