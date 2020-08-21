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

drop view e0002.numeros_modulo10_por_loc_50k;
create view e0002.numeros_modulo10_por_loc_50k as
select prov, dpto, codloc, indec.randint(10)
from e0002.listado
group by prov, dpto, codloc
order by prov, dpto, codloc
;

drop view e0002.listado_segmentado;
create view e0002.listado_segmentado as
select id, prov, dpto, codloc, frac, radio, mza, lado as clado, ccalle, ncalle, 
  nrocatastr, sector, edificio, entrada, orden_reco, piso, dpto_habit, segmento_id as s_id
from e0002.listado
join e0002.segmentacion
on listado.id = listado_id
order by prov, dpto, codloc, frac, radio, mza, lado, orden_reco::integer
;

create view e0002.segmento_digito_muestral as
select prov, dpto, codloc, frac, radio, mza, 
  segmento_id, randint, 
  case when segmento_id % 10 = randint then true
  else Null
  end
  as muestra 
from e0002.segmentacion
join e0002.listado
on listado_id = listado.id
join e0002.numeros_modulo10_por_loc_50k
using (prov, dpto, codloc)
order by prov, dpto, codloc, frac, radio, mza, segmento_id, randint
;


/*
--------------------------------------------------
  numeración y muestreo de segmentos

  insumos 
    listado (C1), 
    segmentación a mza indep (no requiere cobertura)
  productos
    n_s_radio: numeración de segmentos por radio 
    n_s_fraccion: numeración de segmentos por fraccion
    muestrado: True si segmento muestrado, 
                Null si no
--------------------------------------------------
*/
with 
pdlfrmls as (
  select prov, dpto, codloc, frac, radio, mza, lado, segmento_id as s_id
  from e0002.listado
  join e0002.segmentacion
  on listado.id = listado_id
  group by prov, dpto, codloc, frac, radio, mza, lado, segmento_id
  ),
segmentos_con_id_de_radio_completo_a_mza_indep as (
  select prov, dpto, codloc, frac, radio, s_id
  from pdlfrmls
  group by prov, dpto, codloc, frac, radio, s_id
  ),
numerados as (select prov, dpto, codloc, frac, radio, s_id,
  rank() over (partition by prov, dpto, codloc, frac, radio order by prov, dpto, codloc, frac, radio, s_id) as n_s_radio,
  rank() over (partition by prov, dpto, codloc, frac order by prov, dpto, codloc, frac, radio, s_id) as n_s_frac
  from segmentos_con_id_de_radio_completo_a_mza_indep),
muestra as (select prov, dpto, codloc, indec.randint(10)
  from pdlfrmls
  group by prov, dpto, codloc)
select prov, dpto, codloc, frac, radio, s_id, n_s_radio, n_s_frac, 
  case when n_s_frac % 10 = randint then true
  else Null
  end
  as muestrado
from muestra
join numerados
using (prov, dpto, codloc)
;




