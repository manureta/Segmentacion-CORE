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

/*
select prov, dpto, codloc, indec.randint(10)
from generate_series(1,3) as prov, generate_series(1,3) as dpto, generate_series(1,3) as codloc
group by prov, dpto, codloc
order by prov, dpto, codloc
;
*/

/*
select prov, dpto, codloc, indec.randint(10)
from e0002.listado
group by prov, dpto, codloc
order by prov, dpto, codloc
*/

drop view e0002.listado_segmentado;
create view e0002.listado_segmentado as
select id, prov, dpto, codloc, frac, radio, mza, lado, ccalle, ncalle, nrocatastr, piso, sector, edificio, entrada, segmento_id
from e0002.listado
join e0002.segmentacion
on listado.id = listado_id
order by id
;

select * from e0002.listado_segmentado;


