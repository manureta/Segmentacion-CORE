/*
titulo: descripcion_segmentos.sql
descripción: 
crea la descripcion de las segmentos en mzas, lados
para agregarse en el mapa del radio

proceso posterior a la segmentación por lado completo
autor: -h
fecha: 2/5/2020

ejemplo:
      link      | prov | depto | codloc | frac | radio | segmento | seg |                                                                                                 descripcion
----------------+------+-------+--------+------+-------+----------+-----+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 58077010020401 | 58   | 077   | 010    | 02   | 04    | 01       |   1 | manzana 001 completa; manzana 002 lados 3, 4; manzana 003 lado 4; manzana 901 completa
 58077010020402 | 58   | 077   | 010    | 02   | 04    | 02       |   2 | manzana 002 lados 5, 1, 2; manzana 010 completa; manzana 013 lado 2; manzana 016 completa; manzana 017 completa; manzana 021 completa; manzana 022 completa
 58077010020403 | 58   | 077   | 010    | 02   | 04    | 03       |   3 | manzana 003 lados 1, 2, 3; manzana 004 completa; manzana 013 lados 3, 4, 5, 6, 7, 8, 9, 10, 1
 58077010020404 | 58   | 077   | 010    | 02   | 04    | 04       |   4 | manzana 009 completa
 58077010020405 | 58   | 077   | 010    | 02   | 04    | 05       |   5 | manzana 023 completa; manzana 024 completa
 58077010020406 | 58   | 077   | 010    | 02   | 04    | 06       |   6 | manzana 025 completa
 58077010020501 | 58   | 077   | 010    | 02   | 05    | 01       |   1 | manzana 001 lados 5, 1; manzana 002 lado 6
 58077010020502 | 58   | 077   | 010    | 02   | 05    | 02       |   2 | manzana 001 lados 2, 3, 4; manzana 005 lados 3, 4, 5, 6; manzana 006 completa; manzana 016 lados 2, 3, 4; manzana 021 lados 6, 7, 1, 2, 3; manzana 901 completa; manzana 908 completa; manzana 909 completa
 58077010020503 | 58   | 077   | 010    | 02   | 05    | 03       |   3 | manzana 002 lados 1, 2
 58077010020504 | 58   | 077   | 010    | 02   | 05    | 04       |   4 | manzana 002 lados 3, 4, 5; manzana 020 lados 4, 5, 6, 1
 58077010020505 | 58   | 077   | 010    | 02   | 05    | 05       |   5 | manzana 003 lados 1, 2; manzana 021 lados 4, 5; manzana 022 completa
 58077010020506 | 58   | 077   | 010    | 02   | 05    | 06       |   6 | manzana 003 lados 3, 4; manzana 010 lados 1, 2; manzana 012 completa; manzana 902 completa; manzana 903 completa; manzana 907 completa; manzana 910 completa
 58077010020507 | 58   | 077   | 010    | 02   | 05    | 07       |   7 | manzana 003 lado 5; manzana 020 lado 2
 58077010020508 | 58   | 077   | 010    | 02   | 05    | 08       |   8 | manzana 004 lados 1, 2; manzana 007 lados 2, 3; manzana 008 lados 2, 3, 4; manzana 014 completa; manzana 015 lados 4, 1; manzana 905 completa; manzana 906 completa
 58077010020509 | 58   | 077   | 010    | 02   | 05    | 09       |   9 | manzana 004 lados 3, 4; manzana 005 lado 1
 58077010020510 | 58   | 077   | 010    | 02   | 05    | 10       |  10 | manzana 005 lado 2; manzana 007 lados 4, 1
 58077010020511 | 58   | 077   | 010    | 02   | 05    | 11       |  11 | manzana 008 lado 1; manzana 009 completa; manzana 013 completa; manzana 904 completa
 58077010020512 | 58   | 077   | 010    | 02   | 05    | 12       |  12 | manzana 010 lados 3, 4; manzana 020 lado 3
 58077010020513 | 58   | 077   | 010    | 02   | 05    | 13       |  13 | manzana 015 lados 2, 3; manzana 016 lado 1
 58077010020514 | 58   | 077   | 010    | 02   | 05    | 14       |  14 | manzana 017 completa; manzana 024 completa
 58077010020515 | 58   | 077   | 010    | 02   | 05    | 15       |  15 | manzana 018 lados 1, 2; manzana 019 lado 3
 58077010020516 | 58   | 077   | 010    | 02   | 05    | 16       |  16 | manzana 018 lados 3, 4, 5, 6, 7
 58077010020517 | 58   | 077   | 010    | 02   | 05    | 17       |  17 | manzana 019 lados 4, 1, 2.
.
.
*/

create or replace function indec.descripcion_segmentos(aglomerado text)
 returns integer
 language plpgsql volatile
set client_min_messages = error
as $function$

begin
--execute 'drop table if exists "' || aglomerado || '".descripcion_segmentos cascade;';
execute 'drop view if exists "' || aglomerado || '".descripcion_segmentos cascade;';

execute '
create view "' || aglomerado || '".descripcion_segmentos as 
with 
e00 as (
  select * from
  -------------------- cobertura-------------------------
  "' || aglomerado || '".arc
  -------------------------------------------------------
  ),
listado as (
  select * from
  "' || aglomerado || '".listado
  ),
viviendas_colectivas as (
  select id, 
  prov || dpto || codloc || frac || radio as ppdddlllffrr,
  mza, lado::integer, 
  ccalle, ncalle, -- decidir si se pone o no 
  nrocatastr, descripcio, descripci2 
  from listado 
  where tipoviv = ''CO''
  ),
seg_mza_lados as (
  select substr(mzai,1,12) as ppdddlllffrr, 
  segi as seg, substr(mzai,13,3) as mza, ladoi as lado
  from e00
  where mzai is not Null and mzai != '''' and ladoi != 0
  union
  select substr(mzad,1,12) as ppdddlllffrr,
  segd as seg, substr(mzad,13,3) as mza, ladod as lado
  from e00
  where mzad is not Null and mzad != '''' and ladod != 0
  ),
lados_por_mza as (
  select ppdddlllffrr, mza, count(*) as cant_lados
  from seg_mza_lados
  group by ppdddlllffrr, mza
  ),
mzas_en_segmentos as (
  select ppdddlllffrr, mza, seg, count(*) as cant_lados_en_seg
  from seg_mza_lados
  group by ppdddlllffrr, mza, seg
  ),
mzas_completas as (
  select *
  from mzas_en_segmentos
  natural join
  lados_por_mza
  where cant_lados = cant_lados_en_seg
  ),
lados_de_mzas_incompletas as (
  select ppdddlllffrr, seg, mza, lado, lado::integer as i
  from seg_mza_lados
  where (ppdddlllffrr, seg, mza) not in (
    select ppdddlllffrr, seg, mza
    from mzas_completas
    )
  ),
serie as (
  select ppdddlllffrr, seg, mza, generate_series(1, cant_lados) as i
  from lados_de_mzas_incompletas
  natural join lados_por_mza
  group by ppdddlllffrr, seg, mza, cant_lados
  ),
junta as (
  select *
  from lados_de_mzas_incompletas
  natural full join
  serie   
  ),
no_estan as (
  select ppdddlllffrr, seg, mza,
    max(i) as max_no_esta, min(i) as min_no_esta
  from junta
  where lado is Null
  group by ppdddlllffrr, seg, mza, lado
  ),
lados_ordenados as (
  select ppdddlllffrr, seg, mza, lado, 
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
descripciones_lados as (
  select ppdddlllffrr, seg, mza, lado, orden,
  lado::text as descripcion_lado
  from lados_ordenados where (ppdddlllffrr, mza, lado) not in (select ppdddlllffrr, mza, lado from viviendas_colectivas)
  union 
  select ppdddlllffrr, seg, mza, lado, orden,
  (lado::text || '' '' || descripcio)::text as descripcion_lado
  from lados_ordenados 
  join viviendas_colectivas
  using (ppdddlllffrr, mza, lado) -- (!) ver si hay más de 1 viv col en 1 lado hay que usar una agregacion de descripcio
  where (ppdddlllffrr, mza, lado) in (select ppdddlllffrr, mza, lado from viviendas_colectivas)
--    case
--      when lado::text is Null then lado::text
--      else (lado::text || '' '' || descripcio)::text
--    end as descripcion_lado
--  from viviendas_colectivas co
--  full join lados_ordenados l
--  using (ppdddlllffrr, mza, lado)
--  on co.ppdddlllffrr = l.ppdddlllffrr
--  and co.mza = l.mza
--  and case co.lado = l.lado end
  ),
descripciones_mzas as (
  select ppdddlllffrr, seg, ''Manzana ''||mza||'' completa'' as descripcion
  from mzas_completas
  union
  select ppdddlllffrr, seg,
    ''Manzana ''||mza||'' ''|| replace(replace(replace(array_agg(descripcion_lado order by orden)::text, ''{'',
      case
        when cardinality(array_agg(lado)) = 1 then ''Lado ''
        else ''Lados '' end
                                                      ), 
                                              -- cambia inicio de array por lado o lados según cuantos son
                                    ''}'',''''), -- saca fin de array }
                         '','', '', '') -- separador de lados
    as descripcion
  from descripciones_lados
  group by ppdddlllffrr, seg, mza
  order by ppdddlllffrr, seg, descripcion
  )
select ppdddlllffrr || lpad(seg::text,2,''0'') as link, 
     substr(ppdddlllffrr,1,2)::char(2) as prov, substr(ppdddlllffrr,3,3)::char(3) as depto, 
     substr(ppdddlllffrr,6,3)::char(3) as codloc, 
     substr(ppdddlllffrr,9,2)::char(2) as frac, substr(ppdddlllffrr,11,2)::char(2) as radio, 
     lpad(seg::text,2,''0'') as segmento, seg,
  string_agg(descripcion,''; '') as descripcion -- separador de manzanas
from descripciones_mzas
group by ppdddlllffrr, seg
order by ppdddlllffrr, seg
';

return 1;
end;
$function$
;
----------------------------------------





