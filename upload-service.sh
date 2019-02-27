#! /bin/bash

# set -x

# Configuration contains BUCKETPREFIX
. upload-service.conf

# Bug: Depends on starting dir ....
export myname=$(basename $(pwd))-$(basename $0)
export SOURCEDIR=$(dirname $0)/html/tmp
export BUCKETNAME=dpa-newslab-prototype-webspace
export BUCKETURL=s3://$BUCKETNAME$BUCKETPREFIX
export DESTPREFIX=/$BUCKETNAME$BUCKETPREFIX


export PID_FILE_PATH="/tmp/${myname}.pid"
export LOG_FILE_PATH="/tmp/${myname}.log"
export LOG_ERROR_FILE_PATH="/tmp/${myname}.log"

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
RUNNING_FILE=/tmp/$myname.$$.running
COUNTERFILE=/tmp/$myname.counter

process_files() {
   echo processing in $(pwd)
   echo making files writable
   sudo chown -R www-data:ubuntu * 
   sudo chown -R www-data:ubuntu . 
   sudo chmod -R g+w *
   sudo chmod -R g+w .
   echo overwriting index file 
   printf "Updated $(date)\n"  > index.html
   echo removing feeds
   rm -rf feed/* 
   rm -rf comments/* 
   echo rewriting absolute links
   sed -i.original 's_"/wp-content/_"'$DESTPREFIX'wp-content/_g;'"s_'/wp-content/_'${DESTPREFIX}wp-content/_g;" \
		     $(find . -type f | egrep '(js|html|css)$')

}


wait_for_silence() {

while /bin/true
  do
        inotifywatch -e close -t 4 -r ./  2>&1 | \
        tee $COUNTERFILE
  grep -c 'No events' $COUNTERFILE && return
  echo "$(pwd) - watching for silence, next 5 secs"

  done

}

upload_files() {

 AWS_DEFAULT_REGION=eu-central-1 AWS_PROFILE=newslab-prototype-webspace-writer aws s3 sync --acl=public-read --quiet ./ $BUCKETURL 

}

run-service() {
  local action="$1" # Action
  cd $SOURCEDIR
  echo watching $(pwd)
  sudo chown -R www-data:ubuntu *
  while inotifywait -q -e close_write \
                    --timefmt "${TIME_FORMAT}" --format "${OUTPUT_FORMAT}" "./"; do
    if [ ! -f $RUNNING_FILE ] ; then
	    touch $RUNNING_FILE 
	    wait_for_silence
	    process_files
            upload_files
	    date "+%Y-%m-%dT%H:%M:%S ---- Upload of $SOURCEDIR ready" 
	    rm $RUNNING_FILE
	else 
	    echo $RUNNING_FILE already present - skipping
	fi
  done
  trap "{ rm -f $RUNNING_FILE $COUNTERFILE; echo removing temp files; }" exit 
}

before-start() {
  local action="$1" # Action
  mkdir -p $SOURCEDIR
  cd $SOURCEDIR
  echo "Starting $SCRIPTVERSION with $action in $SOURCEDIR"
}

after-finish() {
  local action="$1" # Action
  local serviceExitCode=$2 # Service exit code

  echo "* Finish with $action. Exit code: $serviceExitCode"
}

action="$1"
serviceName="Static Site Updater"

serviceMenu "$action" "$serviceName" run-service "$workDir" before-start after-finish

