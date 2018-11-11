#! /bin/bash



function prepare { 
	if [ ! -d html ] ; then 
	   make deploy
	   sleep 60
	fi	
	make install-local 
	make cli CLI='plugin install all-in-one-wp-migration'
	make cli CLI='plugin activate all-in-one-wp-migration'
	sudo mkdir -p html/wp-content/ai1wm-backups/
	sudo chown 0777 html/wp-content/ai1wm-backups/
}


function restore {
	if [ "$1" == "" ] ; then
		echo "USAGE: $0 <filename> (has to be a backup file created with ai1wm backup)"
	else
	   if [ -f $1 ] ; then
		sudo cp $1 html/wp-content/ai1wm-backups/
		sudo mkdir -p html/wp-content/plugins/all-in-one-wp-migration/storage
		sudo chmod 0777 html/wp-content/plugins/all-in-one-wp-migration/storage
		make cli CLI='wp ai1wm restore '$(basename $1)

	   else 
		File $1 not found.
	   fi
	fi
}


if [ "$1" == "clone" ] ; then
	restore $2
else 
	prepare
	restore $1
fi



