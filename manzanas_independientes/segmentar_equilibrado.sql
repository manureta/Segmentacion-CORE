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



create or replace function 
indec.segmentar_equilibrado(aglomerado text, deseado integer)
    returns integer
    language plpgsql volatile
    set client_min_messages = error
as $function$

begin

execute '
with 
parametros as (
    select ' || deseado || '::float as deseado),
listado as (select * from "' || aglomerado || '".listado),
listado_sin_nulos as (
    select id, prov, dpto, codloc, frac, radio, mza, lado, nrocatastr,
    coalesce(sector,'''') sector, coalesce(edificio,'''') edificio, coalesce(entrada,'''') entrada,
     piso, coalesce(CASE WHEN orden_reco='''' THEN NULL ELSE orden_reco END,''0'')::integer orden_reco
    from listado
    ),

casos as (
    select prov, dpto, codloc, frac, radio, mza,
           count(*) as vivs,
           ceil(count(*)/deseado) as max,
           greatest(1, floor(count(*)/deseado)) as min
    from listado_sin_nulos, parametros
    group by prov, dpto, codloc, frac, radio, mza, deseado
    order by prov, dpto, codloc, frac, radio, mza, deseado
    ),

deseado_manzana as (
    select prov, dpto, codloc, frac, radio, mza, vivs,
        case when abs(vivs/max - deseado)
            < abs(vivs/min - deseado) then max
        else min end as segs_x_mza
    from casos, parametros
    ),

pisos_enteros as (
    select prov, dpto, codloc, frac, radio, mza, lado, 
        nrocatastr, sector, edificio, entrada,
        piso, min(orden_reco::integer) as piso_id
    from listado_sin_nulos
    group by prov, dpto, codloc, frac, radio, mza, lado,
        nrocatastr, sector, edificio, entrada, piso
    ),
pisos_abiertos as (
    select id, prov, dpto, codloc, frac, radio, mza, lado, 
        nrocatastr, sector, edificio, entrada, piso,
        orden_reco::integer, piso_id,
        row_number() over w as row, rank() over w as rank
    from pisos_enteros
    natural join listado_sin_nulos
    window w as (
        partition by prov, dpto, codloc, frac, radio, mza
        order by lado::integer, orden_reco::integer
        )
    ),

segmento_id_en_mza as (
    select id, prov, dpto, codloc, frac, radio, mza, lado, 
        nrocatastr, sector, edificio, entrada, piso, orden_reco::integer,
        floor((rank - 1)*segs_x_mza/vivs) + 1 as sgm_mza, rank
    from deseado_manzana
    join pisos_abiertos
    using (prov, dpto, codloc, frac, radio, mza)
    ),
segmentos_id as (
    select 
        -- row_number() over (order by dpto, frac, radio, mza, sgm_mza) 
        nextval(''"' || aglomerado || '".segmentos_seq'')
        as segmento_id,
        dpto, frac, radio, mza, sgm_mza
    from segmento_id_en_mza
    group by dpto, frac, radio, mza, sgm_mza
    order by dpto, frac, radio, mza, sgm_mza
    )

update "' || aglomerado || '".segmentacion sgm
set segmento_id = j.segmento_id
from (segmentos_id
join segmento_id_en_mza
using (dpto, frac, radio, mza, sgm_mza)) j
where listado_id = j.id
';
return 1;
end;
$function$
;

        
