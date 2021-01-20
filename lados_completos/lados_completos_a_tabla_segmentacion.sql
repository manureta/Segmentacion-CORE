/*
titulo: lados_completos_a_tabla_segmentacion.sql
descripción:
genera el segmento_id 
propagando la segmentacion por lado completo a la
tabla segmentacion
autor: -h
fecha: 2020-10
*/

create or replace function indec.lados_completos_a_tabla_segmentacion(esquema text)
 returns integer
 language plpgsql volatile
set client_min_messages = error
as $function$

begin
execute '
with segmentos_ids as ( 
    select prov, dpto, codloc, frac, radio, nro_segmento_en_radio, 
        nextval(''"' || esquema || '".segmentos_seq'') as segmento_id
    from "' || esquema || '".v_segmentos_lados_completos
    group by prov, dpto, codloc, frac, radio, nro_segmento_en_radio
    ),
    mzas_lados as (
    select prov, dpto, codloc, frac, radio, mza, lado, segmento_id
    from segmentos_ids
    natural join "' || esquema || '".v_segmentos_lados_completos)
update "' || esquema || '".segmentacion
set segmento_id = j.segmento_id
from ("' || esquema || '".listado l
join mzas_lados s
on l.prov::integer = s.prov and l.dpto::integer = s.dpto and l.codloc::integer = s.codloc
and l.frac::integer = s.frac and l.radio::integer = s.radio 
and l.mza::integer = s.mza and l.lado::integer = s.lado) j
where listado_id = j.id

;'
;

return 1;
end;
$function$
;


create or replace function indec.lados_completos_a_tabla_segmentacion_ffrr(esquema text, _frac integer, _radio integer)
 returns integer
 language plpgsql volatile
set client_min_messages = error
as $function$

begin
execute '
with segmentos_ids as (
    select prov, dpto, codloc, frac, radio, nro_segmento_en_radio,
        nextval(''"' || esquema || '".segmentos_seq'') as segmento_id
    from "' || esquema || '".v_segmentos_lados_completos
    where frac::integer = ' || _frac || ' and radio::integer = ' || _radio || '
    group by prov, dpto, codloc, frac, radio, nro_segmento_en_radio
    ),
    mzas_lados as (
    select prov, dpto, codloc, frac, radio, mza, lado, segmento_id
    from segmentos_ids
    natural join "' || esquema || '".v_segmentos_lados_completos)
update "' || esquema || '".segmentacion
set segmento_id = j.segmento_id
from ("' || esquema || '".listado l
join mzas_lados s
on l.prov::integer = s.prov and l.dpto::integer = s.dpto and l.codloc::integer = s.codloc
and l.frac::integer = s.frac and l.radio::integer = s.radio
and l.mza::integer = s.mza and l.lado::integer = s.lado
and l.frac::integer = ' || _frac || ' and l.radio::integer = ' || _radio || ') j
where listado_id = j.id
;'
;

return 1;
end;
$function$
;


 
