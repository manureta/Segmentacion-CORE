-- analiza campos de .shp, 
-- en lo que respecta a .att arc attribute table

drop view ejemplos_de_tipos;
create or replace view ejemplos_de_tipos as
select distinct tipo, codigo20, '0298' as aglo from "0298".arc
union 
select distinct tipo, codigo20, 'e0359' as aglo from "e0359".arc
union
select distinct tipo, codigo20, '0365' as aglo from "0365".arc
union
select distinct tipo, codigo20, '0389' as aglo from "0389".arc
union
select distinct tipo, codigo20, '0960' as aglo from "0960".arc
union
select distinct tipo, codigo20, '1354' as aglo from "1354".arc
union
select distinct tipo, codigo20::integer, 'caba'as aglo from "caba".arcosc1
union
select distinct tipo, codigo20, 'e0355' as aglo from "e0355".arc
union
select distinct tipo, codigo20, 'e0465' as aglo from "e0465".arc
union
select distinct tipo, codigo20, 'e0595' as aglo from "e0595".arc
union
select distinct tipo, codigo20, 'e0628' as aglo from "e0628".arc
union
select distinct tipo, codigo20, 'e0933' as aglo from "e0933".arc
union
select distinct tipo, codigo20, 'e3019' as aglo from "e3019".arc
union
select distinct tipo, codigo20, 'e5757' as aglo from "e5757".arc
union
select distinct tipo, codigo20, 'e5759' as aglo from "e5759".arc
union
select distinct tipo, codigo20, 'e5760' as aglo from "e5760".arc
;

select tipo, count(*)
from ejemplos_de_tipos
group by tipo
;

select distinct tipo, codigo20, aglo
from ejemplos_de_tipos
where tipo like '%OTRO%'
order by aglo, codigo20
;



select tipo, codigo20, aglo, count(*)
from ejemplos_de_tipos
where tipo like '%RUTA%'
group by tipo, codigo20, aglo
;

select tipo, codigo20, count(*)
from ejemplos_de_tipos
where tipo like '%LINEA FERREA%'
or codigo20 between 99900 and 99930
group by tipo, codigo20
;

select tipo, codigo20, count(*)
from ejemplos_de_tipos
where tipo like '%CURSO DE AGUA%'
or codigo20 between 99945 and 99949
or codigo20 between 99970 and 99975
group by tipo, codigo20
;




---- ve casos de adyacencias

select distinct tipo
from segmentacion.adyacencias
;

---------------------------
drop view if exists lados_adyacentes;
create view lados_adyacentes as

with
arcos as (select * from "0298".arc),
cursos_de_agua as (
    select array[99945, 99946, 99947, 99948, 99949,
                 99970, 99971, 99972, 99973, 99974, 99975]::integer[]),
ffcc as (
    select array[99900, 99910, 99915, 99920, 99925, 99930]::integer[]),

pedacitos_de_lado as (-- mza como PPDDDLLLFFRRMMM select mzad as mza, ladod as lado, avg(anchomed) as anchomed,
    select mzad as mza, ladod as lado,
        array_agg(distinct tipo) as tipos,
        array_agg(distinct codigo20) as codigos,
        array_agg(distinct nombre) as calles,
        ST_Union(wkb_geometry) as geom_pedacito -- ST_Union por ser MultiLineString
    from arcos
    where mzad is not Null and mzad != '''' and ladod != 0
    group by mzad, ladod
    union -- duplica los pedazos de lados a derecha e izquierda
    select mzai as mza, ladoi as lado,
        array_agg(distinct tipo) as tipos,
        array_agg(distinct codigo20) as codigos,
        array_agg(distinct nombre) as calles,
        ST_Union(ST_Reverse(wkb_geometry)) as geom_pedacito -- invierte los de mzai
        -- para respetar sentido hombro derecho
    from arcos
    where mzai is not Null and mzai != '''' and ladoi != 0
    group by mzai, ladoi
    ),
lados_orientados as (
    select mza as ppdddlllffrrmmm,
        substr(mza,1,2)::integer as prov, substr(mza,3,3)::integer as dpto,
        substr(mza,6,3)::integer as codloc,
        substr(mza,9,2)::integer as frac, substr(mza,11,2)::integer as radio,
        substr(mza,13,3)::integer as mza, lado,
        tipos, codigos, calles,
        ST_LineMerge(ST_Union(geom_pedacito)) as wkb_geometry -- une por mza,lado
    from pedacitos_de_lado
    group by mza, lado, tipos, codigos, calles
    ),
lados_de_manzana as (
    select row_number() over() as id, *,
        ST_StartPoint(wkb_geometry) as nodo_i_geom, ST_EndPoint(wkb_geometry) as nodo_j_geom
    from lados_orientados
    ),
---- que se puede hacer al llegar a la esquina

max_lado as (
    select ppdddlllffrrmmm, max(lado) as max_lado
    from lados_de_manzana
    group by ppdddlllffrrmmm
    ),
doblando as (
    select ppdddlllffrrmmm,
        lado as de_lado,
        case when lado < max_lado then lado + 1 else 1 end as lado
        -- lado el lado que dobla de la misma mza
    from max_lado
    join lados_de_manzana l
    using (ppdddlllffrrmmm)
    where lado != 0
    ),
lado_para_doblar as (
    select ppdddlllffrrmmm as mza_i, de_lado as lado_i,
        ppdddlllffrrmmm as mza_j, a.lado as lado_j
    from doblando d
    join lados_de_manzana a
    using(ppdddlllffrrmmm, lado)
    )
select * from lado_para_doblar;

----
select tipos, codigos from lados_de_manzana
where not codigos::integer[] && (select * from ffcc)
and not codigos::integer[] && (select * from cursos_de_agua)
and not array['RUTA']::text[] && tipos::text[]
;

select *
from lados_adyacentes
;

------------------------ evaluar algoritmo a usar

CREATE OR REPLACE FUNCTION indec.lados_excedidos(localidad text, deseado integer)
 RETURNS table (prov text, dpto text, codloc text, frac text, radio text, mza text, lado text,
    exceso integer)
 LANGUAGE plpgsql volatile
SET client_min_messages = error
AS $function$

begin

return query execute '
with 
viviendas_por_lado as (
    select prov, dpto, codloc, frac, radio, mza, lado, count(*) as viviendas
    from "' || localidad || '".listado
    group by prov, dpto, codloc, frac, radio, mza, lado
    ),
lados_por_radio as (
    select prov, dpto, codloc, frac, radio, count(*)::integer as lados
    from viviendas_por_lado
    group by prov, dpto, codloc, frac, radio),
lados_excedidos as (
    select prov::text, dpto::text, codloc::text, frac::text, radio::text, 
    mza::text, lado::text, viviendas::integer as exceso
    from viviendas_por_lado
    where viviendas > ' || deseado || ')
select *
--lados_por_radio
--natural join
from lados_excedidos
where exceso > 0
order by prov, dpto, codloc, frac, radio, mza, lado
'

;

end;
$function$
;





---- usando información global en segmentacion.listado

select distinct tabla
from segmentacion.conteos

;


---- ver como se puede hacer indec.costo_adyacencia(m_i, l_i, m_j, l_j)

select * 
from e0359.lados_adyacentes
--where mza_i = mza_j
;





