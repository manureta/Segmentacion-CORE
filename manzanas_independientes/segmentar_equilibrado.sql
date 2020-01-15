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


----
-- estandariza caba al resto
drop table caba.listado;
create table caba.listado as
select comunanumero as dpto, fraccionnumero as frac, radionumero as radio, manzananumero as mza, *
, '1'::text as codloc, ladonumero as lado, numerocatastral as nrocatastr, 
row_number() OVER()  as orden_reco
from puerto_madero.listado
order by
manzananumero::integer,ladonumero::integer,ordenrecorrido::integer,ordenrecorridoedificio::integer
;
----
/*
select prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, piso,
orden_reco 
from caba.listado
order by orden_reco 
;
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
casos as (
    select prov, dpto, codloc, frac, radio, mza,
           count(*) as vivs,
           ceil(count(*)/' || deseado || '::float) as max,
           greatest(1, floor(count(*)/' || deseado || '::float)) as min
    from "' || localidad || '".listado
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
    select prov, dpto, codloc, frac, radio, mza, lado,
        piso, min(orden_reco) as ini_piso
    from "' || localidad || '".listado
    group by prov, dpto, codloc, frac, radio, mza, lado,
        nrocatastr, edificio, entrada, piso
    ),
pisos_abiertos as (
    select prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso,
        orden_reco, ini_piso,
        row_number() over w as row, rank() over w as rank
    from pisos_enteros
    natural join "' || localidad || '".listado
--- se usan ventanas para calcular cortes
    window w as (
        partition by prov, dpto, codloc, frac, radio, mza
        -- separa las manzanas
        order by orden_reco, ini_piso
        -- rankea por ini_piso (como corresponde pares y pisos descendiendo)
        )
    )

select prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso, orden_reco,
    floor((rank - 1)*segs_x_mza/vivs) + 1 as sgm_mza, rank
from deseado_manzana
join pisos_abiertos
using (prov, dpto, codloc, frac, radio, mza)
';
return 1;
end;
$function$
;

