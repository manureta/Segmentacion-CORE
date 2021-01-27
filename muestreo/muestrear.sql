/*
titulo: muestrear.sql
descripción:
function indec.muestrear(aglomerado)

divide al medio segmentos de una muestra del 10%

autor: -h
fecha: 2020-06
https://github.com/hernan-alperin/Segmentacion-CORE/issues/13

*/

create or replace function indec.muestrear(esquema text)
 returns integer
 language plpgsql volatile
set client_min_messages = error
as $function$

begin
execute '
create or replace function indec.randint(integer)
returns integer as
$$
select trunc(random()*$1 + 1)::integer;
$$
language sql stable
;';


execute 'drop table if exists "' || esquema || '".segmentacion_pos_muestra;';
execute 'create table "' || esquema || '".segmentacion_pos_muestra as 
select * from "' || esquema || '".segmentacion;';

execute 'drop table if exists "' || esquema || '".para_la_muestra;';
execute '
create table "' || esquema || '".para_la_muestra as
with
pdlfrs as (
  select prov, dpto, codloc, frac, radio, segmento_id as s_id
  from "' || esquema || '".listado
  join "' || esquema || '".segmentacion
  on listado.id = listado_id
  group by prov, dpto, codloc, frac, radio, segmento_id
  ),
numerados as (select prov, dpto, codloc, frac, radio, s_id,
    rank() over (
    partition by prov, dpto, codloc, frac, radio
      order by prov, dpto, codloc, frac, radio, s_id
      ) as n_s_radio, -- numerados dentro de radio
    rank() over (
    partition by prov, dpto, codloc, frac
      order by prov, dpto, codloc, frac, radio, s_id
      ) as n_s_frac, -- numerados dentro de frac
    rank() over (
    partition by prov, dpto, codloc
      order by prov, dpto, codloc, frac, radio, s_id
      ) as n_s_codloc -- numerados dentro de codloc
  from pdlfrs),
muestra as (select prov, dpto, codloc, indec.randint(10)
  from pdlfrs
  group by prov, dpto, codloc)
select prov, dpto, codloc, frac, radio, s_id, n_s_radio, n_s_frac,
  case when n_s_codloc % 10 = randint then true
  else Null
  end
  as muestreado
from muestra
join numerados
using (prov, dpto, codloc)
;';


execute 'drop table if exists "' || esquema || '".muestra;';
execute '
create table "' || esquema || '".muestra as
select s_id as pos_censal_id, 
nextval(''"' || esquema || '".segmentos_seq'') as pre_censal_id1,
nextval(''"' || esquema || '".segmentos_seq'') as pre_censal_id2
from "' || esquema || '".para_la_muestra
where muestreado
;';

execute '
with a_partir as (
  select l.id, l.prov, l.dpto, l.codloc, l.frac, l.radio, l.mza, l.lado, l.nrocatastr,
     l.sector, l.edificio, l.entrada, l.piso, l.orden_reco, s_id
  from "' || esquema || '".listado l
  join "' || esquema || '".segmentacion
  on l.id = listado_id
  join "' || esquema || '".para_la_muestra
  on segmento_id = s_id
  where muestreado
  ),
  carga_segmentos as (
  select prov, dpto, codloc, frac, radio, s_id, count(*) as cantidad
  from a_partir
  group by prov, dpto, codloc, frac, radio, s_id
  ),

pisos_abiertos as (
    select id, prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso, orden_reco::integer, s_id,
        row_number() over w as row, rank() over w as rank
    from a_partir
    window w as (
        partition by prov, dpto, codloc, frac, radio, s_id
        order by mza, lado, orden_reco
        )
    ),

asignacion_segmentos as (
    select id, prov, dpto, codloc, frac, radio, mza, lado,
        nrocatastr, sector, edificio, entrada, piso, orden_reco::integer, s_id,
        floor((rank - 1)*2/cantidad) + 1 as sgm_listado, rank
    from carga_segmentos
    join pisos_abiertos
    using (prov, dpto, codloc, frac, radio, s_id)
    ),

asignacion_segmentos_pisos_enteros as (
    select prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso, min(sgm_listado) as sgm_listado, s_id
    from asignacion_segmentos
    group by prov, dpto, codloc, frac, radio, mza, lado,
        nrocatastr, sector, edificio, entrada, piso, s_id
    ),

asignacion_sin_cortar_piso as (
    select id, prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso, p.sgm_listado, p.s_id, orden_reco
    from asignacion_segmentos_pisos_enteros p
    join asignacion_segmentos
    using (prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso)
    )

update "' || esquema || '".segmentacion_pos_muestra sgm
set segmento_id = case
  when sgm_listado = 1 then pre_censal_id1
  when sgm_listado = 2 then pre_censal_id2
  else 0 -- ERROR
  end
from ("' || esquema || '".muestra
join asignacion_sin_cortar_piso
on s_id = pos_censal_id) j
where sgm.listado_id = j.id
;';

return 1;

end;
$function$
;



