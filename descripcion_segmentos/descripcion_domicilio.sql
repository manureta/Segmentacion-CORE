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

create or replace function indec.descripcion_colectiva(in esquema text, listado_id integer)
 returns text
 language plpgsql volatile
set client_min_messages = error
as $function$
declare 
domicilio text;
subtipo text := 'vivienda colectiva';
hay_subtipo boolean;

begin

execute
'SELECT EXISTS (SELECT 1
  FROM information_schema.columns
  WHERE table_schema=''' || esquema || ''' AND table_name=''listado'' AND column_name= ''cod_subt_v'')
' into hay_subtipo;

IF (hay_subtipo) THEN
  execute '
  select not (cod_subt_v = '''' or cod_subt_v is Null)
    from "' || esquema || '".listado where id = ' || listado_id || '
' into hay_subtipo;
END IF;

IF (hay_subtipo) THEN
  execute '
  select case when cod_subt_v != ''CO10''
    then nombre
    else ''vivienda colectiva''
  end
  from "' || esquema || '".listado
  join public.subtipo_vivienda st
  on cod_subt_v = st.codigo
  where ' || listado_id || ' = listado.id
  ' into subtipo;
END IF;

execute '
select
  ''' || subtipo || '''  || '' en '' || 
  ccalle || '' - '' || ncalle ||
    case
    when nrocatastr is Null or trim(nrocatastr) = '''' or
         trim(nrocatastr) = ''0'' or trim(nrocatastr) = ''S/N''
            then '' S/N ''
    else '' Nº '' || nrocatastr || '' ''
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
    else '' descripción '' || descripcio
  end
from "' || esquema || '".listado
where ' || listado_id || ' = id
;' into domicilio;

return domicilio;
end;
$function$
;

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
    when nrocatastr is Null or trim(nrocatastr) = '''' or 
         trim(nrocatastr) = ''0'' or trim(nrocatastr) = ''S/N'' 
            then '' S/N ''
    else '' Nº '' || nrocatastr || '' ''
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
    else '' descripción '' || descripcio
  end
from "' || esquema || '".listado
where ' || listado_id || ' = id
;' into domicilio;

return domicilio;
end;
$function$
;


create or replace function indec.descripcion_calle_desde_hasta(in esquema text, desde_id integer, hasta_id integer, completo boolean)
 returns text
 language plpgsql volatile
set client_min_messages = error
as $function$
declare
    calle text;
    desde text;
    hasta text;
begin
execute '
select ccalle || '' - '' || ncalle 
from "' || esquema || '".listado
where listado.id  = ' || desde_id || '
;' into calle;

if completo then 
  return calle;
end if;

execute '
select
--  ccalle || '' - '' || ncalle || '' '' || -- la calle es la misma 
    nrocatastr ||
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
    else '' (descripción: '' || descripcio || '') ''
  end
from "' || esquema || '".listado
where listado.id  = ' || desde_id || '
;' into desde;

execute '
select
--  ccalle || '' - '' || ncalle || '' '' ||  -- la calle es la misma
    nrocatastr ||
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
    else '' (descripción: '' || descripcio || '') ''
  end
from "' || esquema || '".listado
where listado.id  = ' || hasta_id || '
;' into hasta;

return calle || ' desde ' || desde || ' hasta ' || hasta;
end;
$function$
;



