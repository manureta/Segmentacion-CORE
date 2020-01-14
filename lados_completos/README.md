módulo de segmentación para localidades de baja densidad
donde los lados contienen menos de la cantidad deseada de viviendas por segmento

los segmentos contienen uno o más lados adyacentes de la misma manzana o de manzanas adyacentes

ejemplo de ejecución:

```bash
[halperin@arswebdev043 segmentador]$ python3 lados_completos.py e0359.arc 38 28 4 1 20 20 20 15
['e0359.arc', '38', '28', '4', '1', '20', '20', '20', '15']
radio:
38 28 4 1
---------
mínimo local
costo 5087
['segmento', 1, 'carga', 18, 'costo', 31, 'componentes', [(4, 4), 1, (4, 3), (4, 2), (4, 1)]]
['segmento', 2, 'carga', 17, 'costo', 61, 'componentes', [2, 21, 22]]
['segmento', 3, 'carga', 16, 'costo', 79, 'componentes', [(3, 2), (3, 1), (3, 4), (3, 3)]]
['segmento', 4, 'carga', 18, 'costo', 21, 'componentes', [(5, 4), (5, 3), (5, 1), (5, 2)]]
['segmento', 5, 'carga', 20, 'costo', 10, 'componentes', [(6, 4), (6, 3), (6, 1), (6, 2)]]
['segmento', 6, 'carga', 20, 'costo', 10, 'componentes', [(7, 4), (7, 3), (7, 1), (7, 2)]]
['segmento', 7, 'carga', 18, 'costo', 21, 'componentes', [(8, 2), (8, 1), (8, 4), (8, 3)]]
['segmento', 8, 'carga', 18, 'costo', 21, 'componentes', [(9, 1), (9, 2), (9, 4), (9, 3)]]
['segmento', 9, 'carga', 20, 'costo', 10, 'componentes', [(10, 2), (10, 1), (10, 3), (10, 4)]]
['segmento', 10, 'carga', 20, 'costo', 10, 'componentes', [(11, 4), (11, 3), (11, 2), (11, 1)]]
['segmento', 11, 'carga', 18, 'costo', 21, 'componentes', [(12, 2), (12, 1), (12, 3), (12, 4)]]
['segmento', 12, 'carga', 18, 'costo', 21, 'componentes', [(13, 4), (13, 1), (13, 2), (13, 3)]]
['segmento', 13, 'carga', 20, 'costo', 10, 'componentes', [(14, 4), (14, 3), (14, 2), (14, 1)]]
['segmento', 14, 'carga', 18, 'costo', 21, 'componentes', [(15, 4), (15, 3), (15, 2), (15, 1)]]
['segmento', 15, 'carga', 18, 'costo', 21, 'componentes', [(16, 4), (16, 3), (16, 2), (16, 1)]]
['segmento', 16, 'carga', 20, 'costo', 10, 'componentes', [(17, 4), (17, 3), (17, 2), (17, 1)]]
['segmento', 17, 'carga', 23, 'costo', 51, 'componentes', [24, 18]]
['segmento', 18, 'carga', 17, 'costo', 51, 'componentes', [20, 19]]
['segmento', 19, 'carga', 24, 'costo', 79, 'componentes', [(23, 1), (23, 2), (23, 3), (23, 4)]]
['segmento', 20, 'carga', 20, 'costo', 10, 'componentes', [(25, 2), (25, 1), (25, 3), (25, 4)]]
['segmento', 21, 'carga', 23, 'costo', 41, 'componentes', [(26, 1), (26, 2), (26, 4), (26, 3)]]
['segmento', 22, 'carga', 15, 'costo', 161, 'componentes', [30, 27, 28]]
['segmento', 23, 'carga', 24, 'costo', 89, 'componentes', [29, 31]]
['segmento', 24, 'carga', 19, 'costo', 33, 'componentes', [35, 32, (34, 6), (34, 5), (34, 2), (34, 4), (34, 3)]]
['segmento', 25, 'carga', 17, 'costo', 51, 'componentes', [(34, 1), 33]]
['segmento', 26, 'carga', 4, 'costo', 4143, 'componentes', [36, 37, 38]]
deseada: 20, máxima: 20, mínima: 20
10.555717945098877 segundos
[halperin@arswebdev043.indec.gob.ar]$ python /home/DCINDEC/halperin/segmentacion/segmentador/SegmentaManzanasLadosFracRadio.py e0359.arc 38 28 4 1 20 20 20 15
censo2020:segmentador:rodatnemges:172.26.67.239:5432
```

