#! /bin/bash

export myname=$(basename $0)

export SOURCEDIR=$(pwd)/html/wp-content/plugins/simply-static/static-files
export LATEST=$SOURCEDIR/$(ls --sort=time $SOURCEDIR | head -1)
export STATICDIR=/tmp/export

export PID_FILE_PATH="/tmp/${myname}.pid"
export LOG_FILE_PATH="/tmp/${myname}.log"
export LOG_ERROR_FILE_PATH="/tmp/${myname}.error.log"

#
#  ToDo: 
#        - diff --recursive to see which files changed
#        (Done) - Cleanup old static zips
#        - integrate with logrotate
# 	 - versioning / URL Obfuscation 


# wget https://raw.githubusercontent.com/reduardo7/bash-service-manager/master/services.sh
# https://github.com/reduardo7/bash-service-manager/
. services.sh


TIME_FORMAT='%F %H:%M'
OUTPUT_FORMAT='%T Event(s): %e fired for file: %w. Refreshing.'
RUNNING_FILE=/tmp/$0.$$.running

run-service() {
  local action="$1" # Action

  while inotifywait -q -e close_write \
                    --timefmt "${TIME_FORMAT}" --format "${OUTPUT_FORMAT}" "$SOURCEDIR"; do
    if [ ! -f $RUNNING_FILE ] ; then
	    touch $RUNNING_FILE 
	    export LATEST=$SOURCEDIR/$(ls --sort=time $SOURCEDIR | head -1)
	    cd $STATICDIR
	    echo "Unpacking $LATEST"
	    unzip -u -o $LATEST  2>&1 >/dev/null
	    # index file should not be there
	    printf "Updated $(date)\n"  > index.html
	    # no feed
	    rm -rf feed/* 
	    env AWS_DEFAULT_REGION=eu-central-1 AWS_PROFILE=newslab-prototype-webspace-writer aws s3 sync --acl=public-read --quiet ./ s3://dpa-newslab-prototype-webspace/dpa-stories/beta/
	    date "+%Y-%m-%dT%H:%M:%S ---- Uploaded $LATEST" 
	    # find $SOURCEDIR -mtime +10
	    # find html/wp-content/plugins/simply-static/static-files | sort -r 
	    echo Keeping the last 40 versions, removing the rest
	    rm -v $(find $SOURCEDIR -type f | sort -r | sed 1,40d)
	    rm $RUNNING_FILE
	else 
	    echo $RUNNING_FILE already present - skipping
	fi
  done
}

before-start() {
  local action="$1" # Action
  mkdir -p $STATICDIR
  cd $STATICDIR
  # echo "* Starting with $action"
}

after-finish() {
  local action="$1" # Action
  local serviceExitCode=$2 # Service exit code

  echo "* Finish with $action. Exit code: $serviceExitCode"
}

action="$1"
serviceName="Static Site Updater"

serviceMenu "$action" "$serviceName" run-service "$workDir" before-start after-finish

