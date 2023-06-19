#!/bin/bash

#Check and export assembly. This can be provided via command line or as an environment variable from Jenkins
[ -z "$ASSEMBLY" ] || export ASSEMBLY

SERVERNAME=`hostname -s`
#Go to deployment base directory. A deployment configuration should exist for hostname.
DEPBASE=/opt/intershop/install/new_workspace/$SERVERNAME
if [ ! -d "$DEPBASE" ];then
        echo No deployment configuration found
        exit
fi
cd $DEPBASE
#Check if we should wait. Specified as environment variable.
if [ ! -z $WAIT ];then
        echo Waiting for $WAIT seconds 
        sleep $WAIT
fi
export PUBLISH_STATUS=release

# Stopping eserver1-ase
PID=$(cat /opt/intershop/eserver1/local/log/appserver0.pid)
running=true

sudo service eserver1-ase stop &
while $running
  do
    sleep 30
    if ps -p $PID > /dev/null
      then
        echo "Eserver1 is not stopping, killing $PID"
        sleep 1
        kill -9 $PID
        if $?=0
          then
            echo "$PID killed, eserver1 stopped"
            running=false
          else
            echo "Failed to kill $PID, trying again "
        fi      
      else
        echo "Eserver1 was stopped succesfully"
        running=false
    fi
done

sh gradlew deploy --refresh-dependencies

sudo service eserver1-ase start

