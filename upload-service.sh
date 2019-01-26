#! /bin/bash

export myname=$(basename $0)

# export SOURCEDIR=$(pwd)/html/wp-content/plugins/simply-static/static-files
export SOURCEDIR=/home/ubuntu/projekte/stories-wordpress-7/html/tmp
export LATEST=$SOURCEDIR/$(ls --sort=time $SOURCEDIR | head -1)
export STATICDIR=/home/ubuntu/projekte/stories-wordpress-7/html/tmp

export PID_FILE_PATH="/tmp/${myname}.pid"
export LOG_FILE_PATH="/tmp/${myname}.log"
export LOG_ERROR_FILE_PATH="/tmp/${myname}.error.log"

export SCRIPTVERSION=$(ls -l $0)
#
#  ToDo: 
#        - diff --recursive to see which files changed
#        (Done) - Cleanup old static zips
#        - integrate with logrotate
# 	 - versioning / URL Obfuscation 


# wget https://raw.githubusercontent.com/reduardo7/bash-service-manager/master/services.sh
# https://github.com/reduardo7/bash-service-manager/
. services.sh

# set -x

TIME_FORMAT='%F %H:%M:%S'
OUTPUT_FORMAT='%T Event(s): %e fired for file: %w. Refreshing.'
RUNNING_FILE=/tmp/$0.$$.running

process_files() {
   echo making files writable
   sudo chgrp -R ubuntu * 
   sudo chmod -R g+w *
   echo overwriting index file 
   printf "Updated $(date)\n"  > index.html
   echo removing feeds
   rm -rf feed/* 
   echo rewriting absolute links
   sed -i.original 's_"/wp-content/_"/dpa-newslab-prototype-webspace/dpa-stories/beta/wp-content/_g' $(find . -type f | egrep '(js|html|css)$')

}

run-service() {
  local action="$1" # Action

  echo watching $SOURCEDIR
  while inotifywait -q -e close_write \
                    --timefmt "${TIME_FORMAT}" --format "${OUTPUT_FORMAT}" "$SOURCEDIR"; do
    if [ ! -f $RUNNING_FILE ] ; then
	    touch $RUNNING_FILE 
            echo Waiting 40 seconds for export to finish
	    sleep 40
	    # export LATEST=$SOURCEDIR/$(ls --sort=time $SOURCEDIR | head -1)
	    cd $STATICDIR
	    # echo "Unpacking $LATEST"
	    # unzip -u -o $LATEST  2>&1 >/dev/null
	    process_files
	    AWS_DEFAULT_REGION=eu-central-1 AWS_PROFILE=newslab-prototype-webspace-writer aws s3 sync --acl=public-read ./ s3://dpa-newslab-prototype-webspace/dpa-stories/beta/
	    date "+%Y-%m-%dT%H:%M:%S ---- Upload of $STATICDIR ready" 
	    # find $SOURCEDIR -mtime +10
	    # find html/wp-content/plugins/simply-static/static-files | sort -r 
	    # echo Keeping the last 40 versions, removing the rest
	    # rm -v $(find $SOURCEDIR -type f | sort -r | sed 1,40d)
	    trap { rm -f $RUNNING_FILE } exit 
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
  echo "Starting $SCRIPTVERSION with $action"
}

after-finish() {
  local action="$1" # Action
  local serviceExitCode=$2 # Service exit code

  echo "* Finish with $action. Exit code: $serviceExitCode"
}

action="$1"
serviceName="Static Site Updater"

serviceMenu "$action" "$serviceName" run-service "$workDir" before-start after-finish

