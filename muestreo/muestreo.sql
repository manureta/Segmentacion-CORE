/*
--------------------------------------------------
  numeración y muestreo de segmentos
                                                                                                                                                                          insumos                                                                                                                                                                   listado (C1),                                                                                                                                                           segmentación a mza indep (no requiere cobertura)
  productos                                                                                                                                                                 n_s_radio: numeración de segmentos por radio                                                                                                                            n_s_fraccion: numeración de segmentos por fraccion                                                                                                                      muestrado: True si segmento muestrado,                                                                                                                                              Null si no                                                                                                                                              --------------------------------------------------
*/
with
pdlfrmls as (
  select prov, dpto, codloc, frac, radio, mza, lado, segmento_id as s_id
  from e0002.listado
  join e0002.segmentacion
  on listado.id = listado_id
  group by prov, dpto, codloc, frac, radio, mza, lado, segmento_id
  ),
segmentos_con_id_de_radio_completo_a_mza_indep as (
  select prov, dpto, codloc, frac, radio, s_id
  from pdlfrmls
  group by prov, dpto, codloc, frac, radio, s_id
  ),
numerados as (select prov, dpto, codloc, frac, radio, s_id,
    rank() over (
    partition by prov, dpto, codloc, frac, radio 
      order by prov, dpto, codloc, frac, radio, s_id
      ) as n_s_radio, -- numerados dentro de radio
    rank() over (
    partition by prov, dpto, codloc, frac
      order by prov, dpto, codloc, frac, radio, s_id
      ) as n_s_frac, -- numerados dentro de frac
    rank() over (
    partition by prov, dpto, codloc 
      order by prov, dpto, codloc, frac, radio, s_id
      ) as n_s_codloc -- numerados dentro de codloc
  from segmentos_con_id_de_radio_completo_a_mza_indep),
muestra as (select prov, dpto, codloc, indec.randint(10)
  from pdlfrmls
  group by prov, dpto, codloc)
select prov, dpto, codloc, frac, radio, s_id, n_s_radio, n_s_frac,
  case when n_s_codloc % 10 = randint then true
  else Null
  end
  as muestrado
from muestra
join numerados
using (prov, dpto, codloc)
;

/*
en el siguente caso el número aleatorio usado 
para muestrear el 10% (+/- 1u) de los segmentos 
para la localidad identificada como prov, depto, codloc
resultó 2
```
 prov | dpto | codloc | frac | radio | s_id | n_s_radio | n_s_frac | muestrado
------+------+--------+------+-------+------+-----------+----------+-----------
 02   | 014  | 010    | 01   | 01    |    1 |         1 |        1 |
 02   | 014  | 010    | 01   | 01    |    2 |         2 |        2 | t
 02   | 014  | 010    | 01   | 01    |    3 |         3 |        3 |
 02   | 014  | 010    | 01   | 01    |    4 |         4 |        4 |
 02   | 014  | 010    | 01   | 01    |    5 |         5 |        5 |
 02   | 014  | 010    | 01   | 01    |    6 |         6 |        6 |
 02   | 014  | 010    | 01   | 01    |    7 |         7 |        7 |
 02   | 014  | 010    | 01   | 01    |    8 |         8 |        8 |
 02   | 014  | 010    | 01   | 01    |    9 |         9 |        9 |
 02   | 014  | 010    | 01   | 01    |   10 |        10 |       10 |
 02   | 014  | 010    | 01   | 01    |   11 |        11 |       11 |
 02   | 014  | 010    | 01   | 01    |   12 |        12 |       12 | t
 02   | 014  | 010    | 01   | 02    |   13 |         1 |       13 |
 02   | 014  | 010    | 01   | 02    |   14 |         2 |       14 |
 02   | 014  | 010    | 01   | 02    |   15 |         3 |       15 |
 02   | 014  | 010    | 01   | 02    |   16 |         4 |       16 |
 02   | 014  | 010    | 01   | 02    |   17 |         5 |       17 |
 02   | 014  | 010    | 01   | 02    |   18 |         6 |       18 |
 02   | 014  | 010    | 01   | 02    |   19 |         7 |       19 |
 02   | 014  | 010    | 01   | 02    |   20 |         8 |       20 |
 02   | 014  | 010    | 01   | 02    |   21 |         9 |       21 |
 02   | 014  | 010    | 02   | 01    |   22 |         1 |        1 | t
 02   | 014  | 010    | 02   | 01    |   23 |         2 |        2 |
 02   | 014  | 010    | 02   | 01    |   24 |         3 |        3 |
 02   | 014  | 010    | 02   | 01    |   25 |         4 |        4 |
 02   | 014  | 010    | 02   | 01    |   26 |         5 |        5 |
 02   | 014  | 010    | 02   | 01    |   27 |         6 |        6 |
 02   | 014  | 010    | 02   | 01    |   28 |         7 |        7 |
 02   | 014  | 010    | 02   | 01    |   29 |         8 |        8 |
 02   | 014  | 010    | 02   | 01    |   30 |         9 |        9 |
 02   | 014  | 010    | 02   | 01    |   31 |        10 |       10 |
 02   | 014  | 010    | 02   | 01    |   32 |        11 |       11 | t
 02   | 014  | 010    | 02   | 01    |   33 |        12 |       12 |
 02   | 014  | 010    | 02   | 01    |   34 |        13 |       13 |
 02   | 014  | 010    | 02   | 01    |   35 |        14 |       14 |
 02   | 014  | 010    | 02   | 01    |   36 |        15 |       15 |
 02   | 014  | 010    | 02   | 02    |   37 |         1 |       16 |
 02   | 014  | 010    | 02   | 02    |   38 |         2 |       17 |
...
 02   | 014  | 010    | 25   | 10    | 3241 |         4 |      158 |
 02   | 014  | 010    | 25   | 10    | 3242 |         5 |      159 | t
 02   | 014  | 010    | 25   | 10    | 3243 |         6 |      160 |
 02   | 014  | 010    | 25   | 10    | 3244 |         7 |      161 |
 02   | 014  | 010    | 25   | 10    | 3245 |         8 |      162 |
 02   | 014  | 010    | 25   | 10    | 3246 |         9 |      163 |
 02   | 014  | 010    | 25   | 10    | 3247 |        10 |      164 |
 02   | 014  | 010    | 25   | 10    | 3248 |        11 |      165 |
 02   | 014  | 010    | 25   | 10    | 3249 |        12 |      166 |
 02   | 014  | 010    | 25   | 11    | 3250 |         1 |      167 |
 02   | 014  | 010    | 25   | 11    | 3251 |         2 |      168 |
 02   | 014  | 010    | 25   | 11    | 3252 |         3 |      169 | t
 02   | 014  | 010    | 25   | 11    | 3253 |         4 |      170 |
 02   | 014  | 010    | 25   | 11    | 3254 |         5 |      171 |
 02   | 014  | 010    | 25   | 11    | 3255 |         6 |      172 |
 02   | 014  | 010    | 25   | 11    | 3256 |         7 |      173 |
 02   | 014  | 010    | 25   | 11    | 3257 |         8 |      174 |
 02   | 014  | 010    | 25   | 11    | 3258 |         9 |      175 |
 02   | 014  | 010    | 25   | 11    | 3259 |        10 |      176 |
 02   | 014  | 010    | 25   | 11    | 3260 |        11 |      177 |
 02   | 014  | 010    | 25   | 11    | 3261 |        12 |      178 |
 02   | 014  | 010    | 25   | 11    | 3262 |        13 |      179 | t
 02   | 014  | 010    | 25   | 11    | 3263 |        14 |      180 |
 02   | 014  | 010    | 25   | 11    | 3264 |        15 |      181 |
 02   | 014  | 010    | 25   | 11    | 3265 |        16 |      182 |
 02   | 014  | 010    | 25   | 11    | 3266 |        17 |      183 |
 02   | 014  | 010    | 25   | 11    | 3267 |        18 |      184 |
 02   | 014  | 010    | 25   | 11    | 3268 |        19 |      185 |
 02   | 014  | 010    | 25   | 11    | 3269 |        20 |      186 |
 02   | 014  | 010    | 25   | 11    | 3270 |        21 |      187 |
 02   | 014  | 010    | 25   | 11    | 3271 |        22 |      188 |
 02   | 014  | 010    | 25   | 11    | 3272 |        23 |      189 | t
(3272 rows)

```

*/
