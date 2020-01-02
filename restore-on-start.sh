#! /bin/bash


export PATH=/home/ubuntu/bin:/home/ubuntu/.local/bin:/home/ubuntu/bin:/home/ubuntu/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

cd ~/wordpress

# Restore

run () {
	echo START $(date)
	make site-down
	make get-docroot-from-aws
	make get-db-from-aws
	make site-up
	make waiting for db to spin up $(date)
	sleep 30
	make read-db-from-backup

	# Hostnamen setzen

	make set-url
	echo end --- $(date)


}


mv lastrun.log lastrun.log.$(date +%Y%m%d%H%M%S -r lastrun.log) 2>/dev/null
run >lastrun.log 2>&1 

