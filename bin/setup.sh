#!/bin/bash
set -e

SETUP_PATH=${1:-"/opt/ecotruck"}
cd $SETUP_PATH

# "Cache user and pass for bitbucket.org"
echo "=========================================="
[ ! -f "~/.netrc" ] && touch ~/.netrc
domain_count=$(grep 'bitbucket.org' ~/.netrc | wc -l)
if [ "$domain_count" = "0" ]; then
	echo "Cache user and pass for bitbucket.org"
	if [ "$BITBUCKET_USER" = "" ] || [ "$BITBUCKET_PASS" = "" ]; then
		echo -e "Require environment variable:\n  BITBUCKET_USER\n  BITBUCKET_PASS"
		exit 1
	fi
	echo -e "machine bitbucket.org\n  login $BITBUCKET_USER\n  password $BITBUCKET_PASS" >> ~/.netrc
fi

echo "Checkout development repository................................"
[ ! -d "$SETUP_PATH/.setup_process" ] && mkdir "$SETUP_PATH/.setup_process"

if [ ! -d "$SETUP_PATH/ecotruck_development" ]; then
    git clone https://bitbucket.org/ecotruck/ecotruck_development.git
fi

cp $SETUP_PATH/ecotruck_development/local-hosts $SETUP_PATH/local-hosts
HOST_EXISTED=$(grep 'END-ECOHOST' /etc/hosts | wc -l)
if [ "$HOST_EXISTED" = "0" ]; then
	CHOSTNAME=`cat /etc/hostname`
	CIP=`cat /etc/hosts | grep $CHOSTNAME | awk '{print $1}'`
	cat $SETUP_PATH/local-hosts | sed 's/{IP}/127.0.0.1/g' >> /etc/hosts
	cat $SETUP_PATH/local-hosts | sed "s/{IP}/$CIP/g" >> $SETUP_PATH/local_hosts_$CHOSTNAME
fi

# initialize code
$SETUP_PATH/ecotruck_development/scripts/setup_code.sh

# initialize database
[ ! -f "$SETUP_PATH/.setup_process/db.initialized" ] && rm -rf $SETUP_PATH/mysqldata
if [ ! -d "$SETUP_PATH/mysqldata" ]; then
	echo "Clean mysql database"
	mkdir -p "$SETUP_PATH/mysqldata" && chown mysql:mysql $SETUP_PATH/mysqldata
	echo "Start mysql"
	mysqld --initialize-insecure && mysqld --daemonize && sleep 1
	mysql <<< "UPDATE mysql.user SET host='%' WHERE user='root';"	# allow access from all host

	echo "Start rabbitmq"
	/usr/sbin/rabbitmq-server -detached

	# stop services on exit
	trap "kill `cat /run/mysqld/mysqld.pid`; rabbitmqctl stop; exit 0;" EXIT

	echo "DB migrating..."
	$SETUP_PATH/ecotruck_development/scripts/setup_db_migration.sh
	touch "$SETUP_PATH/.setup_process/db.initialized"
else
	echo "Start mysql"
	mysqld --daemonize && sleep 1
	mysql <<< "UPDATE mysql.user SET host='%' WHERE user='root';"	# allow access from all host

	echo "Start rabbitmq"
	/usr/sbin/rabbitmq-server -detached

	# stop services on exit
	trap "kill `cat /run/mysqld/mysqld.pid`; rabbitmqctl stop; exit 0;" EXIT

	echo "DB migrating..."
	$SETUP_PATH/ecotruck_development/scripts/setup_db_migration.sh
fi

touch "$SETUP_PATH/.setup_process/full.done"