/*
renumeracion_ampliado.sql
desc.: renumera segmentos 61, 62, 63, 64, ...
dentro de radio
autor. -h
fecha 2020-08-21 Vi

insumo:
file muestreo.sql
(esto se podría agregar a ese archivo)
que genera numeracion_seg_cfr

producto
vista 
 prov | dpto | codloc | frac | radio | s_id | n_s_radio | n_s_frac | nuevo_numero
para cunado muestrado es True
nuevo_numero se incrementa desde 61 dentro del radio
*/

drop view if exists muestreo_con_nuevos_codigos;
create view muestreo_con_nuevos_codigos as
select prov, dpto, codloc, frac, radio, s_id, n_s_frac, n_s_radio,
  rank() over (
    partition by prov, dpto, codloc, frac, radio 
      order by prov, dpto, codloc, frac, radio, s_id
      )*2 - 1 + 60 as n_s_amp_1, -- ampliado-1 dentro de radio
  rank() over (
    partition by prov, dpto, codloc, frac, radio 
      order by prov, dpto, codloc, frac, radio, s_id
      )*2 + 60 as n_s_amp_2 -- ampliado-2 dentro de radio
from numeracion_seg_cfr
where muestrado
;

select * from muestreo_con_nuevos_codigos;


