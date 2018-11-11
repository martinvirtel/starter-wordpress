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
#        - Cleanup old static zips
#        - integrate with logrotate
# 	 - versioning


# wget https://raw.githubusercontent.com/reduardo7/bash-service-manager/master/services.sh
# https://github.com/reduardo7/bash-service-manager/
. services.sh


run-service() {
  local action="$1" # Action

  while inotifywait -q -r -e close_write \
                      --timefmt "${TIME_FORMAT}" --format "${OUTPUT_FORMAT}" "$SOURCEDIR"; do
    echo "@@@ Running action '${action}'"
    export LATEST=$SOURCEDIR/$(ls --sort=time $SOURCEDIR | head -1)
    cd $STATICDIR
    unzip -u -o $LATEST 
    env AWS_DEFAULT_REGION=eu-central-1 AWS_PROFILE=newslab-prototype-webspace-writer aws s3 sync --no-progress --acl=public-read  ./ s3://dpa-newslab-prototype-webspace/dpa-stories/beta/
    date "+%Y-%m-%dT%H:%M:%S ---- Uploaded $LATEST" 
  done
}

before-start() {
  local action="$1" # Action
  mkdir -p $STATICDIR
  cd $STATICDIR
  echo "* Starting with $action"
}

after-finish() {
  local action="$1" # Action
  local serviceExitCode=$2 # Service exit code

  echo "* Finish with $action. Exit code: $serviceExitCode"
}

action="$1"
serviceName="Static Site Updater"

serviceMenu "$action" "$serviceName" run-service "$workDir" before-start after-finish

