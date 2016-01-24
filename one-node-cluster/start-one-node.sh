#!/bin/bash

docker run --name one_node -v /data/node1:/var/lib/cassandra -d cassandra:latest
