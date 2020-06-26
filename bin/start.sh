#!/bin/bash
set -e

SETUP_PATH=${1:-"/opt/ecotruck"}
cd $SETUP_PATH

# check setup process is done 
if [ ! -f "$SETUP_PATH/.setup_process/full.done" ]; then
	echo "Docker have no fully setup_process. It cannot start"
	exit 1
fi
HOST_EXISTED=$(grep 'END-ECOHOST' /etc/hosts | wc -l)
if [ "$HOST_EXISTED" = "0" ]; then
	CHOSTNAME=`cat /etc/hostname`
	CIP=`cat /etc/hosts | grep $CHOSTNAME | awk '{print $1}'`
	cat $SETUP_PATH/local-hosts | sed 's/{IP}/127.0.0.1/g' >> /etc/hosts
	cat $SETUP_PATH/local-hosts | sed "s/{IP}/$CIP/g" >> $SETUP_PATH/local_hosts_$CHOSTNAME
fi

# start supervisor process
supervisord -c /opt/supervisor/supervisord.conf
