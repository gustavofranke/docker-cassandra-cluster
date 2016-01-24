#!/bin/bash

docker rm `docker ps -aq`

./one-node-cluster/start-one-node.sh
./same-machine-cluster/start-same-machine.sh
