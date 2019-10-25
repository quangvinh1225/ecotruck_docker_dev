#!/bin/bash
set -e

BASEPATH="/opt/development"
CODEPATH="$BASEPATH/code"
SETUPTRACKING="$BASEPATH/.setup_process"

echo "=========================================="
echo "Cache user and pass for bitbucket.org"
if [ "$BITBUCKET_USER" = "" ] || [ "$BITBUCKET_PASS" = "" ]; then
	echo -e "Require environment variable:\n  BITBUCKET_USER\n  BITBUCKET_PASS"
	exit
fi
[ ! -f "~/.netrc" ] && touch ~/.netrc
domain_count=$(grep 'bitbucket.org' ~/.netrc | wc -l)
if [ "$domain_count" = "0" ]; then
	echo -e "machine bitbucket.org\n  login $BITBUCKET_USER\n  password $BITBUCKET_PASS" >> ~/.netrc
fi


# create code dir
[ ! -d "$CODEPATH" ] && mkdir $CODEPATH
[ ! -d "$SETUPTRACKING" ] && mkdir $SETUPTRACKING

### Checkout all codebase suite for docker run
echo "=========================================="
echo "Checking out repositories from bitbucket.org"
projects="
id
web.mc
web.vc
web.ic
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
cd $CODEPATH
for project in $projects
do
	echo "Checking out $project"
	[ ! -f "$SETUPTRACKING/$project.git" ] && rm -rf $CODEPATH/$project
	if [ ! -d "$CODEPATH/$project" ]; then
		# git clone git@bitbucket.org:ecotruck/$project.git
		git clone https://bitbucket.org/ecotruck/$project.git
		touch $SETUPTRACKING/$project.git
	fi
done

### Create virtual env for python projects
echo "=========================================="
echo "Create virtual env for python projects"
python_projects="
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
for project in $python_projects
do
	echo "Create virtual environment for $project"
	if [ -d "$CODEPATH/$project" ]; then
		[ ! -f "$SETUPTRACKING/$project.installed" ] && rm -rf $CODEPATH/$project/venv
		if [ ! -d "$CODEPATH/$project/venv" ]; then
			python3 -m venv "$CODEPATH/$project/venv"
			source $CODEPATH/$project/venv/bin/activate
			$CODEPATH/$project/venv/bin/pip3 install wheel
			$CODEPATH/$project/venv/bin/pip3 install -r "$CODEPATH/$project/requirements.txt"
			deactivate
			touch $SETUPTRACKING/$project.installed
		fi
	else
		echo "Code base is not existed: $project"
	fi
done

# dependency of yii2 php projects
echo "=========================================="
echo "Process dependencies of yii2 php projects - id"
cd "$CODEPATH/id"
[ ! -f "$SETUPTRACKING/id.installed" ] && rm -rf $CODEPATH/id/vendor
if [ ! -d "vendor" ]; then
	chmod -R o+w runtime/
	chmod -R o+w web/assets/
	composer install
	touch $SETUPTRACKING/id.installed
fi

echo "=========================================="
echo "Copying setting files"
cp -rn $BASEPATH/settings/default/* $CODEPATH/  # copy if not existed
cp -r $BASEPATH/settings/local/* $CODEPATH/  # copy and override

### build angular app
export NODE_OPTIONS=--max_old_space_size=8192 
echo "=========================================="
echo "Process dependencies angular project - web-ic"
cd "$CODEPATH/web.ic"
[ ! -f "$SETUPTRACKING/web.ic.installed" ] && rm -rf $CODEPATH/web.ic/dist
if [ ! -d "dist" ]; then
	npm install
	npm run-script ng build -- --prod -e=local
	touch $SETUPTRACKING/web.ic.installed
fi

echo "=========================================="
echo "Process dependencies angular project - web-mc"
cd "$CODEPATH/web.mc"
[ ! -f "$SETUPTRACKING/web.mc.installed" ] && rm -rf $CODEPATH/web.mc/dist
if [ ! -d "dist" ]; then
	npm install
	npm run-script ng build -- --prod -e=local
	touch $SETUPTRACKING/web.mc.installed
fi

echo "=========================================="
echo "Process dependencies angular project - web-vc"
cd "$CODEPATH/web.vc"
[ ! -f "$SETUPTRACKING/web.vc.installed" ] && rm -rf $CODEPATH/web.vc/dist
if [ ! -d "dist" ]; then
	npm install
	npm run-script ng build -- --configuration=local
	touch $SETUPTRACKING/web.vc.installed
fi

echo "Chown new files"
chown -R `stat $BASEPATH -c %u:%g` $CODEPATH/

echo "=========================================="
echo "Setup development environment is completed"
echo "=========================================="
