/*
----------------------------
0.  sqlite3-dbf $1 > ${1}.sql (pasa a sqlite texto commands)

1.  convertir a utf8
    iconv -f latin1 -t utf8 ${1}.sql ${1}-utf8.sql

2.  ahora vi, (luego sed -i)
    :%s/${1}/${1}.listado/gc
    :%s/TEXT/char/gc

3.  resolver comillas simples entre campos
    /'\([^,]*\)'\([^,]*\)'/\1\2/g encuentra una sola comilla y la elimina
    
*/

-- 4. agregar campo id

alter table "0026".listado add column id serial;


-- do it!
select indec.segmentar_equilibrado('0026', 40);



