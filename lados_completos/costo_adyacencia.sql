/*
calcula costos de adyacencias
en funcion de que sean cruzar o volver por ffcc, ruta, etc
function de CORE
Mi 6-2-2020
*/

CREATE OR REPLACE FUNCTION indec.costo_adyacencia(arc_tipo text, arc_codigo integer)
 RETURNS integer
 LANGUAGE sql IMMUTABLE
SET client_min_messages = error
AS $function$
with
    costo_bajo as (
    select array[99968,99971]::integer[] as muy_facil), -- acequia, huaico
    costo_medio as (
    select array[99967]::integer[] as facil), -- barda
    costo_alto as (
    select array[99966, 99974, 99975]::integer[] as dificil), -- zanja, zanjón, barranco
    no_se_puede as (
    select array[99900, 99910, 99915, 99920, 99925, 99930, -- ffcc
                 99945, 99946, 99947, 99948, 99949, -- cursos de agua
                 99970, 99972, 99973 -- canal, embalse, represa
                 ]::integer[] as imposible)
select
    case 
        when $2 in (select * from unnest(muy_facil))
            then 1
        when $2 in (select * from unnest(facil))
            then 10
        when $2 in (select * from unnest(dificil))
            then 100
        when $2 in (select * from unnest(imposible))
            or $1 ilike '%RUTA%'
            then 1000
        else 0
    end
as result
from costo_bajo, costo_medio, costo_alto, no_se_puede
$function$
;


