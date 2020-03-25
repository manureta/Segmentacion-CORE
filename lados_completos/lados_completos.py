# -*- coding: utf-8 -*-
import sys
sys.path.append('.')
from decimal import *
print (sys.argv[1:])
_table = sys.argv[1]
parametro1 = _table.split('.')
_table = parametro1[0]
_prov = int(sys.argv[2])
_dpto = int(sys.argv[3])
_frac = int(sys.argv[4])
_radio = int(sys.argv[5])

#definición de funciones de adyacencia y operaciones sobre manzanas

def son_adyacentes(este, aquel):
    return aquel in adyacentes[este]

# calcula el componente conexo que contiene a este, 
# para calcular las componentes conexas o contiguas luego de una extracción
def clausura_conexa(este, esos):
    # se puede ir de este a ese para todo ese en esos
    if este not in esos:
        return [] # caso seguro
    else:
        clausura = [este] # al menos contiene a este
        i = 0
        while i < len(clausura): # i es el puntero lo que que falta expandir
            # i se incrementa de a 1 expandiendo de a 1 las adyacencias
            # hasta que la variable clausura no se expande más, 
            # queda en un puntos fijo, i.e. es una clausura
            adyacentes_i = [ese for ese in adyacentes[clausura[i]] if ese in esos]
            # los adyacentes a la i-ésimo elemento de la clausura que están en la coleccion
            nuevos = [ese for ese in adyacentes_i if ese not in clausura] # no agragados aún
            clausura.extend(nuevos) # se agregan al final las adyacencias no agregadas
            i = i + 1
        return list(set(clausura))

def conectados(estos):
    # True si coleccion es conexo, no hay partes separadas, 
    if not estos: # es vacio
        return True
    else:
        este = estos[0] # este es cualquiera, se elije el primero
        return len(clausura_conexa(este, estos)) == len(estos)

# extraer un componente
def extraer(este, estos): 
    # devuelve la lista de partes conexas resultado de remover la manzana m del segmento
    if este not in estos:
        return []
    else:
        esos = list(estos) # copia para no modificar el original
        esos.remove(este)
        partes = []
        while esos: # es no vacia
            ese = esos[0] # se elige uno cualquiera, se usa el 1ro
            clausura_de_ese_en_esos = clausura_conexa(ese, esos)
            for aquel in clausura_de_ese_en_esos:
                if aquel not in esos: # (?) cómo puede ser?????
            #        pass
                    raise Exception("elemento " + str(aquel) + " no está en " + str(esos)
                        + "\nclausura_de_ese_en_esos " + str(clausura_de_ese_en_esos))
                else:  # para que no se rompa acá....
                    esos.remove(aquel) # en esos queda el resto no conexo a aquel
            partes.append(clausura_de_ese_en_esos)
        return partes

# transferir un componente de un conjunto a otro
def transferir(este, estos, esos):
    # transferir este del segmento origen al segmento destino
    # devuelve una lista con 2 elementoe ... los nuevos estos y esos
    if not conectados(esos + [este]): # no puedo transferir
        return False
    elif len(estos) == 1: # no queda resto, se fusiona origen con destino
        return [estos + esos]
    else:
        return extraer(este, estos) + [esos + [este]]

def carga(estos):
    conteos = [viviendas[este] for este in estos]
    return sum(conteos)

def cuantas_manzanas(estos):
    tuplas = [cmpt for cmpt in estos if type(cmpt) is tuple]
    mzas = [mza for (mza, lado) in tuplas]
    mzas.extend([cmpt for cmpt in estos if type(cmpt) is int])
    return len(set(mzas))

def adyacencias_componentes(estos):
    #return [este for este in estos]
    return [(este, ese) for este in estos for ese in estos if (este, ese) in adyacencias]

def costo_adyacencia(esta):
    (este, ese) = esta
    if type(este) is int:
        este = (este, 0)
    if type(ese) is int:
        ese = (ese, 0)
    costos = [c_a[2] for c_a in costos_adyacencias if (c_a[0], c_a[1]) == (este, ese)]
    if costos:
        return costos[0]
    
    


#################################################################################
#
# definición de funcion de costo
# y relativas a la calidad del segmento y la segmentación
#
# caso 1
cantidad_de_viviendas_deseada_por_segmento = 20
cantidad_de_viviendas_maxima_deseada_por_segmento = 23
cantidad_de_viviendas_minima_deseada_por_segmento = 17
cantidad_de_viviendas_permitida_para_romper_manzana = 5
multa_fuera_rango_superior = 1
multa_fuera_rango_inferior = 1

if len(sys.argv) > 7:
    cantidad_de_viviendas_minima_deseada_por_segmento = int(sys.argv[6])
    cantidad_de_viviendas_maxima_deseada_por_segmento = int(sys.argv[7])
if len(sys.argv) > 8:
    cantidad_de_viviendas_deseada_por_segmento = int(sys.argv[8])
if len(sys.argv) > 9:
    cantidad_de_viviendas_permitida_para_romper_manzana = int(sys.argv[9])


def costo(segmento): 
    # segmento es una lista de manzanas
    carga_segmento = carga(segmento)
    mzas_segmento = cuantas_manzanas(segmento)
    adyacencias_segmento = adyacencias_componentes(segmento)
    costo_adyacencias = sum(costo_adyacencia(ady) for ady in adyacencias_segmento if costo_adyacencia(ady))
    if carga_segmento > cantidad_de_viviendas_maxima_deseada_por_segmento:
        # la carga es mayor el costo es el cubo
        costo = (abs(carga_segmento - cantidad_de_viviendas_maxima_deseada_por_segmento) 
                *abs(carga_segmento - cantidad_de_viviendas_maxima_deseada_por_segmento) 
                *abs(carga_segmento - cantidad_de_viviendas_maxima_deseada_por_segmento) 
            + (carga_segmento - cantidad_de_viviendas_deseada_por_segmento)
            + multa_fuera_rango_superior)
    elif carga_segmento < cantidad_de_viviendas_minima_deseada_por_segmento:
        # la carga es menor el costo es el cubo
        costo = (abs(cantidad_de_viviendas_minima_deseada_por_segmento - carga_segmento)
                *abs(cantidad_de_viviendas_minima_deseada_por_segmento - carga_segmento)
                *abs(cantidad_de_viviendas_minima_deseada_por_segmento - carga_segmento)
            + abs(carga_segmento - cantidad_de_viviendas_deseada_por_segmento)
            + multa_fuera_rango_inferior)
    else:  # está entre los valores deseados
        # el costo el la diferencia absoluta al valor esperado
        costo = abs(carga_segmento - cantidad_de_viviendas_deseada_por_segmento)
    return costo + 5*mzas_segmento + 100*costo_adyacencias

    """
    # otro caso, costo en rango, cuadrático por arriba y lineal por abajo
    if carga_segmento > cantidad_de_viviendas_deseada_por_segmento:
        return (carga_segmento - cantidad_de_viviendas_deseada_por_segmento)**4
    else:
        return (cantidad_de_viviendas_deseada_por_segmento - carga_segmento)**2
    """

def seg_id(segmento):
    tuplas = [cmpt for cmpt in segmento if type(cmpt) is tuple]
    if tuplas:
        min_m, min_l = min(tuplas)
    else:
        min_m = None
    ints = [cmpt for cmpt in segmento if type(cmpt) is int]
    if ints:
        min_mza = min(ints)
    else:
        min_mza = None
    if not min_m:
        return (min_mza, 0)
    if min_mza and min_mza < min_m:
        return (min_mza, 0)
    else: 
        return (min_m, min_l)

def cmpt_id(cmpt):
    if type(cmpt) is tuple:
        return cmpt
    else:
        return (cmpt, 0)
 
        
    

#####################################################################################
    
def costos_segmentos(segmentacion):
    # segmentacion es una lista de segmentos
    return map(costo, segmentacion)
    # la lista de costos de los segmentos    

def costo_segmentacion(segmentacion): 
    # segmentacion es una lista de segmentos
#    cantidad_de_segmentos = len(segmentacion)
#    if cantidad_de_segmentos <= 2:
        return sum(costos_segmentos(segmentacion))
#        # suma la aplicación de costo a todos los segmentos
#    else:
#        return sum(costos_segmentos(segmentacion)) + 1e6*cantidad_de_segmentos

# definicón del vecindario de una segmentacíon para definir y recorrer la red de segementaciones
# vecindario devuelve array de vecinos usando extraer y transferir 

def vecinos(segmento, segmentacion):
    sgm = list(segmento)
    vecinos = []
    # extracciones
    for este in sgm:
        sgm2 = list(segmento)
        vecinos.append(este)
        vecinos.extend(extraer(este, sgm2))
    # transferencias
    for este in sgm:
        for otro in segmentacion:
            for ese in otro:
                if (este, ese) in adyacencias:
                    otr = list(otro)
                    # vecinos.extend(extraer(este, list(segmento)))
                    # ya agregado en extracciones
                    vecinos.append(otr.append(este))
    return vecinos    

def vecindario(segmentacion):
    # devuelve array de vecinos
    vecindario = []
    # extracciones
    for segmento in segmentacion:
        sgms = list(segmentacion)
        sgms.remove(segmento) # el resto no considerado de la segmentación
        if len(segmento) == 2: # segmento binario se parte, no se analizan los 2 casos, ya que son el mismo
            este = segmento[0]; ese = segmento[1]
            vecino = [[este], [ese]] + sgms
            vecindario.append(vecino)
        elif len(segmento) > 2: 
            for este in segmento: 
                vecino = [[este]] + extraer(este, segmento) + sgms
                vecindario.append(vecino)
    # transferencias                
    if len(segmentacion) >= 2: # se puede hacer una transferencia
        for i, este in enumerate(segmentacion):
            esa = list(segmentacion) # copia para preservar la original
            esa.remove(este) # elimino de la copia de la segmentacion a este segmento
            for j, ese in enumerate(esa): # busco otro segmento
                aquella = list(esa) # copia de para eliminar a ese
                aquella.remove(ese) # copia de segmentacion sin este ni ese
                if len(este) == 1 and len(ese) == 1 and i < j:
                    pass # si no se repiten cuando este y ese se permuten
                else:
                    for cada in este:
                        transferencia = transferir(cada, este, ese)
                        if transferencia: # se pudo hacer 
                            vecino = transferencia + aquella
                    #        print ('transferí', cada, este, ese)
                            vecindario.append(vecino)
                # fusión de 2 segmentos evitando repeticiones 
                #(cuando alguno es una solo elemento la fusion es considerada en la transferencia)
                if len(este) > 1 and len(ese) > 1 and conectados(este + ese):
                    vecino = [este + ese] + aquella
                    #print ('transferí', cada, este, ese)
                    vecindario.append(vecino) # analizar fusiones
    return vecindario
# devuelve repeticiones

#
# optimización
#

# fin de definiciones


import psycopg2
import operator
import time
import os

import DAO

dao = DAO.DAO()
#dao.db('segmentador:rodatnemges:censo2020:172.26.67.239')
dao.db('halpe:halpe:CPHyV2020:172.26.68.174')

radios = dao.get_radios(_table)

for prov, dpto, frac, radio in radios:
    if (radio and prov == _prov and dpto == _dpto and frac == _frac and radio == _radio): # las del _table
        print
        print ("radio: ")
        print (prov, dpto, frac, radio)
        conteos_mzas = dao.get_conteos_mzas(_table, prov, dpto, frac, radio)
        manzanas = [mza for mza, conteo in conteos_mzas]

        conteos = dao.get_conteos_lados(_table, prov, dpto, frac, radio)
        conteos_lados = [((mza, lado), conteo) for mza, lado, conteo in conteos]
        lados = [(mza, lado) for mza, lado, conteo in conteos]

        costos_adyacencias = [((mza, lado), (mza_ady, lado_ady), costo) for mza, lado, mza_ady, lado_ady, costo 
            in dao.get_costos_adyacencias(_table, prov, dpto, frac, radio)]
        #print (costos_adyacencias)

        adyacencias_mzas_mzas = dao.get_adyacencias_mzas_mzas(_table, prov, dpto, frac, radio)

        adyacencias_mzas_lados = [(mza, (mza_ady, lado_ady)) for mza, mza_ady, lado_ady 
            in dao.get_adyacencias_mzas_lados(_table, prov, dpto, frac, radio)]
    
        adyacencias_lados_mzas= [((mza, lado), mza_ady) for mza, lado, mza_ady 
            in dao.get_adyacencias_lados_mzas(_table, prov, dpto, frac, radio)]

        lados_enfrentados = [((mza, lado), (mza_ady, lado_ady)) for mza, lado, mza_ady, lado_ady 
            in dao.get_adyacencias_lados_enfrentados(_table, prov, dpto, frac, radio)]
#        print ('lados_enfrentados', lados_enfrentados)

        lados_contiguos = [((mza, lado), (mza_ady, lado_ady)) for mza, lado, mza_ady, lado_ady
            in dao.get_adyacencias_lados_contiguos(_table, prov, dpto, frac, radio)]
#       print ('lados_contiguos', lados_contiguos)

        conteos = conteos_mzas
        adyacencias = adyacencias_mzas_mzas


        conteos_excedidos = [(manzana, conteo) for (manzana, conteo) in conteos_mzas
                            if conteo > cantidad_de_viviendas_permitida_para_romper_manzana]
        mzas_excedidas = [mza for mza, conteo in conteos_excedidos]
        
        lados_excedidos = [(mza, lado) for ((mza, lado), conteo) in conteos_lados
                            if conteo > cantidad_de_viviendas_permitida_para_romper_manzana]

        print ('manzanas a partir:', mzas_excedidas)
        print ('lados excedidas:', lados_excedidos)


        componentes = [mza for mza in manzanas if mza not in mzas_excedidas]
        conteos = [(mza, conteo) for (mza, conteo) in conteos if mza not in mzas_excedidas]
        adyacencias = [(mza, mza_ady) for (mza, mza_ady) in adyacencias 
                        if mza not in mzas_excedidas and mza_ady not in mzas_excedidas]
        # se eliminana manzanas excedidas

        componentes.extend([(mza, lado) for (mza, lado) in lados if mza in mzas_excedidas])
        conteos.extend([((mza, lado), conteo) for ((mza, lado), conteo) in conteos_lados
                        if mza in mzas_excedidas])
        adyacencias.extend([((mza, lado), mza_ady) for (mza, lado), mza_ady in adyacencias_lados_mzas
                        if mza in mzas_excedidas and mza_ady not in mzas_excedidas])
        adyacencias.extend([(mza, (mza_ady, lado_ady)) 
                        for mza, (mza_ady, lado_ady) in adyacencias_mzas_lados
                        if mza not in mzas_excedidas and mza_ady in mzas_excedidas])
        adyacencias.extend([((mza, lado), (mza_ady, lado_ady)) 
                        for (mza, lado), (mza_ady, lado_ady) in lados_enfrentados
                        if mza in mzas_excedidas and mza_ady in mzas_excedidas])
        adyacencias.extend([((mza, lado), (mza_ady, lado_ady))
                        for (mza, lado), (mza_ady, lado_ady) in lados_contiguos])
        # se agregan los lados correspondientes a esas manzanas
        #print ((adyacencias))
        #print >> sys.stderr, "componentes"
        #print >> sys.stderr, componentes
#
#        adyacencias.extend((ese, este) for (este, ese) in adyacencias)
#        adyacencias = list(set(adyacencias))

#        print (adyacencias)
        adyacencias = [(este, ese) for (este, ese) in adyacencias if este not in lados_excedidos and ese not in lados_excedidos]
#        print (adyacencias)
#        print (lados_excedidos)
#        print (componentes)
        componentes = list(set(componentes) - set(lados_excedidos))
#        print (componentes)


        # elimina lado con más de cant deseada para aplicarles el otro algoritmo

#---- hasta acá

        if adyacencias:
            start = time.time()
#            print (adyacencias)

            # crea los dictionary
            componentes_en_adyacencias = list(set([cpte for cpte, cpte_ady in adyacencias]))
            todos_los_componentes = list(set(componentes + componentes_en_adyacencias))

            viviendas = dict()
            for cpte in componentes:
                viviendas[cpte] = 0
            for cpte, conteo in conteos:
                viviendas[cpte] = int(conteo)

            componentes_no_en_adyacencias = list(set(todos_los_componentes) - set(componentes_en_adyacencias))
            # print ("no están en cobertura", manzanas_no_en_adyacencias)
            # hay que ponerle nula la lista de adyacencias
            adyacentes = dict()
            for cpte in todos_los_componentes:
                adyacentes[cpte] = list([])
            for cpte, adyacente in adyacencias:
                adyacentes[cpte] = adyacentes[cpte] + [adyacente]
                adyacentes[adyacente] = adyacentes[adyacente] + [cpte]
#            for manzana in sorted(adyacentes.iterkeys()):
#                print (manzana, adyacentes[manzana])

            # optimización

            ##############################
            # soluciones iniciales
            soluciones_iniciales = []
            # iniciando de un extremo de la red de segmentaciones: segmento único igual a todo el radio
            todos_juntos = [componentes]
            soluciones_iniciales.append(todos_juntos)
            # iniciando del otro extremo de la red de segmentaciones: un segmento por manzana
            # TODO: probar un segmento x lado
            todos_separados = [[cpte] for cpte in componentes]
            soluciones_iniciales.append(todos_separados)
            ##############################

            # TODO: cargar el segmento de la segmentación anterior sgm en segmentacio.conteos para el caso de lados

            costo_minimo = float('inf')
            for solucion in soluciones_iniciales:
                # algoritmo greedy
                vecinos = list(vecindario(solucion))
                costo_actual = costo_segmentacion(solucion)
                # costos_vecinos = map(costo_segmentacion, vecinos)
                costos_vecinos = [costo_segmentacion(vecino) for vecino in vecinos]

                if not costos_vecinos:
                    print ('Costos vecinos vacios')
                else:
                  while min(costos_vecinos) < costo_actual: # se puede mejorar 
                      min_id, mejor_costo = min(enumerate(costos_vecinos), key=operator.itemgetter(1))
                      solucion = vecinos[min_id] # greedy
                      # print (mejor_costo)
                      vecinos = list(vecindario(solucion))
                      costo_actual = mejor_costo 
                      # costos_vecinos = map(costo_segmentacion, vecinos)
                      costos_vecinos = [costo_segmentacion(vecino) for vecino in vecinos]
                if costo_actual < costo_minimo:
                    costo_minimo = costo_actual
                    mejor_solucion = solucion
                    
            #muestra warnings
            if componentes_no_en_adyacencias:
                print ("Cuidado: ")
                print
                print ("no están en adyacencias, cobertura con errores, quizás?", componentes_no_en_adyacencias)
                print ("no se les asignó componentes adyacentes y quedaron aisladas")
                print

            # muestra solución
            mejor_solucion.sort(key = seg_id)
            print ("---------")
            print ("mínimo local")
            print ("costo", costo_minimo)
            for s, segmento in enumerate(mejor_solucion):
                segmento.sort(key = cmpt_id)
                print (["segmento", s+1, 
                   "carga", carga(segmento), 
                   "costo", costo(segmento), 
                   "componentes", segmento,
                    "cuantas_manzanas", cuantas_manzanas(segmento)
#                   "adyacencias", adyacencias_componentes(segmento),
#                   "costo_adyacencias", sum([costo_adyacencia(ady) for ady in adyacencias_componentes(segmento) if costo_adyacencia(ady)])
                    ])
#            print ((vecindario(mejor_solucion)))

            print ("deseada: %d, máxima: %d, mínima: %d" % (cantidad_de_viviendas_deseada_por_segmento,
                cantidad_de_viviendas_maxima_deseada_por_segmento, 
                cantidad_de_viviendas_minima_deseada_por_segmento))



            end = time.time()
            print (str(end - start) + " segundos")

            # actualiza los valores de segmento en la tabla de polygons para representar graficamente
            segmentos = {}

            for s, segmento in enumerate(mejor_solucion):
                for cpte in segmento:
                    segmentos[cpte] = s + 1
            
            # por ahora solo junin de los andes buscar la tabla usando una relacion prov, dpto - aglomerado
#------
# update _table = shapes.eAAAAa  (usando lados)
#------
            for cpte in componentes:
               dao.set_componente_segmento(_table, prov, dpto, frac, radio, cpte, segmentos[cpte])
#            raw_input("Press Enter to continue...")
        else:
            print ("sin adyacencias")
#    else:
#        print ("radio Null")

# guarda ejecucion
import os
pwd = os.path.dirname(os.path.realpath(__file__))
#print(pwd)
import socket
host = socket.gethostname()
import getpass
user = getpass.getuser()
user_host = user + '@' + host
comando = " ".join(sys.argv[:])
print('[' + user_host + ']$ python ' + pwd + '/' + comando)
print(":".join(dao.conn_info))
import datetime

dao.set_corrida(comando, user_host, pwd, prov, dpto, frac, radio, datetime.datetime.now())

