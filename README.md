# set up DB2 database "mydb" in docker.
I have extracted from the repository openshift-workshop-was (https://github.com/IBM/openshift-workshop-was) this readme. Intention is to update and just focus here on the docker image creation for the database.

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

## Create the docker container

The command creates the mydb database, sets the db2inst1 password, and the scripts that were copied to the /var/custom folder on the image automatically run (when using the IBM DB2 11 Docker image. The scripts create the tables and populate the DB. It also stores the DATA on the local VM in the location specified by the -v option. And it maps to the /database directory in the docker container. Add network for myapp app. Add hostname so myapp app can access db.

```
docker run -itd --name myapp-mydb --privileged --network=myappNetwork --hostname=mydb -p 50000:50000 -e DBNAME=mydb -e LICENSE=accept -e DB2INST1_PASSWORD=db2inst1 -v /home/ibmuser/mydb/database:/database  myapp-mydb:latest
```

## Repeat checking of the db2 logs to ensure DB is setup and running. 

### Note: The .sql files and the .sh files run. The .swl files will show errors, but the PopulateDB.sh script should run, and successfull create the table and populate the DB, using the same .sql files. 
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

### Inside the container 
```
su db2inst1
db2 list database directory
db2 connect to mydb
db2 list tables
```

### Check data
```
db2    (get to the DB2 command processor) 

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
