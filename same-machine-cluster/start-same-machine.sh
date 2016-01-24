#!/bin/bash

docker run -d -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' one_node)" cassandra:latest
