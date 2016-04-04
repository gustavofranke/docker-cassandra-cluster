#!/bin/bash

# Dependencies
#  Check if CCM is installed
#  Remove any running Cassandra instances
#  Remove defined CCM clusters
#  Remove extracted Cassandra directories
#  Remove Cassandra tarballs

#  Check if CCM is installed
if [ `ccm | grep "command not found" | wc -l` != "0" ]
then
  echo "Error: CCM is not installed."
  exit 0
fi

echo ""
echo "Warning!! This script will reset the VM and permanently remove any additional files that may have been created. "

read -p "Are you sure you want to continue? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then

  echo "  Remove existing Cassandra clusters..."

  #  Remove any running Cassandra instances
  if [ `ccm status | grep "No currently active cluster" | wc -l` != "1" ]
  then
    ccm stop
  fi
  pkill java

  #  Remove defined CCM clusters
  while [ `ccm list | wc -l` != "0" ]
  do
    cluster_name=`ccm list | head -1 | tr -d '* '`
    ccm switch $cluster_name
    ccm remove
  done

  #  Remove extracted Cassandra directories
  rm -rf ~/Downloads/apache-cassandra*/
  rm -rf ~/Downloads/dsc-cassandra*/
  rm -rf ~/apache-cassandra*/
  rm -rf ~/dsc-cassandra*/
  rm -rf ~/cassandra

  # Remove link to CCM node1
  rm -f ~/node1

  # Remove data directories from additional disks
  rm -rf /mnt/disk*/*

  echo ""
  echo "Setup complete!"
  echo ""
fi
