/*
titulo: segmentos_lados_desde_hasta.sql
descripción: 
arma la relacion que determina donde empieza y termina un segmento y lado 
según los id de listado
autor: -h
fecha: 2020-10
*/

create or replace function indec.segmentos_lados_desde_hasta(esquema text)
 returns integer
 language plpgsql volatile
set client_min_messages = error
as $function$

begin
execute 'drop table if exists "' || esquema || '".segmentos_lados_desde_hasta';
execute '
create table "' || esquema || '".segmentos_lados_desde_hasta as 
with 
  listado as (select * from "' || esquema || '".listado),
  listados_lados as (
    select a.id, a.orden_reco, b.id as lado_id
    from listado a
    join 
    "' || esquema || '".lados b
    on a.prov::integer = b.prov
    and a.dpto::integer = b.dpto
    and a.codloc::integer = b.codloc
    and a.frac::integer = b.frac
    and a.radio::integer = b.radio
    and a.mza::integer = b.mza
    and a.lado::integer = b.lado
  ),
  desde_hasta_usando_orden_segmentos_lados as (
    select min(orden_reco) as primero, max(orden_reco) as ultimo, segmento_id, lado_id
    from listados_lados as listado
    join "' || esquema || '".segmentacion
    on listado_id = listado.id
    group by lado_id, segmento_id
  ),
  id_desdes as (
    select segmento_id, listado.lado_id, id as desde_listado_id
    from desde_hasta_usando_orden_segmentos_lados dh
    join listados_lados as listado
    on dh.lado_id = listado.id
    and listado.orden_reco = primero
  ),
  id_hastas as (
    select segmento_id, listado.lado_id, id as hasta_listado_id
    from desde_hasta_usando_orden_segmentos_lados dh
    join listados_lados as listado
    on dh.lado_id = listado.id
    and listado.orden_reco = ultimo
  )
select segmento_id, lado_id, desde_listado_id, hasta_listado_id
from id_desdes
join id_hastas
using (segmento_id, lado_id)
order by segmento_id,
lado_id  ---- ver BIEN el recorrido de la manzana
';

return 1;
end;
$function$
;



