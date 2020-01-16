/*
titulo: segmentar_equilibrado.sql
descripción: con circuitos definidos por manzanas independientes
segmenta en forma equilibrada sin cortar piso, balanceando la
cantidad deseada con la proporcional de viviendas por segmento 
usando la cantidad de viviendas en la manzana.
El objetivo es que los segmentos se aparten lo mínimo de la cantidad deseada
y que la carga de los censistas esté lo más balanceado
autor: -h+M
fecha: 2019-06-05 Mi
*/



CREATE OR REPLACE FUNCTION indec.segmentar_equilibrado(localidad text, deseado integer)
 RETURNS integer
 LANGUAGE plpgsql volatile
SET client_min_messages = error
AS $function$

begin

execute 'drop table if exists "' || localidad || '".segmentacion;';

execute '
create table "' || localidad || '".segmentacion as
with 
listado as (
    SELECT id, prov, dpto, codloc, frac, radio, mza, lado, nrocatastr,
    COALESCE(sector,'''') sector, COALESCE(edificio,'''') edificio, COALESCE(entrada,'''') entrada,
     piso, orden_reco
    FROM "' || localidad || '".listado
    ),

casos as (
    select prov, dpto, codloc, frac, radio, mza,
           count(*) as vivs,
           ceil(count(*)/' || deseado || '::float) as max,
           greatest(1, floor(count(*)/' || deseado || '::float)) as min
    from caba.listado
    group by prov, dpto, codloc, frac, radio, mza
    ),

deseado_manzana as (
    select prov, dpto, codloc, frac, radio, mza, vivs,
        case when abs(vivs/max - ' || deseado || '::float)
            < abs(vivs/min - ' || deseado || '::float) then max
        else min end as segs_x_mza
    from casos
    ),

pisos_enteros as (
    select prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada,
        piso, min(orden_reco) as piso_id
    from listado
    group by prov, dpto, codloc, frac, radio, mza, lado,
        nrocatastr, sector, edificio, entrada, piso
    ),
pisos_abiertos as (
    select id, prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso,
        orden_reco, piso_id,
        row_number() over w as row, rank() over w as rank
    from pisos_enteros
     join listado using (prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso)
    window w as (
        partition by prov, dpto, codloc, frac, radio, mza
        order by orden_reco
        )
    ),
segmento_id_en_mza as (
    select id, prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso, orden_reco,
        floor((rank - 1)*segs_x_mza/vivs) + 1 as sgm_mza, rank
    from deseado_manzana
    join pisos_abiertos
    using (prov, dpto, codloc, frac, radio, mza)
    ),

segmentos_id as (
    select row_number() over (order by dpto, frac, radio, mza, sgm_mza) as segmento_id,
        dpto, frac, radio, mza, sgm_mza
    from segmento_id_en_mza
    group by dpto, frac, radio, mza, sgm_mza
    )
select id as listado_id, segmento_id
--
, prov, dpto, frac, radio, mza, lado
--
from segmentos_id
join segmento_id_en_mza
using (dpto, frac, radio, mza, sgm_mza)
order by dpto, frac, radio, mza, lado, segmento_id
';
return 1;
end;
$function$
;

