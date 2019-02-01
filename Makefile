

SHELL := /bin/bash

STACK_NAME := wordpress

WP_CONTAINER=$(shell docker inspect $$(docker stack ps $(STACK_NAME) --filter "name=$(STACK_NAME)_wordpress"  --filter "desired-state=Running" --format {{.ID}}) --format {{.Status.ContainerStatus.ContainerID}})




WORDPRESS_DB_PASSWORD := aceasfsd

include config.makefile

DIRS:= ./mysql  ./html ./log ./sql ./duplicity-cache

dirs:
	@{ \
	if [ ! -d html ] ; then \
		mkdir html ;\
		sudo chown 33:$${USER} html ;\
		sudo chmod g+wx html ;\
	fi ;\
	if [ ! -d log ] ; then \
		mkdir log ;\
		sudo chown 33:$${USER} log ;\
		sudo chmod g+wx html ;\
	fi ;\
	if [ ! -d mysql ] ; then \
		mkdir mysql ;\
		sudo chown 999:$${USER} mysql ;\
		sudo chmod g+wx mysql ;\
	fi ;\
	if [ ! -d sql ] ; then \
		mkdir sql ;\
		sudo chown 82:$${USER} sql ;\
		sudo chmod g+wx sql ;\
	fi ;\
	if [ ! -d duplicity-cache ] ; then \
		mkdir duplicity-cache ;\
		sudo chown 1896:$${USER} duplicity-cache ;\
		sudo chmod g+wx duplicity-cache ;\
	fi ;\
	}

CLI := core version
cli:
	echo CLI=$(CLI) ;\
	docker run -it --rm --volumes-from $(WP_CONTAINER) --network container:$(WP_CONTAINER) wordpress:cli-php7.1 $(CLI)

enter:
	docker exec -it $(WP_CONTAINER) /bin/bash 

deploy: 
	docker stack deploy --compose-file wordpress.yml $(STACK_NAME)



backup-db:
	docker run -it --rm --volumes-from $(WP_CONTAINER) \
		--volume $$(pwd)/sql:/tmp/sql \
		--network container:$(WP_CONTAINER) wordpress:cli-php7.1 db export /tmp/sql/dump.sql


DUP := duplicity --help
duplicity: 
	@echo duplicity DUP=$(DUP);\
	docker run --rm \
		--env AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		--env AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
                --volume $$(pwd)/duplicity-cache:/home/duplicity/.cache/duplicity \
                --volume $$(pwd)/sql:/var/www/sql \
		--volumes-from $(WP_CONTAINER) \
 		--network container:$(WP_CONTAINER) \
	wernight/duplicity $(DUP)

run-backup: backup-db
	$(MAKE) duplicity DUP="duplicity --s3-use-new-style --s3-european-buckets --full-if-older-than 1M --no-encryption /var/www $(AWS_BACKUP_BUCKET)"
	$(MAKE) duplicity DUP="duplicity --s3-use-new-style --s3-european-buckets remove-older-than 2M --force $(AWS_BACKUP_BUCKET)"

