#!/bin/bash

curl --location --request PUT 'localhost:9200/_snapshot/repository/snapshot1'

docker run --rm --name=ubuntuborg -v /home/USER/.ssh/id_rsa/:/root/.ssh/id_rsa:ro -v elasticsearch-deferred_databack:/usr/share/elasticsearch/backup -v cacheBorg:/root/.cache/borg ubuntussh

curl --location --request DELETE 'localhost:9200/_snapshot/repository/snapshot1'

