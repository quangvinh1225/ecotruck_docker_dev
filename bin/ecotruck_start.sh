#!/bin/bash
set -e

# add eco hosts to file /etc/hosts 
if [ ! -f "/opt/ecotruck_development/local-hosts" ]; then
	echo "Local domains file is not exist. Make sure your map volumn development correctly."
	exit 1
fi
HOST_EXISTED=$(grep 'END-ECOHOST' /etc/hosts | wc -l)
if [ "$HOST_EXISTED" = "0" ]; then
	cat /opt/ecotruck_development/local-hosts | sed 's/{IP}/127.0.0.1/g' >> /etc/hosts
fi

# "Cache user and pass for bitbucket.org"
if [ "$BITBUCKET_USER" != "" ] && [ "$BITBUCKET_PASS" != "" ]; then
	[ ! -f "~/.netrc" ] && touch ~/.netrc
	domain_count=$(grep 'bitbucket.org' ~/.netrc | wc -l)
	if [ "$domain_count" = "0" ]; then
		echo -e "machine bitbucket.org\n  login $BITBUCKET_USER\n  password $BITBUCKET_PASS" >> ~/.netrc
	fi
fi


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
	if [ ! -d "/opt/ecotruck_development/code/$project" ]; then
		echo "Code base is missing $project"
		exit 1
	fi
done

# start supervisor process
supervisord -c /opt/supervisor/supervisord.conf
