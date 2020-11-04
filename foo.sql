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








