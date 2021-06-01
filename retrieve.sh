#! /bin/bash

. .credentials

AWS_DEFAULT_REGION=eu-central-1 AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} aws s3 sync s3://backup.versicherungsmonitor/einsundeins/2018-03-25T20:20/ data/




