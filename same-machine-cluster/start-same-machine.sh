#!/bin/bash

docker run -v /data/node2:/var/lib/cassandra -d -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' one_node)" cassandra:latest
