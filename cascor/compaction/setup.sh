#!/bin/bash

# Dependencies
#  Check if CCM is installed
#  Remove any running Cassandra instances
#  Remove defined CCM clusters
#  Extract the Cassandra tarball to the expected location
#  Create and start CCM cluster 
#  Populate cluster with musicdb (from intro-cql-dm module)

CASSANDRA_VERSION="2.1.2"
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

  # Remove link to CCM node1
  rm -f ~/node1

  # Remove data directories from additional disks
  rm -rf /mnt/disk*/*

  echo "  Installing Cassandra $CASSANDRA_VERSION..."

  #  Extract the Cassandra tarball to the expected location
  rm -rf ~/Downloads/apache-cassandra*/
  rm -rf ~/.downloads/apache-cassandra*/
  rm -rf ~/apache-cassandra*/
  rm -rf ~/cassandra
  tar xzf ~/Downloads/apache-cassandra-$CASSANDRA_VERSION-bin.tar.gz -C ~/
  ln -s ~/apache-cassandra-$CASSANDRA_VERSION/ ~/cassandra

  #  Starting the installed Cassandra node and populating with musicdb
  sleep 5
  /home/student/cassandra/bin/cassandra > /var/log/cascor.log
  cd ~/cascor/tools/exercise-2
  while [ `cqlsh -f musicdb.cql 2>&1 | grep "Connection error" | wc -l` == "1" ]
  do
     sleep 5
  done
  pkill java
  while [ `ps -ef | grep java | grep cassandra | wc -l` != "0" ]
  do
     sleep 1
  done

  #  Create and populate 3 node Cassandra cluster with musicdb
  ccm create cascor -v $CASSANDRA_VERSION -n 3 --vnodes >/dev/null
  ccm updateconf "num_tokens: 3" >/dev/null
  ccm start

  ln -s ~/.ccm/cascor/node1 ~/node1

  echo "  Populating musicdb keyspace..."

  #  Populate cluster with musicdb (from tools module)
  cd ~/cascor/intro-dm-cql/exercise-4
  cqlsh -e "CREATE KEYSPACE musicdb with REPLICATION = {'class': 'SimpleStrategy','replication_factor':3};"
  ccm node1 cqlsh -f musicdb.cql
  sstableloader /opt/cassandra/data/data/musicdb/album-3f108480c28a11e4bb11398ff2ec44cc -d 127.0.0.1,127.0.0.2,127.0.0.3 --no-progress > /dev/null
  sstableloader /opt/cassandra/data/data/musicdb/albums_by_genre-3f410a60c28a11e4bb11398ff2ec44cc -d 127.0.0.1,127.0.0.2,127.0.0.3 --no-progress > /dev/null
  sstableloader /opt/cassandra/data/data/musicdb/albums_by_performer-3f2c49e0c28a11e4bb11398ff2ec44cc -d 127.0.0.1,127.0.0.2,127.0.0.3 --no-progress > /dev/null
  sstableloader /opt/cassandra/data/data/musicdb/albums_by_track-3f65d070c28a11e4bb11398ff2ec44cc -d 127.0.0.1,127.0.0.2,127.0.0.3 --no-progress > /dev/null
  sstableloader /opt/cassandra/data/data/musicdb/performer-3ee92660c28a11e4bb11398ff2ec44cc -d 127.0.0.1,127.0.0.2,127.0.0.3 --no-progress > /dev/null
  sstableloader /opt/cassandra/data/data/musicdb/performers_by_style-3efd2390c28a11e4bb11398ff2ec44cc -d 127.0.0.1,127.0.0.2,127.0.0.3 --no-progress > /dev/null
  sstableloader /opt/cassandra/data/data/musicdb/tracks_by_album-3f84ca20c28a11e4bb11398ff2ec44cc -d 127.0.0.1,127.0.0.2,127.0.0.3 --no-progress > /dev/null
  ccm flush

  echo ""
  echo "  Setup complete!"
  echo ""

fi
