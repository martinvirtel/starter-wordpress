
SHELL := /bin/bash

include config.makefile



# WP_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=vmonitor_wordpress" --filter "desired-state=Ready" --format '{{.ID}}' )

# WP_CONTAINER := $(shell docker inspect $(WP_SERVICE) --format '{{.ID}}')

WP_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=$(STACK_NAME)_wordpress" --filter "desired-state=Running" --format '{{.ID}}' 2>/dev/null || echo '')
WP_CONTAINER := $(shell docker inspect $(WP_SERVICE) --format '{{.Status.ContainerStatus.ContainerID}}' 2>/dev/null || echo '')


MYSQL_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=$(STACK_NAME)_mysql" --filter "desired-state=Running" --format '{{.ID}}' 2>/dev/null || echo '')
MYSQL_CONTAINER := $(shell docker inspect $(MYSQL_SERVICE) --format '{{.Status.ContainerStatus.ContainerID}}' 2>/dev/null || echo '')


MYSQL_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=$(STACK_NAME)_mysql" --filter "desired-state=Running" --format '{{.ID}}' 2>/dev/null || echo '')
MYSQL_CONTAINER := $(shell docker inspect $(MYSQL_SERVICE) --format '{{.Status.ContainerStatus.ContainerID}}' 2>/dev/null || echo '')


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

enter:
	docker exec -it $(WP_CONTAINER) /bin/bash 

LOG := -f
log:
	echo LOG=$(LOG) ;\
	docker logs $(LOG) $(WP_CONTAINER)

deploy: dirs 
	{ \
	if [ "$(MYSQL_NETWORK)" == "" ] ; then \
		WORDPRESS_PORT=$(WORDPRESS_PORT) \
		MYSQL_ROOT_PASSWORD=$(MYSQL_ROOT_PASSWORD) \
		docker stack deploy --compose-file wordpress.yml $(STACK_NAME) ;\
	else \
		WORDPRESS_PORT=$(WORDPRESS_PORT) \
		MYSQL_ROOT_PASSWORD=$(MYSQL_ROOT_PASSWORD) \
		MYSQL_NETWORK=$(MYSQL_NETWORK) \
		WORDPRESS_DB_NAME=${STACK_NAME} \
		docker stack deploy --compose-file wordpress-with-external-db.yml $(STACK_NAME) ;\
	fi ;\
	}


ST = ps
stack:  
	@echo ST=$(ST) - docker stack $(ST) $(STACK_NAME) ;\
	docker stack $(ST) $(STACK_NAME)


swarm-init:
	docker swarm init --advertise-addr 127.0.0.1


CLI := core version
# User 33 = www-data https://github.com/docker-library/wordpress/issues/256
cli:
	@echo wp CLI=$(CLI) ;\
	docker run -u 33 -it --rm --volumes-from $(WP_CONTAINER) --network container:$(WP_CONTAINER) wordpress:cli-php7.1 $(CLI)

backup-db:
	docker run -it --rm --volumes-from $(WP_CONTAINER) \
		--volume $$(pwd)/sql:/tmp/sql \
		--network container:$(WP_CONTAINER) wordpress:cli-php7.1 db export /tmp/sql/dump.sql

install-local:
	ADMIN_PASSWORD=$$(head /dev/urandom | md5sum | sed 's/  -//') ;\
	$(MAKE) cli CLI="core install --url=http://$(WORDPRESS_CNAME):$(WORDPRESS_PORT) --admin_user=admin --admin_password=$${ADMIN_PASSWORD} --admin_email=test@random.domain --title=$(WORDPRESS_CNAME) --skip-email"

test-container:
	@echo wordpress=$(WP_CONTAINER) mysql=$(MYSQL_CONTAINER)


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


site.conf: site.conf.template Makefile config.makefile
	printf "# DO NOT EDIT BY HAND \n# Generated by $(MAKE) from $$(pwd)/$< on $$(date)\n#\n#\n" >$@ ;\
	WORDPRESS_CNAME=$(WORDPRESS_CNAME) \
	WORDPRESS_PORT=$(WORDPRESS_PORT) \
	CWD=$(shell pwd) \
	envsubst <$< '$$WORDPRESS_CNAME $$CWD $$WORDPRESS_PORT' | \
        sed '1,/^$$/d' >>$@ 

CONFFILE := /etc/nginx/sites-enabled/$(WORDPRESS_CNAME).conf	
enable-site.conf: site.conf
	@if [ -e $(CONFFILE) ] ; then \
		if [ "$$(readlink $(CONFFILE))" != "$$(pwd)/site.conf" ] ; then  \
			echo $(CONFFILE) exists: $$(ls -l $(CONFFILE)); \
		else \
			echo $(CONFFILE) links to $$(pwd)/site.conf ;\
		fi \
	else \
		echo linking $(CONFFILE) to $$(pwd)/site.conf ;\
		sudo ln -s $$(pwd)/site.conf $(CONFFILE) ;\
	fi  ;\
	echo please restart nginx to make changes take effect


disable-site.conf:
	@echo removing $(CONFFILE) ;\
	sudo rm $(CONFFILE) ;\
	echo please restart nginx to make changes take effect


CNAME = "http://$(WORDPRESS_CNAME):$(WORDPRESS_PORT)"
set-cname:
	$(MAKE) cli CLI="option set home http://$(CNAME)"	
	$(MAKE) cli CLI="option set siteurl http://$(CNAME)"	

test-vars:
	echo WP_SERVICE=$(WP_SERVICE) WP_CONTAINER=$(WP_CONTAINER)
