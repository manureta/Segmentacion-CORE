
----
-- estandariza caba al resto
drop table if exists caba.listado;
create table caba.listado as
select
comunanumero as dpto, fraccionnumero as frac, radionumero as radio, manzananumero as mza, *
, '1'::text as codloc, ladonumero as lado, numerocatastral as nrocatastr,
row_number() OVER(order by manzananumero::integer,ladonumero::integer,ordenrecorrido::integer,ordenrecorridoedificio::integer)  as orden_reco,
row_number() OVER() as id
from puerto_madero.listado
;
----
/*
select prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, piso,
orden_reco
from caba.listado
order by orden_reco
;
*/

-- archivo para testear las functiones
\i segmentar_equilibrado.sql

select indec.segmentar_equilibrado('caba',40);

select mza, segmento_id, count(*) 
from caba.segmentacion 
group by mza, segmento_id
order by mza, segmento_id
;

select listado_id, segmento_id
from caba.segmentacion
order by listado_id
;


with
casos as (
    select prov, dpto, codloc, frac, radio, mza,
           count(*) as vivs,
           ceil(count(*)/40::float) as max,
           greatest(1, floor(count(*)/40::float)) as min
    from caba.listado
    group by prov, dpto, codloc, frac, radio, mza
    ),
listado as (
SELECT id, prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, 
COALESCE(sector,'') sector, COALESCE(edificio,'') edificio, COALESCE(entrada,'') entrada,
 piso, orden_reco
FROM caba.listado
),
deseado_manzana as (
    select prov, dpto, codloc, frac, radio, mza, vivs,
        case when abs(vivs/max - 40::float)
            < abs(vivs/min - 40::float) then max
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
    )



select *
from segmento_id_en_mza 

;




