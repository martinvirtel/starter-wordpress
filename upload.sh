#! /bin/bash

export SOURCEDIR=$(pwd)/html/wp-content/plugins/simply-static/static-files
export LATEST=$SOURCEDIR/$(ls --sort=time $SOURCEDIR | head -1)
export STATICDIR=/tmp/export


mkdir -p $STATICDIR
cd $STATICDIR
unzip -u -o $LATEST 
env AWS_DEFAULT_REGION=eu-central-1 AWS_PROFILE=newslab-prototype-webspace-writer aws s3 sync --acl=public-read  ./ s3://dpa-newslab-prototype-webspace/dpa-stories/beta/


