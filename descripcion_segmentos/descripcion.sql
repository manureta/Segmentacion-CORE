/*
titulo:cripcion
descripción:
genera una descripcion para un registro en el listado
autor: -h
fecha: 18/7/2020
*/
create or replace function indec.descripcion (d record) returns text AS
$function$
begin
--return '|'|| d.nrocatastr || '|';
return d.ccalle || ' - ' || d.ncalle || ' ' || 
  case 
    when substr(d.ccalle, 1, 4)::integer = 999 then ''
    when d.nrocatastr = '0' then ' S/N '
    else d.nrocatastr || ' piso ' || d.piso
  end;
end;
$function$
language plpgsql;

