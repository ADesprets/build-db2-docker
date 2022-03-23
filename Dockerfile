FROM ibmcom/db2:11.5.7.0
RUN mkdir /var/custom
RUN mkdir /var/custom/sql
COPY createTables.sql /var/custom/sql/.
COPY mydb-data.sql /var/custom/sql/.
COPY populateDB.sh /var/custom/.
RUN chmod a+x /var/custom/populateDB.sh
