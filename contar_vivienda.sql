/*
titulo: contar_vivienda.sql
descripción: 
define por tipoviv cual registro se contabiliza como vivenda
devuelve tipoviv si se cuenta, Null si no
para usar el count(tipoviv)
es usada por generar_conteos

autor: -h
fecha: 2020-05

A Casa, Rancho
B1 Edificio o Monoblock
B2 PH o Departamento tipo casa
B3 Vivienda en Country o Barrio Cerrado
C Vivienda Colectiva con Hogares particulares: Pieza en Inquilinato, Hotel
Familiar o Pensión
-- se excluye
CO Vivienda Colectiva sin Hogares particulares
-------------
D Vivienda en un Lugar de Trabajo
H Vivienda en Villa
J Local no construido para habitación, con hogar particular
VE Vivienda establecimiento
FD Vivienda de uso para fin de semana
-- cómo aparecen estos códigos ?
CA /CP Viviendas en Construcción
--------------------------------
-- '' y Null se excluyen
*/

create or replace function indec.contar_vivienda(in tipoviv text)
 returns text
 language sql immutable
as $function$
select 
  case 
    when upper(trim($1)) in ('A', 'B1', 'B2', 'B3', 'C', 'D', 'H', 'J', 'VE', 'FD', 'CA/CP') then $1
    else Null
  end as tipoviv_que_cuenta;
$function$
;

