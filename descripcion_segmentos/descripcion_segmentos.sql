/*
titulo: descripcion_segmentos.sql
descripción: 
crea la descripcion de las segmentos en mzas, lados
para agregarse en el mapa del radio

proceso posterior a la segmentación por lado completo
autor: -h
fecha: 2/5/2020

ejemplo:
 ppdddlllffrr | prov | depto | codloc | frac | radio | segmento |                                                                                                                             descripcion                                                                                                                             
--------------+------+-------+--------+------+-------+----------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 380280400401 | 38   | 028   | 040    | 04   | 01    | 01       | manzana 001 completa, manzana 002 lados 3 4 1, manzana 019 completa, manzana 020 completa, manzana 021 completa
 380280400401 | 38   | 028   | 040    | 04   | 01    | 02       | manzana 002 lado 2, manzana 003 lados 3 4, manzana 022 completa
 380280400401 | 38   | 028   | 040    | 04   | 01    | 03       | manzana 003 lados 1 2, manzana 004 lados 3 4, manzana 006 lados 3 4
 380280400401 | 38   | 028   | 040    | 04   | 01    | 04       | manzana 004 lados 1 2, manzana 005 lados 3 4, manzana 006 lado 1
 380280400401 | 38   | 028   | 040    | 04   | 01    | 05       | manzana 005 lados 1 2, manzana 008 lado 4
 380280400401 | 38   | 028   | 040    | 04   | 01    | 06       | manzana 006 lado 2, manzana 007 lados 3 4
 380280400401 | 38   | 028   | 040    | 04   | 01    | 07       | manzana 007 lado 1, manzana 008 lados 1 2 3, manzana 009 lados 3 4, manzana 010 lado 1
 380280400401 | 38   | 028   | 040    | 04   | 01    | 08       | manzana 007 lado 2, manzana 010 lados 3 4

*/

create or replace function indec.descripcion_segmentos(aglomerado text)
 returns integer
 language plpgsql volatile
set client_min_messages = error
as $function$

begin
execute 'drop view if exists "' || aglomerado || '".descripcion_segmentos;';

execute '
create view "' || aglomerado || '".descripcion_segmentos as 
with 
e00 as (
    select * from
    -------------------- cobertura-------------------------
    "' || aglomerado || '".arc
    -------------------------------------------------------
    ),
seg_mza_lados as (
    select substr(mzai,1,13) || lpad(segi::text,2,''0'') as ppdddlllffrrss, 
    segi as seg, substr(mzai,13,3) as mza, ladoi as lado
    from e00
    where mzai is not Null and mzai != '''' and ladoi != 0
    union
    select substr(mzad,1,12) || lpad(segd::text,2,''0'') as ppdddlllffrr,
    segd as seg, substr(mzad,13,3) as mza, ladod as lado
    from e00
    where mzad is not Null and mzad != '''' and ladod != 0
    ),
lados_por_mza as (
  select ppdddlllffrrss, mza, count(*) as cant_lados
  from seg_mza_lados
  group by ppdddlllffrrss, mza
  ),
mzas_en_segmentos as (
  select ppdddlllffrrss, mza, seg, count(*) as cant_lados_en_seg
  from seg_mza_lados
  group by ppdddlllffrrss, mza, seg
  ),
mzas_completas as (
  select *
  from mzas_en_segmentos
  natural join
  lados_por_mza
  where cant_lados = cant_lados_en_seg
  ),
lados_de_mzas_incompletas as (
  select ppdddlllffrrss, seg, mza, lado, lado::integer as i
  from seg_mza_lados
  where (ppdddlllffrrss, seg, mza) not in (
    select ppdddlllffrrss, seg, mza
    from mzas_completas
    )
  ),
serie as (
  select ppdddlllffrrss, seg, mza, generate_series(1, cant_lados) as i
  from lados_de_mzas_incompletas
  natural join lados_por_mza
  group by ppdddlllffrrss, seg, mza, cant_lados
  ),
junta as (
  select *
  from lados_de_mzas_incompletas
  natural full join
  serie   
  ),
no_estan as (
  select ppdddlllffrrss, seg, mza,
    max(i) as max_no_esta, min(i) as min_no_esta
  from junta
  where lado is Null
  group by ppdddlllffrrss, seg, mza, lado
  ),
lados_ordenados as (
  select ppdddlllffrrss, seg, mza, lado, 
  case
  when lado::integer > max_no_esta then lado::integer - max_no_esta -- el hueco está abajo
  when min_no_esta > lado::integer then cant_lados - max_no_esta + lado::integer -- el hueco está arriba
  when min_no_esta = 1 and max_no_esta = cant_lados then lado::integer -- hay hueco a ambos lados, no empieza en 1 
  end
  as orden
  from no_estan
  natural join
  lados_de_mzas_incompletas
  natural join
  lados_por_mza
  natural join
  mzas_en_segmentos),
descripcion_mza as (
  select ppdddlllffrrss, seg, ''manzana ''||mza||'' completa'' as descripcion
  from mzas_completas
  union
  select ppdddlllffrrss, seg,
    ''manzana ''||mza||'' ''|| replace(replace(replace(array_agg(lado order by orden)::text, ''{'',
      case
        when cardinality(array_agg(lado)) = 1 then ''lado ''
        else ''lados '' end
                                                  ), ''}'',''''), '','', '' '')
    as descripcion
  from lados_ordenados
  group by ppdddlllffrrss, seg, mza
  order by ppdddlllffrrss, seg, descripcion
  )
select ppdddlllffrrss::character(14), 
       substr(ppdddlllffrrss,1,2)::char(2) as prov, substr(ppdddlllffrrss,3,3)::char(3) as depto, 
       substr(ppdddlllffrrss,6,3)::char(3) as codloc, 
       substr(ppdddlllffrrss,9,2)::char(2) as frac, substr(ppdddlllffrrss,11,2)::char(2) as radio, 
       lpad(seg::text,2,''0'')::character(2) as segmento, 
    string_agg(descripcion,'', '') as descripcion
from descripcion_mza
group by ppdddlllffrrss, seg
order by ppdddlllffrrss, seg
';

return 1;
end;
$function$
;
----------------------------------------

      
      




