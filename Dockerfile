FROM ibmcom/db2:11.5.5.0
RUN mkdir /var/custom
RUN mkdir /var/sql
COPY createOrderDB.sql /var/sql
COPY orderdb-data.sql /var/sql
COPY populateDB.sh /var/custom
RUN chmod a+x /var/custom/populateDB.sh

