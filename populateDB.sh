#!/bin/sh +

whoami

echo "set password for db2inst1 to never expire"
passwd -x 9999 db2inst1
sudo -i -u db2inst1 bash -c '/opt/ibm/db2/V11.5/bin/db2 CONNECT TO orderdb && /opt/ibm/db2/V11.5/bin/db2 -stvf /var/sql/createOrderDB.sql -z create.log'
sudo -i -u db2inst1 bash -c '/opt/ibm/db2/V11.5/bin/db2 CONNECT TO orderdb && /opt/ibm/db2/V11.5/bin/db2 -stvf /var/sql/orderdb-data.sql -z populate.log'
#/opt/ibm/db2/V11.5/bin/db2 -stvf createOrderDB.sql -z create.log
#/opt/ibm/db2/V11.5/bin/db2 -svft orderdb-data.sql -z populate.log
