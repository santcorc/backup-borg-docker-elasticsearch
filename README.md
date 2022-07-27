# backup-borg-docker-elasticsearch
A dockerized borg container to create backups of docker volumes applied to elasticsearch snapshots.

## Usage

For run this component in your elasticsearch environment, it is needed to add in the *docker-compose.yml* file a new volume for the backup in each one of the elasticsearch nodes. An example of the elasticsearch node would be the following:

```
 es01:
    image: elasticsearch:${ELASTICSEARCH_VERSION}
    container_name: es01
    volumes:
      - esdata01:/usr/share/elasticsearch/data
      - databack:/usr/share/elasticsearch/backup
    ports:
      - ${ELASTICSEARCH_PORT}:9200
    environment:
      - node.name=es01
      - cluster.name=${CLUSTER_NAME}
      - cluster.initial_master_nodes=es01
      - discovery.seed_hosts=es02,es03
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms2g -Xmx2g"
      - path.repo=/usr/share/elasticsearch/backup
       #- node.roles=master SOLO DISPONIBLE A PARTIR DE LA VERSION 7.9
    ulimits:
      memlock:
        soft: -1
        hard: -1
```

Where *esdata01* is the previous volume where the data is persisted and *databack* is the volume created to backup. 

The next step is to create a borg repositorie in the machine where the backup is wanted to be made. This is done with the command 

```
borg init --encryption=none /Location
```

With the repositorie created, it is needed to change the permissions of the folder where the snapshots are created (in this case, the folder named *backup*) with the command *chown*

```
docker exec -it es01 /bin/bash

chown elasticsearch /backup. 
```

And create a elasticsearch repository where the snapshots will be stored:

```
curl --location --request PUT 'IPADDRESSELASTICSEARCHCONTAINER:9200/_snapshot/repository' \
--header 'Content-Type: application/json' \
--data-raw '{
  "type": "fs",
  "settings": {
    "location": "/usr/share/elasticsearch/backup/repository"
  }
}'
```

Finally, to make possible the automatic connection between the server where the elasticsearch environment is running and the remote machine where the backup is being done, it is needed to include the public key of the first server in the *authorized_keys* folder of the backup server. In case the public key is not created, it can be done with 

```
ssh-keygen
```

And then copying the file *id_rsa.pub* it into */home/USER/.ssh/authorized_keys*

Before running the script, it is needed to build the image located in the Dockerfile with 

```
sudo docker build -t ubuntussh .
```

Following the previous steps, the file *scriptC.sh* can be run and the elasticsearch snaphshots will be stored correctly.

## Automate backup with cron

When working with backups, it is interesting to automatize them in order to ensure, in case of fault of the system, have an updated copy of it. 

In order to do that, cron is a good tool to execute periodically things, in this case the script. 

To access it, execute the command

```
crontab -e
```

And at the end of the file add the following:

```
1 2 * * * /home/USER/LOCATIONOFSCRIPT/scriptC.sh
```

This will execute the *scriptC.sh* once a day at 02:01 AM. To change the hour of execution of the script visit the website *https://crontab.guru/* 

## Restore the backup

Backups are nothing if they cannot be restored. In this case, the restoration must be done in two steps. 

First, extract the borg backup of the volume. To do that it is only needed to execute the command:

```
borg extract ./NAMEOFREPOSITORIE::NAMEOFBACKUPWANTED
```

Once it is extracted, it is needed to load the volume into the new docker container. To do that, run it with 

```
docker run --rm --volumes-from es01 -v $(pwd):/backup ubuntu bash -c "cd /usr && tar xvf /backup/backup.tar --strip 1"
```

Once it is running, the final step to restore the elasticsearch database is creating a snapshot with the same name than the one located in the previous machine with (IMPORTANT, IT WILL NOT DELETE THE SNAPSHOT RESTORED) and restore it with 

```
curl --location --request PUT 'IPADDRESS:9200/_snapshot/repository/NAMEOFSNAPSHOT' 
```