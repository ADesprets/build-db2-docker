#!/bin/sh +

whoami

echo "set password for db2inst1 to never expire";
passwd -x 9999 db2inst1
sudo -i -u db2inst1 bash -c '/opt/ibm/db2/V11.5/bin/db2 UPDATE DBM CFG USING SPM_NAME mydb_spm'
sudo -i -u db2inst1 bash -c '/opt/ibm/db2/V11.5/bin/db2 CONNECT TO mydb'
sudo -i -u db2inst1 bash -c '/opt/ibm/db2/V11.5/bin/db2 CONNECT TO mydb && /opt/ibm/db2/V11.5/bin/db2 -stvf /var/custom/sql/createTables.sql -z create-tables.log'
sudo -i -u db2inst1 bash -c '/opt/ibm/db2/V11.5/bin/db2 CONNECT TO mydb && /opt/ibm/db2/V11.5/bin/db2 -stvf /var/custom/sql/mydb-data.sql -z populate-tables.log'
