#! /bin/bash
set -Eeuo pipefail

if [ "${DEBUG:-}" != "" ] ; then
    set -x
fi


export PATH=/home/ubuntu/bin:/home/ubuntu/.local/bin:/home/ubuntu/bin:/home/ubuntu/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

if [ -L $0 ] ; then
	cd $(dirname $(readlink $0))
fi
make run-backup >backup.log 2>&1

