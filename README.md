# set up DB2 database "mydb" in docker.
I have extracted from the repository openshift-workshop-was (https://github.com/IBM/openshift-workshop-was) this readme. Intention is to update and just focus here on the docker image creation for the database.

I have made the following changes:
* Updated the version of DB2 to include the log4J correction (using the DB2 11.5.7.0 version).
* Added this line to make sure the the SPM name is not the same as the database:  `db2 update dbm cfg using SPM_NAME mydb_spm`
* Changed the script that it used to populate the Database (to avoid execute non-executable file).


In the DB2 image there is the following code:

```
# If the /var/custom directory exists, run all scripts there. It is for products that build on top of our base image
if [[ -d /var/custom ]]; then
 echo "(*) Running user-provided scripts ... "
 for script in `ls /var/custom`; do
 echo "(*) Running $script ..."
 /var/custom/$script
 done
fi
```

So it is important to not add non executables in the /var/custom/ because they will be run.


## Clone the workshop git repo
```
git clone git@github.com:ADesprets/build-db2-docker.git
```

## Change to the db2-docker directory (where you cloned this repository)
```
cd ~/build-db2-docker
```

## Build the database image 

Using the Dockerfile in the current directory. It copies all of the scripts that run when the docker run command executes.

```
docker build . -t myapp-mydb
```

## Create the docker network
If you have not done this already create the network in order to allow communication between several containers.
```
docker network create myappNetwork
```

## Create the docker container

The command creates the mydb database, sets the db2inst1 password, and the scripts that were copied to the /var/custom folder on the image automatically run (when using the IBM DB2 11 Docker image. The scripts create the tables and populate the DB. It also stores the DATA on the local VM in the location specified by the -v option. And it maps to the /database directory in the docker container. Add network for myapp app. Add hostname so myapp app can access db.

```
docker run -itd --name myapp-mydb --privileged=true --network=myappNetwork --hostname=mydb -p 50000:50000 -e DBNAME=mydb -e LICENSE=accept -e DB2INST1_PASSWORD=db2inst1 -v /home/desprets/mydb/database:/database myapp-mydb:latest
```

## Check the container logs to ensure DB is setup and running. 

```
docker logs myapp-mydb -f
```

### FYI: The docker run command invokes the populateDB.sh inside of the container
You should see the following commande being executed in the log.
 
```
echo "set password for db2inst1 so it never expires"
passwd -x 9999 db2inst1
```
 
## Start and stop the db2 container as needed 

### Start DB2
```
docker start myapp-mydb
```

### Stop DB2
```
docker stop myapp-mydb
```

## Inside the docker container, commands to verify all is OK 
```
docker exec -it myapp-mydb /bin/sh
```
or 
docker exec -ti mydb2 bash -c "su - ${DB2INSTANCE}" where ${DB2INSTANCE} is either db2inst1 or the name chosen via the DB2INSTANCE variable.


### Inside the container 
```
su - db2inst1
db2 list database directory
db2 connect to mydb
db2 list tables
```

### Check data
```
db2 (get to the DB2 command processor) 

select * product
quit
```

### Check the /database directory at the root of the filesystem. 

The Data folder should have the database content. 
```
cd /database
```

## Start and stop the db2 container as needed 

### Start DB2
```
docker start myapp-mydb
```

### Stop DB2
```
docker stop myapp-mydb
```

## Additional useful commands in DB2

Get the configuration of DB2: `db2 get database manager configuration`

To change a configuration: `db2 update dbm cfg using INSTANCE_MEMORY AUTOMATIC`

See what options are available: `db2 ? options`

Check the version of DB2: `db2licm -l`

Get the instances: `db2ilist`

Check the status and ow long it was started: `db2pd -`

Catalog a databae if problem: `db2 catalog database mydb on /database/data/mydb`

To see the advanced configuration, you can check the url: https://hub.docker.com/r/ibmcom/db2

## License terms
https://www-03.ibm.com/software/sla/sladb.nsf/displaylis/8F5B48B9F5DF2BD1852586FC0062FBF0?OpenDocument