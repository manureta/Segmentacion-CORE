# -*- coding: utf-8 -*-
"""
título: DAO.py
descripción: Objeto Abstacto de Datos
envuelve la comunicación entre el código los datos
usando classes
fecha: 2020-02-26
autor: -h
"""
from operator import *
import psycopg2
import logging
import sys

class DAO:
    # Data Abract Object
    def __init__(self):
        pass

    def db(self, db_string):
        self.conn_info = db_string.split(':')
        if len(self.conn_info) < 3:
            raise Exception('connection string: "' + db_string + '" must be user:pass:db(:server(:port))')

        self.user = self.conn_info[0]
        self.passwd = self.conn_info[1]
        self.dbname = self.conn_info[2]
        self.host = 'localhost'
        self.port = '5432'
        if len(self.conn_info) > 3:
            self.host = self.conn_info[3]
        if len(self.conn_info) > 4:
            self.port = self.conn_info[4]
    
        try:
            self.conn = psycopg2.connect(user=self.user, password=self.passwd,
                dbname=self.dbname, host=self.host, port=self.port)
        except psycopg2.Error as e:
            raise Exception('cannot connect', db_string)
        self.cur = self.conn.cursor()
        return 

    def __str__(self):
        return self.conn_info

    def get_radios(self, region):
        # checkear que region es string y existe como schema, si no raise
        if not isinstance(region, str):
            raise Exception(region + 'debe ser de tipo string')
        sql = ("select distinct prov::integer, dpto::integer, frac::integer, radio::integer"
           " from " + region + ".listado"
           " order by prov::integer, dpto::integer, frac::integer, radio::integer;")
        try:
            self.cur.execute(sql)
            self.radios = self.cur.fetchall()
        except psycopg2.Error as e:
            print ('no puede ejecutar ' + sql, region)
            print (e)
        return self.radios

    def get_listado(self, region):
        sql = 'select * from "' + region + '".listado'
        try:
            self.cur.execute(sql)
            listado = self.cur.fetchall()
            return listado
        except psycopg2.Error as e:
            print ('no puede cargar listado: ' + sql, region)
            print (e)

    def sql_where_pdfr(self, prov, dpto, frac, radio):
        return ("\nwhere prov::integer = " + str(prov)
            + "\n and dpto::integer = " + str(dpto)
            + "\n and frac::integer = " + str(frac)
            + "\n and radio::integer = " + str(radio))

    def get_conteos_mzas(self, region, prov, dpto, frac, radio):
        sql = ('select mza, sum(conteo)::int from "' + region + '".conteos'
            + self.sql_where_pdfr(prov, dpto, frac, radio)
            + '\ngroup by mza;')
        try:
            self.cur.execute(sql)
            conteos = self.cur.fetchall()
            return conteos
        except psycopg2.Error as e:
            print ('no puede cargar conteos: ' + sql, region)
            print (e)

    def get_conteos_lados(self, region, prov, dpto, frac, radio):
        sql = ('select mza, lado, sum(conteo)::int from "' + region + '".conteos'
            + self.sql_where_pdfr(prov, dpto, frac, radio)
            + '\ngroup by mza, lado;')
        try:
            self.cur.execute(sql)
            conteos = self.cur.fetchall()
            return conteos
        except psycopg2.Error as e:
            print ('no puede cargar conteos: ' + sql, region)
            print (e)

    def get_ultimo_lado_mzas(self, region, prov, dpto, frac, radio):
        sql = ('select mza, max(lado) from "' + region + '".conteos'
            + self.sql_where_pdfr(prov, dpto, frac, radio)
            + '\ngroup by mza order by mza;')
        try:
            self.cur.execute(sql)
            conteos = self.cur.fetchall()
            return conteos
        except psycopg2.Error as e:
            print ('no puede cargar ulimo lado: ' + sql, region)
            print (e)



    def get_costos_adyacencias(self, region, prov, dpto, frac, radio):
        sql = ('select substr(mza_i,13,3)::integer, lado_i, substr(mza_j,13,3)::integer, lado_j, indec.costo_adyacencias(arc_tipo, arc_codigo) '
            + '\nfrom "' + region + '".lados_adyacentes\n'
            + self.sql_where_PPDDDLLLFFRR(prov, dpto, frac, radio)
            + "\n and substr(mza_i,13,3)::integer != substr(mza_j,13,3)::integer"
            + "\nunion"
            + "\nselect substr(mza_i,13,3)::integer, 0, substr(mza_j,13,3)::integer, 0, max(indec.costo_adyacencias(arc_tipo, arc_codigo))"
            + '\nfrom "' + region + '".lados_adyacentes\n'
            + self.sql_where_PPDDDLLLFFRR(prov, dpto, frac, radio)
            + "\n and substr(mza_i,13,3)::integer != substr(mza_j,13,3)::integer"
            + "\n group by substr(mza_i,13,3)::integer, substr(mza_j,13,3)::integer"
            + "\nunion"
            + "\nselect substr(mza_i,13,3)::integer, 0, substr(mza_j,13,3)::integer, lado_j, max(indec.costo_adyacencias(arc_tipo, arc_codigo)) "
            + '\nfrom "' + region + '".lados_adyacentes\n'
            + self.sql_where_PPDDDLLLFFRR(prov, dpto, frac, radio)
            + "\n and substr(mza_i,13,3)::integer != substr(mza_j,13,3)::integer"
            + "\n group by substr(mza_i,13,3)::integer, substr(mza_j,13,3)::integer, lado_j"
            + "\nunion"
            + "\nselect substr(mza_i,13,3)::integer, lado_i, substr(mza_j,13,3)::integer, 0, max(indec.costo_adyacencias(arc_tipo, arc_codigo)) "
            + '\nfrom "' + region + '".lados_adyacentes\n'
            + self.sql_where_PPDDDLLLFFRR(prov, dpto, frac, radio)
            + "\n and substr(mza_i,13,3)::integer != substr(mza_j,13,3)::integer"
            + "\n group by substr(mza_i,13,3)::integer, lado_i, substr(mza_j,13,3)::integer"
            )
        try:
            self.cur.execute(sql)
            adyacencias = self.cur.fetchall()
            return adyacencias
        except psycopg2.Error as e:
            print ('no puede cargar costos adyacentes: \n' + sql, region)
            print (e)

    def get_adyacencias_mzas_mzas(self, region, prov, dpto, frac, radio):
        sql = ('select substr(mza_i,13,3)::integer, substr(mza_j,13,3)::integer from "' + region + '".lados_adyacentes'
            + self.sql_where_PPDDDLLLFFRR(prov, dpto, frac, radio)
            + "\n and mza_i != mza_j"
            + "\norder by substr(mza_i,13,3)::integer, substr(mza_j,13,3)::integer;\n")
        try:
            self.cur.execute(sql)
            adyacencias = self.cur.fetchall()
            return adyacencias
        except psycopg2.Error as e:
            print ('no puede cargar adyacentes: \n' + sql, region)
            print (e)

    def get_adyacencias_mzas_lados(self, region, prov, dpto, frac, radio):
        sql = ('select substr(mza_i,13,3)::integer, substr(mza_j,13,3)::integer, lado_j from "' + region + '".lados_adyacentes'
            + self.sql_where_PPDDDLLLFFRR(prov, dpto, frac, radio)
            + "\n and mza_i != mza_j"
            + "\norder by substr(mza_i,13,3)::integer, substr(mza_j,13,3)::integer, lado_j;\n"
            )
        try:
            self.cur.execute(sql)
            adyacencias = self.cur.fetchall()
            return adyacencias
        except psycopg2.Error as e:
            print ('no puede cargar adyacentes: \n' + sql, region)
            print (e)

    def get_adyacencias_lados_mzas(self, region, prov, dpto, frac, radio):
        sql = ('select substr(mza_i,13,3)::integer, lado_i, substr(mza_j,13,3)::integer from "' + region + '".lados_adyacentes'
            + self.sql_where_PPDDDLLLFFRR(prov, dpto, frac, radio)
            + "\n and mza_i != mza_j"
            + "\norder by substr(mza_i,13,3)::integer, lado_i, substr(mza_j,13,3)::integer;\n"
            )
        try:
            self.cur.execute(sql)
            adyacencias = self.cur.fetchall()
            return adyacencias
        except psycopg2.Error as e:
            print ('no puede cargar adyacentes: \n' + sql, region)
            print (e)

    def get_adyacencias_lados_lados(self, region, prov, dpto, frac, radio):
        sql = ('select substr(mza_i,13,3)::integer, lado_i, substr(mza_j,13,3)::integer, lado_j from "' + region + '".lados_adyacentes'
            + self.sql_where_PPDDDLLLFFRR(prov, dpto, frac, radio)
            + "\n and mza_i != mza_j"
            + "\norder by substr(mza_i,13,3)::integer, lado_i, substr(mza_j,13,3)::integer, lado_j;\n"
            )
        try:
            self.cur.execute(sql)
            adyacencias = self.cur.fetchall()
            return adyacencias
        except psycopg2.Error as e:
            print ('no puede cargar adyacentes: \n' + sql, region)
            print (e)

    
    def get_adyacencias_lados_enfrentados(self, region, prov, dpto, frac, radio):
        sql = ('select substr(mza_i,13,3)::integer, lado_i, substr(mza_j,13,3)::integer, lado_j from "' + region + '".lados_adyacentes'
            + self.sql_where_PPDDDLLLFFRR(prov, dpto, frac, radio)
            + "\n and mza_i != mza_j and tipo = 'enfrente'"
            + "\norder by substr(mza_i,13,3)::integer, lado_i, substr(mza_j,13,3)::integer, lado_j;\n"
            )
        try:
            self.cur.execute(sql)
            adyacencias = self.cur.fetchall()
            return adyacencias
        except psycopg2.Error as e:
            print ('no puede cargar adyacentes: \n' + sql, region)
            print (e)


    def get_adyacencias_lados_contiguos(self, region, prov, dpto, frac, radio):
        sql = ('select substr(mza_i,13,3)::integer, lado_i, substr(mza_j,13,3)::integer, lado_j from "' + region + '".lados_adyacentes'
            + self.sql_where_PPDDDLLLFFRR(prov, dpto, frac, radio)
            + "\n and tipo = 'dobla'\n"
            + "\norder by substr(mza_i,13,3)::integer, lado_i, substr(mza_j,13,3)::integer, lado_j;\n"
            )
        try:
            self.cur.execute(sql)
            adyacencias = self.cur.fetchall()
            return adyacencias
        except psycopg2.Error as e:
            print ('no puede cargar adyacentes: \n' + sql, region)
            print (e)


    def sql_where_PPDDDLLLFFRR(self, prov, depto, frac, radio):
        where_mza = ("\nwhere substr(mza_i,1,2)::integer = " + str(prov)
                + "\n and substr(mza_i,3,3)::integer = " + str(depto)
                + "\n and substr(mza_i,9,2)::integer = " + str(frac)
                + "\n and substr(mza_i,11,2)::integer = " + str(radio)
                )
        return where_mza



    def sql_where_PPDDDLLLMMM(self, prov, dpto, frac, radio, cpte, side):
        if type(cpte) is int:
            mza = cpte
        elif type(cpte) is tuple:
            (mza, lado) = cpte
        where_mza = ("\nwhere substr(mza" + side + ",1,2)::integer = " + str(prov)
            + "\n and substr(mza" + side + ",3,3)::integer = " + str(dpto)
            + "\n and substr(mza" + side + ",9,2)::integer = " + str(frac)
            + "\n and substr(mza" + side + ",11,2)::integer = " + str(radio)
            + "\n and substr(mza" + side + ",13,3)::integer = " + str(mza)
            )
        if type(cpte) is tuple:
            where_mza = (where_mza 
            + "\n and lado" + side + "::integer = " + str(lado))
        return where_mza

    def set_componente_segmento(self, region, prov, dpto, frac, radio, cpte, seg):
    #------
    # update table = region.arc  (usando lados)
    #------
         sql_i = ("update " + region + '.arc'
            + " set segi = " + str(seg)
            + self.sql_where_PPDDDLLLMMM(prov, dpto, frac, radio, cpte, 'i')
            + " AND mzai is not null AND mzai != ''"
            + "\n;")
         #print "", sql_i
         self.cur.execute(sql_i)
         sql_d = ("update " + region + '.arc'   
            + " set segd = " + str(seg)
            + self.sql_where_PPDDDLLLMMM(prov, dpto, frac, radio, cpte, 'd')
            + " AND mzad is not null AND mzad != ''"
            + "\n;")
         #print " ", sql_d
         self.cur.execute(sql_d)
         self.conn.commit()

    def set_corrida(self, comando, user_host, pwd, prov, dpto, frac, radio, cuando):
        sql = ("insert into corrida (comando, user_host, pwd, conexion, prov, dpto, frac, radio, cuando) values"
             + " ('" + str(comando)
             + "', '" + str(user_host)
             + "', '" + str(pwd)
             + "', '" + str(":".join(self.conn_info))
             + "', " + str(prov)
             + " , " + str(dpto)
             + " , " + str(frac)
             + " , " + str(radio)
             + " , '" + str(cuando)
             + "')\n;")

        try:
            self.cur.execute(sql)
            self.conn.commit()
        except psycopg2.Error as e:
            print ('no puede cargar datos de corrida: \n' + sql)
            print (e)
            
            
        
 
"""
dao = DAO()
#conn = dao.db()
#conn = dao.db('a')
#conn = dao.db('u:p:d')
dao.db('segmentador:rodatnemges:censo2020:172.26.67.239')
print (dao.conn) # xq no usa __str__ ?
print (dao.cur)

#radios = dao.radios(1)
#radios = dao.radios('1')
radios = dao.radios('e0359')
print (radios)

#listado = dao.get_listado('e0298')
#print (listado)

#adyacencias = dao.get_adyacencias('0365')
#print (adyacencias)

"""

