#! /bin/bash


export PATH=${HOME}/bin:${HOME}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

cd ~/wordpress

# Restore

run () {
	echo START RESTORE --- $(date)
	  make site-down
	  ( make db-up
	    make get-db-from-aws
	    sleep 10
	    make read-db-from-backup 
	    make set-url
	    make db-down ) &
	  make -f certbot.Makefile renew &
	  make get-docroot-from-aws &
	  wait
	  make site-up
	  make correct-docroot
	echo END RESTORE --- $(date)

}

mkdir -p logs
test -f logs/lastrun.log \
	&& mv logs/lastrun.log logs/lastrun.log.$(date +%Y%m%d%H%M%S -r logs/lastrun.log) \
	2>/dev/null
run >logs/lastrun.log 2>&1 

