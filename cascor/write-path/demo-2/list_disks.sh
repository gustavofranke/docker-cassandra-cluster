#!/bin/bash

ksdir=musicdb
tabledir=performer

if [ $# -gt 0 ]
then
  if [ $# -eq 2 ]
  then
    ksdir=$1
    tabledir=$2
  else
    echo "Usage: list_disks.sh [keyspace name] [table name]"
    exit
  fi
fi

echo ""
echo "/mnt/disk1:"
find /mnt/disk1/$ksdir/$tabledir* -maxdepth 1 -name '*-Data.db' -exec ls -lh {} \;

echo ""
echo "/mnt/disk2:"
find /mnt/disk2/$ksdir/$tabledir* -maxdepth 1 -name '*-Data.db' -exec ls -lh {} \;

echo ""
echo "/mnt/disk3:"
find /mnt/disk3/$ksdir/$tabledir* -maxdepth 1 -name '*-Data.db' -exec ls -lh {} \;

echo ""
