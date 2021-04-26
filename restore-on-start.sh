#! /bin/bash


export PATH=/home/ubuntu/bin:/home/ubuntu/.local/bin:/home/ubuntu/bin:/home/ubuntu/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

cd ~/wordpress

# Restore

run () {
	echo START --- $(date)
	  make site-down
	  make get-docroot-from-aws &
	  ( make get-db-from-aws
	    make db-up
	    sleep 10
	    make read-db-from-backup 
	    make set-url
	    make db-down ) &
	  wait
	  make site-up
	  make correct-docroot
	echo end --- $(date)

}


mv logs/lastrun.log logs/lastrun.log.$(date +%Y%m%d%H%M%S -r logs/lastrun.log) 2>/dev/null
run >logs/lastrun.log 2>&1 

