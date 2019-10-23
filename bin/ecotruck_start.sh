#!/bin/bash
set -e

# add some /etc/hosts 
# TODO how to check hosts is existed
cat /opt/etc/hosts | sed 's/{IP}/127.0.0.1/g' >> /etc/hosts

# make sure all code base is existed
projects="
api.center
api.id
api.mc
api.vc
flower
logic.center
logic.id
logic.mc
logic.vc
repo.accounting
repo.am
repo.analytics
repo.core
repo.doc
repo-location
repo.notification
repo.price
repo-tracking
"

for project in $projects
do
	if [ ! -d "/opt/code/$project" ]; then
		echo "Code base is missing $project"
		exit 1
	fi
done

# print hosts
echo "================================================="
echo "====Please add to file hosts of your machine====="
CONT_IP=`grep "$HOSTNAME" /etc/hosts|awk 'END{print $1}'`
cat /opt/etc/hosts | sed s/{IP}/$CONT_IP/g
echo "================================================="
echo "================================================="

# start supervisor process
supervisord -c /opt/supervisor/supervisord.conf
