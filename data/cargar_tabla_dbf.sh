echo pasar dbf a sqlite && \
echo "sqlite3-dbf ${1}.dbf > ${1}.sql 2> /tmp/${1}.log" && \
echo "sqlite3-dbf ${1}.dbf > ${1}.sql 2> /tmp/${1}.log" > /tmp/${1}.log && \
sqlite3-dbf ${1}.dbf > ${1}.sql 2>> /tmp/${1}.log && \
echo poner tabla en schema "(hay que crear schema)" && \
echo "sed -i 's/${1}/${1}.listado/g' ${1}.sql 2> /tmp/${1}.log" && \
echo "sed -i 's/${1}/${1}.listado/g' ${1}.sql 2> /tmp/${1}.log" >> /tmp/${1}.log && \
sed -i 's/${1}/${1}.listado/g' ${1}.sql 2>> /tmp/${1}.log && \
echo cambiar cmnd sqlite a psql &&
echo "sed -i 's/TEXT/char/g' ${1}.sql 2> /tmp/${1}.log" && \
echo "sed -i 's/TEXT/char/g' ${1}.sql 2> /tmp/${1}.log" >> /tmp/${1}.log && \
sed -i 's/TEXT/char/g' ${1}.sql 2>> /tmp/${1}.log && \
echo eliminar comillas simple dentro campos"'" && \
echo "sed -i -e \"s/\([^,]\)''/\1'/g\" ${1}.sql 2> /tmp/${1}.log" && \
echo "sed -i -e \"s/\([^,]\)''/\1'/g\" ${1}.sql 2> /tmp/${1}.log" >> /tmp/${1}.log && \
sed -i -e "s/\([^,]\)''/\1'/g" ${1}.sql >> /tmp/${1}.log && \
echo pasar encoding && \
echo "iconv -f latin1 -t utf8 ${1}.sql > /tmp/${1}.sql 2>> /tmp/${1}.log" && \
echo "iconv -f latin1 -t utf8 ${1}.sql > /tmp/${1}.sql 2>> /tmp/${1}.log" >> /tmp/${1}.log && \
iconv -f latin1 -t utf8 ${1}.sql > /tmp/${1}.sql 2>> /tmp/${1}.log && \
echo "mv /tmp/${1}.sql ${1}.sql 2>> /tmp/${1}.log" && \
echo "mv /tmp/${1}.sql ${1}.sql 2>> /tmp/${1}.log" >> /tmp/${1}.log && \
mv /tmp/${1}.sql ${1}.sql 2>> /tmp/${1}.log && \
echo cargar en DB && \
echo "psql censo2020 -h 172.26.67.239 -U halpe -c 'create schema if not exists \"${1}\"' 2>> /tmp/${1}.log" >> /tmp/${1}.log && \
echo "psql censo2020 -h 172.26.67.239 -U halpe -c 'create schema if not exists \"${1}\"' 2>> /tmp/${1}.log" && \
psql censo2020 -h 172.26.67.239 -U halpe -c "create schema if not exists \"${1}\"" 2>> /tmp/${1}.log && \
echo "psql censo2020 -h 172.26.67.239 -U halpe -f ${1}.sql 2>> /tmp/${1}.log" >> /tmp/${1}.log && \
echo "psql censo2020 -h 172.26.67.239 -U halpe -f ${1}.sql 2>> /tmp/${1}.log" && \
psql censo2020 -h 172.26.67.239 -U halpe -f ${1}.sql > /dev/null 2>> /tmp/${1}.log && \
echo "done!"

