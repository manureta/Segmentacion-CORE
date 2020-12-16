-- radios de más de 1 manzana

with mzas as (
  select distinct frac, radio, mza
  from e0002.listado
  )
select frac, radio
from mzas
group by frac, radio
having count(*) > 1
order by frac, radio
;





select segmento_id, count(*)
from e0002.segmentacion
group by segmento_id
order by count(*)
;


select ppdddcccffrr, nro_segmento_en_radio, array_agg(mza::text || '.' || lado::text), sum(vivs) as vivs
from e0002.v_segmentos_lados_completos
group by ppdddcccffrr, nro_segmento_en_radio
order by ppdddcccffrr, nro_segmento_en_radio
;


select distinct mza, lado, segmento_id
from e0002.segmentacion
join e0002.listado
on listado.id = listado_id
where frac::integer = 2 
and radio::integer = 7
order by  segmento_id

;


select 
frac, radio, mza, lado, ccalle, ncalle, nrocatastr, piso, dpto_habit,
orden_rec2::integer as orden_reco
from e0002.listado
order by frac, radio, mza, lado, 
orden_rec2 
;





select 
frac, radio, mza, lado, ccalle, ncalle, nrocatastr, piso,
orden_rec2::integer as orden_reco
from e0002.listado
where orden_rec2 != ''
order by frac, radio, mza, lado, 
orden_rec2::integer 
;

select frac, radio, mza, lado, ccalle, ncalle, nrocatastr, piso, orden_reco, orden_rec2
from e0002.listado
where orden_reco = '' or orden_rec2 = ''
;





select id, orden_reco, mza, lado, segmento_id, nrocatastr
from e0002.segmentacion
join e0002.listado
on listado.id = listado_id
where segmento_id = 25
order by mza, lado, id, orden_reco
;

select *
from e0002.segmentos_desde_hasta_ids
where segmento_id = 25
;

select *
from e0002.segmentos_desde_hasta
where segmento_id = 25
;
                                                                                                                                                                       
with
parametros as (select 36::float as deseado),
listado as (select * from e0002.listado),
listado_sin_nulos as (
    select id, prov, dpto, codloc, frac, radio, mza, lado, nrocatastr,
    coalesce(sector,'') sector, coalesce(edificio,'') edificio, coalesce(entrada,'') entrada,
    piso, coalesce(CASE WHEN orden_reco='' THEN NULL ELSE orden_reco END,'0')::integer orden_reco
    from listado
    ),
casos as (
    select prov, dpto, codloc, frac, radio, mza,
           count(*) as vivs, ceil(count(*)/deseado) as max, greatest(1, floor(count(*)/deseado)) as min
    from listado_sin_nulos, parametros
    group by prov, dpto, codloc, frac, radio, mza, deseado
    order by prov, dpto, codloc, frac, radio, mza, deseado
    ),
deseado_manzana as (
    select prov, dpto, codloc, frac, radio, mza, vivs,
        case when abs(vivs/max - deseado) < abs(vivs/min - deseado) then max else min end as segs_x_mza
    from casos, parametros
    ),
pisos_enteros as (
    select prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso, min(id) as piso_id
    from listado_sin_nulos
    group by prov, dpto, codloc, frac, radio, mza, lado,
        nrocatastr, sector, edificio, entrada, piso
    ),
pisos_abiertos as (
    select id, prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso, orden_reco::integer, piso_id,
        row_number() over w as row, rank() over w as rank
    from pisos_enteros
    natural join listado_sin_nulos
    window w as (
        partition by prov, dpto, codloc, frac, radio, mza
        order by lado::integer, orden_reco::integer)
    ),
segmento_id_en_mza as (
    select id, piso_id, prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso, orden_reco::integer,
        floor((rank - 1)*segs_x_mza/vivs) + 1 as sgm_mza, rank
    from deseado_manzana
    join pisos_abiertos
    using (prov, dpto, codloc, frac, radio, mza)
    )
select prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso, sgm_mza, count(*)
from segmento_id_en_mza
group by prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso, sgm_mza
;



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

