----------------------------------------
CREATE OR REPLACE FUNCTION indec.cargar_conteos(localidad text)
 RETURNS integer
 LANGUAGE plpgsql volatile
SET client_min_messages = error
AS $function$

begin
execute 'drop table if exists "' || localidad || '".conteos;';
-- usa tabla global de conteos
execute 'delete from segmentacion.conteos where tabla = ''' || localidad || ''';';

execute '
create table "' || localidad || '".conteos as
WITH listado_sin_vacios AS (
    SELECT
    id, prov::integer, nom_provin, dpto::integer, nom_dpto, codaglo, codloc::integer,
    nom_loc, codent, nom_ent, frac::integer, radio::integer, mza::integer, lado::integer,
    tipoviv
    FROM
    -------------------- listado --------------------------
    "' || localidad || '".listado
    -------------------------------------------------------
    WHERE prov::text!='''' AND dpto::text!=''''  AND codloc::text!=''''
    and frac::text!='''' and radio::text!='''' and mza::text !='''' and lado::text !=''''
    and mza !~* ''[A-Z]''
    ),
    e00 as (
    SELECT codigo10, nomencla, codigo20, ancho, anchomed, tipo, nombre, ladoi, ladod, desdei, desded, hastai, hastad, mzai, mzad,
    codloc20, nomencla10, nomenclai, nomenclad, wkb_geometry,
    -------------------- nombre de covertura y tabla de shape
    ''' || localidad || '.arc''::text as cover
    FROM "' || localidad || '".arc
    ---------------------------------------------------------
    ),
    lados_de_manzana as (
    select codigo20, mzai||''-''||ladoi as lado_id, mzai as mza, ladoi as lado, avg(anchomed) as anchomed,
        st_linemerge(st_union(st_reverse(wkb_geometry))) as geom, cover
    from e00
    where mzai is not Null and mzai != ''''
    group by codigo20, mzai, ladoi, cover
    union
    select codigo20, mzad||''-''||ladod as lado_id, mzad as mza, ladod as lado, avg(anchomed) as anchomed,
        st_linemerge(st_union(wkb_geometry)) as geom, cover
    from e00
    where mzad is not Null and mzad != ''''
    group by codigo20, mzad, ladod, cover
    ),
    lados_codigos as (
    select codigo20, lado_id, mza, lado,
        st_simplifyVW(st_linemerge(st_union(geom)),10) as geom, cover
    from lados_de_manzana
    group by codigo20, lado_id, mza, lado, cover
    ),
    lado_manzana AS (
    select substring(mza,1,2)::integer as prov,substring(mza,3,3)::integer as dpto,substring(mza,6,3)::integer as codloc,
    substring(mza,9,2)::integer as frac, substring(mza,11,2)::integer radio,
        substring(mza,13,3)::integer as mza,
        codigo20, lado_id, mza link, lado::integer,
        geom, st_azimuth(st_startpoint(geom), st_endpoint(geom)) azimuth, cover,
        CASE WHEN st_geometrytype(geom) != ''ST_LineString'' THEN ''Lado discontinuo'' END as error_msg
    from lados_codigos
    ORDER BY mza, lado
    ), listado_carto AS (
    SELECT *
    FROM lado_manzana
    LEFT JOIN listado_sin_vacios USING (prov,dpto,codloc,frac,radio,mza,lado)
    ),
    conteos as (
    SELECT ''' || localidad || '''::text as tabla, prov, dpto dpto, codloc,
        frac, radio, mza, lado,
        count(CASE
          WHEN trim(tipoviv) in ('''', ''CO'', ''N'', ''CA/'', ''LO'')
            THEN NULL
            ELSE tipoviv END) conteo
    from listado_carto
    GROUP BY prov, dpto, codloc, frac, radio, mza, lado, geom
    ORDER BY count(CASE WHEN trim(tipoviv)='''' THEN NULL ELSE tipoviv END) desc
    )
select * from conteos;
';


---- en tabla global 
execute '
delete 
from segmentacion.conteos
where tabla = ''' || localidad || '''
;

insert INTO segmentacion.conteos (tabla, prov, dpto, codloc, frac, radio, mza, lado, conteo)
-- inserta en tabla global de conteos
SELECT ''' || localidad || '''::text as tabla, prov, dpto, codloc,
    frac, radio, mza, lado, conteo
from "' || localidad || '".conteos 
';

return 1;
end;
$function$
;
----------------------------------------


