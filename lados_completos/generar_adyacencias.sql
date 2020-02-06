/*
function de CORE
2da de enero 2020 
*/

CREATE OR REPLACE FUNCTION indec.generar_adyacencias(localidad text)
 RETURNS integer
 LANGUAGE plpgsql volatile
SET client_min_messages = error
AS $function$

begin

execute 'drop table if exists "' || localidad || '".lados_adyacentes;';

execute '
create table "' || localidad || '".lados_adyacentes as 

with 

arcos as (select * from "' || localidad || '".arc),

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
        ppdddlllffrrmmm as mza_j, a.lado as lado_j,
        Null::text as arc_tipo, Null::integer as arc_codigo
    from doblando d
    join lados_de_manzana a
    using(ppdddlllffrrmmm, lado)
    ),

--  adyacencias entre manzanas ------------------------------------
--  para calcular los lados de cruzar y volver

manzanas_adyacentes as (
    select mzad as mza_i, mzai as mza_j, tipo as arc_tipo, codigo20 as arc_codigo
    -- agrega tipo y codigo para calcular costo de pasar a mza adyacente
    from arcos
    where substr(mzad,1,12) = substr(mzai,1,12) -- mismo PPDDDLLLFFRR
        and mzad is not Null and mzad != '''' and ladod != 0
        and mzai is not Null and mzai != '''' and ladod != 0
        and mzai != mzad
    union -- hacer simétrica
    select mzai as mza_i, mzad as mza_j, tipo as arc_tipo, codigo20 as arc_codigo
    from arcos
    where substr(mzad,1,12) = substr(mzai,1,12) -- mismo PPDDDLLLFFRR
        and mzad is not Null and mzad != '''' and ladod != 0
        and mzai is not Null and mzai != '''' and ladod != 0
        and mzad != mzai
    ),

---- "volver" en realidad es que está en frente -------------------
---- fin(lado_i) = inicio(lado_j),
---- mza_i ady mza_j, y
---- la intersección es 1 linea

lado_de_enfrente as (
    select i.ppdddlllffrrmmm as mza_i, i.lado as lado_i,
        j.ppdddlllffrrmmm as mza_j, j.lado as lado_j,
        a.arc_tipo, a.arc_codigo
    from lados_de_manzana i
    join lados_de_manzana j
    on i.nodo_j_geom = j.nodo_i_geom -- el lado_i termina donde el lado_j empieza
    -- los lados van de nodo_i a nodo_j
    join manzanas_adyacentes a
    on i.ppdddlllffrrmmm = a.mza_i and j.ppdddlllffrrmmm = a.mza_j -- las manzanas son adyacentes
    where ST_Dimension(ST_Intersection(i.wkb_geometry,j.wkb_geometry)) = 1
    ),

---- cruzar -----------------------------------------------------------
---- fin(lado_i) = inicio(lado_j),
---- mza_i ady mza_j, y
---- la intersección es 1 punto

lado_para_cruzar as (
    select i.ppdddlllffrrmmm as mza_i, i.lado as lado_i,
        j.ppdddlllffrrmmm as mza_j, j.lado as lado_j,
        a.arc_tipo, a.arc_codigo
    from lados_de_manzana i
    join lados_de_manzana j
    on i.nodo_j_geom = j.nodo_i_geom
    -- el lado_i termina donde el lado_j empieza
    -- los lados van de nodo_i a nodo_j
    join manzanas_adyacentes a
    on i.ppdddlllffrrmmm = a.mza_i and j.ppdddlllffrrmmm = a.mza_j
    -- las manzanas son adyacentes
    where ST_Dimension(ST_Intersection(i.wkb_geometry,j.wkb_geometry)) = 0
    )

select *, ''dobla''::text as tipo from lado_para_doblar
union
select *, ''enfrente''::text from lado_de_enfrente
union
select *, ''cruza''::text from lado_para_cruzar
;'
;

-----------------------------------------------------------------------

execute '
delete
from segmentacion.adyacencias
where shape = ''' || localidad || '''
;'
;


execute '
insert into segmentacion.adyacencias (shape, prov, dpto, codloc, frac, radio, mza, lado, mza_ady, lado_ady, tipo)
select ''' || localidad || '''::text as shape, substr(mza_i,1,2)::integer as prov,
    substr(mza_i,3,3)::integer as dpto,
    substr(mza_i,6,3)::integer as codloc,
    substr(mza_i,9,2)::integer as frac,
    substr(mza_i,11,2)::integer as radio,
    substr(mza_i,13,3)::integer as mza, lado_i,
    substr(mza_j,13,3)::integer as mza_ady, lado_j as lado_ady,
    tipo
from "' || localidad || '".lados_adyacentes;
;'
;

return 1;
end;
$function$
;
----------------------------------------


