# set up DB2 database "mydb" in docker.
I have extracted from the repository openshift-workshop-was (https://github.com/IBM/openshift-workshop-was) this readme. Intention is to update and just focus here on the docker image creation for the database.

I have updated the version of DB2 to include the log4J correction.
I added this line to make sure the the SPM name is not the same as the database:  db2 update dbm cfg using SPM_NAME mydb_spm
I also changed the script that it used to populate the Database.
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

## Repeat checking of the db2 logs to ensure DB is setup and running. 

### Note: The .sql files and the .sh files run. The .swl files will show errors, but the PopulateDB.sh script should run, and successful create the table and populate the DB, using the same .sql files. 
```
docker logs myapp-mydb
```

### FYI: The docker run command invokes the populateDB.sh inside of the container
I have added the following commands to set the db2inst1 user password to never expire. Run docker logs myapp-mydb command to see the output that it was successful. 
```
echo "set password for db2inst1 to never expire"
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

db2 catalog database mydb on /database/data/mydb

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

db2 get database manager configuration

To change a configuration
db2 update dbm cfg using INSTANCE_MEMORY AUTOMATIC

db2 ? options

db2licm -l

db2ilist

db2pd -

To see the advanced configuration, you can check the url: https://hub.docker.com/r/ibmcom/db2

## License terms
https://www-03.ibm.com/software/sla/sladb.nsf/displaylis/8F5B48B9F5DF2BD1852586FC0062FBF0?OpenDocument