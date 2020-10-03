/*
titulo: cargar_conteos.sql
descripción: 
sumariza las viviendas por lados y carga ese conteo en las tablas
"shape".conteos, y
segmentacion.conteos (usada por lados_completos.py)

proceso necesario anterior a segmentar por lado completo
autor: -h+M
fecha: 2020-01
*/

create or replace function indec.cargar_conteos(esquema text)
 returns integer
 language plpgsql volatile
set client_min_messages = error
as $function$

begin
execute 'drop table if exists "' || esquema || '".conteos cascade;';
execute 'delete from segmentacion.conteos where tabla = ''' || esquema || ''';';

execute '
create table "' || esquema || '".conteos as
with listado_sin_vacios as (
    select
    id, prov::integer, dpto::integer, codaglo, codloc::integer,
    codent, frac::integer, radio::integer, mza::integer, lado::integer,
    tipoviv
    from
    -------------------- listado --------------------------
    "' || esquema || '".listado
    -------------------------------------------------------
    where prov::text!='''' and dpto::text!=''''  and codloc::text!=''''
    and frac::text!='''' and radio::text!='''' and mza::text !='''' and lado::text !=''''
    and mza !~* ''[a-z]''
    ),
    e00 as (
    select codigo10, codigo20, ancho, anchomed, tipo, nombre, ladoi, ladod, desdei, desded, hastai, hastad, mzai, mzad,
    codloc20, wkb_geometry,
    -------------------- nombre de covertura y tabla de shape
    ''' || esquema || '.arc''::text as cover
    from "' || esquema || '".arc
    ---------------------------------------------------------
    ),
    lados_de_manzana as (
    select codigo20, mzai||''-''||ladoi as lado_id, mzai as mza, ladoi as lado, avg(anchomed) as anchomed,
        st_linemerge(st_union(st_reverse(wkb_geometry))) as geom, cover
    from e00
    where mzai is not null and mzai != ''''
    group by codigo20, mzai, ladoi, cover
    union
    select codigo20, mzad||''-''||ladod as lado_id, mzad as mza, ladod as lado, avg(anchomed) as anchomed,
        st_linemerge(st_union(wkb_geometry)) as geom, cover
    from e00
    where mzad is not null and mzad != ''''
    group by codigo20, mzad, ladod, cover
    ),
    lados_codigos as (
    select codigo20, lado_id, mza, lado,
        st_simplifyvw(st_linemerge(st_union(geom)),10) as geom, cover
    from lados_de_manzana
    group by codigo20, lado_id, mza, lado, cover
    ),
    lado_manzana as (
    select substring(mza,1,2)::integer as prov,substring(mza,3,3)::integer as dpto,substring(mza,6,3)::integer as codloc,
    substring(mza,9,2)::integer as frac, substring(mza,11,2)::integer radio,
        substring(mza,13,3)::integer as mza,
        codigo20, lado_id, mza link, lado::integer,
        geom, st_azimuth(st_startpoint(geom), st_endpoint(geom)) azimuth, cover,
        case when st_geometrytype(geom) != ''st_linestring'' then ''lado discontinuo'' end as error_msg
    from lados_codigos
    order by mza, lado
    ), listado_carto as (
    select *
    from lado_manzana
    left join listado_sin_vacios using (prov,dpto,codloc,frac,radio,mza,lado)
    ),
    conteos as (
    select ''' || esquema || '''::text as tabla, prov, dpto dpto, codloc,
        frac, radio, mza, lado,
        count(indec.contar_vivienda(tipoviv)) as conteo
    from listado_carto
    group by prov, dpto, codloc, frac, radio, mza, lado, geom
    order by count(case when trim(tipoviv)='''' then null else tipoviv end) desc
    )
select * from conteos;
';


---- en tabla global 
execute '
delete 
from segmentacion.conteos
where tabla = ''' || esquema || '''
;
insert into segmentacion.conteos (tabla, prov, dpto, codloc, frac, radio, mza, lado, conteo)
-- inserta en tabla global de conteos
select ''' || esquema || '''::text as tabla, prov, dpto, codloc,
    frac, radio, mza, lado, conteo
from "' || esquema || '".conteos 
';

return 1;
end;
$function$
;
----------------------------------------

--- to be deprecated

create schema if not exists segmentacion;

-- crea tabla segmentacion.conteos

CREATE TABLE if not exists segmentacion.conteos (
    tabla text,
    prov integer,
    dpto integer,
    codloc integer,
    frac integer,
    radio integer,
    mza integer,
    lado integer,
    conteo bigint,
    id serial
);

--- crea la tabla global to be deprecated
CREATE TABLE if not exists segmentacion.adyacencias (
    shape text,
    prov integer,
    dpto integer,
    codloc integer,
    frac integer,
    radio integer,
    mza integer,
    lado integer,
    mza_ady integer,
    lado_ady integer,
    tipo text
);
--- (!) ordenar esto: poner en otro archivo 
--- o juntar todo en un solo archivo .sql




