#!/bin/bash

node=node1
ksdir=musicdb
tabledir=performer

if [ $# -gt 0 ]
then
  if [ $# -eq 3 ]
  then
    node=$1
    ksdir=$2
    tabledir=$3
  else
    echo "Usage: sstablelevel.sh [node #] [keyspace name] [table name]"
    exit
  fi
fi

echo ""
cd ~/.ccm/cascor/$node/data/$ksdir/$tabledir*
for i in *Data.db
do
   echo "$i - "`sstablemetadata $i | grep Level`
done
echo ""
