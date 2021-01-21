/*
titulo: muestrear.sql
descripción:
function indec.muestrear(aglomerado)

divide al medio segmentos de una muestra del 10%

autor: -h
fecha: 2020-06
https://github.com/hernan-alperin/Segmentacion-CORE/issues/13

*/

create or replace function indec.muestrear(aglomerado text)
 returns integer
 language plpgsql volatile
set client_min_messages = error
as $function$

begin

execute '
with
pdlfrs as (
  select prov, dpto, codloc, frac, radio, mza, lado, segmento_id as s_id
  from "' || esquema || '".listado
  join "' || esquema || '".segmentacion
  on listado.id = listado_id
  group by prov, dpto, codloc, frac, radio, mza, lado, segmento_id
  ),
segmentos_con_id_de_radio_completo_a_mza_indep as (
  select prov, dpto, codloc, frac, radio, s_id
  from pdlfrmls
  group by prov, dpto, codloc, frac, radio, s_id
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
  from segmentos_con_id_de_radio_completo_a_mza_indep),
muestra as (select prov, dpto, codloc, indec.randint(10)
  from pdlfrmls
  group by prov, dpto, codloc)
select prov, dpto, codloc, frac, radio, s_id, n_s_radio, n_s_frac,
  case when n_s_codloc % 10 = randint then true
  else Null
  end
  as muestrado
from muestra
join numerados
using (prov, dpto, codloc)
;


;';

return 1

end;
$function$
;



