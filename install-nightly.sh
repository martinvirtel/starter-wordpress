#! /bin/bash

. .aws-credentials

REMOTE_PATH=s3://newslab-backups/wordpress-kaufhalle/wp-content/backups-dup-pro/
LOCAL_COPY=/tmp/lastbackup.zip

LAST_BACKUP=$(aws s3 ls $REMOTE_PATH | grep 'nightly.*_archive.zip' | awk -n 'END { print $4 }')
       

aws s3 cp $REMOTE_PATH$LAST_BACKUP $LOCAL_COPY 

./unpack-duplicator.sh $LOCAL_COPY

