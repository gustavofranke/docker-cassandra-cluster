#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: musicdb-workload.sh <number of clients>"
  exit 0
fi

if [ `ccm status | grep "node1: UP" | wc -l` -ne 1 ]; then
  echo "Cassandra cluster not up"
  exit 0
fi

while [ 1 ]; do
  ccm flush
  while [ `jobs -rp | wc -l` -lt $1 ]; do
    ./musicdb-workload.py &
    sleep 2
  done
  sleep 4
done
