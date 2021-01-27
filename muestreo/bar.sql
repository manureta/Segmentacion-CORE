with a_partir as (
  select l.id, l.prov, l.dpto, l.codloc, l.frac, l.radio, l.mza, l.lado, l.nrocatastr,
     l.sector, l.edificio, l.entrada, l.piso, l.orden_reco, s_id
  from e0002.listado l
  join e0002.segmentacion
  on l.id = listado_id
  join e0002.para_la_muestra
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
    )

select *
from a_partir

/*
update e0002.segmentacion sgm
set segmento_id = case
  when sgm_listado = 1 then pre_censal_id1
  when sgm_listado = 2 then pre_censal_id2
  else 0 -- ERROR
  end
from (e0002.muestra
join asignacion_segmentos_pisos_enteros
on s_id = pos_censal_id) j
where s_id = pos_censal_id

*/

;

