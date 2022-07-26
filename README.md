# backup-borg-docker-elasticsearch
A dockerized borg container to create backups of docker volumes applied to elasticsearch snapshots

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

## Restore the backup



## How it works



When running the borg container, it will point to the location of *databack* volume in */usr/share/elasticsearch/data* as can be seen in the file *params.sh*


