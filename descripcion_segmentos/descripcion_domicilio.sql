/*
titulo: descripcion_domicilio.sql 
https://github.com/hernan-alperin/Segmentacion-CORE/issues/20
descripción:  devuelva el domicilio para desde-hasta de segmentos en R3
usando el id del listado
autor: -h
fecha:2020-11

usar columnas
                                         Table "e0002.listado"
------------+------------------------+-----------+----------+-------------------------------------------
 ccalle     | character varying(6)   |           |          |
 ncalle     | character varying(34)  |           |          |
 nrocatastr | character varying(4)   |           |          |
 piso       | character varying(3)   |           |          |
 dpto_habit | character varying(15)  |           |          |
 sector     | character varying(1)   |           |          |
 edificio   | character varying(15)  |           |          |
 entrada    | character varying(1)   |           |          |
 tipoviv    | character varying(3)   |           |          |
 descripcio | character varying(220) |           |          |
 descripci2 | character varying(1)   |           |          |
*/

create or replace function indec.descripcion_domicilio(in esquema text, listado_id integer)
 returns text
 language plpgsql volatile
set client_min_messages = error
as $function$
declare domicilio text;     
begin
execute '
select
  ccalle || '' - '' || ncalle || 
    case
    when nrocatastr is Null or nrocatastr = '''' or nrocatastr = '0' then '' S/N ''
    else '' '' || nrocatastr
  end ||
  case
    when edificio is Null or edificio = '''' then ''''
    else '' edificio '' || edificio
  end ||
  case
    when entrada is Null or entrada = '''' then ''''
    else '' entrada '' || entrada
  end ||
  case
    when sector is Null or sector = '''' then ''''
    else '' sector '' || sector
  end ||
  case
    when piso is Null or piso = '''' then ''''
    else '' piso '' || piso
  end ||
  case
    when descripcio is Null or descripcio = '''' then ''''
    else '' descripcio '' || descripcio
  end
from "' || esquema || '".listado
where ' || listado_id || ' = id
;' into domicilio;

return domicilio;
end;
$function$
;

